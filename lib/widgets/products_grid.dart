// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:online_shop/providers/products.dart';
import 'package:online_shop/widgets/product_item.dart';

import '../models/product.dart';

class ProductsGrid extends StatefulWidget {
  final bool showFavorite;
  const ProductsGrid(
    this.showFavorite, {
    Key? key,
  }) : super(key: key);

  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  late Future _productsFuture;

  Future _getProductsFuture() {
    return Provider.of<Products>(context, listen: false).getProductsFromFirebase(true);
  }

  @override
  void initState() {
    _productsFuture = _getProductsFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _productsFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error == null) {
              return Consumer<Products>(
                builder: (c, products, child) {
                  final ps =
                      widget.showFavorite ? products.favorites : products.list;

                  return ps.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 3 / 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                          ),
                          itemCount: ps.length,
                          itemBuilder: (ctx, i) {
                            return ChangeNotifierProvider.value(
                              value: ps[i],
                              child: const ProductItem(),
                            );
                          })
                      : const Center(
                          child: Text("There is not any products"),
                        );
                },
              );
            } else {
              //.. error
              return const Center(
                child: Text("An error occured"),
              );
            }
          }
        });
  }
}
