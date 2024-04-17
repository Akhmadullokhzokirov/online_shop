import 'package:flutter/material.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../screens/product_details_screen.dart';

import 'package:provider/provider.dart';
import '../models/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
  

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (ctx, pro, child) {
              return IconButton(
                onPressed: () {
                  product.toggledFavorite(auth.token!, auth.userId!); 
                },
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addToCart(
                product.id,
                product.title,
                product.imageUrl,
                product.price,
              );
              // ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              // ScaffoldMessenger.of(context).showMaterialBanner(
              //   MaterialBanner(
              //     backgroundColor: Colors.grey.shade800,
              //     content: const Text(
              //       "Added to cart",
              //       style: TextStyle(color: Colors.white),
              //     ),
              //     actions: [
              //       TextButton(
              //         onPressed: () {
              //           cart.removeSingleItem(product.id, isCartButton: true);
              //           ScaffoldMessenger.of(context)
              //               .hideCurrentMaterialBanner();
              //         },
              //         child: const Text(
              //           'CANCEL',
              //           style: TextStyle(color: Colors.red),
              //         ),
              //       ),
              //     ],
              //   ),
            //  );
              // Future.delayed(Duration(seconds: 2)).then(
              //   (value) =>
              //       ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            //  );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Added to cart"),
                duration: Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'CANCEL',textColor: Colors.red,
                  onPressed: () {
                    cart.removeSingleItem(product.id, isCartButton: true);
                  },
                ),
                )
              );
            },
            icon: Icon(Icons.shopping_cart_outlined,
                color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}
