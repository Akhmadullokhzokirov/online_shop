import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _list = [
    // Product(
    //   id: 'p1',
    //   title: 'Macbook Pro',
    //   description:
    //       " Awesome MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.Awesome MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.Awesome MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005. Awesome MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.MacBook is a brand of Mac notebook computers designed and marketed by Apple that use Apple's macOS operating system since 2006. The MacBook brand replaced the PowerBook and iBook brands during the Mac transition to Intel processors, announced in 2005.",
    //   price: 1200,
    //   imageUrl:
    //       "https://media.cnn.com/api/v1/images/stellar/prod/230125131405-macbook-pro-14-inch-2023-review-cnnu-7.jpg?c=original",
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Airpods',
    //   description: "Awesome",
    //   price: 900,
    //   imageUrl:
    //       'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5znXZbMeKOC9tDjpSfES17VnST18WvoyZsQ&usqp=CAU',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Smart watch',
    //   description: "Awesome",
    //   price: 1500,
    //   imageUrl:
    //       "https://cdn11.bigcommerce.com/s-4q0pjazhsg/images/stencil/1280x1280/products/37946/93267/10__57636.1670330491.jpg?c=3",
    // ),
  ];

  String? _authToken;
  String? _userId;

  void setParams(String? authToken, String? userId) {
    _authToken = authToken;
    _userId = userId;
  }

  List<Product> get list {
    return [..._list];
  }

  List<Product> get favorites {
    return _list.where((product) => product.isFavorite).toList();
  }

  Future<void> getProductsFromFirebase([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
        print(filterByUser);
    final url = Uri.parse(
        "https://onlineshop-d3229-default-rtdb.firebaseio.com/products.json?auth=$_authToken&$filterString");
    try {
      final response = await http.get(url);
      if (jsonDecode(response.body) != null) {
        final favoriteUrl = Uri.parse(
            "https://onlineshop-d3229-default-rtdb.firebaseio.com/userFavorite/$_userId/.json?auth=$_authToken");

        final favoriteResponse = await http.get(favoriteUrl);
        final favoriteData = jsonDecode(favoriteResponse.body);

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<Product> loadedProducts = [];
        data.forEach((productId, productData) {
          loadedProducts.add(Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
          ));
          
        });
        print(loadedProducts);
        _list = loadedProducts;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url = Uri.parse(
          "https://onlineshop-d3229-default-rtdb.firebaseio.com/products.json?auth=$_authToken");
      final response = await http.post(
        url,
        body: jsonEncode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': _userId, // 1
        }),
      );

      final name = (jsonDecode(response.body) as Map<String, dynamic>)["name"];
      final newProduct = Product(
          id: UniqueKey().toString(),
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _list.add(newProduct);
      // _list.insert(3, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final productIndex = _list.indexWhere(
      (product) => product.id == updatedProduct.id,
    );
    if (productIndex >= 0) {
      final url = Uri.parse(
          "https://onlineshop-d3229-default-rtdb.firebaseio.com/products/${updatedProduct.id}.json?auth=$_authToken");

      try {
        await http.patch(url,
            body: jsonEncode({
              'title': updatedProduct.title,
              'description': updatedProduct.description,
              'price': updatedProduct.price,
              'imageUrl': updatedProduct.imageUrl,
            }));
        _list[productIndex] = updatedProduct;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://onlineshop-d3229-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken");

    try {
      var deletingProduct = _list.firstWhere((product) => product.id == id);
      final productIndex = _list.indexWhere((product) => product.id == id);
      _list.removeWhere((product) => product.id == id);
      notifyListeners();

      final response = await http.delete(url);
      print(response.statusCode);

      if (response.statusCode >= 400) {
        _list.insert(productIndex, deletingProduct);
        notifyListeners();
        throw const HttpException("Sorry, deletion error");
      }
    } catch (e) {
      rethrow;
    }
  }

  Product findById(String productId) {
    return _list.firstWhere((product) => product.id == productId);
  }
}
