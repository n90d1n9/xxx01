// Properties Panel Widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/node_card.dart';
import '../states/node_route_provider.dart';
import '../states/select_route_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(selectedNodeProvider);
    final route = ref.watch(selectedRouteProvider);

    return Container(
      color: Colors.grey[100],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 8),
              Text(
                'Properties',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (node == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.touch_app, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Select a node to edit properties',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: node.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(node.icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          node.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Configuration',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...node.config.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key
                              .replaceAllMapped(
                                RegExp(r'([A-Z])'),
                                (match) => ' ${match.group(0)}',
                              )
                              .trim(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (entry.value is bool)
                          SwitchListTile(
                            value: entry.value as bool,
                            onChanged: (value) {
                              _updateNodeConfig(
                                ref,
                                route!.id,
                                node,
                                entry.key,
                                value,
                              );
                            },
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          )
                        else if (entry.value is int)
                          TextField(
                            controller: TextEditingController(
                              text: entry.value.toString(),
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check, size: 18),
                                onPressed: () {},
                              ),
                            ),
                            onSubmitted: (value) {
                              _updateNodeConfig(
                                ref,
                                route!.id,
                                node,
                                entry.key,
                                int.tryParse(value) ?? entry.value,
                              );
                            },
                          )
                        else
                          TextField(
                            controller: TextEditingController(
                              text: entry.value.toString(),
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (value) {
                              _updateNodeConfig(
                                ref,
                                route!.id,
                                node,
                                entry.key,
                                value,
                              );
                            },
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Node Info',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('ID', node.id),
                _buildInfoRow('Type', node.type),
                _buildInfoRow(
                  'Position',
                  '(${node.position.dx.toInt()}, ${node.position.dy.toInt()})',
                ),
                _buildInfoRow(
                  'Connections',
                  node.connections.length.toString(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _updateNodeConfig(
    WidgetRef ref,
    String routeId,
    NodeCard node,
    String key,
    dynamic value,
  ) {
    final updatedConfig = Map<String, dynamic>.from(node.config);
    updatedConfig[key] = value;
    final updatedNode = node.copyWith(config: updatedConfig);
    ref
        .read(routesProvider.notifier)
        .updateNodeInRoute(routeId, node.id, updatedNode);
  }
}
