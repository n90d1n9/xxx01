import 'package:flutter_riverpod/legacy.dart';

import '../models/data_schema.dart';
import '../models/field_mapping.dart';
import '../models/schema_mapping_config.dart';
import '../models/transformation_rule.dart';
import '../models/transformation_rule_set.dart';

// Schema Manager
class SchemaManager extends StateNotifier<List<DataSchema>> {
  SchemaManager() : super([]);

  void addSchema(DataSchema schema) {
    state = [...state, schema];
  }

  void removeSchema(String schemaId) {
    state = state.where((schema) => schema.id != schemaId).toList();
  }

  DataSchema? getSchemaById(String schemaId) {
    try {
      return state.firstWhere((schema) => schema.id == schemaId);
    } catch (e) {
      return null;
    }
  }
}

final schemaManagerProvider =
    StateNotifierProvider<SchemaManager, List<DataSchema>>((ref) {
      return SchemaManager();
    });

// Mapping Manager
class MappingManager extends StateNotifier<SchemaMappingConfiguration?> {
  MappingManager() : super(null);

  void createMapping(DataSchema sourceSchema, DataSchema targetSchema) {
    final suggestedMappings = _generateAutoMappings(sourceSchema, targetSchema);

    state = SchemaMappingConfiguration(
      sourceSchema: sourceSchema,
      targetSchema: targetSchema,
      fieldMappings: suggestedMappings,
    );
  }

  List<FieldMapping> _generateAutoMappings(
    DataSchema sourceSchema,
    DataSchema targetSchema,
  ) {
    return targetSchema.fields.map((targetField) {
      final matchingSourceField = sourceSchema.fields.firstWhere(
        (sourceField) =>
            sourceField.name.toLowerCase() == targetField.name.toLowerCase() &&
            sourceField.type == targetField.type,
        orElse: () => targetField,
      );

      return FieldMapping(
        sourceField: matchingSourceField,
        targetField: targetField,
        strategy: MappingStrategy.direct,
      );
    }).toList();
  }

  void updateFieldMapping(FieldMapping mapping) {
    if (state == null) return;

    final updatedMappings =
        state!.fieldMappings.map((existingMapping) {
          return existingMapping.sourceField.id == mapping.sourceField.id
              ? mapping
              : existingMapping;
        }).toList();

    state = state!.copyWith(fieldMappings: updatedMappings);
  }
}

final mappingManagerProvider =
    StateNotifierProvider<MappingManager, SchemaMappingConfiguration?>((ref) {
      return MappingManager();
    });

// Transformation Manager
class TransformationManager extends StateNotifier<TransformationRuleSet> {
  TransformationManager() : super(TransformationRuleSet(rules: []));

  void addTransformationRule(TransformationRule rule) {
    state = state.copyWith(rules: [...state.rules, rule]);
  }

  void removeTransformationRule(String ruleId) {
    state = state.copyWith(
      rules: state.rules.where((rule) => rule.id != ruleId).toList(),
    );
  }
}

final transformationManagerProvider =
    StateNotifierProvider<TransformationManager, TransformationRuleSet>((ref) {
      return TransformationManager();
    });
