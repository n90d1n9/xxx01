import 'package:flutter/material.dart';

class ComponentCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ComponentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ComponentCategories {
  static List<ComponentCategory> getCategories() => [
    const ComponentCategory(
      id: 'endpoints',
      name: 'Endpoints',
      icon: Icons.cloud_outlined,
      color: Colors.blue,
    ),
    const ComponentCategory(
      id: 'routing',
      name: 'Routing',
      icon: Icons.alt_route,
      color: Colors.purple,
    ),
    const ComponentCategory(
      id: 'transformation',
      name: 'Transform',
      icon: Icons.transform,
      color: Colors.orange,
    ),
    const ComponentCategory(
      id: 'messaging',
      name: 'Messaging',
      icon: Icons.message,
      color: Colors.green,
    ),
    const ComponentCategory(
      id: 'database',
      name: 'Database',
      icon: Icons.storage,
      color: Colors.teal,
    ),
    const ComponentCategory(
      id: 'processors',
      name: 'Processors',
      icon: Icons.settings,
      color: Colors.indigo,
    ),
    const ComponentCategory(
      id: 'error',
      name: 'Error Handling',
      icon: Icons.error_outline,
      color: Colors.red,
    ),
  ];
}
