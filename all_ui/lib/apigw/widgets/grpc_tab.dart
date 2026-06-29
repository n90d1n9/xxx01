import 'package:flutter/material.dart';

class GrpcTab extends StatelessWidget {
  const GrpcTab({super.key});

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
                    'gRPC Configuration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Endpoint configuration
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Listen Port',
                            hintText: '50051',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('TLS Enabled'),
                          value: true,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Protocol selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Protocol Version',
                      border: OutlineInputBorder(),
                    ),
                    value: 'grpc',
                    items:
                        ['grpc', 'grpc-web']
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

                  // Proto files
                  ExpansionTile(
                    title: const Text('Proto Files'),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: const Text('user_service.proto'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: const Text('product_service.proto'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Proto File'),
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

          // Reflection and transcoding
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
                    'Advanced gRPC Features',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    title: const Text('Enable Server Reflection'),
                    subtitle: const Text(
                      'Allows dynamic discovery of services (useful for debugging)',
                    ),
                    value: true,
                    onChanged: (value) {},
                  ),

                  const Divider(),

                  CheckboxListTile(
                    title: const Text('HTTP/JSON Transcoding'),
                    subtitle: const Text(
                      'Expose gRPC services as REST APIs automatically',
                    ),
                    value: true,
                    onChanged: (value) {},
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'HTTP Endpoint for Transcoded Services',
                      hintText: '/api/grpc',
                      border: OutlineInputBorder(),
                      enabled: true,
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
