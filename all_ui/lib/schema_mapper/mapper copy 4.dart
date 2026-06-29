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
// lib/presentation/widgets/schema_field_card.dart

class SchemaFieldCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> field;
  final bool isSource;
  final Function(Map<String, dynamic>) onFieldUpdate;

  const SchemaFieldCard({
    Key? key,
    required this.field,
    this.isSource = true,
    required this.onFieldUpdate,
  }) : super(key: key);

  @override
  _SchemaFieldCardState createState() => _SchemaFieldCardState();
}

class _SchemaFieldCardState extends ConsumerState<SchemaFieldCard> {
  late Map<String, dynamic> _fieldData;

  @override
  void initState() {
    super.initState();
    _fieldData = Map.from(widget.field);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          widget.isSource ? Icons.arrow_right : Icons.arrow_left,
          color: widget.isSource ? Colors.blue : Colors.green,
        ),
        title: Text(_fieldData['name'] ?? 'Unnamed Field'),
        subtitle: Text('Type: ${_fieldData['type'] ?? 'Unknown'}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Field Name Input
                TextFormField(
                  initialValue: _fieldData['name'],
                  decoration: InputDecoration(
                    labelText: 'Field Name',
                    prefixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _fieldData['name'] = value;
                    });
                    widget.onFieldUpdate(_fieldData);
                  },
                ),
                const SizedBox(height: 16),

                // Data Type Dropdown
                DropdownButtonFormField<String>(
                  value: _fieldData['type'],
                  decoration: InputDecoration(
                    labelText: 'Data Type',
                    prefixIcon: Icon(Icons.data_array),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items:
                      ['String', 'Integer', 'Double', 'Boolean', 'DateTime']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _fieldData['type'] = value;
                    });
                    widget.onFieldUpdate(_fieldData);
                  },
                ),
                const SizedBox(height: 16),

                // Transformation Options
                ExpansionTile(
                  title: const Text('Transformation'),
                  leading: Icon(Icons.shuffle),
                  children: [
                    // Add transformation options
                    CheckboxListTile(
                      title: const Text('Trim Whitespace'),
                      value: _fieldData['trim'] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          _fieldData['trim'] = value ?? false;
                        });
                        widget.onFieldUpdate(_fieldData);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Convert to Uppercase'),
                      value: _fieldData['uppercase'] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          _fieldData['uppercase'] = value ?? false;
                        });
                        widget.onFieldUpdate(_fieldData);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/presentation/screens/schema_mapping_screen.dart

class SchemaMappingScreen extends ConsumerStatefulWidget {
  const SchemaMappingScreen({Key? key}) : super(key: key);

  @override
  _SchemaMappingScreenState createState() => _SchemaMappingScreenState();
}

class _SchemaMappingScreenState extends ConsumerState<SchemaMappingScreen> {
  List<Map<String, dynamic>> _sourceFields = [];
  List<Map<String, dynamic>> _targetFields = [];
  List<Map<String, dynamic>> _mappedFields = [];

  void _addSourceField() {
    setState(() {
      _sourceFields.add({
        'name': 'New Field ${_sourceFields.length + 1}',
        'type': 'String',
      });
    });
  }

  void _addTargetField() {
    setState(() {
      _targetFields.add({
        'name': 'New Field ${_targetFields.length + 1}',
        'type': 'String',
      });
    });
  }

  void _performMapping() {
    // Implement advanced mapping logic
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mapping Preview'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _mappedFields.map((field) {
                      return ListTile(
                        title: Text('Source: ${field['source']}'),
                        subtitle: Text('Target: ${field['target']}'),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement export logic
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mapping exported successfully'),
                    ),
                  );
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Source Schema Panel
              Expanded(
                child: Container(
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text('Source Schema'),
                        backgroundColor: Colors.blue.shade50,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addSourceField,
                            tooltip: 'Add Source Field',
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _sourceFields.length,
                          itemBuilder: (context, index) {
                            return SchemaFieldCard(
                              field: _sourceFields[index],
                              isSource: true,
                              onFieldUpdate: (updatedField) {
                                setState(() {
                                  _sourceFields[index] = updatedField;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Mapping Controls
              Container(
                width: 100,
                color: Colors.grey.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      iconSize: 48,
                      color: Theme.of(context).primaryColor,
                      onPressed: _performMapping,
                      tooltip: 'Map Fields',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mapping\nControls',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Target Schema Panel
              Expanded(
                child: Container(
                  color: Colors.green.shade50,
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text('Target Schema'),
                        backgroundColor: Colors.green.shade50,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTargetField,
                            tooltip: 'Add Target Field',
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _targetFields.length,
                          itemBuilder: (context, index) {
                            return SchemaFieldCard(
                              field: _targetFields[index],
                              isSource: false,
                              onFieldUpdate: (updatedField) {
                                setState(() {
                                  _targetFields[index] = updatedField;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
