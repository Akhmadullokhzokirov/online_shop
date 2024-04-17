// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:online_shop/providers/cart.dart';
import 'package:online_shop/providers/products.dart';
import 'package:online_shop/screens/cart_screen.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    Key? key,
  }) : super(key: key);
  static const routeName = '/product-details';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments;
    final product = Provider.of<Products>(context, listen: false)
        .findById(productId as String);

    final products = Provider.of<Products>(context).list;
    print(products);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        // 1 detail info
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(product.description),
            )
          ],
        ),
      ),
      bottomSheet: BottomAppBar(
        // 2 BottomAppBar
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price:",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Consumer<Cart>(builder: (ctx, cart, child) {
                final isProductAdded = cart.items.containsKey(productId);
                if (isProductAdded) {
                  return ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(CartScreen.routName),
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 15,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Go to cart",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () => cart.addToCart(productId, product.title,
                        product.imageUrl, product.price),
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                  );
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
