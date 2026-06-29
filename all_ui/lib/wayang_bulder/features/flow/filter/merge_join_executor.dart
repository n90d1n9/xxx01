import 'merge_join_definition.dart';
import 'merge_strategy.dart';

class MergeJoinNodeExecutor {
  final MergeJoinNodeDefinition definition;
  final List<Map<String, dynamic>?> _receivedInputs;
  DateTime? _firstInputTime;

  MergeJoinNodeExecutor(this.definition)
    : _receivedInputs = List.filled(definition.inputCount, null);

  Future<Map<String, dynamic>> addInput(
    int inputIndex,
    Map<String, dynamic> data,
  ) async {
    if (inputIndex < 0 || inputIndex >= definition.inputCount) {
      return {'success': false, 'error': 'Invalid input index: $inputIndex'};
    }

    _receivedInputs[inputIndex] = data;
    _firstInputTime ??= DateTime.now();

    // Check if ready to merge
    if (_isReadyToMerge()) {
      return await _executeMerge();
    }

    // Check timeout
    if (definition.timeout != null && _firstInputTime != null) {
      final elapsed = DateTime.now().difference(_firstInputTime!);
      if (elapsed > definition.timeout!) {
        return await _executeMerge(); // Merge with available data
      }
    }

    return {
      'success': true,
      'waiting': true,
      'received': _receivedInputs.where((i) => i != null).length,
      'total': definition.inputCount,
    };
  }

  bool _isReadyToMerge() {
    if (definition.waitForAll) {
      return _receivedInputs.every((input) => input != null);
    } else {
      return _receivedInputs.any((input) => input != null);
    }
  }

  Future<Map<String, dynamic>> _executeMerge() async {
    final validInputs = _receivedInputs
        .where((i) => i != null)
        .cast<Map<String, dynamic>>()
        .toList();

    if (validInputs.isEmpty) {
      return {'success': false, 'error': 'No inputs received'};
    }

    Map<String, dynamic> merged;

    switch (definition.strategy) {
      case MergeStrategy.union:
        merged = _mergeUnion(validInputs);
        break;
      case MergeStrategy.intersection:
        merged = _mergeIntersection(validInputs);
        break;
      case MergeStrategy.leftJoin:
        merged = _mergeLeftJoin(validInputs);
        break;
      case MergeStrategy.rightJoin:
        merged = _mergeRightJoin(validInputs);
        break;
      case MergeStrategy.custom:
        merged = _mergeCustom(validInputs);
        break;
    }

    // Reset for next merge
    _receivedInputs.fillRange(0, _receivedInputs.length, null);
    _firstInputTime = null;

    return {
      'success': true,
      'output_port': 'merged',
      'data': merged,
      'inputs_merged': validInputs.length,
    };
  }

  Map<String, dynamic> _mergeUnion(List<Map<String, dynamic>> inputs) {
    final result = <String, dynamic>{};
    for (final input in inputs) {
      result.addAll(input);
    }
    return result;
  }

  Map<String, dynamic> _mergeIntersection(List<Map<String, dynamic>> inputs) {
    if (inputs.isEmpty) return {};

    final result = <String, dynamic>{};
    final firstKeys = inputs.first.keys.toSet();

    for (final key in firstKeys) {
      if (inputs.every((input) => input.containsKey(key))) {
        result[key] = inputs.last[key]; // Use last value
      }
    }

    return result;
  }

  Map<String, dynamic> _mergeLeftJoin(List<Map<String, dynamic>> inputs) {
    if (inputs.isEmpty) return {};
    final result = Map<String, dynamic>.from(inputs.first);

    for (var i = 1; i < inputs.length; i++) {
      for (final entry in inputs[i].entries) {
        result.putIfAbsent(entry.key, () => entry.value);
      }
    }

    return result;
  }

  Map<String, dynamic> _mergeRightJoin(List<Map<String, dynamic>> inputs) {
    if (inputs.isEmpty) return {};
    final result = <String, dynamic>{};

    for (final input in inputs) {
      result.addAll(input);
    }

    return result;
  }

  Map<String, dynamic> _mergeCustom(List<Map<String, dynamic>> inputs) {
    final result = <String, dynamic>{};

    // Apply custom merge rules
    for (final entry in definition.mergeRules.entries) {
      final fieldName = entry.key;
      final rule = entry.value;

      if (rule == 'first') {
        for (final input in inputs) {
          if (input.containsKey(fieldName)) {
            result[fieldName] = input[fieldName];
            break;
          }
        }
      } else if (rule == 'last') {
        for (final input in inputs.reversed) {
          if (input.containsKey(fieldName)) {
            result[fieldName] = input[fieldName];
            break;
          }
        }
      } else if (rule == 'concat') {
        final values = inputs
            .where((i) => i.containsKey(fieldName))
            .map((i) => i[fieldName])
            .toList();
        result[fieldName] = values;
      }
    }

    return result;
  }

  void reset() {
    _receivedInputs.fillRange(0, _receivedInputs.length, null);
    _firstInputTime = null;
  }
}
