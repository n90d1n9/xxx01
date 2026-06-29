// lib/core/enums/data_type.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:math';

enum DataType { string, integer, double, boolean, datetime, unknown }

// lib/core/models/schema_field.dart

class SchemaField {
  String id;
  String? name;
  String? type;
  Map<String, dynamic> transformations;
  String? defaultValue;
  bool? nullable;
  final String? sourceKey;
  final String? targetKey;
  final DataType? sourceType;
  final DataType? targetType;
  final String? transformationScript;

  SchemaField({
    required this.id,
    this.name,
    this.type,
    this.transformations = const {},
    this.defaultValue,
    this.nullable,
    this.sourceKey,
    this.targetKey,
    this.sourceType,
    this.targetType,
    this.transformationScript,
  });

  // Advanced transformation method
  dynamic transform(dynamic value) {
    if (value == null) {
      return nullable == true ? null : defaultValue;
    }

    dynamic processedValue = value;

    // Apply transformations in order
    transformations.forEach((key, config) {
      switch (key) {
        case 'trim':
          processedValue = processedValue.toString().trim();
          break;
        case 'uppercase':
          processedValue = processedValue.toString().toUpperCase();
          break;
        case 'lowercase':
          processedValue = processedValue.toString().toLowerCase();
          break;
        case 'replace':
          processedValue = processedValue.toString().replaceAll(
            config['from'],
            config['to'],
          );
          break;
        case 'regex':
          final regex = RegExp(config['pattern']);
          processedValue = regex.hasMatch(processedValue.toString());
          break;
      }
    });

    // Type conversion
    switch (type) {
      case 'Integer':
        return int.tryParse(processedValue.toString()) ?? defaultValue;
      case 'Double':
        return double.tryParse(processedValue.toString()) ?? defaultValue;
      case 'Boolean':
        return processedValue.toString().toLowerCase() == 'true';
      case 'DateTime':
        return DateTime.tryParse(processedValue.toString());
      default:
        return processedValue.toString();
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

  // JSON serialization methods
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'transformations': transformations,
    'defaultValue': defaultValue,
    'nullable': nullable,
  };

  factory SchemaField.fromJson(Map<String, dynamic> json) => SchemaField(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    transformations: Map<String, dynamic>.from(json['transformations'] ?? {}),
    defaultValue: json['defaultValue'],
    nullable: json['nullable'],
  );
}
/* 
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

  
}
 */
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
        targetRow[rule.targetKey!] = rule.transform(sourceValue);
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
// lib/models/schema_field.dart

// lib/services/type_inferrer.dart
class TypeInferrer {
  static String inferType(List<dynamic> values) {
    // Remove null values for type inference
    final nonNullValues = values.where((v) => v != null).toList();

    if (nonNullValues.isEmpty) return 'String';

    // Check if all values are of the same type
    final firstValue = nonNullValues.first;
    bool allSameType = nonNullValues.every(
      (v) => v.runtimeType == firstValue.runtimeType,
    );

    if (!allSameType) {
      // Try to convert to most specific type
      return _tryConvertToMostSpecificType(nonNullValues);
    }

    // Specific type inference
    if (nonNullValues.every((v) => _isInteger(v))) return 'Integer';
    if (nonNullValues.every((v) => _isDouble(v))) return 'Double';
    if (nonNullValues.every((v) => _isBoolean(v))) return 'Boolean';
    if (nonNullValues.every((v) => _isDateTime(v))) return 'DateTime';

    return 'String';
  }

  static bool _isInteger(dynamic value) {
    return int.tryParse(value.toString()) != null;
  }

  static bool _isDouble(dynamic value) {
    return double.tryParse(value.toString()) != null;
  }

  static bool _isBoolean(dynamic value) {
    return ['true', 'false', '1', '0'].contains(value.toString().toLowerCase());
  }

  static bool _isDateTime(dynamic value) {
    return DateTime.tryParse(value.toString()) != null;
  }

  static String _tryConvertToMostSpecificType(List<dynamic> values) {
    // Attempt to convert to most specific type
    if (values.every((v) => _isInteger(v))) return 'Integer';
    if (values.every((v) => _isDouble(v))) return 'Double';

    return 'String';
  }
}

// lib/services/schema_config_service.dart

class SchemaConfigService {
  // Export schema configuration to JSON file
  Future<void> exportSchemaConfig(
    List<SchemaField> sourceFields,
    List<SchemaField> targetFields,
  ) async {
    final config = {
      'sourceSchema': sourceFields.map((f) => f.toJson()).toList(),
      'targetSchema': targetFields.map((f) => f.toJson()).toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/schema_config.json');

    await file.writeAsString(json.encode(config));
  }

  // Import schema configuration from JSON file
  Future<Map<String, List<SchemaField>>> importSchemaConfig() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/schema_config.json');

      if (!await file.exists()) {
        throw Exception('No saved schema configuration found');
      }

      final contents = await file.readAsString();
      final config = json.decode(contents);

      return {
        'sourceSchema':
            (config['sourceSchema'] as List)
                .map((f) => SchemaField.fromJson(f))
                .toList(),
        'targetSchema':
            (config['targetSchema'] as List)
                .map((f) => SchemaField.fromJson(f))
                .toList(),
      };
    } catch (e) {
      print('Error importing schema config: $e');
      rethrow;
    }
  }
}

