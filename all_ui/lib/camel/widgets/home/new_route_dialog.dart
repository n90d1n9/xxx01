import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/node.dart';
import '../../states/node_route_provider.dart';
import '../../states/select_route_provider.dart';

class NewRouteDialog extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  const NewRouteDialog({
    super.key,
    required this.nameController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('New Route'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Route Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final route = WNode(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name:
                  nameController.text.isNotEmpty
                      ? nameController.text
                      : 'New Route',
              description: descController.text,
            );
            ref.read(routesProvider.notifier).addRoute(route);
            ref.read(selectedRouteIdProvider.notifier).state = route.id;
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
