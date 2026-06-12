import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/field_type_definition.dart';
import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../states/form_field_provider.dart';

class ComponentPalette extends ConsumerWidget {
  final FormTheme? theme;
  const ComponentPalette({super.key, this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = fieldTypes.map((f) => f.category).toSet().toList();

    return Container(
      width: 250,
      color: const Color(0xFF252526),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'COMPONENTS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryFields = fieldTypes
                    .where((f) => f.category == category)
                    .toList();

                return ExpansionTile(
                  initiallyExpanded: category == 'Layout',
                  title: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  iconColor: Colors.white70,
                  collapsedIconColor: Colors.white70,
                  children: categoryFields.map((fieldType) {
                    return InkWell(
                      onTap: () => _addField(ref, fieldType),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(fieldType.icon, size: 18, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fieldType.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if ([
                              'container',
                              'row',
                              'column',
                              'card',
                              'grid',
                            ].contains(fieldType.type))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'LAYOUT',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addField(WidgetRef ref, FieldTypeDefinition fieldType) {
    final field = FieldConfig(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      type: fieldType.type,
      name:
          [
            'section',
            'divider',
            'html',
            'container',
            'row',
            'column',
            'card',
            'grid',
          ].contains(fieldType.type)
          ? null
          : '${fieldType.type}_${ref.read(formFieldsProvider).length + 1}',
      label:
          [
            'section',
            'html',
            'container',
            'row',
            'column',
            'card',
            'grid',
          ].contains(fieldType.type)
          ? null
          : fieldType.label,
      title: fieldType.type == 'section' ? 'Section Title' : null,
      description: fieldType.type == 'section' ? '' : null,
      content: fieldType.type == 'html' ? 'Your content here' : null,
      options: ['select', 'radio', 'chips'].contains(fieldType.type)
          ? ['Option 1', 'Option 2', 'Option 3']
          : null,
      min: ['number', 'slider'].contains(fieldType.type) ? 0 : null,
      max: ['number', 'slider'].contains(fieldType.type) ? 100 : null,
      maxLines: fieldType.type == 'textarea' ? 4 : null,
      maxRating: fieldType.type == 'rating' ? 5 : null,
      children:
          [
            'container',
            'row',
            'column',
            'card',
            'grid',
          ].contains(fieldType.type)
          ? []
          : null,
      padding: ['container', 'card'].contains(fieldType.type)
          ? const EdgeInsets.all(16)
          : null,
      columns: fieldType.type == 'grid' ? 2 : null,
      spacing: fieldType.type == 'grid' ? 12 : null,
    );

    ref.read(formFieldsProvider.notifier).addField(field);
    ref.read(selectedFieldProvider.notifier).state = field;
  }
}
