// rule_engine/validators/yaml_validator.dart
//
// Validates YAML rule documents for basic schema correctness and expression parseability.
import 'package:yaml/yaml.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';

class YamlValidationError {
  final String ruleName;
  final String message;
  YamlValidationError(this.ruleName, this.message);

  @override
  String toString() => 'Rule "$ruleName": $message';
}

class YamlValidator {
  /// Allowed action keys at top-level inside a 'then' map. Extendable.
  static const allowedActionKeys = <String>{
    // Default actions
    'log', 'set', 'retract', 'modify',
    // Faraid actions
    'assignFixedShare', 'assignRemainingShare', 'assignToSonsAndDaughters',
    'computeRemaining', 'applyAwl', 'applyRadd',
    // Domain-agnostic actions
    'assign', 'calculate', 'when', 'forEach', 'check_conditions',
    'calculate_fixed_share', 'sum_object_values',
    // Synonyms
    'apply',
  };

  /// Validate the YAML document loaded by [loadYaml].
  /// Returns a list of YamlValidationError; empty list means valid.
  static List<YamlValidationError> validate(YamlMap doc) {
    final errors = <YamlValidationError>[];

    if (!doc.containsKey('rules')) {
      errors.add(YamlValidationError('', 'Top-level "rules" key not found'));
      return errors;
    }

    final rulesNode = doc['rules'];
    if (rulesNode is! YamlList) {
      errors.add(YamlValidationError('', '"rules" must be a list'));
      return errors;
    }

    for (final r in rulesNode) {
      if (r is! YamlMap) {
        errors.add(YamlValidationError('', 'Each rule must be a map'));
        continue;
      }

      final name = r['name']?.toString() ?? '<unnamed>';
      if (!r.containsKey('then')) {
        errors.add(YamlValidationError(name, 'Missing "then" actions'));
      }

      // Validate "when" block: support list of string expressions or a single string
      if (r.containsKey('when')) {
        final when = r['when'];
        if (when is YamlList) {
          for (final cond in when) {
            if (cond is! String) {
              errors.add(
                YamlValidationError(
                  name,
                  'Each condition in "when" must be a string expression',
                ),
              );
            } else {
              _validateExpression(cond, name, errors);
            }
          }
        } else if (when is String) {
          _validateExpression(when, name, errors);
        } else {
          errors.add(
            YamlValidationError(
              name,
              '"when" must be a string or list of strings',
            ),
          );
        }
      }

      // Validate then actions
      if (r.containsKey('then')) {
        final thenNode = r['then'];
        if (thenNode is! YamlList) {
          errors.add(YamlValidationError(name, '"then" must be a list'));
        } else {
          for (final action in thenNode) {
            if (action is String) {
              // allow simple "log: message" string? better if map or string with "log:..."
              continue;
            } else if (action is YamlMap) {
              // each action map should have one top-level key in allowedActionKeys
              if (action.keys.isEmpty) {
                errors.add(YamlValidationError(name, 'Action map is empty'));
                continue;
              }
              for (final k in action.keys) {
                final key = k.toString();
                if (!allowedActionKeys.contains(key)) {
                  errors.add(
                    YamlValidationError(name, 'Unknown action key "$key"'),
                  );
                }
                // Basic argument type checks for common actions
                final val = action[k];
                if ((key == 'assignShare' ||
                        key == 'set' ||
                        key == 'modify' ||
                        key == 'retract') &&
                    val is! YamlMap) {
                  errors.add(
                    YamlValidationError(name, '"$key" action must be a map'),
                  );
                }
              }
            } else {
              errors.add(
                YamlValidationError(
                  name,
                  'Actions must be either string or map',
                ),
              );
            }
          }
        }
      }
    }

    return errors;
  }

  static void _validateExpression(
    String expr,
    String ruleName,
    List<YamlValidationError> errors,
  ) {
    try {
      final lexer = Lexer(expr);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      parser.parse();
    } catch (e) {
      errors.add(
        YamlValidationError(ruleName, 'Invalid expression "$expr": $e'),
      );
    }
  }
}
