import 'package:flutter/material.dart';

import '../models/project_custom_attribute.dart';
import '../services/project_custom_attribute_editor_context_service.dart';
import 'project_custom_attribute_row.dart';

typedef ProjectCustomAttributeIndexedChanged =
    void Function(int index, ProjectCustomAttribute attribute);

class ProjectCustomAttributeRowsList extends StatelessWidget {
  const ProjectCustomAttributeRowsList({
    required this.rows,
    required this.focusedAttributeKey,
    required this.onChanged,
    required this.onRemoved,
    super.key,
  });

  final List<ProjectCustomAttributeEditorRowContext> rows;
  final String focusedAttributeKey;
  final ProjectCustomAttributeIndexedChanged onChanged;
  final ValueChanged<int> onRemoved;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      key: const ValueKey('project-custom-attribute-rows-list'),
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          ProjectCustomAttributeRow(
            key: ValueKey(
              'project-custom-attribute-row-${rows[index].attribute.key}',
            ),
            attribute: rows[index].attribute,
            isFocused:
                focusedAttributeKey.isNotEmpty &&
                rows[index].attribute.key == focusedAttributeKey,
            metadata: rows[index].metadata,
            onChanged: (attribute) => onChanged(index, attribute),
            onRemoved: () => onRemoved(index),
          ),
          if (index != rows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
