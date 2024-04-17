import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/http_exceptioin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _expiryData;
  String? _userId;
  Timer? _autoLogoutTimer;

  static const apiKey = 'AIzaSyCJHJ1tHxRiObQIryhK6FFm9AkMWhfObwA';

  bool get isAuth {
    return _token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryData != null &&
        DateTime.parse("$_expiryData").isAfter(DateTime.now()) &&
        _token != null) {
      // token mavjud
      return _token;
    }
    // token mavjud emas
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey');

    try {
      final response = await http.post(url,
          body: jsonEncode(
            {
              'email': email,
              'password': password,
              'returnSecureToken': true,
            },
          ));
      print(jsonDecode(response.body));
      final data = jsonDecode(response.body);
      if (data['error'] != null) {
        throw HttpException(data['error']['message']);
      }
      _token = data['idToken'];
      _expiryData = DateTime.now()
          .add(
            Duration(
              seconds: int.parse(
                data['expiresIn'],
              ),
            ),
          )
          .toString();
      _userId = data['localId'];
      _autoLogout(); // _autoLogout
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        "token": _token,
        "userId": _userId,
        "expiryData": _expiryData,
      });
      prefs.setString("userData", userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> singup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
      final userData =
          jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;

      final expiryData = DateTime.parse(userData['_expiryData']);

      if (expiryData.isBefore(DateTime.now())) {
        // token muddat tugagan
        return false;
      }
        // token muddat tugmadi
        _token = userData['token'];
        _userId = userData['userId'];
        _expiryData = expiryData.toString();
        notifyListeners();
         autoLogin();

        return true;
      }
    
 

  void logout() async{
    _token = null;
    _userId = null;
    _expiryData = null;
    if (_autoLogoutTimer != null) {
      _autoLogoutTimer!.cancel();
      _autoLogoutTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();

   // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_autoLogoutTimer != null) {
      _autoLogoutTimer!.cancel();
    }
    final timeToExpiry =
        DateTime.parse("$_expiryData").difference(DateTime.now()).inSeconds;
    _autoLogoutTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
