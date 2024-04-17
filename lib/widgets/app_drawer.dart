import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../screens/home_screen.dart';
import '../screens/manage_products_screen.dart';
import '../screens/orders_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // 2
      child: Column(
        children: [
          AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: const Text("Welcome"),
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text("Shop"),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(HomeScreen.routeName),
          ),
         const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text("Orders"),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrdersScreen.routeName),
          ),
         const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Manage Products"),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(ManageProductsScreen.routeName),
          ),
         const Divider(),
            ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Excit"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            }
          ),
         
        ],
      ),
    );
  }
}
