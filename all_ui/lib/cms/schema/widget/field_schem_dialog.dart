import 'package:flutter/material.dart';

import '../model/field_contraint.dart';
import '../model/field_schema.dart';
import '../../models/select_option.dart';
import '../../models/sql_type.dart';
import '../../models/ui_field_type.dart';
import '../../models/validation_rules.dart';
import '../../models/widget_options.dart';

class FieldSchemaDialog extends StatefulWidget {
  final FieldSchema? field;
  final Function(FieldSchema) onSave;

  const FieldSchemaDialog({super.key, this.field, required this.onSave});

  @override
  State<FieldSchemaDialog> createState() => _FieldSchemaDialogState();
}

class _FieldSchemaDialogState extends State<FieldSchemaDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _labelController;
  late TextEditingController _descController;
  late TextEditingController _placeholderController;
  late TextEditingController _helpTextController;
  late UIFieldType _uiType;
  late SQLType _sqlType;
  late bool _nullable;
  late bool _unique;
  late bool _indexed;
  late ValidationRules? _validation;
  late List<SelectOption> _selectOptions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _nameController = TextEditingController(text: widget.field?.name);
    _labelController = TextEditingController(text: widget.field?.label);
    _descController = TextEditingController(text: widget.field?.description);
    _placeholderController = TextEditingController(
      text: widget.field?.widgetOptions?.placeholder,
    );
    _helpTextController = TextEditingController(
      text: widget.field?.widgetOptions?.helpText,
    );
    _uiType = widget.field?.uiType ?? UIFieldType.textInput;
    _sqlType = widget.field?.sqlType ?? SQLType.varchar;
    _nullable = widget.field?.constraints.nullable ?? true;
    _unique = widget.field?.constraints.unique ?? false;
    _indexed = widget.field?.constraints.indexed ?? false;
    _validation = widget.field?.validation;
    _selectOptions = widget.field?.widgetOptions?.options ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        height: 700,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.create, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.field == null ? 'New Field' : 'Edit Field',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Define field schema and behavior',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Basic', icon: Icon(Icons.info, size: 20)),
                Tab(text: 'Database', icon: Icon(Icons.storage, size: 20)),
                Tab(
                  text: 'Validation',
                  icon: Icon(Icons.check_circle, size: 20),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicTab(),
                  _buildDatabaseTab(),
                  _buildValidationTab(),
                ],
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
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Field'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Field Name (API)',
                hintText: 'e.g., title, author_name, price',
                helperText: 'Used in database and API (snake_case)',
                prefixIcon: Icon(Icons.code),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (!RegExp(r'^[a-z][a-z0-9_]*').hasMatch(v!)) {
                  return 'Only lowercase, numbers, underscores';
                }
                return null;
              },
              onChanged: (v) {
                if (_labelController.text.isEmpty) {
                  _labelController.text = v
                      .split('_')
                      .map(
                        (w) =>
                            w.isEmpty
                                ? ''
                                : w[0].toUpperCase() + w.substring(1),
                      )
                      .join(' ');
                }
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., Title, Author Name, Price',
                helperText: 'Display name shown in forms',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of this field',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<UIFieldType>(
              value: _uiType,
              decoration: const InputDecoration(
                labelText: 'UI Field Type',
                helperText: 'How users interact with this field',
                prefixIcon: Icon(Icons.widgets),
              ),
              items:
                  UIFieldType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
              onChanged:
                  (v) => setState(() {
                    _uiType = v!;
                    _sqlType = _getDefaultSQLType(v);
                  }),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _placeholderController,
              decoration: const InputDecoration(
                labelText: 'Placeholder (Optional)',
                hintText: 'e.g., Enter title here...',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _helpTextController,
              decoration: const InputDecoration(
                labelText: 'Help Text (Optional)',
                hintText: 'Additional guidance for users',
                prefixIcon: Icon(Icons.help_outline),
              ),
              maxLines: 2,
            ),
            if (_needsOptions()) ...[
              const SizedBox(height: 20),
              _buildOptionsEditor(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SQLType>(
            value: _sqlType,
            decoration: const InputDecoration(
              labelText: 'SQL Data Type',
              helperText: 'Database column type',
              prefixIcon: Icon(Icons.storage),
            ),
            items:
                SQLType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
            onChanged: (v) => setState(() => _sqlType = v!),
          ),
          const SizedBox(height: 24),
          Text(
            'Constraints',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Nullable'),
            subtitle: const Text('Allow NULL values'),
            value: _nullable,
            onChanged: (v) => setState(() => _nullable = v),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Unique'),
            subtitle: const Text('Enforce unique values'),
            value: _unique,
            onChanged: (v) => setState(() => _unique = v),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Indexed'),
            subtitle: const Text('Create database index'),
            value: _indexed,
            onChanged: (v) => setState(() => _indexed = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SQL Preview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _generateFieldSQL(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_supportsLengthValidation()) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _validation?.minLength?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Min Length',
                      prefixIcon: Icon(Icons.remove),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (v) => _updateValidation(
                          minLength: v.isEmpty ? null : int.tryParse(v),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _validation?.maxLength?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Max Length',
                      prefixIcon: Icon(Icons.add),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (v) => _updateValidation(
                          maxLength: v.isEmpty ? null : int.tryParse(v),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          if (_supportsNumericValidation()) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _validation?.min?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Min Value',
                      prefixIcon: Icon(Icons.remove),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (v) => _updateValidation(
                          min: v.isEmpty ? null : num.tryParse(v),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _validation?.max?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Max Value',
                      prefixIcon: Icon(Icons.add),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged:
                        (v) => _updateValidation(
                          max: v.isEmpty ? null : num.tryParse(v),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          TextFormField(
            initialValue: _validation?.pattern,
            decoration: const InputDecoration(
              labelText: 'Pattern (Regex)',
              hintText: 'e.g., ^[A-Z][a-z]+',
              prefixIcon: Icon(Icons.pattern),
              helperText: 'Regular expression for validation',
            ),
            onChanged: (v) => _updateValidation(pattern: v.isEmpty ? null : v),
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _validation?.errorMessage,
            decoration: const InputDecoration(
              labelText: 'Custom Error Message',
              hintText: 'Message shown when validation fails',
              prefixIcon: Icon(Icons.error_outline),
            ),
            onChanged:
                (v) => _updateValidation(errorMessage: v.isEmpty ? null : v),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Options',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Option'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectOptions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                'No options yet. Add your first option.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ..._selectOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(option.label),
                subtitle: Text('Value: ${option.value}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed:
                      () => setState(() => _selectOptions.removeAt(index)),
                ),
              ),
            );
          }),
      ],
    );
  }

  void _addOption() {
    final valueController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'e.g., draft, published',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'e.g., Draft, Published',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (valueController.text.isNotEmpty &&
                      labelController.text.isNotEmpty) {
                    setState(() {
                      _selectOptions.add(
                        SelectOption(
                          value: valueController.text,
                          label: labelController.text,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  bool _needsOptions() {
    return _uiType == UIFieldType.dropdown ||
        _uiType == UIFieldType.radioGroup ||
        _uiType == UIFieldType.checkboxGroup;
  }

  bool _supportsLengthValidation() {
    return _uiType == UIFieldType.textInput ||
        _uiType == UIFieldType.textArea ||
        _uiType == UIFieldType.richTextEditor;
  }

  bool _supportsNumericValidation() {
    return _uiType == UIFieldType.numberInput || _uiType == UIFieldType.slider;
  }

  SQLType _getDefaultSQLType(UIFieldType uiType) {
    switch (uiType) {
      case UIFieldType.textInput:
        return SQLType.varchar;
      case UIFieldType.textArea:
      case UIFieldType.richTextEditor:
      case UIFieldType.markdown:
      case UIFieldType.code:
        return SQLType.text;
      case UIFieldType.numberInput:
      case UIFieldType.slider:
      case UIFieldType.rating:
        return SQLType.integer;
      case UIFieldType.datePicker:
        return SQLType.date;
      case UIFieldType.dateTimePicker:
        return SQLType.timestamp;
      case UIFieldType.timePicker:
        return SQLType.time;
      case UIFieldType.toggle:
      case UIFieldType.checkbox:
        return SQLType.boolean;
      case UIFieldType.json:
        return SQLType.jsonb;
      default:
        return SQLType.varchar;
    }
  }

  String _generateFieldSQL() {
    final buffer = StringBuffer();
    buffer.write(
      '${_nameController.text.isEmpty ? 'field_name' : _nameController.text} ',
    );
    buffer.write(_sqlType.name.toUpperCase());
    if (!_nullable) buffer.write(' NOT NULL');
    if (_unique) buffer.write(' UNIQUE');
    return buffer.toString();
  }

  void _updateValidation({
    int? minLength,
    int? maxLength,
    num? min,
    num? max,
    String? pattern,
    String? errorMessage,
  }) {
    setState(() {
      _validation = ValidationRules(
        minLength: minLength ?? _validation?.minLength,
        maxLength: maxLength ?? _validation?.maxLength,
        min: min ?? _validation?.min,
        max: max ?? _validation?.max,
        pattern: pattern ?? _validation?.pattern,
        errorMessage: errorMessage ?? _validation?.errorMessage,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final field = FieldSchema(
      id: widget.field?.id ?? 'field_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      label: _labelController.text,
      description: _descController.text.isEmpty ? null : _descController.text,
      uiType: _uiType,
      sqlType: _sqlType,
      constraints: FieldConstraints(
        nullable: _nullable,
        unique: _unique,
        indexed: _indexed,
      ),
      validation: _validation,
      widgetOptions: WidgetOptions(
        placeholder:
            _placeholderController.text.isEmpty
                ? null
                : _placeholderController.text,
        helpText:
            _helpTextController.text.isEmpty ? null : _helpTextController.text,
        options: _selectOptions.isEmpty ? null : _selectOptions,
      ),
      position: widget.field?.position ?? 0,
    );

    widget.onSave(field);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _labelController.dispose();
    _descController.dispose();
    _placeholderController.dispose();
    _helpTextController.dispose();
    super.dispose();
  }
}
