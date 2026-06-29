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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Source Schema Panel
              _buildSchemaPanel(
                context: context,
                title: 'Source Schema',
                color: Colors.blue.shade50,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.upload),
                    tooltip: 'Import Source CSV',
                    onPressed: () => _importSourceSchema(),
                  ),
                ],
                child: _buildSourceSchemaView(),
              ),

              // Mapping Panel
              _buildMappingPanel(context),

              // Target Schema Panel
              _buildSchemaPanel(
                context: context,
                title: 'Target Schema',
                color: Colors.green.shade50,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export Target CSV',
                    onPressed: () => _exportTargetSchema(),
                  ),
                ],
                child: _buildTargetSchemaView(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _performMapping,
        icon: const Icon(Icons.shuffle),
        label: const Text('Map Schemas'),
      ),
    );
  }

  Widget _buildSchemaPanel({
    required BuildContext context,
    required String title,
    required Color color,
    required List<Widget> actions,
    required Widget child,
  }) {
    return Expanded(
      child: Container(
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              title: Text(title),
              backgroundColor: color,
              actions: actions,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSchemaView() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Source schema preview or empty state
          const Expanded(
            child: Center(
              child: Text(
                'Import Source Schema',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fields: 0', style: Theme.of(context).textTheme.bodySmall),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                  onPressed: () {
                    // TODO: Implement add field logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingPanel(BuildContext context) {
    return Container(
      width: 100,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.shuffle, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    'Map Fields',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _performMapping,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.arrow_right),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSchemaView() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Target schema preview or empty state
          const Expanded(
            child: Center(
              child: Text(
                'Define Target Schema',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fields: 0', style: Theme.of(context).textTheme.bodySmall),
                TextButton.icon(
                  icon: const Icon(Icons.abc),
                  label: const Text('Add Field'),
                  onPressed: () {
                    // TODO: Implement add field logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _importSourceSchema() {
    // TODO: Implement source schema import
  }

  void _exportTargetSchema() {
    // TODO: Implement target schema export
  }

  void _performMapping() {
    // TODO: Implement schema mapping logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mapping in progress...')));
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
