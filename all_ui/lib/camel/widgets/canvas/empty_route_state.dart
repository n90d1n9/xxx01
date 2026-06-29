import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmptyRouteState extends ConsumerWidget {
  const EmptyRouteState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No route selected',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // Trigger new route dialog from parent
              _showCreateRouteDialog(context, ref);
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Route'),
          ),
        ],
      ),
    );
  }

  void _showCreateRouteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Route'),
            content: const Text('Enter a name for your new route:'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Create new route logic
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}
