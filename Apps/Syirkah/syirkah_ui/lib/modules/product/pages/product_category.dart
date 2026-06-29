import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCategoryScreen extends ConsumerWidget {
  const ProductCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Category'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(index.toString()),
                  onDismissed: (direction) {
                    // Handle item dismissal
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: Icon(
                      getLeadingIcon(index),
                      size: 40,
                    ),
                    title: Text(getCategoryName(index)),
                    trailing: Text(index.toString()),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {
                // Handle add new category
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  IconData getLeadingIcon(int index) {
    switch (index) {
      case 0:
        return Icons.restaurant_menu;
      case 1:
        return Icons.local_drink;
      case 2:
        return Icons.restaurant;
      case 3:
        return Icons.fastfood;
      case 4:
        return Icons.cake;
      default:
        return Icons.error;
    }
  }

  String getCategoryName(int index) {
    switch (index) {
      case 0:
        return 'Main Course';
      case 1:
        return 'Beverages';
      case 2:
        return 'Appetizers';
      case 3:
        return 'Snack';
      case 4:
        return 'Dessert';
      default:
        return 'Unknown';
    }
  }
}