
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/cart_provider.dart';

class ProductItem extends StatelessWidget {
  final String name;
  final double price;
  final String description;
  final String imagePath;

  const ProductItem({
    super.key,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final cart = ref.watch(cartProvider);
       final cartItem = cart.firstWhereOrNull((element) => element.name == name);
        return Column(
          children: [
            Image.asset(imagePath),
            Text(name),
            Text(description),
            Text('\$${price.toStringAsFixed(1)}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (cartItem != null) {
                     ref.read(cartProvider.notifier).removeItem(cartItem);
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text(cartItem != null ? cartItem.quantity.toString() : '0'),
                IconButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(CartItem(name: name, price: price, quantity: 1));
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}