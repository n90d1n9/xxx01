import 'package:flutter/material.dart';

class WebSocketTab extends StatelessWidget {
  const WebSocketTab({super.key});

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
                    'WebSocket Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Endpoint configuration
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'WebSocket Endpoint',
                      hintText: '/ws',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Connection settings
                  ExpansionTile(
                    title: const Text('Connection Settings'),
                    initiallyExpanded: true,
                    children: [
                      ListTile(
                        title: const Text('Ping Interval (seconds)'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '30',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Max Frame Size (KB)'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '64',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Connection Timeout (seconds)'),
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
                      CheckboxListTile(
                        title: const Text('Compress Messages'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Protocol selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Subprotocol',
                      border: OutlineInputBorder(),
                    ),
                    value: 'json',
                    items:
                        ['json', 'mqtt', 'stomp', 'none']
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item.toUpperCase()),
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

          // Security settings
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
                    'Security Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Authentication
                  ExpansionTile(
                    title: const Text('Authentication'),
                    initiallyExpanded: true,
                    children: [
                      RadioListTile<String>(
                        title: const Text('No Authentication'),
                        value: 'none',
                        groupValue: 'token',
                        onChanged: (value) {},
                      ),
                      RadioListTile<String>(
                        title: const Text('Token Authentication'),
                        value: 'token',
                        groupValue: 'token',
                        onChanged: (value) {},
                      ),
                      RadioListTile<String>(
                        title: const Text('Basic Authentication'),
                        value: 'basic',
                        groupValue: 'token',
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Token Query Parameter',
                          hintText: 'access_token',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rate limiting
                  ListTile(
                    title: const Text('Maximum Connections per IP'),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '100',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),

                  ListTile(
                    title: const Text('Maximum Messages per Second'),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '50',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
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
