// lib/core/enums/data_type.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:math';

enum DataType { string, integer, double, boolean, datetime, unknown }

// lib/core/models/schema_field.dart

@immutable
class SchemaField {
  final String id;
  final String sourceKey;
  final String targetKey;
  final DataType sourceType;
  final DataType targetType;
  final String? transformationScript;

  const SchemaField({
    required this.id,
    required this.sourceKey,
    required this.targetKey,
    required this.sourceType,
    required this.targetType,
    this.transformationScript,
  });

  SchemaField copyWith({
    String? id,
    String? sourceKey,
    String? targetKey,
    DataType? sourceType,
    DataType? targetType,
    String? transformationScript,
  }) {
    return SchemaField(
      id: id ?? this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      targetKey: targetKey ?? this.targetKey,
      sourceType: sourceType ?? this.sourceType,
      targetType: targetType ?? this.targetType,
      transformationScript: transformationScript ?? this.transformationScript,
    );
  }

  // Advanced transformation method using a simple scripting approach
  dynamic transform(dynamic value) {
    if (transformationScript != null) {
      // Simple scripting engine (can be expanded)
      switch (transformationScript) {
        case 'uppercase':
          return value.toString().toUpperCase();
        case 'lowercase':
          return value.toString().toLowerCase();
        case 'trim':
          return value.toString().trim();
      }
    }

    // Default type conversion
    switch (targetType) {
      case DataType.string:
        return value?.toString();
      case DataType.integer:
        return int.tryParse(value.toString()) ?? 0;
      case DataType.double:
        return double.tryParse(value.toString()) ?? 0.0;
      case DataType.boolean:
        return value is bool
            ? value
            : (value.toString().toLowerCase() == 'true');
      case DataType.datetime:
        return DateTime.tryParse(value.toString());
      case DataType.unknown:
        return value;
    }
  }

  // Helper method to infer data type
  static DataType inferDataType(dynamic value) {
    if (value == null) return DataType.unknown;

    if (value is String) {
      if (DateTime.tryParse(value) != null) return DataType.datetime;
      if (int.tryParse(value) != null) return DataType.integer;
      if (double.tryParse(value) != null) return DataType.double;
      return DataType.string;
    }

    if (value is int) return DataType.integer;
    if (value is double) return DataType.double;
    if (value is bool) return DataType.boolean;
    if (value is DateTime) return DataType.datetime;

    return DataType.unknown;
  }
}

// lib/core/services/csv_service.dart

class CsvService {
  Future<List<Map<String, dynamic>>> importCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return [];

    File file = File(result.files.single.path!);
    return parseCsvFile(file);
  }

  List<Map<String, dynamic>> parseCsvFile(File file) {
    final input = file.readAsStringSync();
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(input);

    // Assuming first row is headers
    List<String> headers = csvTable.first.map((e) => e.toString()).toList();

    return csvTable.skip(1).map((row) {
      Map<String, dynamic> rowMap = {};
      for (int i = 0; i < headers.length; i++) {
        rowMap[headers[i]] = row[i];
      }
      return rowMap;
    }).toList();
  }

  void exportToCsv(List<Map<String, dynamic>> data, {String? path}) async {
    if (data.isEmpty) return;

    // Get all unique keys
    Set<String> headers = data.expand((map) => map.keys).toSet();

    // Create CSV rows
    List<List<dynamic>> csvData = [
      headers.toList(), // Header row
      ...data.map((row) => headers.map((header) => row[header] ?? '').toList()),
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    if (path != null) {
      File(path).writeAsStringSync(csv);
    } else {
      String? selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export CSV',
        fileName: 'exported_data.csv',
      );

      if (selectedPath != null) {
        File(selectedPath).writeAsStringSync(csv);
      }
    }
  }
}

// lib/core/providers/schema_providers.dart

class SchemaNotifier extends StateNotifier<List<SchemaField>> {
  SchemaNotifier() : super([]);

  void addSchemaField() {
    final newField = SchemaField(
      id: _generateUniqueId(),
      sourceKey: '',
      targetKey: '',
      sourceType: DataType.unknown,
      targetType: DataType.unknown,
    );
    state = [...state, newField];
  }

  void updateSchemaField(String id, SchemaField updatedField) {
    state = [
      for (final field in state)
        if (field.id == id) updatedField else field,
    ];
  }

  void removeSchemaField(String id) {
    state = state.where((field) => field.id != id).toList();
  }

