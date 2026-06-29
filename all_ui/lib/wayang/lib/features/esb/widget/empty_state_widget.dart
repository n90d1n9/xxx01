import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/integration_route.dart';
import '../states/current_route_notifier.dart';
import '../states/route_notifier.dart';
import 'route_list_dialog.dart';

class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree, size: 120, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Welcome to Integration Builder',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new route or open an existing one to get started',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final nameController = TextEditingController();
                  final descController = TextEditingController();

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Create New Route'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Route Name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
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
                            final route = IntegrationRoute(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              description: descController.text,
                              components: [],
                              connections: [],
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            ref.read(routesProvider.notifier).addRoute(route);
                            ref
                                .read(currentRouteProvider.notifier)
                                .setRoute(route);
                            Navigator.pop(context);
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Route'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const RoutesListDialog(),
                  );
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Existing Route'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
