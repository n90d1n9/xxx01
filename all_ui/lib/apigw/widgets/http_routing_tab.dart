import 'package:flutter/material.dart';

class HttpRoutingTab extends StatelessWidget {
  const HttpRoutingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HTTP Route Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Host and path fields
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      hintText: 'api.example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.domain),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Path',
                      hintText: '/users/:id',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.route),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Methods selection
                  Text(
                    'Methods',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'].map((method) {
                          return FilterChip(
                            label: Text(method),
                            selected: method == 'GET' || method == 'POST',
                            onSelected: (bool selected) {},
                            backgroundColor:
                                Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                            selectedColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            checkmarkColor:
                                Theme.of(context).colorScheme.primary,
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Headers
                  ExpansionTile(
                    title: const Text('Headers'),
                    leading: const Icon(Icons.view_headline),
                    children: [
                      ListTile(
                        title: const Text('X-API-Version'),
                        subtitle: const Text('v1.0'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {},
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Add Header'),
                        leading: const Icon(Icons.add_circle_outline),
                        onTap: () {},
                      ),
                    ],
                  ),

                  // Query parameters
                  ExpansionTile(
                    title: const Text('Query Parameters'),
                    leading: const Icon(Icons.help_outline),
                    children: [
                      ListTile(
                        title: const Text('version'),
                        subtitle: const Text('1.0'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {},
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Add Query Parameter'),
                        leading: const Icon(Icons.add_circle_outline),
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Target service
                  Text(
                    'Target Service',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: 'user-service',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cloud),
                    ),
                    items:
                        ['user-service', 'auth-service', 'product-service']
                            .map(
                              (service) => DropdownMenuItem(
                                value: service,
                                child: Text(service),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 24),

                  // Add route button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Existing routes
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Existing Routes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  _buildRouteItem(
                    context,
                    host: 'api.example.com',
                    path: '/users/:id',
                    methods: 'GET, POST',
                    target: 'user-service',
                  ),

                  const Divider(),

                  _buildRouteItem(
                    context,
                    host: 'api.example.com',
                    path: '/auth/*',
                    methods: 'POST',
                    target: 'auth-service',
                  ),

                  const Divider(),

                  _buildRouteItem(
                    context,
                    host: 'api.example.com',
                    path: '/products',
                    methods: 'GET, POST, PUT, DELETE',
                    target: 'product-service',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(
    BuildContext context, {
    required String host,
    required String path,
    required String methods,
    required String target,
  }) {
    return ListTile(
      title: Text('$host$path'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  methods,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  target,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outlined), onPressed: () {}),
        ],
      ),
    );
  }
}
