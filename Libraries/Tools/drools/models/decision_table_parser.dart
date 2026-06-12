import 'dart:convert';
import 'dart:math';

import 'fact.dart';
import 'operator.dart';
import 'constraint.dart';
import 'rule.dart';
import 'rule_engine.dart';
import 'rule_builder.dart';

class DecisionTableParser {
  static List<Rule> parseCSV(String csv) {
    final lines =
        csv
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
    if (lines.isEmpty) return [];
    return _parseTable(lines);
  }

  static List<Rule> _parseTable(List<String> lines) {
    final rules = <Rule>[];
    var tableStartRow = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().contains('RULETABLE')) {
        tableStartRow = i;
        break;
      }
    }
    if (tableStartRow == -1) {
      print('No RuleTable found');
      return rules;
    }
    String? ruleName;
    int salience = 0;
    String? agendaGroup;
    var headerRow = tableStartRow + 1;
    for (
      var i = tableStartRow + 1;
      i < min(tableStartRow + 10, lines.length);
      i++
    ) {
      final line = lines[i].toUpperCase();
      if (line.contains('CONDITION') || line.contains('ACTION')) {
        headerRow = i;
        break;
      }
      if (lines[i].toLowerCase().contains('name')) {
        ruleName = lines[i].split(',').skip(1).first.trim();
      }
      if (lines[i].toLowerCase().contains('salience')) {
        salience = int.tryParse(lines[i].split(',').skip(1).first.trim()) ?? 0;
      }
    }
    final headers = lines[headerRow].split(',').map((h) => h.trim()).toList();
    final conditionIndices = <int>[];
    final actionIndices = <int>[];
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].toUpperCase().contains('CONDITION')) {
        conditionIndices.add(i);
      } else if (headers[i].toUpperCase().contains('ACTION')) {
        actionIndices.add(i);
      }
    }
    if (headerRow + 1 >= lines.length) return rules;
    final templateRow =
        lines[headerRow + 1].split(',').map((c) => c.trim()).toList();
    for (var i = headerRow + 2; i < lines.length; i++) {
      final cells = lines[i].split(',').map((c) => c.trim()).toList();
      if (cells.isEmpty || cells[0].isEmpty) continue;
      final ruleBuilder = RuleBuilder()
          .name(ruleName != null ? '$ruleName-$i' : 'Rule-$i')
          .salience(salience);
      if (agendaGroup != null) {
        ruleBuilder.agendaGroup(agendaGroup);
      }
      for (final idx in conditionIndices) {
        if (idx < cells.length && cells[idx].isNotEmpty) {
          final template = templateRow[idx];
          final value = cells[idx];
          _addConditionFromTemplate(ruleBuilder, template, value);
        }
      }
      final actionCells = <String>[];
      for (final idx in actionIndices) {
        if (idx < cells.length && cells[idx].isNotEmpty) {
          actionCells.add(cells[idx]);
        }
      }
      ruleBuilder.then((bindings, engine) {
        for (final action in actionCells) {
          _executeAction(action, bindings, engine);
        }
      });
      try {
        rules.add(ruleBuilder.build());
      } catch (e) {
        print('Error building rule from row $i: $e');
      }
    }
    return rules;
  }

  static void _addConditionFromTemplate(
    RuleBuilder builder,
    String template,
    String value,
  ) {
    final match = RegExp(r'\$(\w+):\s*(\w+)\((.*?)\)').firstMatch(template);
    if (match == null) return;
    final alias = match.group(1)!;
    final type = match.group(2)!;
    final condition = match.group(3)!;
    final replacedCondition = condition.replaceAll(RegExp(r'\$\d+'), value);
    Constraint? constraint;
    if (replacedCondition.contains('>')) {
      final parts = replacedCondition.split('>');
      constraint = Constraint(
        parts[0].trim(),
        Operator.greaterThan,
        _parseValue(parts[1].trim()),
      );
    } else if (replacedCondition.contains('==')) {
      final parts = replacedCondition.split('==');
      constraint = Constraint(
        parts[0].trim(),
        Operator.equals,
        _parseValue(parts[1].trim()),
      );
    }
    if (constraint != null) {
      builder.when(alias, type, constraints: [constraint]);
    }
  }

  static void _executeAction(
    String action,
    Map<String, Fact> bindings,
    RuleEngine engine,
  ) {
    final setMatch = RegExp(
      r'\$(\w+)\.set\("(\w+)",\s*"?([^"]+)"?\)',
    ).firstMatch(action);
    if (setMatch != null) {
      final alias = setMatch.group(1)!;
      final field = setMatch.group(2)!;
      final value = setMatch.group(3)!.trim();
      if (bindings.containsKey(alias)) {
        bindings[alias]!.set(field, _parseValue(value));
      }
    }
  }

  static dynamic _parseValue(String value) {
    value = value.trim();
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    final numValue = num.tryParse(value);
    if (numValue != null) return numValue;
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    return value;
  }
}
