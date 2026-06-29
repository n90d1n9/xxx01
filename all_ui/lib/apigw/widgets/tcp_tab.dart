import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class TcpUdpProxyTab extends StatelessWidget {
  const TcpUdpProxyTab({super.key});

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
                    'L4 TCP/UDP Proxy Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Protocol selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('TCP'),
                          value: 'tcp',
                          groupValue: 'tcp',
                          onChanged: (value) {},
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('UDP'),
                          value: 'udp',
                          groupValue: 'tcp',
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Port configuration
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Listen Port',
                            hintText: '8080',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Target Port',
                            hintText: '9000',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Target service
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Target Service',
                      hintText: 'database.internal:5432',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.storage),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Advanced options
                  ExpansionTile(
                    title: const Text('Advanced Options'),
                    children: [
                      CheckboxListTile(
                        title: const Text('Enable Keep-Alive'),
                        subtitle: const Text('Maintain persistent connections'),
                        value: true,
                        onChanged: (value) {},
                      ),
                      CheckboxListTile(
                        title: const Text('Connection Pooling'),
                        subtitle: const Text(
                          'Reuse connections for better performance',
                        ),
                        value: true,
                        onChanged: (value) {},
                      ),
                      ListTile(
                        title: const Text('Timeout (seconds)'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '60',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Buffer Size (KB)'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '8',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Connection monitoring card
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
                    'Connection Status',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: const Text('Active Connections'),
                    trailing: const Text('0'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: const Text('Connection Rate'),
                    trailing: const Text('0/sec'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: const Text('Data Transfer Rate'),
                    trailing: const Text('0 KB/s'),
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
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Proxy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
