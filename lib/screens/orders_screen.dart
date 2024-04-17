import 'package:flutter/material.dart';
import '../providers/orders.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const routeName = '/orders';
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _getOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).getOrdersFromFirebase();
  }

  @override
  void initState() {
    _ordersFuture = _getOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Orders"),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
            future: _ordersFuture,
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapshot.error == null) {
                  return Consumer<Orders>(
                    builder: (context, orders, child) => orders.items.isEmpty
                        ? const Center(
                            child: Text("There is not any order!"),
                          )
                        : ListView.builder(
                            itemCount: orders.items.length,
                            itemBuilder: (ctx, i) {
                              final order = orders.items[i];
                              return Order_item(
                                totalPrice: order.totalPrice,
                                date: order.date,
                                products: order.products,
                              );
                            },
                          ),
                  );
                } else {
                  // ... error
                  return const Center(
                    child: Text("An error occured"),
                  );
                }
              }
            }));
  }
}
