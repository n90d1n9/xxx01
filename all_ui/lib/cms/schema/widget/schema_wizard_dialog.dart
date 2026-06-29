import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../content/model/content_type_schema.dart';
import '../../content/model/content_type_settings.dart';
import '../model/field_schema.dart';
import '../../models/ui_field_type.dart';
import '../../states/cms_repository_provider.dart';
import 'schema_wizard_dialog.dart';

class SchemaWizardDialog extends ConsumerStatefulWidget {
  final Function(ContentTypeSchema) onComplete;
  const SchemaWizardDialog({super.key, required this.onComplete});
  @override
  ConsumerState<SchemaWizardDialog> createState() => _SchemaWizardDialogState();
}

class _SchemaWizardDialogState extends ConsumerState<SchemaWizardDialog> {
  final _nameController = TextEditingController();
  List<FieldSchema> _suggestedFields = [];
  final Set<String> _selectedFields = {};
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Smart Schema Wizard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Schema Name',
                        hintText: 'e.g., User, Product, Blog Post',
                        prefixIcon: Icon(Icons.lightbulb),
                      ),
                      onChanged: (value) {
                        if (value.length > 2) {
                          setState(() {
                            _suggestedFields = ref
                                .read(cmsRepositoryProvider)
                                .suggestFields(value);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_suggestedFields.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 20,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Suggested Fields',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select the fields you want to include:',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ..._suggestedFields.map((field) {
                        return CheckboxListTile(
                          value: _selectedFields.contains(field.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedFields.add(field.id);
                              } else {
                                _selectedFields.remove(field.id);
                              }
                            });
                          },
                          title: Text(field.label),
                          subtitle: Text(
                            '${field.uiType.name} • ${field.sqlType.name}',
                          ),
                          secondary: Icon(_getFieldIcon(field.uiType)),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _selectedFields.isEmpty ? null : _createSchema,
                    icon: const Icon(Icons.check),
                    label: const Text('Create Schema'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFieldIcon(UIFieldType type) {
    switch (type) {
      case UIFieldType.textInput:
        return Icons.text_fields;
      case UIFieldType.numberInput:
        return Icons.numbers;
      case UIFieldType.datePicker:
        return Icons.calendar_today;
      case UIFieldType.toggle:
        return Icons.toggle_on;
      case UIFieldType.imageUpload:
        return Icons.image;
      case UIFieldType.slug:
        return Icons.link;
      case UIFieldType.richTextEditor:
        return Icons.format_align_left;
      default:
        return Icons.create;
    }
  }

  void _createSchema() {
    if (_nameController.text.isEmpty || _selectedFields.isEmpty) return;
    final selectedFieldSchemas =
        _suggestedFields.where((f) => _selectedFields.contains(f.id)).toList();
    final now = DateTime.now();
    final tableName = _nameController.text.toLowerCase().replaceAll(' ', '_');
    final schema = ContentTypeSchema(
      id: 'ct_${now.millisecondsSinceEpoch}',
      name: _nameController.text,
      tableName: tableName,
      description: 'Auto-generated schema for ${_nameController.text}',
      icon: 'article',
      fields: selectedFieldSchemas,
      settings: const ContentTypeSettings(),
      createdAt: now,
      updatedAt: now,
    );
    widget.onComplete(schema);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
