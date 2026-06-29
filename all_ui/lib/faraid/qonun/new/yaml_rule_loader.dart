// rule_engine/loader/yaml_rule_loader.dart
//
// Loads YAML rules, validates them, and converts into runtime Rule objects.
// Uses the Parser to parse string expressions into ExprNode ASTs.
// Returns a list of LoadedRule which contains parsed when-expressions as ExprNode.

import 'package:yaml/yaml.dart';

import 'ast_nodes.dart';
import 'core.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';
import 'yaml_validator.dart';

class LoadedRule {
  final String name;
  final String group;
  final int salience;
  final bool noLoop;
  final List<ExprNode> when; // parsed AST expressions
  final List<dynamic> then; // raw action maps (Map<String,dynamic>) or strings
  final String? description;

  LoadedRule({
    required this.name,
    required this.group,
    required this.salience,
    required this.noLoop,
    required this.when,
    required this.then,
    this.description,
  });

  Rule toRule() {
    // Convert LoadedRule to the previous Rule shape if needed (keeping when as strings would
    // lose the AST; choose to store AST in rule.when as dynamic)
    return Rule(
      name: name,
      group: group,
      salience: salience,
      noLoop: noLoop,
      when: when, // note: now contains ExprNode objects
      then: then,
    );
  }
}
// rule_engine/loader/yaml_rule_loader.dart

class YamlRuleLoader {
  /// Load rules from a YAML string.
  /// Throws FormatException if YAML invalid or validation fails.
  static List<Rule> load(String yamlString, {bool validate = true}) {
    final doc = loadYaml(yamlString);
    if (doc == null || doc is! YamlMap) return [];

    if (validate) {
      final errors = YamlValidator.validate(doc);
      if (errors.isNotEmpty) {
        final msgs = errors.map((e) => e.toString()).join('\n');
        throw FormatException('YAML validation failed:\n$msgs');
      }
    }

    final rulesNode = doc['rules'];
    if (rulesNode is! YamlList) return [];

    final rules = <Rule>[];

    for (final r in rulesNode) {
      if (r is! YamlMap) continue;

      final name = r['name']?.toString() ?? 'Unnamed Rule';
      final group = r['group']?.toString() ?? 'default';
      final salience =
          (r['salience'] is num)
              ? (r['salience'] as num).toInt()
              : int.tryParse(r['salience']?.toString() ?? '') ?? 0;
      final noLoop = r['no_loop'] == true || r['noLoop'] == true;
      final description = r['description']?.toString();

      final whenList = <dynamic>[];
      if (r.containsKey('when')) {
        final whenNode = r['when'];
        if (whenNode is YamlList) {
          for (final cond in whenNode) {
            if (cond is String) {
              // parse to ExprNode
              final lexer = Lexer(cond);
              final tokens = lexer.tokenize();
              final parser = Parser(tokens);
              final expr = parser.parse();
              whenList.add(expr);
            } else {
              whenList.add(cond);
            }
          }
        } else if (whenNode is String) {
          final lexer = Lexer(whenNode);
          final tokens = lexer.tokenize();
          final parser = Parser(tokens);
          final expr = parser.parse();
          whenList.add(expr);
        }
      }

      final thenList = <dynamic>[];
      if (r.containsKey('then')) {
        final thenNode = r['then'];
        if (thenNode is YamlList) {
          for (final act in thenNode) {
            if (act is YamlMap) {
              // convert YamlMap -> Map<String, dynamic>
              final m = <String, dynamic>{};
              for (final k in act.keys) {
                m[k.toString()] = _convertYamlValue(act[k]);
              }
              thenList.add(m);
            } else if (act is String) {
              thenList.add(act);
            }
          }
        }
      }

      final rule = Rule(
        name: name,
        group: group,
        salience: salience,
        noLoop: noLoop,
        when: whenList,
        then: thenList,
        description: description,
      );

      rules.add(rule);
    }

    return rules;
  }

  static dynamic _convertYamlValue(dynamic v) {
    if (v is YamlMap) {
      final m = <String, dynamic>{};
      for (final k in v.keys) {
        m[k.toString()] = _convertYamlValue(v[k]);
      }
      return m;
    } else if (v is YamlList) {
      return v.map(_convertYamlValue).toList();
    }
    return v;
  }
}
