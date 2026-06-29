// Data Mapping
import 'package:flutter_riverpod/legacy.dart';

class DataMapping {
  final String sourceField;
  final String targetField;
  final String? transformation;
  final String? defaultValue;

  DataMapping({
    required this.sourceField,
    required this.targetField,
    this.transformation,
    this.defaultValue,
  });

  DataMapping copyWith({
    String? sourceField,
    String? targetField,
    String? transformation,
    String? defaultValue,
  }) {
    return DataMapping(
      sourceField: sourceField ?? this.sourceField,
      targetField: targetField ?? this.targetField,
      transformation: transformation ?? this.transformation,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceField': sourceField,
      'targetField': targetField,
      if (transformation != null) 'transformation': transformation,
      if (defaultValue != null) 'defaultValue': defaultValue,
    };
  }
}

final dataMappingsProvider = StateProvider<List<DataMapping>>((ref) => []);
