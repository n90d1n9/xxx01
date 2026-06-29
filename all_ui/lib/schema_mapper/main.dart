import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/schema.dart';
import 'screens/mapping_editor.dart';

class SchemaMapperApp extends StatelessWidget {
  const SchemaMapperApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schema Mapper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SchemaMapperHomePage(),
    );
  }
}

class SchemaMapperHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schema Mapper')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startNewMapping(context),
              child: const Text('Create New Mapping'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadExistingMapping(context),
              child: const Text('Load Existing Mapping'),
            ),
          ],
        ),
      ),
    );
  }

  void _startNewMapping(BuildContext context) {
    // Example predefined schemas for demonstration
    final sourceFields = [
      SchemaField(name: 'id', type: DataType.integer),
      SchemaField(name: 'name', type: DataType.string),
      SchemaField(name: 'email', type: DataType.string),
    ];

    final targetFields = [
      SchemaField(name: 'userId', type: DataType.integer),
      SchemaField(name: 'fullName', type: DataType.string),
      SchemaField(name: 'contactEmail', type: DataType.string),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => SchemaMappingEditorWidget(
              sourceFields: sourceFields,
              targetFields: targetFields,
            ),
      ),
    );
  }

  void _loadExistingMapping(BuildContext context) {
    // Implement loading existing mapping configurations
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Load Mapping - Coming Soon')));
  }
}

void main() {
  runApp(const ProviderScope(child: SchemaMapperApp()));
}


/* write professional, modern & trendy flutter code using riverpod for export & import mapping schema data. So from ones CSV data scheme to others data schema by mapping field with same data type or have option tools to modify or transform for each filed. below the requirement:

* There is two panel, data schema source on the left and data schema target on the right
* visual mapping editor with Drag-and-drop field mapping
* complex transformation options
* Implement advanced type conversion rules
* Create  robust UI for mapping configuration
* Add validation and error handling
* Advanced transformation scripting
* complex type inference
* Import/export schema configurations
* Support for multiple data types
* Custom type transformers
* Automatic mapping suggestions
* Extensible design
* used vanilla code as possible */