import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewsWidget extends ConsumerWidget {
  const AddNewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Start At',
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Expire At',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Select Audience:'),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Unselect All'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Select All'),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            CheckboxListTile(
              title: const Text('Owner'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Manager'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Waiter'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Kitchen'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Cashier'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Custom'),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
