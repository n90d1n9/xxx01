import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemRelationScreen extends ConsumerWidget {
  const ItemRelationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Relation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: const [
                  _ItemRelationTile(
                    icon: Icons.fastfood,
                    title: 'Main Course',
                  ),
                  _ItemRelationTile(
                    icon: Icons.local_drink,
                    title: 'Beverages',
                  ),
                  _ItemRelationTile(
                    icon: Icons.restaurant_menu,
                    title: 'Appetizers',
                  ),
                  _ItemRelationTile(
                    icon: Icons.food_bank,
                    title: 'Snack',
                  ),
                  _ItemRelationTile(
                    icon: Icons.cake,
                    title: 'Dessert',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRelationTile extends StatelessWidget {
  const _ItemRelationTile({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
      ),
    );
  }
}