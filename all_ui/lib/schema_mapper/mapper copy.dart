// lib/models/schema_field.dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

enum DataType { string, integer, double, boolean, datetime }

class SchemaField {
  final String sourceKey;
  final String targetKey;
  final DataType sourceType;
  final DataType targetType;
  final dynamic Function(dynamic)? transformer;

  SchemaField({
    required this.sourceKey,
    required this.targetKey,
    required this.sourceType,
    required this.targetType,
    this.transformer,
  });

  // Transform method to convert between different data types
  dynamic transform(dynamic value) {
    if (transformer != null) {
      return transformer!(value);
    }

    // Default type conversion logic
    switch (targetType) {
      case DataType.string:
        return value.toString();
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
    }
  }
}

// lib/services/csv_parser.dart

class CsvParser {
  static List<Map<String, dynamic>> parseFromFile(File file) {
    final input = file.readAsStringSync();
    List<List<dynamic>> csvTable = CsvToListConverter().convert(input);

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

  static void exportToCsv(List<Map<String, dynamic>> data, File outputFile) {
    if (data.isEmpty) return;

    // Get all unique keys
    Set<String> headers = data.expand((map) => map.keys).toSet();

    // Create CSV rows
    List<List<dynamic>> csvData = [
      headers.toList(), // Header row
      ...data.map((row) => headers.map((header) => row[header] ?? '').toList()),
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    outputFile.writeAsStringSync(csv);
  }
}

// lib/services/schema_mapper.dart

class SchemaMapper {
  final List<SchemaField> mappingRules;

  SchemaMapper({required this.mappingRules});

  List<Map<String, dynamic>> mapSchemas(List<Map<String, dynamic>> sourceData) {
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

  // Create a mapping suggestion based on data type compatibility
  static List<SchemaField> suggestMappings(
    List<Map<String, dynamic>> sourceSchema,
    List<Map<String, dynamic>> targetSchema,
  ) {
    List<SchemaField> suggestions = [];

    for (var sourceField in sourceSchema) {
      var matchingTargetField = targetSchema.firstWhere(
        (target) => _isTypeCompatible(sourceField['type'], target['type']),
        orElse: () => {},
      );

      if (matchingTargetField != null) {
        suggestions.add(
          SchemaField(
            sourceKey: sourceField['name'],
            targetKey: matchingTargetField['name'],
            sourceType: _parseDataType(sourceField['type']),
            targetType: _parseDataType(matchingTargetField['type']),
          ),
        );
      }
    }

    return suggestions;
  }

  static bool _isTypeCompatible(String sourceType, String targetType) {
    // Simple type compatibility logic
    final compatibilityMap = {
      'string': ['string', 'text'],
      'integer': ['integer', 'number', 'long'],
      'double': ['double', 'float', 'number'],
      'boolean': ['boolean', 'bit'],
      'datetime': ['date', 'timestamp', 'datetime'],
    };

    return compatibilityMap.entries.any(
      (entry) =>
          entry.key == sourceType.toLowerCase() &&
          entry.value.contains(targetType.toLowerCase()),
    );
  }

  static DataType _parseDataType(String type) {
    type = type.toLowerCase();
    if (type.contains('string') || type.contains('text'))
      return DataType.string;
    if (type.contains('int') || type.contains('long')) return DataType.integer;
    if (type.contains('double') || type.contains('float'))
      return DataType.double;
    if (type.contains('bool') || type.contains('bit')) return DataType.boolean;
    if (type.contains('date') || type.contains('time'))
      return DataType.datetime;
    return DataType.string; // Default fallback
  }
}

// lib/screens/schema_mapping_screen.dart

class SchemaMappingScreen extends StatefulWidget {
  const SchemaMappingScreen({super.key});

  @override
  _SchemaMappingScreenState createState() => _SchemaMappingScreenState();
}

class _SchemaMappingScreenState extends State<SchemaMappingScreen> {
  List<SchemaField> _mappingRules = [];

  void _addMappingRule() {
    // Implement UI to add mapping rules dynamically
    setState(() {
      _mappingRules.add(
        SchemaField(
          sourceKey: '',
          targetKey: '',
          sourceType: DataType.string,
          targetType: DataType.string,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schema Mapping Tool'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _addMappingRule),
        ],
      ),
      body: ListView.builder(
        itemCount: _mappingRules.length,
        itemBuilder: (context, index) {
          return _buildMappingRuleCard(_mappingRules[index]);
        },
      ),
    );
  }

  Widget _buildMappingRuleCard(SchemaField rule) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Implement dropdowns for source/target fields and types
            // Add transformer configuration
          ],
        ),
      ),
    );
  }
}

// Example usage in main.dart
void demonstrateSchemaMapping() {
  // Sample source and target data
  List<Map<String, dynamic>> sourceData = [
    {'user_id': '1', 'full_name': 'John Doe', 'age': '30'},
  ];

  // Define mapping rules
  List<SchemaField> mappingRules = [
    SchemaField(
      sourceKey: 'user_id',
      targetKey: 'id',
      sourceType: DataType.string,
      targetType: DataType.integer,
      transformer: (value) => int.parse(value),
    ),
    SchemaField(
      sourceKey: 'full_name',
      targetKey: 'name',
      sourceType: DataType.string,
      targetType: DataType.string,
    ),
  ];

  // Create mapper
  SchemaMapper mapper = SchemaMapper(mappingRules: mappingRules);

  // Map data
  List<Map<String, dynamic>> transformedData = mapper.mapSchemas(sourceData);
}

void main(List<String> args) {
  runApp(const MaterialApp(home: SchemaMappingScreen()));
}
