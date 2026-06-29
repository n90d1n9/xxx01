import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ElementPaletteItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final String elementType;

  const ElementPaletteItem({
    super.key,
    required this.icon,
    required this.label,
    required this.elementType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<String>(
      data: elementType,
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(width: 8), Text(label)],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[800]),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}
