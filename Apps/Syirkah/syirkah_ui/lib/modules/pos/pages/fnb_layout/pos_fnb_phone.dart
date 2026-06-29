import 'package:flutter/material.dart';
import 'package:syirkah/core/routes/navigation.dart';
import 'package:syirkah/shared/data/product_items.dart';

import '../cart_screen.dart';

class PosFnB extends StatelessWidget {
  const PosFnB({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: productItems,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigation.go(context, const CartScreen());
        },
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  openDialog(context, String title, Widget content, List<Widget> actions) =>
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text(title), content: content, actions: actions);
          });
}
