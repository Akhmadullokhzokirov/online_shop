import 'package:flutter/material.dart';
import 'models/product.dart';
import 'providers/cart.dart';
import 'providers/orders.dart';
import 'providers/products.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/manage_products_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Auth>(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products(),
            update: (ctx, auth, previousProducts) =>
                previousProducts!..setParams(auth.token, auth.userId),
          ),
          ChangeNotifierProvider<Cart>(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders(),
            update: (ctx, auth, previousOrders) => previousOrders!
              ..setParams(auth.token, auth.userId), // 2 for order
          ),
        ],
        child: Consumer<Auth>(builder: (ctx, authData, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                useMaterial3: false,
                scaffoldBackgroundColor: Colors.white,
                fontFamily: "Edufonts_wght.ttf"),
            debugShowCheckedModeBanner: false,
            home: authData.isAuth
                ? const HomeScreen()
                : FutureBuilder(
                    future: authData.autoLogin(),
                    builder: (c, autoLoginData) {
                      if (autoLoginData.connectionState ==
                          ConnectionState.waiting) {
                        return SplashScreen();
                      } else {
                        return const AuthScreen();
                      }
                    }),
            routes: {
              HomeScreen.routeName: (ctx) => const HomeScreen(),
              ProductDetailsScreen.routeName: (ctx) =>
                  const ProductDetailsScreen(),
              CartScreen.routName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              ManageProductsScreen.routeName: (ctx) =>
                  const ManageProductsScreen(),
              EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            },
          );
        }));
  }
}
