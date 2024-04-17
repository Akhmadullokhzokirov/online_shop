import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/products.dart';
import '../screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  const UserProductItem({super.key});

  void _notifyUserAboutDelete(BuildContext context, Function() removeItem) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text("Product deleting!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  removeItem();
                  Navigator.of(context).pop();
                },
                child: const Text("DELETE"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.imageUrl),
        ),
        title: Text(product.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              splashRadius: 20,
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,
                    arguments: product.id);
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.teal,
              ),
            ),
            IconButton(
              splashRadius: 20,
              onPressed: () {
                _notifyUserAboutDelete(context, ()async {
                  try {
                   await Provider.of<Products>(context, listen: false)
                      .deleteProduct(product.id);
                  } catch (e) {
                   scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
                  }
               
                });
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
