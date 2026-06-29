import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/field_type.dart';
import '../model/field_type_definition.dart';
import '../model/field_config.dart';
import '../states/form_field_provider.dart';
import 'field_card.dart';

class ContainerFieldCard extends ConsumerWidget {
  final FieldConfig field;
  final int depth;

  const ContainerFieldCard({super.key, required this.field, this.depth = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);
    final isSelected = selectedField?.id == field.id;
    final expandedContainers = ref.watch(expandedContainersProvider);
    final isExpanded = expandedContainers.contains(field.id);

    return Container(
      margin: EdgeInsets.only(bottom: 12, left: depth * 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        border: Border.all(
          color: isSelected ? Colors.purple : const Color(0xFF3D3D3D),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Container Header
          InkWell(
            onTap: () => ref.read(selectedFieldProvider.notifier).state = field,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    color: Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _getContainerIcon(field.type),
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getContainerLabel(field.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (field.children != null && field.children!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${field.children!.length} item${field.children!.length != 1 ? "s" : ""}',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                    ),
                    color: Colors.white70,
                    onPressed: () {
                      final newSet = Set<String>.from(expandedContainers);
                      if (isExpanded) {
                        newSet.remove(field.id);
                      } else {
                        newSet.add(field.id);
                      }
                      ref.read(expandedContainersProvider.notifier).state =
                          newSet;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 20),
                    color: Colors.green,
                    tooltip: 'Add Field',
                    onPressed: () =>
                        _showAddFieldDialog(context, ref, field.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 18),
                    color: Colors.white70,
                    tooltip: 'Duplicate',
                    onPressed: () => ref
                        .read(formFieldsProvider.notifier)
                        .duplicateField(field),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red,
                    tooltip: 'Delete',
                    onPressed: () {
                      ref
                          .read(formFieldsProvider.notifier)
                          .deleteField(field.id);
                      if (selectedField?.id == field.id) {
                        ref.read(selectedFieldProvider.notifier).state = null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Container Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: field.children == null || field.children!.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Empty Container',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'Add Field',
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () =>
                                _showAddFieldDialog(context, ref, field.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.purple,
                              side: const BorderSide(color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildContainerLayout(field, ref),
            ),
        ],
      ),
    );
  }

  Widget _buildContainerLayout(FieldConfig container, WidgetRef ref) {
    final children = container.children!;

    if (container.type == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: container.columns ?? 2,
          crossAxisSpacing: container.spacing ?? 12,
          mainAxisSpacing: container.spacing ?? 12,
          childAspectRatio: 2,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return FieldCard(
            field: children[index],
            index: index,
            depth: depth + 1,
          );
        },
      );
    } else if (container.type == 'row') {
      return Row(
        crossAxisAlignment:
            container.crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisAlignment:
            container.mainAxisAlignment ?? MainAxisAlignment.start,
        children: children.map((child) {
          return Expanded(
            flex: child.flex ?? 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: container.spacing ?? 8),
              child: FieldCard(
                field: child,
                index: children.indexOf(child),
                depth: depth + 1,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        crossAxisAlignment:
            container.crossAxisAlignment ?? CrossAxisAlignment.stretch,
        mainAxisAlignment:
            container.mainAxisAlignment ?? MainAxisAlignment.start,
        children: children.map((child) {
          return FieldCard(
            field: child,
            index: children.indexOf(child),
            depth: depth + 1,
          );
        }).toList(),
      );
    }
  }

  void _showAddFieldDialog(
    BuildContext context,
    WidgetRef ref,
    String containerId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Add Field to Container',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView(
            children: fieldTypes
                .where(
                  (f) =>
                      f.category != 'Layout' ||
                      ![
                        'container',
                        'row',
                        'column',
                        'card',
                        'grid',
                      ].contains(f.type),
                )
                .map((fieldType) {
                  return ListTile(
                    leading: Icon(fieldType.icon, color: Colors.blue),
                    title: Text(
                      fieldType.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      final field = FieldConfig(
                        id: 'field_${DateTime.now().millisecondsSinceEpoch}',
                        type: fieldType.type,
                        name:
                            [
                              'section',
                              'divider',
                              'html',
                            ].contains(fieldType.type)
                            ? null
                            : '${fieldType.type}_${DateTime.now().millisecondsSinceEpoch}',
                        label: ['section', 'html'].contains(fieldType.type)
                            ? null
                            : fieldType.label,
                        title: fieldType.type == 'section'
                            ? 'Section Title'
                            : null,
                        options:
                            [
                              'select',
                              'radio',
                              'chips',
                            ].contains(fieldType.type)
                            ? ['Option 1', 'Option 2', 'Option 3']
                            : null,
                      );
                      ref
                          .read(formFieldsProvider.notifier)
                          .addField(field, parentId: containerId);
                      Navigator.pop(context);
                    },
                  );
                })
                .toList(),
          ),
        ),
      ),
    );
  }

  IconData _getContainerIcon(String type) {
    switch (type) {
      case 'row':
        return Icons.view_week;
      case 'column':
        return Icons.view_agenda;
      case 'card':
        return Icons.credit_card;
      case 'grid':
        return Icons.grid_on;
      default:
        return Icons.crop_square;
    }
  }

  String _getContainerLabel(String type) {
    switch (type) {
      case 'row':
        return 'Row Layout';
      case 'column':
        return 'Column Layout';
      case 'card':
        return 'Card';
      case 'grid':
        return 'Grid Layout';
      default:
        return 'Container';
    }
  }
}
