import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:queue_ui/schema_mapper_new/sample.dart';

import 'models/data_schema.dart';
import 'states/providers.dart';
import 'widgets/drag_drop.dart';

class MappingEditorScreen extends ConsumerStatefulWidget {
  const MappingEditorScreen({super.key});

  @override
  _MappingEditorScreenState createState() => _MappingEditorScreenState();
}

class _MappingEditorScreenState extends ConsumerState<MappingEditorScreen> {
  DataSchema? _sourceSchema;
  DataSchema? _targetSchema;

  @override
  Widget build(BuildContext context) {
    final schemaManager = ref.watch(schemaManagerProvider);
    final mappingManager = ref.watch(mappingManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema Mapping Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showSchemaSelectionDialog,
          ),
          if (_sourceSchema != null && _targetSchema != null)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveMapping),
        ],
      ),
      body: _sourceSchema != null && _targetSchema != null
          ? DragDropMappingWidget(
              sourceSchema: _sourceSchema!,
              targetSchema: _targetSchema!,
            )
          : Center(
              child: ElevatedButton(
                onPressed: _showSchemaSelectionDialog,
                child: const Text('Select Schemas to Map'),
              ),
            ),
    );
  }

  void _showSchemaSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Schemas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<DataSchema>(
              hint: const Text('Select Source Schema'),
              items:
                  //ref.read(schemaManagerProvider).map((schema) {
                  SchemaExamples.getAllSchemas().map((schema) {
                    return DropdownMenuItem(
                      value: schema,
                      child: Text(schema.name),
                    );
                  }).toList(),
              onChanged: (schema) {
                setState(() {
                  _sourceSchema = schema;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DataSchema>(
              hint: const Text('Select Target Schema'),
              items:
                  //ref.read(schemaManagerProvider).map((schema) {
                  SchemaExamples.getAllSchemas().map((schema) {
                    return DropdownMenuItem(
                      value: schema,
                      child: Text(schema.name),
                    );
                  }).toList(),
              onChanged: (schema) {
                setState(() {
                  _targetSchema = schema;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_sourceSchema != null && _targetSchema != null) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _saveMapping() {
    final mappingConfig = ref.read(mappingManagerProvider);
    if (mappingConfig == null) return;

    // Implement saving logic (e.g., to file, database)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mapping saved for ${mappingConfig.sourceSchema.name} '
          'to ${mappingConfig.targetSchema.name}',
        ),
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: MappingEditorScreen())));
}
