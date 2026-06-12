import 'dart:convert';
import 'dart:math';

import 'fact.dart';
import 'operator.dart';
import 'constraint.dart';
import 'rule.dart';
import 'rule_engine.dart';
import 'rule_builder.dart';

class DrlParser {
  static List<Rule> parse(String drl) {
    final rules = <Rule>[];
    final ruleBlocks = _extractRuleBlocks(drl);
    for (final block in ruleBlocks) {
      try {
        final rule = _parseRule(block);
        rules.add(rule);
      } catch (e) {
        print('Error parsing rule: $e');
      }
    }
    return rules;
  }

  static List<String> _extractRuleBlocks(String drl) {
    final blocks = <String>[];
    final lines = drl.split('\n');
    String? currentBlock;
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('//')) continue;
      if (line.startsWith('rule ')) {
        if (currentBlock != null) {
          blocks.add(currentBlock);
        }
        currentBlock = line;
      } else if (currentBlock != null) {
        currentBlock += '\n$line';
      }
    }
    if (currentBlock != null) {
      blocks.add(currentBlock);
    }
    return blocks;
  }

  static Rule _parseRule(String block) {
    final builder = RuleBuilder();
    final nameMatch = RegExp(r'rule\s+"([^"]+)"').firstMatch(block);
    if (nameMatch != null) {
      builder.name(nameMatch.group(1)!);
    }
    final salienceMatch = RegExp(r'salience\s+(-?\d+)').firstMatch(block);
    if (salienceMatch != null) {
      builder.salience(int.parse(salienceMatch.group(1)!));
    }
    final agendaMatch = RegExp(r'agenda-group\s+"([^"]+)"').firstMatch(block);
    if (agendaMatch != null) {
      builder.agendaGroup(agendaMatch.group(1)!);
    }
    final activationMatch = RegExp(
      r'activation-group\s+"([^"]+)"',
    ).firstMatch(block);
    if (activationMatch != null) {
      builder.activationGroup(activationMatch.group(1)!);
    }
    if (block.contains('no-loop true')) {
      builder.noLoop(true);
    }
    final whenMatch = RegExp(
      r'when\s+(.*?)\s+then',
      dotAll: true,
    ).firstMatch(block);
    if (whenMatch != null) {
      final whenContent = whenMatch.group(1)!;
      _parseWhenConditions(whenContent, builder);
    }
    final thenMatch = RegExp(
      r'then\s+(.*?)\s+end',
      dotAll: true,
    ).firstMatch(block);
    if (thenMatch != null) {
      final thenContent = thenMatch.group(1)!.trim();
      builder.then((bindings, engine) {
        _executeThenBlock(thenContent, bindings, engine);
      });
    }
    return builder.build();
  }

  static void _parseWhenConditions(String whenContent, RuleBuilder builder) {
    final patterns = RegExp(
      r'\$(\w+)\s*:\s*(\w+)\s*\((.*?)\)',
    ).allMatches(whenContent);
    for (final match in patterns) {
      final alias = match.group(1)!;
      final type = match.group(2)!;
      final conditions = match.group(3)!.trim();
      final constraints = <Constraint>[];
      if (conditions.isNotEmpty) {
        final condParts = conditions.split(',');
        for (var cond in condParts) {
          cond = cond.trim();
          final constraint = _parseConstraint(cond);
          if (constraint != null) {
            constraints.add(constraint);
          }
        }
      }
      builder.when(alias, type, constraints: constraints);
    }
  }

  static Constraint? _parseConstraint(String condition) {
    condition = condition.trim();
    final operatorPatterns = {
      '==': Operator.equals,
      '!=': Operator.notEquals,
      '>=': Operator.greaterThanOrEqual,
      '<=': Operator.lessThanOrEqual,
      '>': Operator.greaterThan,
      '<': Operator.lessThan,
      'contains': Operator.contains,
      'matches': Operator.matches,
      'memberOf': Operator.memberOf,
    };
    for (final entry in operatorPatterns.entries) {
      if (condition.contains(entry.key)) {
        final parts = condition.split(entry.key);
        if (parts.length == 2) {
          final field = parts[0].trim();
          final value = _parseValue(parts[1].trim());
          return Constraint(field, entry.value, value);
        }
      }
    }
    return null;
  }

  static dynamic _parseValue(String value) {
    value = value.trim();
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1);
    }
    final numValue = num.tryParse(value);
    if (numValue != null) return numValue;
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    return value;
  }

  static void _executeThenBlock(
    String thenContent,
    Map<String, Fact> bindings,
    RuleEngine engine,
  ) {
    final lines = thenContent.split(';');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('insert(')) {
        continue;
      }
      if (line.startsWith('retract(')) {
        final match = RegExp(r'retract\(\$(\w+)\)').firstMatch(line);
        if (match != null) {
          final alias = match.group(1)!;
          if (bindings.containsKey(alias)) {
            engine.retract(bindings[alias]!);
          }
        }
        continue;
      }
      final setMatch = RegExp(
        r'\$(\w+)\.set\("(\w+)",\s*(.+)\)',
      ).firstMatch(line);
      if (setMatch != null) {
        final alias = setMatch.group(1)!;
        final field = setMatch.group(2)!;
        final value = _parseValue(setMatch.group(3)!);
        if (bindings.containsKey(alias)) {
          bindings[alias]!.set(field, value);
        }
      }
    }
  }
}
