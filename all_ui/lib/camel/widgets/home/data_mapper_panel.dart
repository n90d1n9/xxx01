import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataMapperPanel extends ConsumerWidget {
  const DataMapperPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: SizedBox(
        width: 800,
        height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.compare_arrows, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Data Mapper',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // Source
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Source Fields',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: [
                                _buildFieldItem('orderId', 'string'),
                                _buildFieldItem('customerId', 'string'),
                                _buildFieldItem('amount', 'number'),
                                _buildFieldItem('status', 'string'),
                                _buildFieldItem('items[]', 'array'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Mapping area
                  Container(
                    width: 100,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.arrow_forward, size: 32),
                    ),
                  ),
                  // Target
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Fields',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              children: [
                                _buildFieldItem('id', 'string'),
                                _buildFieldItem('customer', 'string'),
                                _buildFieldItem('total', 'number'),
                                _buildFieldItem('state', 'string'),
                                _buildFieldItem('products[]', 'array'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Mapping'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldItem(String name, String type) {
    return Card(
      child: ListTile(
        leading: Icon(
          type == 'string'
              ? Icons.text_fields
              : type == 'number'
              ? Icons.numbers
              : type == 'array'
              ? Icons.list
              : Icons.circle,
          size: 20,
        ),
        title: Text(name),
        subtitle: Text(type, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
