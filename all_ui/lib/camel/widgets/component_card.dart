import 'package:flutter/material.dart';

import '../models/component_template.dart';

class ComponentCard extends StatelessWidget {
  final ComponentTemplate template;
  final bool isDragging;

  const ComponentCard({
    super.key,
    required this.template,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDragging ? 200 : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: template.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            isDragging
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(template.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (!isDragging && template.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              template.description,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
