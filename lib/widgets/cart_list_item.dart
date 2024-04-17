// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:online_shop/providers/cart.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartListItem extends StatelessWidget {
  final String productId; // 1
  final String imageUrl;
  final String title;
  final double price;
  final int quantity;
  const CartListItem({
    Key? key,
    required this.productId,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.quantity,
  }) : super(key: key);

  void _notifyUserAboutDelete(BuildContext context, Function() removeItem) {
    showDialog(
      context: context, 
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text("Product deleting in the cart!"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(),
             child: const Text('CANCEL',style: TextStyle(color: Colors.grey),),
             ),
             ElevatedButton(onPressed: () {
              removeItem();
              Navigator.of(context).pop();
             },
              child: const Text("DELETE"), style:  ElevatedButton.styleFrom(backgroundColor: Colors.red),)
          ],
          
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false); 
    return Slidable( 
      key: ValueKey(productId),
      endActionPane: ActionPane(
        extentRatio: 0.3,
        motion: const ScrollMotion(),
        children: [
          ElevatedButton(
            onPressed: () => _notifyUserAboutDelete(
              context, 
              () => cart.removeItem(productId),
            ),
             child: const Text('Delete', style: TextStyle(fontSize: 20),),
             style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 20,
              )
             ))
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: (NetworkImage(imageUrl)),
          ),
          title: Text(title),
          subtitle: Text("ALL: \$${(price * quantity).toStringAsFixed(2)}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => cart.removeSingleItem(productId), 
                icon: const Icon(
                  Icons.remove,
                  color: Colors.black,
                ),
                splashRadius: 20,
              ),
              Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade100,
                ),
                child: Text("$quantity"),
              ),
              IconButton(
                onPressed: () =>
                    cart.addToCart(productId, title, imageUrl, price),
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