  void inferTypesFromData(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return;

    // Get all possible keys from the data
    Set<String> allKeys = data.expand((map) => map.keys).toSet();

    // Update state with inferred types
    state =
        allKeys.map((key) {
          // Find first non-null value to infer type
          dynamic firstValue =
              data.firstWhere((map) => map[key] != null, orElse: () => {})[key];

          return SchemaField(
            id: _generateUniqueId(),
            sourceKey: key,
            targetKey: key,
            sourceType: SchemaField.inferDataType(firstValue),
            targetType: SchemaField.inferDataType(firstValue),
          );
        }).toList();
  }

  // Utility method to generate unique IDs
  String _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}

// Providers
final csvServiceProvider = Provider((ref) => CsvService());

final schemaNotifierProvider =
    StateNotifierProvider<SchemaNotifier, List<SchemaField>>((ref) {
      return SchemaNotifier();
    });

// lib/core/services/schema_mapper_service.dart
class SchemaMapperService {
  List<Map<String, dynamic>> mapSchemas({
    required List<Map<String, dynamic>> sourceData,
    required List<SchemaField> mappingRules,
  }) {
    return sourceData.map((sourceRow) {
      Map<String, dynamic> targetRow = {};

      for (var rule in mappingRules) {
        // Get source value
        dynamic sourceValue = sourceRow[rule.sourceKey];

        // Transform and map to target key
        targetRow[rule.targetKey] = rule.transform(sourceValue);
      }

      return targetRow;
    }).toList();
  }
}

// lib/presentation/screens/schema_mapping_screen.dart

class SchemaMappingScreen extends ConsumerStatefulWidget {
  const SchemaMappingScreen({Key? key}) : super(key: key);

  @override
  _SchemaMappingScreenState createState() => _SchemaMappingScreenState();
}

class _SchemaMappingScreenState extends ConsumerState<SchemaMappingScreen> {
  List<Map<String, dynamic>> _importedData = [];

  void _importCsv() async {
    final csvService = ref.read(csvServiceProvider);
    final data = await csvService.importCsv();

    setState(() {
      _importedData = data;
    });

    // Automatically infer schema
    ref.read(schemaNotifierProvider.notifier).inferTypesFromData(data);
  }

  void _exportCsv() {
    final csvService = ref.read(csvServiceProvider);
    final schemaFields = ref.read(schemaNotifierProvider);

    // Map data using current schema
    final mappedData = SchemaMapperService().mapSchemas(
      sourceData: _importedData,
      mappingRules: schemaFields,
    );

    csvService.exportToCsv(mappedData);
  }

  @override
  Widget build(BuildContext context) {
    final schemaFields = ref.watch(schemaNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema Mapper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importCsv,
          ),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportCsv),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: schemaFields.length,
              itemBuilder: (context, index) {
                final field = schemaFields[index];
                return _buildSchemaFieldCard(field);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed:
                  () =>
                      ref
                          .read(schemaNotifierProvider.notifier)
                          .addSchemaField(),
              child: const Text('Add Mapping Rule'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaFieldCard(SchemaField field) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Source Field Dropdown
            DropdownButtonFormField<String>(
              value: field.sourceKey,
              hint: const Text('Source Field'),
              items:
                  _importedData.isNotEmpty
                      ? _importedData.first.keys
                          .map(
                            (key) =>
                                DropdownMenuItem(value: key, child: Text(key)),
                          )
                          .toList()
                      : [],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(schemaNotifierProvider.notifier)
                      .updateSchemaField(
                        field.id,
                        field.copyWith(sourceKey: value),
                      );
                }
              },
            ),
            // Target Field Input
            TextFormField(
              initialValue: field.targetKey,
              decoration: const InputDecoration(labelText: 'Target Field Name'),
              onChanged: (value) {
                ref
                    .read(schemaNotifierProvider.notifier)
                    .updateSchemaField(
                      field.id,
                      field.copyWith(targetKey: value),
                    );
              },
            ),
            // Source Type Dropdown
            DropdownButtonFormField<DataType>(
              value: field.sourceType,
              hint: const Text('Source Type'),
              items:
                  DataType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(schemaNotifierProvider.notifier)
                      .updateSchemaField(
                        field.id,
                        field.copyWith(sourceType: value),
                      );
                }
              },
            ),
            // Target Type Dropdown
            DropdownButtonFormField<DataType>(
              value: field.targetType,
              hint: const Text('Target Type'),
              items:
                  DataType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(schemaNotifierProvider.notifier)
                      .updateSchemaField(
                        field.id,
                        field.copyWith(targetType: value),
                      );
                }
              },
            ),
            // Remove Field Button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  () => ref
                      .read(schemaNotifierProvider.notifier)
                      .removeSchemaField(field.id),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/main.dart

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schema Mapper',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SchemaMappingScreen(),
    );
  }
}
