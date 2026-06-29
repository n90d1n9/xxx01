import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/expression_state.dart';
import '../service/cel_evaluator.dart';
import '../service/cel_exception.dart';
import '../state/expression_provider.dart';

class TestExpressionDialog extends ConsumerStatefulWidget {
  const TestExpressionDialog({super.key});

  @override
  ConsumerState<TestExpressionDialog> createState() =>
      _TestExpressionDialogState();
}

class _TestExpressionDialogState extends ConsumerState<TestExpressionDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _inputErrors = {};
  dynamic _evaluationResult;
  bool _isEvaluating = false;
  String? _evaluationError;

  @override
  Widget build(BuildContext context) {
    final expressionState = ref.watch(expressionProvider);
    final contextVariables = expressionState.context.variables;
    final expression = expressionState.script;

    return AlertDialog(
      title: const Text('Test Expression'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expression display
            _buildExpressionSection(expression),
            const SizedBox(height: 16),

            // Input values section
            _buildInputSection(contextVariables),

            // Result section
            if (_evaluationResult != null || _evaluationError != null) ...[
              const SizedBox(height: 16),
              _buildResultSection(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _isEvaluating ? null : _evaluateExpression,
          child: _isEvaluating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Evaluate'),
        ),
      ],
    );
  }

  Widget _buildExpressionSection(String expression) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expression:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            expression.isEmpty ? '(empty expression)' : expression,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(Map<String, dynamic> contextVariables) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Values:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        if (contextVariables.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No context variables defined',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        else
          ...contextVariables.keys.map((varName) {
            _controllers.putIfAbsent(varName, () => TextEditingController());
            final error = _inputErrors[varName];
            final defaultValue = contextVariables[varName];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controllers[varName],
                    decoration: InputDecoration(
                      labelText: '$varName (${_getTypeName(defaultValue)})',
                      hintText: _getDefaultValueHint(defaultValue),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: error,
                      errorMaxLines: 2,
                    ),
                    onChanged: (_) {
                      // Clear error when user starts typing
                      if (_inputErrors.containsKey(varName)) {
                        setState(() {
                          _inputErrors.remove(varName);
                        });
                      }
                    },
                  ),
                  if (defaultValue != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Default: ${defaultValue.toString()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Result:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _evaluationError != null ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _evaluationError != null
                  ? Colors.red[300]!
                  : Colors.green[300]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_evaluationError != null)
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Evaluation Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Evaluation Successful',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              SelectableText(
                _evaluationError ?? _formatResult(_evaluationResult),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: _evaluationError != null
                      ? Colors.red[700]
                      : Colors.green[700],
                ),
              ),
              if (_evaluationResult != null && _evaluationError == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Type: ${_evaluationResult.runtimeType}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTypeName(dynamic value) {
    if (value == null) return 'dynamic';
    return value.runtimeType.toString();
  }

  String _getDefaultValueHint(dynamic defaultValue) {
    if (defaultValue == null) return 'Enter value...';
    return 'e.g., ${defaultValue.toString()}';
  }

  String _formatResult(dynamic result) {
    if (result == null) return 'null';
    if (result is String) return '"$result"';
    if (result is List) return result.toString();
    if (result is Map) return result.toString();
    return result.toString();
  }

  Future<void> _evaluateExpression() async {
    final expressionState = ref.read(expressionProvider);
    final expression = expressionState.script;
    final contextVariables = expressionState.context.variables;

    if (expression.trim().isEmpty) {
      setState(() {
        _evaluationError = 'Expression is empty';
        _evaluationResult = null;
      });
      return;
    }

    // Validate inputs and build evaluation context
    final inputValues = <String, dynamic>{};
    final errors = <String, String>{};

    for (final varName in contextVariables.keys) {
      final controller = _controllers[varName];
      final value = controller?.text.trim() ?? '';
      final variableType = contextVariables[varName];

      try {
        if (value.isEmpty) {
          // For Object types, provide default mock objects
          if (variableType == Object) {
            inputValues[varName] = _createMockObject(varName);
          } else {
            errors[varName] = 'Value is required';
          }
        } else {
          // Parse input based on variable type
          inputValues[varName] = _parseInputValue(value, variableType);
        }
      } catch (e) {
        errors[varName] =
            'Invalid format for ${_getTypeName(variableType)}: ${e.toString()}';
      }
    }

    if (errors.isNotEmpty) {
      setState(() {
        _inputErrors.clear();
        _inputErrors.addAll(errors);
        _evaluationError = 'Please fix input errors';
        _evaluationResult = null;
      });
      return;
    }

    setState(() {
      _isEvaluating = true;
      _evaluationError = null;
      _evaluationResult = null;
      _inputErrors.clear();
    });

    try {
      // Use the actual CEL evaluator
      final evaluator = CELEvaluator();

      // Register available functions from context
      _registerAvailableFunctions(evaluator, expressionState);

      // Evaluate the expression
      final result = evaluator.evaluate(expression, inputValues);

      setState(() {
        _evaluationResult = result;
        _evaluationError = null;
      });
    } on CELEvaluationException catch (e) {
      setState(() {
        _evaluationError = 'CEL Evaluation Error: ${e.message}';
        if (e.expression != null) {
          _evaluationError =
              '${_evaluationError ?? ''}\nExpression: ${e.expression}';
        }
        _evaluationResult = null;
      });
    } catch (e) {
      setState(() {
        _evaluationError = 'Unexpected error: ${e.toString()}';
        _evaluationResult = null;
      });
    } finally {
      setState(() {
        _isEvaluating = false;
      });
    }
  }

  dynamic _createMockObject(String varName) {
    switch (varName) {
      case 'user':
        return {
          'age': 25,
          'email': 'user@example.com',
          'roles': ['user', 'member'],
          'name': 'John Doe',
          'isActive': true,
        };
      case 'request':
        return {
          'auth': {
            'uid': 'user123',
            'claims': {'admin': false, 'premium': true},
          },
          'method': 'GET',
          'path': '/api/data',
          'headers': {'content-type': 'application/json'},
        };
      case 'resource':
        return {
          'name': 'document1',
          'owner': 'user123',
          'permissions': ['read', 'write'],
          'metadata': {'created': '2024-01-01', 'size': 1024},
        };
      default:
        return {'mock': true, 'name': varName};
    }
  }

  void _registerAvailableFunctions(
    CELEvaluator evaluator,
    ExpressionState state,
  ) {
    // Register functions based on availableFunctions in context
    final availableFunctions = state.context.availableFunctions;

    for (final funcName in availableFunctions) {
      // Only register if not already registered by CELEvaluator
      if (!_isFunctionRegistered(evaluator, funcName)) {
        _registerCustomFunction(evaluator, funcName);
      }
    }

    // Register template-specific functions
    _registerTemplateFunctions(evaluator);
  }

  bool _isFunctionRegistered(CELEvaluator evaluator, String funcName) {
    // This would need reflection or the evaluator to expose registered functions
    // For now, assume standard functions are registered in CELEvaluator constructor
    final standardFunctions = {
      'size',
      'contains',
      'startsWith',
      'endsWith',
      'matches',
      'filter',
      'map',
      'exists',
      'all',
      'has',
      'int',
      'double',
      'string',
      'abs',
      'ceil',
      'floor',
      'round',
      'min',
      'max',
      'timestamp',
    };
    return standardFunctions.contains(funcName);
  }

  void _registerCustomFunction(CELEvaluator evaluator, String funcName) {
    switch (funcName) {
      case 'isEmpty':
        evaluator.registerFunction('isEmpty', (dynamic value) {
          if (value == null) return true;
          if (value is String) return value.isEmpty;
          if (value is List) return value.isEmpty;
          if (value is Map) return value.isEmpty;
          return false;
        });
        break;
      case 'length':
        evaluator.registerFunction('length', (dynamic value) {
          if (value is String) return value.length;
          if (value is List) return value.length;
          if (value is Map) return value.length;
          throw CELEvaluationException(
            'length() requires string, list, or map',
          );
        });
        break;
      // Add more custom functions as needed
    }
  }

  void _registerTemplateFunctions(CELEvaluator evaluator) {
    // Functions commonly used in templates
    evaluator.registerFunction('now', () => DateTime.now());
    evaluator.registerFunction('isEmail', (String email) {
      final regex = RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      return regex.hasMatch(email);
    });
  }

  void _registerCustomFunctions(CELEvaluator evaluator, ExpressionState state) {
    // Register any custom functions that might be defined in the expression state
    // For example, if your state has custom functions:
    /*
  if (state.customFunctions != null) {
    for (final function in state.customFunctions!) {
      evaluator.registerFunction(function.name, function.implementation);
    }
  }
  */

    // Example of registering some common utility functions
    evaluator.registerFunction('now', () => DateTime.now());
    evaluator.registerFunction('isEmpty', (dynamic value) {
      if (value == null) return true;
      if (value is String) return value.isEmpty;
      if (value is List) return value.isEmpty;
      if (value is Map) return value.isEmpty;
      return false;
    });

    evaluator.registerFunction('length', (dynamic value) {
      if (value is String) return value.length;
      if (value is List) return value.length;
      if (value is Map) return value.length;
      throw CELEvaluationException('length() requires string, list, or map');
    });
  }

  dynamic _parseInputValue(String input, dynamic defaultValue) {
    if (defaultValue is int) {
      final value = int.tryParse(input);
      if (value == null) {
        throw FormatException('Invalid integer: $input');
      }
      return value;
    } else if (defaultValue is double) {
      final value = double.tryParse(input);
      if (value == null) {
        throw FormatException('Invalid double: $input');
      }
      return value;
    } else if (defaultValue is bool) {
      if (input.toLowerCase() == 'true') return true;
      if (input.toLowerCase() == 'false') return false;
      throw FormatException('Invalid boolean value: $input');
    } else if (defaultValue is String) {
      return input;
    } else if (defaultValue is List) {
      // Enhanced list parsing that handles different types
      return _parseListValue(input, defaultValue);
    } else if (defaultValue is Map) {
      // Basic map parsing - in real implementation, use proper JSON parsing
      return _parseMapValue(input, defaultValue);
    } else if (defaultValue == null) {
      // Try to infer type from input
      return _inferTypeFromInput(input);
    } else {
      // Fallback to string or try JSON parsing
      try {
        return _tryParseJson(input);
      } catch (e) {
        return input;
      }
    }
  }

  List<dynamic> _parseListValue(String input, List<dynamic> defaultList) {
    if (input.trim().isEmpty) return [];

    // Remove brackets if present
    var cleanedInput = input.trim();
    if (cleanedInput.startsWith('[') && cleanedInput.endsWith(']')) {
      cleanedInput = cleanedInput.substring(1, cleanedInput.length - 1);
    }

    final items = cleanedInput.split(',').map((item) => item.trim()).toList();

    if (defaultList.isNotEmpty) {
      // Parse based on the type of the first element in default list
      final sampleType = defaultList.first;
      return items.map((item) => _parseInputValue(item, sampleType)).toList();
    } else {
      // Infer types for each item
      return items.map(_inferTypeFromInput).toList();
    }
  }

  Map<dynamic, dynamic> _parseMapValue(
    String input,
    Map<dynamic, dynamic> defaultMap,
  ) {
    if (input.trim().isEmpty) return {};

    try {
      // Simple key:value parsing
      final result = <dynamic, dynamic>{};
      final pairs = input.split(',').map((pair) => pair.trim()).toList();

      for (final pair in pairs) {
        final keyValue = pair.split(':').map((part) => part.trim()).toList();
        if (keyValue.length == 2) {
          final key = _inferTypeFromInput(keyValue[0]);
          final value = _inferTypeFromInput(keyValue[1]);
          result[key] = value;
        }
      }

      return result;
    } catch (e) {
      throw FormatException('Invalid map format: $input');
    }
  }

  dynamic _inferTypeFromInput(String input) {
    if (input.toLowerCase() == 'true') return true;
    if (input.toLowerCase() == 'false') return false;
    if (input.toLowerCase() == 'null') return null;

    final intValue = int.tryParse(input);
    if (intValue != null) return intValue;

    final doubleValue = double.tryParse(input);
    if (doubleValue != null) return doubleValue;

    // Check if it's a string in quotes
    if ((input.startsWith('"') && input.endsWith('"')) ||
        (input.startsWith("'") && input.endsWith("'"))) {
      return input.substring(1, input.length - 1);
    }

    return input;
  }

  dynamic _tryParseJson(String input) {
    try {
      // Simple JSON parsing for basic types
      final trimmed = input.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        // This would need a proper JSON parser in a real implementation
        // For now, return as string
        return input;
      }
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        return _parseListValue(input, []);
      }
      return input;
    } catch (e) {
      return input;
    }
  }
  /* 
  dynamic _mockEvaluateExpression(
    String expression,
    Map<String, dynamic> context,
  ) {
    // Simple mock evaluation for demonstration
    // In real implementation, integrate with a CEL library like cel_dart

    final lowerExpression = expression.toLowerCase();

    if (lowerExpression.contains('request.auth.uid')) {
      return context['request.auth.uid'] ?? 'user123';
    }

    if (lowerExpression.contains('resource.name')) {
      return context['resource.name'] ?? 'default_resource';
    }

    if (lowerExpression.contains(' == ') || lowerExpression.contains(' != ')) {
      // Simple equality mock
      final parts = expression.split(RegExp(r'==|!='));
      if (parts.length == 2) {
        final left = parts[0].trim();
        final right = parts[1].trim().replaceAll("'", "").replaceAll('"', '');

        if (context.containsKey(left)) {
          return context[left].toString() == right;
        }
      }
      return false;
    }

    if (lowerExpression.contains(' > ') || lowerExpression.contains(' < ')) {
      // Simple comparison mock
      return true;
    }

    if (lowerExpression.contains(' in ')) {
      // Simple "in" operation mock
      return true;
    }

    // Return a mock result based on context
    return context.isNotEmpty ? context.values.first : 'mock_result';
  } */

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
