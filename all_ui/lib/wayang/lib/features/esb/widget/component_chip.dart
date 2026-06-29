import 'package:flutter/material.dart';

import '../model/component_type.dart';

class ComponentChip extends StatelessWidget {
  final ComponentType type;

  const ComponentChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _getColor(type),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(type), color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            type.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ComponentType type) {
    // Same as ComponentPaletteItem
    switch (type) {
      case ComponentType.from:
        return Icons.input;
      case ComponentType.to:
        return Icons.output;
      case ComponentType.transform:
        return Icons.transform;
      case ComponentType.filter:
        return Icons.filter_alt;
      case ComponentType.choice:
        return Icons.call_split;
      case ComponentType.log:
        return Icons.article;
      case ComponentType.setHeader:
        return Icons.view_headline;
      case ComponentType.setBody:
        return Icons.data_object;
      case ComponentType.process:
        return Icons.settings;
      case ComponentType.split:
        return Icons.call_split;
      case ComponentType.aggregate:
        return Icons.merge;
      case ComponentType.enrich:
        return Icons.add_circle;
      case ComponentType.multicast:
        return Icons.broadcast_on_personal;
      case ComponentType.wiretap:
        return Icons.visibility;
      case ComponentType.loop:
        return Icons.loop;
      case ComponentType.delay:
        return Icons.schedule;
      case ComponentType.throttle:
        return Icons.speed;
      default:
        return Icons.widgets;
    }
  }

  Color _getColor(ComponentType type) {
    switch (type) {
      case ComponentType.from:
        return Colors.green;
      case ComponentType.to:
        return Colors.red;
      case ComponentType.transform:
      case ComponentType.setBody:
      case ComponentType.setHeader:
        return Colors.purple;
      case ComponentType.choice:
      case ComponentType.filter:
      case ComponentType.multicast:
      case ComponentType.split:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
