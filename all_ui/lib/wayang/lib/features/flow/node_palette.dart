import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'node_catalog.dart';

class NodePalette extends ConsumerWidget {
  final Function(String nodeType) onNodeSelected;

  const NodePalette({Key? key, required this.onNodeSelected}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 300,
      color: const Color(0xFF252525),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: const Row(
              children: [
                Icon(Icons.widgets, size: 20),
                SizedBox(width: 12),
                Text(
                  'Node Palette',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategory('Control Flow', NodeCatalog.controlFlowNodes),
                const SizedBox(height: 24),
                _buildCategory('Advanced Nodes', NodeCatalog.advancedNodes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, List<Map<String, dynamic>> nodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...nodes.map((node) => _buildNodeCard(node)),
      ],
    );
  }

  Widget _buildNodeCard(Map<String, dynamic> node) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onNodeSelected(node['id']),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (node['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(node['icon'], color: node['color'], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node['category'],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_outline,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
