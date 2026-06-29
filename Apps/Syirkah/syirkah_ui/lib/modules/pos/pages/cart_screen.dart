
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final cart = ref.watch(cartProvider);
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return ListTile(
                      title: Text(item.name),
                      trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(1)}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Subtotal: \$${cart.fold<double>(0, (previousValue, element) => previousValue + (element.price * element.quantity)).toStringAsFixed(1)}'),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement checkout logic
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}