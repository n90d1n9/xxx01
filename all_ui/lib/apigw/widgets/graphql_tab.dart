import 'package:flutter/material.dart';

class GraphQLTab extends StatelessWidget {
  const GraphQLTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    'GraphQL Gateway Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Endpoint configuration
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'GraphQL Endpoint',
                      hintText: '/graphql',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Schema configuration
                  CheckboxListTile(
                    title: const Text('Enable Schema Stitching'),
                    subtitle: const Text(
                      'Combine multiple GraphQL services into a unified schema',
                    ),
                    value: true,
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 16),

                  // Playground
                  CheckboxListTile(
                    title: const Text('Enable GraphQL Playground'),
                    subtitle: const Text('Interactive web-based GraphQL IDE'),
                    value: true,
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 16),

                  // Query depth limiting
                  ExpansionTile(
                    title: const Text('Security Settings'),
                    children: [
                      ListTile(
                        title: const Text('Maximum Query Depth'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '10',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Maximum Query Complexity'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '1000',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        title: const Text(
                          'Disable Introspection in Production',
                        ),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Upstream services
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
                    'Upstream GraphQL Services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    leading: const Icon(Icons.api),
                    title: const Text('Users Service'),
                    subtitle: const Text('http://users-service:4000/graphql'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.api),
                    title: const Text('Products Service'),
                    subtitle: const Text(
                      'http://products-service:4001/graphql',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Service'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.restore),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Save Configuration'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
