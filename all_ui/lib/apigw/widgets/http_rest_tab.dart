import 'package:flutter/material.dart';

class HttpRestTab extends StatelessWidget {
  const HttpRestTab({super.key});

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
                    'HTTP/REST API Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Version selection
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('HTTP/1.1'),
                          value: true,
                          onChanged: (value) {},
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('HTTP/2'),
                          value: true,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Base configuration
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Base Path',
                      hintText: '/api/v1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CORS configuration
                  ExpansionTile(
                    title: const Text('CORS Settings'),
                    children: [
                      CheckboxListTile(
                        title: const Text('Enable CORS'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Allowed Origins',
                          hintText: '*',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Allowed Methods',
                          hintText: 'GET, POST, PUT, DELETE',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Allowed Headers',
                          hintText: 'Content-Type, Authorization',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // OpenAPI Integration
                  ExpansionTile(
                    title: const Text('OpenAPI Integration'),
                    children: [
                      CheckboxListTile(
                        title: const Text('Enable OpenAPI Documentation'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'OpenAPI Spec URL',
                          hintText: '/openapi.json',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Enable Swagger UI'),
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

          // Rate limiting section
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
                    'Rate Limiting',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    title: const Text('Enable Rate Limiting'),
                    value: true,
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Requests',
                            hintText: '100',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Time Window',
                            border: OutlineInputBorder(),
                          ),
                          value: 'minute',
                          items:
                              ['second', 'minute', 'hour', 'day']
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Rate Limit Strategy',
                      border: OutlineInputBorder(),
                    ),
                    value: 'sliding_window',
                    items:
                        [
                              'fixed_window',
                              'sliding_window',
                              'token_bucket',
                              'leaky_bucket',
                            ]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.replaceAll('_', ' ')),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
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
