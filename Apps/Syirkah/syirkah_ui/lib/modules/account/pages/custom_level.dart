import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomLevelScreen extends ConsumerWidget {
  const CustomLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Level'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Level Name*',
              ),
            ),
            const SizedBox(height: 16.0),
            const ExpansionTile(
              title: Text('Menu Authorization'),
              children: [
                // Add widgets for menu authorization
              ],
            ),
            const SizedBox(height: 16.0),
            const ExpansionTile(
              title: Text('Order List Authorization'),
              children: [
                // Add widgets for order list authorization
              ],
            ),
            const SizedBox(height: 16.0),
            ExpansionTile(
              title: const Text('Order Monitoring Authorization'),
              children: [
                SwitchListTile(
                  title: const Text('Allow Set Process'),
                  value: false,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Allow Set Ready'),
                  value: false,
                  onChanged: (value) {},
                ),
                SwitchListTile(
                  title: const Text('Allow Set Served'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const ExpansionTile(
              title: Text('Notification Authorization'),
              children: [
                // Add widgets for notification authorization
              ],
            ),
            const SizedBox(height: 16.0),
            const ExpansionTile(
              title: Text('Report Authorization'),
              children: [
                // Add widgets for report authorization
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('0 Branch(s) Selected'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('View Selected Branch'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}