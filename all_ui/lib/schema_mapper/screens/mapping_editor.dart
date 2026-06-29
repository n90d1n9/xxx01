import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../models/schema.dart';
import '../states/mapping_provider.dart';

class SchemaMappingEditorWidget extends ConsumerStatefulWidget {
  final List<SchemaField> sourceFields;
  final List<SchemaField> targetFields;

  const SchemaMappingEditorWidget({
    Key? key,
    required this.sourceFields,
    required this.targetFields,
  }) : super(key: key);

  @override
  _SchemaMappingEditorWidgetState createState() =>
      _SchemaMappingEditorWidgetState();
}

class _SchemaMappingEditorWidgetState
    extends ConsumerState<SchemaMappingEditorWidget> {
  late List<FieldMapping> _fieldMappings;

  @override
  void initState() {
    super.initState();
    _initializeFieldMappings();
  }

  void _initializeFieldMappings() {
    _fieldMappings =
        widget.targetFields.map((targetField) {
          // Attempt automatic mapping based on name or type
          final matchingSourceField = _findBestMatchingSourceField(targetField);

          return FieldMapping(
            sourceField:
                matchingSourceField ??
                SchemaField(name: 'Unmapped', type: DataType.custom),
            targetField: targetField,
            confidence: matchingSourceField != null ? 0.8 : 0.0,
          );
        }).toList();
  }

  SchemaField? _findBestMatchingSourceField(SchemaField targetField) {
    // Advanced mapping logic
    return widget.sourceFields.firstWhere(
      (sourceField) =>
          sourceField.name.toLowerCase() == targetField.name.toLowerCase() ||
          sourceField.type == targetField.type,
      orElse: () => SchemaField(name: '', type: DataType.string),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema Mapping Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfiguration,
          ),
        ],
      ),
      body: ReorderableGridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
        ),
        itemCount: _fieldMappings.length,
        itemBuilder: (context, index) {
          final mapping = _fieldMappings[index];
          return _buildMappingTile(mapping, index);
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final item = _fieldMappings.removeAt(oldIndex);
            _fieldMappings.insert(newIndex, item);
          });
        },
      ),
    );
  }

  Widget _buildMappingTile(FieldMapping mapping, int index) {
    return Card(
      key: ValueKey(mapping.targetField.name),
      child: ListTile(
        title: Text(mapping.targetField.name),
        subtitle: Text('Mapped from: ${mapping.sourceField.name}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showMappingConfigDialog(index),
            ),
            Text('${(mapping.confidence ?? 0 * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }

  void _showMappingConfigDialog(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Configure Field Mapping'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add transformation rule selection
                // Add custom mapping options
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _saveConfiguration() {
    final configuration = SchemaMappingConfiguration(
      sourceSchemaName: 'Source Schema',
      targetSchemaName: 'Target Schema',
      fieldMappings: _fieldMappings,
    );

    ref.read(schemaMappingProvider.notifier).addConfiguration(configuration);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mapping Configuration Saved')),
    );
  }
}
