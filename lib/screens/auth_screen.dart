import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../providers/auth.dart';
import 'home_screen.dart';
import '../services/http_exceptioin.dart';
import 'package:provider/provider.dart';

enum AuthMode { Register, Login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  static const routeName = "/auth";
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();
  var _loading = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("Okay!"))
            ],
          );
        });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
      });

      try {
        if (_authMode == AuthMode.Login) {
          //.. Login user
          await Provider.of<Auth>(context, listen: false)
              .login(_authData['email']!, _authData['password']!);
        } else {
          //.. Register user
          await Provider.of<Auth>(context, listen: false)
              .singup(_authData['email']!, _authData['password']!,
              );
        }
       // Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } on HttpException catch (error) {
        var errorMessage = 'An error occured';
        if (error.message.contains('EMAIL_EXISTS')) {
          
          errorMessage = 'Email busy';
      
        } else if (error.message.contains('INVALID_EMAIL')) {
          errorMessage = 'Please enter a valid email';
        } else if (error.message.contains('WEAK_PASSWORD')) {
          errorMessage = 'Password too weak';
        } else if (error.message.contains('EMAIL_NOT_FOUND')) {
          errorMessage = 'No user found with this email';
        } else if (error.message.contains('INVALID_PASSWORD')) {
          errorMessage = 'Password is incorrect';
        } else if (error.message.contains('INVALID_LOGIN_CREDENTIALS')){
          errorMessage =  "wrong email or password";
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        var errorMessage = 'Sorry an error occured. Please try again.';
        print(errorMessage);
        _showErrorDialog(errorMessage);
      }
      setState(() {
        _loading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Register;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _authMode == AuthMode.Register
                    ? Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/login.webp'),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email address"),
                  validator: (email) {
                    if (email == null || email.isEmpty) {
                      return "Please, enter email address.";
                    } else if (!email.contains('@')) {
                      return 'Please, enterr cuurect email.';
                    }
                  },
                  onSaved: (email) {
                    _authData['email'] = email!;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password"),
                  controller: _passwordController,
                  obscureText: true,
                  validator: (password) {
                    if (password == null || password.isEmpty) {
                      return 'Please, enter password';
                    } else if (password.length < 6) {
                      return "password is very easy";
                    }
                  },
                  onSaved: (password) {
                    _authData['password'] = password!;
                  },
                ),
                if (_authMode == AuthMode.Register)
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Confirm Password"),
                        obscureText: true,
                        validator: (confirmedPassword) {
                          if (_passwordController.text != confirmedPassword) {
                            return "passwords do not match";
                          }
                        },
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 60,
                ),
                _loading  ? Center(child:  const CircularProgressIndicator(),)
                    
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          _authMode == AuthMode.Login ? "ENTER" : "REGISTER",
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(double.infinity, 10)),
                      ),
                const SizedBox(
                  height: 40,
                ),
                TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      _authMode == AuthMode.Login ? "REGISTER" : "ENTER",
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
