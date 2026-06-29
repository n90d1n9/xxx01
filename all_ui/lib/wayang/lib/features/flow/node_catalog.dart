import 'package:flutter/material.dart';

class NodeCatalog {
  static const controlFlowNodes = [
    {
      'id': 'if_else',
      'name': 'If/Else',
      'icon': Icons.alt_route,
      'color': Colors.blue,
      'category': 'Control Flow',
    },
    {
      'id': 'while_loop',
      'name': 'While Loop',
      'icon': Icons.loop,
      'color': Colors.purple,
      'category': 'Control Flow',
    },
    {
      'id': 'human_in_loop',
      'name': 'Human Approval',
      'icon': Icons.person_pin_circle,
      'color': Colors.orange,
      'category': 'Control Flow',
    },
  ];

  static const advancedNodes = [
    {
      'id': 'try_catch',
      'name': 'Try-Catch-Finally',
      'icon': Icons.error_outline,
      'color': Colors.red,
      'category': 'Error Handling',
    },
    {
      'id': 'parallel',
      'name': 'Parallel Execution',
      'icon': Icons.call_split,
      'color': Colors.cyan,
      'category': 'Concurrency',
    },
    {
      'id': 'router',
      'name': 'Switch/Router',
      'icon': Icons.route,
      'color': Colors.teal,
      'category': 'Routing',
    },
    {
      'id': 'batch',
      'name': 'Batch Processor',
      'icon': Icons.layers,
      'color': Colors.amber,
      'category': 'Performance',
    },
    {
      'id': 'merge',
      'name': 'Merge/Join',
      'icon': Icons.merge,
      'color': Colors.indigo,
      'category': 'Data',
    },
    {
      'id': 'delay',
      'name': 'Delay/Schedule',
      'icon': Icons.schedule,
      'color': Colors.deepOrange,
      'category': 'Timing',
    },
    {
      'id': 'filter',
      'name': 'Filter/Transform',
      'icon': Icons.filter_alt,
      'color': Colors.green,
      'category': 'Data',
    },
    {
      'id': 'cache',
      'name': 'Cache',
      'icon': Icons.cached,
      'color': Colors.pink,
      'category': 'Performance',
    },
  ];

  static List<Map<String, dynamic>> get allNodes => [
    ...controlFlowNodes,
    ...advancedNodes,
  ];

  static Map<String, dynamic>? getNodeInfo(String nodeId) {
    return allNodes.firstWhere(
      (node) => node['id'] == nodeId,
      orElse: () => {},
    );
  }
}
