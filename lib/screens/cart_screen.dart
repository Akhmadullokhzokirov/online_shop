import 'package:flutter/material.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';
import 'orders_screen.dart';
import '../widgets/cart_list_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const routName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Your carts"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.only(top: 16, right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All: ",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Chip(
                      label: Text(
                        '\$${cart.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.teal),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final cartItem = cart.items.values.toList()[i];
                    return CartListItem(
                        productId: cart.items.keys.toList()[i], //4
                        imageUrl: cartItem.image,
                        title: cartItem.title,
                        price: cartItem.price,
                        quantity: cartItem.quantity);
                  }))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    super.key,
    required this.cart,
  });

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (widget.cart.items.isEmpty || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addToOrders(
                  widget.cart.items.values.toList(), widget.cart.totalPrice);
              setState(() {
                _isLoading = false;
              });
              widget.cart.clearCart();
              // Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text("GIVE AN ORDER"),
    );
  }
}
