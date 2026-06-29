import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class DatabaseProxyTab extends StatelessWidget {
  const DatabaseProxyTab({super.key});

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
                    'Database Proxy Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Database type
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Database Type',
                      border: OutlineInputBorder(),
                    ),
                    value: 'postgresql',
                    items:
                        ['postgresql', 'mysql', 'redis', 'mongodb']
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 16),

                  // Connection configuration
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Listen Port',
                            hintText: '5432',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Database Host',
                            hintText: 'db.internal',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Database Port',
                            hintText: '5432',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Authentication
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'db_user',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Database name
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Database Name',
                      hintText: 'my_database',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Connection pooling options
                  Text(
                    'Connection Pooling',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Max Connections',
                            hintText: '100',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Min Connections',
                            hintText: '10',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Idle Timeout (s)',
                            hintText: '300',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Advanced settings
                  ExpansionTile(
                    title: Text(
                      'Advanced Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    children: [
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Enable SSL/TLS'),
                        subtitle: const Text('Secure connection to database'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Query Caching'),
                        subtitle: const Text('Cache frequently used queries'),
                        value: false,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Connection Multiplexing'),
                        subtitle: const Text(
                          'Share connections between clients',
                        ),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Connection Timeout (ms)',
                          hintText: '5000',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Command Timeout (ms)',
                          hintText: '10000',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SQL filtering
                  ExpansionTile(
                    title: Text(
                      'SQL Filtering & Security',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    children: [
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('SQL Injection Protection'),
                        subtitle: const Text(
                          'Analyze and block malicious queries',
                        ),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Table Access Control'),
                        subtitle: const Text(
                          'Restrict access to specific tables',
                        ),
                        value: false,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Allowed Tables (comma separated)',
                          hintText: 'users, products, orders',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Blocked SQL Keywords',
                          hintText: 'DROP, DELETE, TRUNCATE',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Database proxy instances card
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
                    'Active Database Proxies',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final databases = [
                        {
                          'name': 'User Database',
                          'type': 'PostgreSQL',
                          'port': '5000',
                          'status': 'Active',
                        },
                        {
                          'name': 'Product Catalog',
                          'type': 'MySQL',
                          'port': '5001',
                          'status': 'Active',
                        },
                        {
                          'name': 'Cache Service',
                          'type': 'Redis',
                          'port': '6000',
                          'status': 'Inactive',
                        },
                      ];

                      final db = databases[index];
                      final isActive = db['status'] == 'Active';

                      return ListTile(
                        title: Text(db['name']!),
                        subtitle: Text('${db['type']} • Port: ${db['port']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                db['status']!,
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                isActive
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Database Proxy'),
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
              OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () {},
                child: const Text('Save Configuration'),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