// lib/presentation/widgets/draggable_schema_field.dart

class DraggableSchemaField extends StatelessWidget {
  final SchemaField field;
  final bool isSource;

  const DraggableSchemaField({
    Key? key,
    required this.field,
    this.isSource = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<SchemaField>(
      data: field,
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: isSource ? Colors.blue.shade100 : Colors.green.shade100,
          child: Text(
            field.name!,
            style: TextStyle(
              color: isSource ? Colors.blue : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildFieldCard(context)),
      child: _buildFieldCard(context),
    );
  }

  Widget _buildFieldCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          isSource ? Icons.arrow_right : Icons.arrow_back,
          color: isSource ? Colors.blue : Colors.green,
        ),
        title: Text(field.name!),
        subtitle: Text('Type: ${field.type}'),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }
}

// lib/presentation/screens/schema_mapping_screen.dart

class SchemaMappingScreen extends StatefulWidget {
  const SchemaMappingScreen({Key? key}) : super(key: key);

  @override
  _SchemaMappingScreenState createState() => _SchemaMappingScreenState();
}

class _SchemaMappingScreenState extends State<SchemaMappingScreen> {
  List<SchemaField> _sourceFields = [];
  List<SchemaField> _targetFields = [];
  List<Map<String, SchemaField>> _mappedFields = [];

  final SchemaConfigService _configService = SchemaConfigService();

  void _addSourceField() {
    setState(() {
      _sourceFields.add(
        SchemaField(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'New Source Field ${_sourceFields.length + 1}',
          type: 'String',
        ),
      );
    });
  }

  void _addTargetField() {
    setState(() {
      _targetFields.add(
        SchemaField(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'New Target Field ${_targetFields.length + 1}',
          type: 'String',
        ),
      );
    });
  }

  void _handleFieldDrop(SchemaField sourceField, SchemaField targetField) {
    setState(() {
      // Check for existing mapping and remove if exists
      _mappedFields.removeWhere(
        (mapping) =>
            mapping['source']?.id == sourceField.id ||
            mapping['target']?.id == targetField.id,
      );

      // Add new mapping
      _mappedFields.add({'source': sourceField, 'target': targetField});
    });
  }

  void _exportSchemaConfig() async {
    try {
      await _configService.exportSchemaConfig(_sourceFields, _targetFields);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schema configuration exported successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  void _importSchemaConfig() async {
    try {
      final config = await _configService.importSchemaConfig();
      setState(() {
        _sourceFields = config['sourceSchema']!;
        _targetFields = config['targetSchema']!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Schema configuration imported successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema Mapping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _exportSchemaConfig,
            tooltip: 'Export Schema Configuration',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _importSchemaConfig,
            tooltip: 'Import Schema Configuration',
          ),
        ],
      ),
      body: Row(
        children: [
          // Source Fields
          Expanded(
            child: DragTarget<SchemaField>(
              builder: (context, candidateData, rejectedData) {
                return Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addSourceField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Source Field'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _sourceFields.length,
                        itemBuilder: (context, index) {
                          return DraggableSchemaField(
                            field: _sourceFields[index],
                            isSource: true,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              onWillAccept: (data) => data != null,
              onAccept: (sourceField) {
                // This is for target-to-source dragging if needed
              },
            ),
          ),

          // Mapping Area
          Container(
            width: 100,
            color: Colors.grey.shade100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  _mappedFields.map((mapping) {
                    return Card(
                      child: ListTile(
                        title: Text(mapping['source']?.name ?? ''),
                        subtitle: Text('→ ${mapping['target']?.name ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _mappedFields.remove(mapping);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Target Fields
          Expanded(
            child: DragTarget<SchemaField>(
              builder: (context, candidateData, rejectedData) {
                return Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addTargetField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Target Field'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _targetFields.length,
                        itemBuilder: (context, index) {
                          return DragTarget<SchemaField>(
                            builder: (context, candidateData, rejectedData) {
                              return DraggableSchemaField(
                                field: _targetFields[index],
                                isSource: false,
                              );
                            },
                            onWillAccept: (data) => data != null,
                            onAccept: (sourceField) {
                              _handleFieldDrop(
                                sourceField,
                                _targetFields[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              onWillAccept: (data) => data != null,
              onAccept: (sourceField) {
                // This is for source-to-target dragging
              },
            ),
          ),
        ],
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
