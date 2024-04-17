import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';

class Order_item extends StatefulWidget {
  final double totalPrice;
  final DateTime date;
  final List<CartItem> products;
  const Order_item({
    super.key,
    required this.totalPrice,
    required this.date,
    required this.products,
  });

  @override
  State<Order_item> createState() => _Order_itemState();
}

class _Order_itemState extends State<Order_item> {
  bool _expandItem = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        ListTile(
          title: Text("\$${widget.totalPrice}"),
          subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(widget.date)),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                _expandItem = !_expandItem;
              });
            },
            icon: Icon(
              _expandItem ? Icons.expand_less : Icons.expand_more,
            ),
          ),
        ),
        if (_expandItem)
          Container(
            height: min(widget.products.length * 20 + 40, 100),
            child: ListView.builder(
               itemExtent: 40,
                itemCount: widget.products.length,
                itemBuilder: (ctx, i) {
                  final product = widget.products[i];
                  return ListTile(
                   // dense: true, // elementlarni kichikroq qilib beradi
                    title: Text(product.title),
                    trailing: Text("${product.quantity}x \$${product.price}", style: TextStyle(color: Colors.grey),),
                  );
                }),
          )
      ]),
    );
  }
}
