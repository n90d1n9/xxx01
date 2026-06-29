import '../cel_expression.dart';
import 'filter_transform_definition.dart';
import 'transform_operation.dart';

class FilterTransformNodeExecutor {
  final FilterTransformNodeDefinition definition;

  FilterTransformNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    try {
      dynamic result;

      switch (definition.operation) {
        case TransformOperation.filter:
          result = _executeFilter(input);
          break;
        case TransformOperation.map:
          result = _executeMap(input);
          break;
        case TransformOperation.aggregate:
          result = _executeAggregate(input);
          break;
        case TransformOperation.groupBy:
          result = _executeGroupBy(input);
          break;
        case TransformOperation.sort:
          result = _executeSort(input);
          break;
        case TransformOperation.distinct:
          result = _executeDistinct(input);
          break;
      }

      return {
        'success': true,
        'output_port': 'transformed',
        'data': result,
        'operation': definition.operation.name,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString(), 'data': input};
    }
  }

  dynamic _executeFilter(Map<String, dynamic> input) {
    if (definition.filterCondition == null) return input;

    if (input.containsKey('items') && input['items'] is List) {
      final items = input['items'] as List;
      final filtered = items.where((item) {
        try {
          final cel = CELExpression(definition.filterCondition!);
          return cel.evaluate(
            item is Map<String, dynamic> ? item : {'value': item},
          );
        } catch (e) {
          return false;
        }
      }).toList();

      return {...input, 'items': filtered, 'filtered_count': filtered.length};
    }

    // Filter single object
    final cel = CELExpression(definition.filterCondition!);
    if (cel.evaluate(input)) {
      return input;
    }

    return {'filtered': true, 'match': false};
  }

  dynamic _executeMap(Map<String, dynamic> input) {
    if (definition.fieldMappings == null) return input;

    if (input.containsKey('items') && input['items'] is List) {
      final items = input['items'] as List;
      final mapped = items.map((item) {
        if (item is! Map<String, dynamic>) return item;
        return _mapFields(item);
      }).toList();

      return {...input, 'items': mapped};
    }

    // Map single object
    return _mapFields(input);
  }

  Map<String, dynamic> _mapFields(Map<String, dynamic> item) {
    final result = <String, dynamic>{};

    for (final entry in definition.fieldMappings!.entries) {
      final sourcePath = entry.value;
      final targetKey = entry.key;

      // Support nested paths like "user.name"
      if (sourcePath.contains('.')) {
        final parts = sourcePath.split('.');
        dynamic value = item;
        for (final part in parts) {
          if (value is Map && value.containsKey(part)) {
            value = value[part];
          } else {
            value = null;
            break;
          }
        }
        result[targetKey] = value;
      } else {
        result[targetKey] = item[sourcePath];
      }
    }

    return result;
  }

  dynamic _executeAggregate(Map<String, dynamic> input) {
    if (definition.aggregateField == null ||
        definition.aggregateFunction == null) {
      return input;
    }

    if (!input.containsKey('items') || input['items'] is! List) {
      return {'error': 'No items array found for aggregation'};
    }

    final items = input['items'] as List;
    final field = definition.aggregateField!;
    final function = definition.aggregateFunction!;

    final values = items
        .where((item) => item is Map && item.containsKey(field))
        .map((item) => item[field])
        .where((v) => v is num)
        .cast<num>()
        .toList();

    if (values.isEmpty) {
      return {...input, 'aggregate_result': null, 'count': 0};
    }

    dynamic result;
    switch (function.toLowerCase()) {
      case 'sum':
        result = values.reduce((a, b) => a + b);
        break;
      case 'count':
        result = values.length;
        break;
      case 'avg':
        result = values.reduce((a, b) => a + b) / values.length;
        break;
      case 'min':
        result = values.reduce((a, b) => a < b ? a : b);
        break;
      case 'max':
        result = values.reduce((a, b) => a > b ? a : b);
        break;
      default:
        result = null;
    }

    return {
      ...input,
      'aggregate_result': result,
      'aggregate_function': function,
      'aggregate_field': field,
      'count': values.length,
    };
  }

  dynamic _executeGroupBy(Map<String, dynamic> input) {
    if (definition.groupByField == null) return input;

    if (!input.containsKey('items') || input['items'] is! List) {
      return {'error': 'No items array found for grouping'};
    }

    final items = input['items'] as List;
    final field = definition.groupByField!;
    final groups = <String, List>{};

    for (final item in items) {
      if (item is! Map || !item.containsKey(field)) continue;

      final key = item[field].toString();
      groups.putIfAbsent(key, () => []).add(item);
    }

    return {
      ...input,
      'groups': groups,
      'group_count': groups.length,
      'grouped_by': field,
    };
  }

  dynamic _executeSort(Map<String, dynamic> input) {
    if (definition.sortField == null) return input;

    if (!input.containsKey('items') || input['items'] is! List) {
      return {'error': 'No items array found for sorting'};
    }

    final items = List.from(input['items'] as List);
    final field = definition.sortField!;

    items.sort((a, b) {
      if (a is! Map || b is! Map) return 0;

      final aVal = a[field];
      final bVal = b[field];

      if (aVal == null) return 1;
      if (bVal == null) return -1;

      int comparison;
      if (aVal is num && bVal is num) {
        comparison = aVal.compareTo(bVal);
      } else {
        comparison = aVal.toString().compareTo(bVal.toString());
      }

      return definition.sortAscending ? comparison : -comparison;
    });

    return {
      ...input,
      'items': items,
      'sorted_by': field,
      'sort_order': definition.sortAscending ? 'ascending' : 'descending',
    };
  }

  dynamic _executeDistinct(Map<String, dynamic> input) {
    if (!input.containsKey('items') || input['items'] is! List) {
      return {'error': 'No items array found for distinct operation'};
    }

    final items = input['items'] as List;
    final seen = <String>{};
    final distinct = [];

    for (final item in items) {
      final key = item.toString();
      if (!seen.contains(key)) {
        seen.add(key);
        distinct.add(item);
      }
    }

    return {
      ...input,
      'items': distinct,
      'original_count': items.length,
      'distinct_count': distinct.length,
      'duplicates_removed': items.length - distinct.length,
    };
  }
}
