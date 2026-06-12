import 'package:flutter/material.dart';

import '../models/ui_field_type.dart';
import '../schema/model/field_schema.dart';
import '../schema/widget/field_schem_dialog.dart';
import 'model/content_type_schema.dart';
import 'model/content_type_settings.dart';

class ContentTypeBuilderPage extends StatefulWidget {
  final ContentTypeSchema? contentType;
  final Function(ContentTypeSchema) onSave;

  const ContentTypeBuilderPage({
    super.key,
    this.contentType,
    required this.onSave,
  });

  @override
  State<ContentTypeBuilderPage> createState() => _ContentTypeBuilderPageState();
}

class _ContentTypeBuilderPageState extends State<ContentTypeBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _tableNameController;
  late TextEditingController _descController;
  late String _selectedIcon;
  late List<FieldSchema> _fields;
  late ContentTypeSettings _settings;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contentType?.name);
    _tableNameController = TextEditingController(
      text: widget.contentType?.tableName,
    );
    _descController = TextEditingController(
      text: widget.contentType?.description,
    );
    _selectedIcon = widget.contentType?.icon ?? 'article';
    _fields = widget.contentType?.fields ?? [];
    _settings = widget.contentType?.settings ?? const ContentTypeSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.contentType == null ? 'New Content Schema' : 'Edit Schema',
        ),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle),
            label: const Text('Save Schema'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Schema Info & Fields
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoCard(),
                    const SizedBox(height: 24),
                    _buildFieldsCard(),
                  ],
                ),
              ),
            ),
            // Right Panel - Settings & Preview
            Container(
              width: 350,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsCard(),
                    const SizedBox(height: 24),
                    _buildPreviewCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Schema Name',
                hintText: 'e.g., Blog Post, Product, User',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onChanged: (v) {
                if (_tableNameController.text.isEmpty ||
                    widget.contentType == null) {
                  _tableNameController.text = v.toLowerCase().replaceAll(
                    ' ',
                    '_',
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tableNameController,
              decoration: const InputDecoration(
                labelText: 'Table Name (Database)',
                hintText: 'e.g., blog_posts, products, users',
                prefixIcon: Icon(Icons.storage),
                helperText: 'Snake_case recommended for database compatibility',
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (!RegExp(r'^[a-z][a-z0-9_]*').hasMatch(v!)) {
                  return 'Only lowercase, numbers, underscores';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of this content type',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedIcon,
              decoration: const InputDecoration(
                labelText: 'Icon',
                prefixIcon: Icon(Icons.emoji_symbols),
              ),
              items: const [
                DropdownMenuItem(value: 'article', child: Text('📄 Article')),
                DropdownMenuItem(value: 'image', child: Text('🖼️ Image')),
                DropdownMenuItem(value: 'video', child: Text('🎥 Video')),
                DropdownMenuItem(value: 'person', child: Text('👤 Person')),
                DropdownMenuItem(value: 'category', child: Text('📁 Category')),
                DropdownMenuItem(value: 'settings', child: Text('⚙️ Settings')),
              ],
              onChanged: (v) => setState(() => _selectedIcon = v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Fields',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_fields.length}',
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_fields.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.layers, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No fields yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first field to define the schema',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fields.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final field = _fields.removeAt(oldIndex);
                    _fields.insert(newIndex, field);
                    for (int i = 0; i < _fields.length; i++) {
                      _fields[i] = _fields[i].copyWith(position: i);
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final field = _fields[index];
                  return _FieldListItem(
                    key: ValueKey(field.id),
                    field: field,
                    onEdit: () => _editField(index),
                    onDelete: () => setState(() => _fields.removeAt(index)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Publishing'),
              subtitle: const Text('Draft/Published status'),
              value: _settings.enablePublishing,
              onChanged:
                  (v) => setState(() {
                    _settings = ContentTypeSettings(
                      enablePublishing: v,
                      enableVersioning: _settings.enableVersioning,
                      enableComments: _settings.enableComments,
                    );
                  }),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Enable Versioning'),
              subtitle: const Text('Track content versions'),
              value: _settings.enableVersioning,
              onChanged:
                  (v) => setState(() {
                    _settings = ContentTypeSettings(
                      enablePublishing: _settings.enablePublishing,
                      enableVersioning: v,
                      enableComments: _settings.enableComments,
                    );
                  }),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Enable Comments'),
              subtitle: const Text('Allow user comments'),
              value: _settings.enableComments,
              onChanged:
                  (v) => setState(() {
                    _settings = ContentTypeSettings(
                      enablePublishing: _settings.enablePublishing,
                      enableVersioning: _settings.enableVersioning,
                      enableComments: v,
                    );
                  }),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SQL Preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _generatePreviewSQL(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generatePreviewSQL() {
    if (_tableNameController.text.isEmpty) return '-- Enter table name';

    final buffer = StringBuffer();
    buffer.writeln('CREATE TABLE ${_tableNameController.text} (');
    buffer.writeln('  id UUID PRIMARY KEY,');

    for (var field in _fields.take(3)) {
      buffer.writeln('  ${field.toSQLColumn()},');
    }

    if (_fields.length > 3) {
      buffer.writeln('  ...');
    }

    buffer.writeln('  created_at TIMESTAMP');
    buffer.write(');');

    return buffer.toString();
  }

  void _addField() {
    showDialog(
      context: context,
      builder:
          (context) => FieldSchemaDialog(
            onSave: (field) {
              setState(
                () => _fields.add(field.copyWith(position: _fields.length)),
              );
            },
          ),
    );
  }

  void _editField(int index) {
    showDialog(
      context: context,
      builder:
          (context) => FieldSchemaDialog(
            field: _fields[index],
            onSave: (field) {
              setState(() => _fields[index] = field);
            },
          ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix the errors')));
      return;
    }

    if (_fields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one field')));
      return;
    }

    final now = DateTime.now();
    final schema = ContentTypeSchema(
      id: widget.contentType?.id ?? 'ct_${now.millisecondsSinceEpoch}',
      name: _nameController.text,
      tableName: _tableNameController.text,
      description: _descController.text.isEmpty ? null : _descController.text,
      icon: _selectedIcon,
      fields: _fields,
      settings: _settings,
      createdAt: widget.contentType?.createdAt ?? now,
      updatedAt: now,
      version: widget.contentType?.version ?? 1,
    );

    widget.onSave(schema);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tableNameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

class _FieldListItem extends StatelessWidget {
  final FieldSchema field;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FieldListItem({
    super.key,
    required this.field,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey.shade50,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getFieldTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getFieldIcon(), color: _getFieldTypeColor(), size: 20),
        ),
        title: Row(
          children: [
            Text(
              field.label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (!field.constraints.nullable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (field.constraints.unique)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Unique',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${field.name} • ${field.uiType.name} → ${field.sqlType.name.toUpperCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (field.description != null) ...[
              const SizedBox(height: 4),
              Text(
                field.description!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Color _getFieldTypeColor() {
    switch (field.uiType) {
      case UIFieldType.textInput:
      case UIFieldType.textArea:
        return Colors.blue;
      case UIFieldType.numberInput:
        return Colors.orange;
      case UIFieldType.datePicker:
      case UIFieldType.dateTimePicker:
        return Colors.purple;
      case UIFieldType.toggle:
      case UIFieldType.checkbox:
        return Colors.green;
      case UIFieldType.imageUpload:
      case UIFieldType.fileUpload:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getFieldIcon() {
    switch (field.uiType) {
      case UIFieldType.textInput:
        return Icons.text_fields;
      case UIFieldType.textArea:
        return Icons.notes;
      case UIFieldType.richTextEditor:
        return Icons.format_align_left;
      case UIFieldType.numberInput:
        return Icons.numbers;
      case UIFieldType.datePicker:
        return Icons.calendar_today;
      case UIFieldType.dateTimePicker:
        return Icons.access_time;
      case UIFieldType.toggle:
        return Icons.toggle_on;
      case UIFieldType.dropdown:
        return Icons.arrow_drop_down_circle;
      case UIFieldType.imageUpload:
        return Icons.image;
      case UIFieldType.colorPicker:
        return Icons.palette;
      default:
        return Icons.create;
    }
  }
}
