import 'package:flutter/material.dart';
import '../providers/cart.dart';
import 'cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/custom_cart.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';

enum FiltersOption {
  Favorite,
  All,
}

class HomeScreen extends StatefulWidget {
 const  HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _showOnlyFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My shop'),
        actions: [
          PopupMenuButton(onSelected: (FiltersOption filter) {
            setState(() {
              if (filter == FiltersOption.All) {
                // .... show all
                _showOnlyFavorite = false;
              } else {
                // ... show Favorite
                _showOnlyFavorite = true;
              }
            });
            print(filter);
          }, itemBuilder: (ctx) {
            return const [
              PopupMenuItem(
                child: Text("All"),
                value: FiltersOption.All,
              ),
              PopupMenuItem(
                child: Text("Favorite"),
                value: FiltersOption.Favorite,
              ),
            ];
          }),
          Consumer<Cart>(
            builder: (ctx, cart, child) {
            return CustomCart(
              child: child!,
              number: cart.itemsCount().toString(),
            );
          },
           child: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.of(context).pushNamed(CartScreen.routName),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: ProductsGrid(_showOnlyFavorite),
    );
  }
}
