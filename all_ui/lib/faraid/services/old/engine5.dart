// engine4_fixed.dart
// Improved & fixed Drools-like rule engine in Dart based on user-provided engine4.txt
import 'dart:convert';
import 'dart:math';
import 'dart:io';

// -----------------------------------------------------------------------------
// CORE MODELS
// -----------------------------------------------------------------------------

class Fact {
  final String type;
  final Map<String, dynamic> attributes;
  final String id;

  Fact(this.type, this.attributes) : id = _generateId();

  static String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(10000)}';

  dynamic operator [](String key) => attributes[key];
  void operator []=(String key, dynamic value) => attributes[key] = value;

  dynamic get(String key) => attributes[key];
  void set(String key, dynamic value) => attributes[key] = value;
  bool has(String key) => attributes.containsKey(key);

  @override
  String toString() => 'Fact($type, $attributes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum Operator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  contains,
  notContains,
  matches,
  isNull,
  isNotNull,
  inList,
  notInList,
  memberOf,
  startsWith,
  endsWith,
}

class Constraint {
  final String field;
  final Operator operator;
  final dynamic value;

  Constraint(this.field, this.operator, [this.value]);

  bool evaluate(Fact fact) {
    final fieldValue = fact.get(field);

    switch (operator) {
      case Operator.equals:
        return fieldValue == value;
      case Operator.notEquals:
        return fieldValue != value;
      case Operator.greaterThan:
        return _compareNumeric(fieldValue, value, (a, b) => a > b);
      case Operator.lessThan:
        return _compareNumeric(fieldValue, value, (a, b) => a < b);
      case Operator.greaterThanOrEqual:
        return _compareNumeric(fieldValue, value, (a, b) => a >= b);
      case Operator.lessThanOrEqual:
        return _compareNumeric(fieldValue, value, (a, b) => a <= b);
      case Operator.contains:
        if (fieldValue is List) return fieldValue.contains(value);
        if (fieldValue is String && value is String)
          return fieldValue.contains(value);
        return fieldValue?.toString().contains(value.toString()) ?? false;
      case Operator.notContains:
        if (fieldValue is List) return !fieldValue.contains(value);
        if (fieldValue is String && value is String)
          return !fieldValue.contains(value);
        return !(fieldValue?.toString().contains(value.toString()) ?? false);
      case Operator.matches:
        if (fieldValue == null) return false;
        return RegExp(value.toString()).hasMatch(fieldValue.toString());
      case Operator.isNull:
        return fieldValue == null;
      case Operator.isNotNull:
        return fieldValue != null;
      case Operator.inList:
        if (value is! List) return false;
        return (value as List).contains(fieldValue);
      case Operator.notInList:
        if (value is! List) return true;
        return !(value as List).contains(fieldValue);
      case Operator.memberOf:
        return (fieldValue is List) && (fieldValue as List).contains(value);
      case Operator.startsWith:
        if (fieldValue == null) return false;
        return fieldValue.toString().startsWith(value.toString());
      case Operator.endsWith:
        if (fieldValue == null) return false;
        return fieldValue.toString().endsWith(value.toString());
    }
  }

  bool _compareNumeric(dynamic a, dynamic b, bool Function(num, num) compare) {
    if (a is num && b is num) return compare(a, b);
    if (a is String && b is num) {
      final numA = num.tryParse(a);
      if (numA != null) return compare(numA, b);
    }
    return false;
  }
}

class Pattern {
  final String alias;
  final String type;
  final List<Constraint> constraints;
  final bool Function(Fact, Map<String, Fact>)? customPredicate;
  final bool isNegated;
  final bool isExists;

  Pattern(
    this.alias,
    this.type, {
    this.constraints = const [],
    this.customPredicate,
    this.isNegated = false,
    this.isExists = false,
  });

  bool matches(Fact fact, Map<String, Fact> bindings) {
    if (fact.type != type) return false;

    for (final constraint in constraints) {
      if (!constraint.evaluate(fact)) return false;
    }

    if (customPredicate != null) {
      bindings[alias] = fact;
      return customPredicate!(fact, bindings);
    }

    return true;
  }

  @override
  String toString() =>
      'Pattern(alias:$alias,type:$type,neg:${isNegated},exists:${isExists})';
}

typedef ActionFunction =
    void Function(Map<String, Fact> bindings, RuleEngine engine);

class Rule {
  final String name;
  final String? description;
  final int salience;
  final String? agendaGroup;
  final String? activationGroup;
  final bool noLoop;
  final bool lockOnActive;
  final List<Pattern> when;
  final ActionFunction then;
  bool enabled;
  int executionCount = 0;
  DateTime? lastFired;
  final Set<String> _firedForBindings = {};

  Rule({
    required this.name,
    this.description,
    this.salience = 0,
    this.agendaGroup,
    this.activationGroup,
    this.noLoop = false,
    this.lockOnActive = false,
    required this.when,
    required this.then,
    this.enabled = true,
  });

  bool hasBeenFiredForBindings(Map<String, Fact> bindings) {
    if (!noLoop) return false;

    final bindingKey =
        bindings.entries.map((e) => '${e.key}:${e.value.id}').toList()..sort();

    final key = '${name}_${bindingKey.join('|')}';
    return _firedForBindings.contains(key);
  }

  void markFiredForBindings(Map<String, Fact> bindings) {
    if (!noLoop) return;

    final bindingKey =
        bindings.entries.map((e) => '${e.key}:${e.value.id}').toList()..sort();

    final key = '${name}_${bindingKey.join('|')}';
    _firedForBindings.add(key);
  }

  void resetFiredBindings() {
    _firedForBindings.clear();
  }

  @override
  String toString() => 'Rule($name, salience: $salience)';
}

// -----------------------------------------------------------------------------
// RULE ENGINE
// -----------------------------------------------------------------------------

class RuleEngine {
  final List<Rule> _rules = [];
  final List<Fact> _workingMemory = [];
  final Set<Fact> _factsToRetract = {};
  final List<String> _executionLog = [];
  final Map<String, dynamic> _globals = {};
  final Set<String> _firedActivationGroups = {};
  String? _currentAgendaGroup;

  int maxExecutions = 1000;
  bool logExecution = true;

  void debugRules() {
    print('\n=== DEBUG INFO ===');
    print('Working Memory: ${_workingMemory.length} facts');
    for (final fact in _workingMemory) {
      print('  - $fact');
    }

    print('\nRules: ${_rules.length}');
    for (final rule in _rules) {
      print('  - ${rule.name} (enabled: ${rule.enabled})');
      print('    Patterns: ${rule.when.length}');
      for (final pattern in rule.when) {
        print(
          '      - $pattern: ${pattern.type}${pattern.isNegated ? " [NEGATED]" : ""}${pattern.isExists ? " [EXISTS]" : ""}',
        );
        for (final constraint in pattern.constraints) {
          print(
            '          ${constraint.field} ${constraint.operator} ${constraint.value}',
          );
        }
      }
      final matches = _findMatches(rule);
      print('    Matches found: ${matches.length}');
      for (final match in matches) {
        print(
          '      - ${match.keys.map((k) => '$k:${match[k]!.id}').join(', ')}',
        );
      }
    }
    print('==================\n');
  }

  void addRule(Rule rule) {
    _rules.add(rule);
    _sortRules();
  }

  void addRules(List<Rule> rules) {
    _rules.addAll(rules);
    _sortRules();
  }

  bool removeRule(String name) {
    final initialCount = _rules.length;
    _rules.removeWhere((r) => r.name == name);
    final finalCount = _rules.length;
    return finalCount < initialCount;
  }

  void setRuleEnabled(String name, bool enabled) {
    try {
      final rule = _rules.firstWhere((r) => r.name == name);
      rule.enabled = enabled;
    } catch (e) {
      print('Warning: Rule "$name" not found');
    }
  }

  void setGlobal(String name, dynamic value) {
    _globals[name] = value;
    _log('Set global: $name');
  }

  dynamic getGlobal(String name) => _globals[name];

  Fact insert(Fact fact) {
    _workingMemory.add(fact);
    _log('Inserted: ${fact.type}');
    return fact;
  }

  void update(Fact fact) {
    _log('Updated: ${fact.type}');
  }

  void retract(Fact fact) {
    _factsToRetract.add(fact);
    _log('Retract: ${fact.type}');
  }

  List<Fact> getFactsByType(String type) {
    return _workingMemory.where((f) => f.type == type).toList();
  }

  List<Fact> getAllFacts() => List.unmodifiable(_workingMemory);

  void clearFacts() {
    _workingMemory.clear();
    _factsToRetract.clear();
  }

  void clearRules() {
    _rules.clear();
  }

  void resetRules() {
    for (final rule in _rules) {
      rule.executionCount = 0;
      rule.lastFired = null;
      rule.resetFiredBindings();
    }
  }

  List<String> getExecutionLog() => List.unmodifiable(_executionLog);

  void clearLog() {
    _executionLog.clear();
  }

  void setFocus(String? agendaGroup) {
    _currentAgendaGroup = agendaGroup;
    _log('Focus: ${agendaGroup ?? "default"}');
  }

  void fireAllRules() {
    _executionLog.clear();
    _firedActivationGroups.clear();

    for (final rule in _rules) {
      rule.resetFiredBindings();
    }

    var iterations = 0;
    var totalFired = 0;

    while (iterations < maxExecutions) {
      final fired = _fireOnce();
      totalFired += fired;

      if (fired == 0) break;
      iterations++;

      _performRetractions();
    }

    _log('Total fired: $totalFired in $iterations iterations');
  }

  int _fireOnce() {
    var firedCount = 0;
    final eligibleRules = _getEligibleRules();

    _log(
      'Eligible rules for agenda group "$_currentAgendaGroup": ${eligibleRules.length}',
    );

    for (final rule in eligibleRules) {
      if (!rule.enabled) {
        _log('Rule ${rule.name} is disabled, skipping');
        continue;
      }

      if (rule.activationGroup != null) {
        if (_firedActivationGroups.contains(rule.activationGroup)) {
          _log(
            'Rule ${rule.name} skipped - activation group ${rule.activationGroup} already fired',
          );
          continue;
        }
      }

      final matches = _findMatches(rule);
      _log('Rule ${rule.name} has ${matches.length} matches');

      for (final bindings in matches) {
        if (rule.noLoop && rule.hasBeenFiredForBindings(bindings)) {
          _log(
            'Rule ${rule.name} skipped - no-loop and already fired for these bindings',
          );
          continue;
        }

        _log('Firing: ${rule.name}');
        rule.executionCount++;
        rule.lastFired = DateTime.now();
        rule.markFiredForBindings(bindings);

        rule.then(bindings, this);
        firedCount++;

        if (rule.activationGroup != null) {
          _firedActivationGroups.add(rule.activationGroup!);
        }
      }
    }

    return firedCount;
  }

  List<Rule> _getEligibleRules() {
    if (_currentAgendaGroup == null) {
      return _rules.where((r) => r.agendaGroup == null).toList();
    } else {
      return _rules.where((r) => r.agendaGroup == _currentAgendaGroup).toList();
    }
  }

  List<Map<String, Fact>> _findMatches(Rule rule) {
    if (rule.when.isEmpty) return [];

    final matches = <Map<String, Fact>>[];
    _findMatchesRecursive(rule.when, 0, {}, matches);
    return matches;
  }

  void _findMatchesRecursive(
    List<Pattern> patterns,
    int patternIndex,
    Map<String, Fact> currentBindings,
    List<Map<String, Fact>> matches,
  ) {
    if (patternIndex >= patterns.length) {
      matches.add(Map.from(currentBindings));
      return;
    }

    final pattern = patterns[patternIndex];

    if (pattern.isNegated) {
      final factsOfType =
          _workingMemory
              .where((fact) => fact.type == pattern.type)
              .where((fact) => !_factsToRetract.contains(fact))
              .toList();

      bool foundMatch = false;
      for (final fact in factsOfType) {
        final testBindings = Map<String, Fact>.from(currentBindings);
        if (pattern.matches(fact, testBindings)) {
          foundMatch = true;
          break;
        }
      }

      if (!foundMatch) {
        _findMatchesRecursive(
          patterns,
          patternIndex + 1,
          currentBindings,
          matches,
        );
      }
      return;
    }

    if (pattern.isExists) {
      final factsOfType =
          _workingMemory
              .where((fact) => fact.type == pattern.type)
              .where((fact) => !_factsToRetract.contains(fact))
              .toList();

      bool existsMatch = false;
      for (final fact in factsOfType) {
        final newBindings = Map<String, Fact>.from(currentBindings);
        if (pattern.matches(fact, newBindings)) {
          existsMatch = true;
          break;
        }
      }

      if (existsMatch) {
        _findMatchesRecursive(
          patterns,
          patternIndex + 1,
          currentBindings,
          matches,
        );
      }
      return;
    }

    final factsOfType =
        _workingMemory
            .where((fact) => fact.type == pattern.type)
            .where((fact) => !_factsToRetract.contains(fact))
            .toList();

    for (final fact in factsOfType) {
      final newBindings = Map<String, Fact>.from(currentBindings);

      if (pattern.matches(fact, newBindings)) {
        newBindings[pattern.alias] = fact;
        _findMatchesRecursive(patterns, patternIndex + 1, newBindings, matches);
      }
    }
  }

  void _performRetractions() {
    if (_factsToRetract.isNotEmpty) {
      _workingMemory.removeWhere((f) => _factsToRetract.contains(f));
      _log('Retracted ${_factsToRetract.length} facts');
      _factsToRetract.clear();
    }
  }

  void _sortRules() {
    _rules.sort((a, b) => b.salience.compareTo(a.salience));
  }

  void _log(String message) {
    if (logExecution) {
      _executionLog.add(message);
      print(message);
    }
  }

  Map<String, dynamic> getStatistics() {
    return {
      'totalRules': _rules.length,
      'enabledRules': _rules.where((r) => r.enabled).length,
      'totalFacts': _workingMemory.length,
      'globals': _globals.keys.toList(),
      'ruleExecutions':
          _rules
              .map(
                (r) => {
                  'name': r.name,
                  'executions': r.executionCount,
                  'lastFired': r.lastFired?.toIso8601String(),
                },
              )
              .toList(),
    };
  }
}

// -----------------------------------------------------------------------------
// RULE BUILDER
// -----------------------------------------------------------------------------

class RuleBuilder {
  String? _name;
  String? _description;
  int _salience = 0;
  String? _agendaGroup;
  String? _activationGroup;
  bool _noLoop = false;
  bool _lockOnActive = false;
  final List<Pattern> _patterns = [];
  ActionFunction? _action;

  RuleBuilder name(String name) {
    _name = name;
    return this;
  }

  RuleBuilder description(String description) {
    _description = description;
    return this;
  }

  RuleBuilder salience(int salience) {
    _salience = salience;
    return this;
  }

  RuleBuilder agendaGroup(String group) {
    _agendaGroup = group;
    return this;
  }

  RuleBuilder activationGroup(String group) {
    _activationGroup = group;
    return this;
  }

  RuleBuilder noLoop(bool value) {
    _noLoop = value;
    return this;
  }

  RuleBuilder lockOnActive(bool value) {
    _lockOnActive = value;
    return this;
  }

  RuleBuilder when(
    String alias,
    String type, {
    List<Constraint>? constraints,
    bool Function(Fact, Map<String, Fact>)? predicate,
    bool isNegated = false,
    bool isExists = false,
  }) {
    _patterns.add(
      Pattern(
        alias,
        type,
        constraints: constraints ?? [],
        customPredicate: predicate,
        isNegated: isNegated,
        isExists: isExists,
      ),
    );
    return this;
  }

  RuleBuilder notExists(
    String alias,
    String type, {
    List<Constraint>? constraints,
  }) {
    _patterns.add(
      Pattern(alias, type, constraints: constraints ?? [], isNegated: true),
    );
    return this;
  }

  RuleBuilder exists(
    String alias,
    String type, {
    List<Constraint>? constraints,
  }) {
    _patterns.add(
      Pattern(alias, type, constraints: constraints ?? [], isExists: true),
    );
    return this;
  }

  RuleBuilder then(ActionFunction action) {
    _action = action;
    return this;
  }

  Rule build() {
    if (_name == null) throw StateError('Rule name required');
    if (_action == null) throw StateError('Rule action required');

    return Rule(
      name: _name!,
      description: _description,
      salience: _salience,
      agendaGroup: _agendaGroup,
      activationGroup: _activationGroup,
      noLoop: _noLoop,
      lockOnActive: _lockOnActive,
      when: _patterns,
      then: _action!,
    );
  }
}

// -----------------------------------------------------------------------------
// DRL PARSER
// -----------------------------------------------------------------------------

class DrlParser {
  static List<Rule> parse(String drl, {Function(String)? printCallback}) {
    final rules = <Rule>[];
    final ruleBlocks = _extractRuleBlocks(drl);

    for (final block in ruleBlocks) {
      try {
        final rule = _parseRule(block, printCallback);
        rules.add(rule);
      } catch (e) {
        print('Error parsing rule: $e');
      }
    }

    return rules;
  }

  static List<String> _extractRuleBlocks(String drl) {
    final blocks = <String>[];
    final buffer = StringBuffer();
    var inRule = false;

    for (var rawLine in drl.split('\n')) {
      var line = rawLine.trim();

      if (!inRule && (line.isEmpty || line.startsWith('//'))) continue;

      if (line.startsWith('rule ')) {
        if (buffer.isNotEmpty) {
          blocks.add(buffer.toString());
          buffer.clear();
        }
        inRule = true;
        buffer.writeln(line);
      } else if (inRule) {
        buffer.writeln(line);

        if (line == 'end' || line.endsWith(' end')) {
          blocks.add(buffer.toString());
          buffer.clear();
          inRule = false;
        }
      }
    }

    if (buffer.isNotEmpty) {
      blocks.add(buffer.toString());
    }

    return blocks;
  }

  static Rule _parseRule(String block, Function(String)? printCallback) {
    final builder = RuleBuilder();

    // Parse rule name
    final nameMatch = RegExp(r'rule\s+"([^"]+)"').firstMatch(block);
    if (nameMatch != null) {
      builder.name(nameMatch.group(1)!);
    } else {
      final fallbackNameMatch = RegExp(r'rule\s+(\w+)').firstMatch(block);
      if (fallbackNameMatch != null) {
        builder.name(fallbackNameMatch.group(1)!);
      } else {
        builder.name('UnnamedRule_${Random().nextInt(1000)}');
      }
    }

    // Parse salience
    final salienceMatch = RegExp(r'salience\s+(-?\d+)').firstMatch(block);
    if (salienceMatch != null) {
      builder.salience(int.parse(salienceMatch.group(1)!));
    }

    // Parse agenda-group
    final agendaMatch = RegExp(r'agenda-group\s+"([^"]+)"').firstMatch(block);
    if (agendaMatch != null) {
      builder.agendaGroup(agendaMatch.group(1)!);
    }

    // Parse activation-group
    final activationMatch = RegExp(
      r'activation-group\s+"([^"]+)"',
    ).firstMatch(block);
    if (activationMatch != null) {
      builder.activationGroup(activationMatch.group(1)!);
    }

    // Parse no-loop
    if (block.contains('no-loop true') || block.contains('no-loop')) {
      builder.noLoop(true);
    }

    // When section
    final whenMatch = RegExp(
      r'when\s*((.|\n)*?)(?:\s+then\s+|$)',
      dotAll: true,
    ).firstMatch(block);
    if (whenMatch != null) {
      final whenContent = whenMatch.group(1)!.trim();
      _parseWhenConditions(whenContent, builder);
    }

    // Then section
    final thenMatch = RegExp(
      r'then\s*((.|\n)*?)(?:\s+end\s*|$)',
      dotAll: true,
    ).firstMatch(block);
    if (thenMatch != null) {
      final thenContent = thenMatch.group(1)!.trim();
      builder.then((bindings, engine) {
        _executeThenBlock(thenContent, bindings, engine, printCallback);
      });
    } else {
      builder.then((bindings, engine) {
        final message =
            'Rule ${builder._name} executed with ${bindings.length} bindings';
        if (printCallback != null) {
          printCallback(message);
        } else {
          print(message);
        }
      });
    }

    return builder.build();
  }

  static void _parseWhenConditions(String whenContent, RuleBuilder builder) {
    whenContent = whenContent.trim();
    // Try regex based detection
    final simplePattern = RegExp(r'\$(\w+)\s*:\s*(\w+)\s*\(([^)]*)\)');
    final simpleMatches = simplePattern.allMatches(whenContent);

    final flexiblePattern = RegExp(
      r'\$(\w+)\s*:\s*(\w+)\s*\((.*?)\)',
      dotAll: true,
    );
    final flexibleMatches = flexiblePattern.allMatches(whenContent);

    // If matches exist use them
    final matches = simpleMatches.isNotEmpty ? simpleMatches : flexibleMatches;

    if (matches.isNotEmpty) {
      for (final match in matches) {
        final alias = match.group(1)!;
        final type = match.group(2)!;
        final conditions = match.group(3)!.trim();
        final constraints = _parseConstraints(conditions);
        builder.when(alias, type, constraints: constraints);
      }
    } else {
      // Look for not and exists lines and simple pattern lines manually
      final lines =
          whenContent
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();
      for (final line in lines) {
        if (line.startsWith('not ')) {
          final m = RegExp(
            r'not\s+(?:exists\s+)?(\w+)\s*\((.*?)\)',
          ).firstMatch(line);
          if (m != null) {
            final type = m.group(1)!;
            final cond = m.group(2)!.trim();
            final constraints = _parseConstraints(cond);
            // use alias 'not_<type>' to store something (not used for binding)
            builder.notExists('not_$type', type, constraints: constraints);
            continue;
          }
        }

        if (line.startsWith('exists ')) {
          final m = RegExp(r'exists\s+(\w+)\s*\((.*?)\)').firstMatch(line);
          if (m != null) {
            final type = m.group(1)!;
            final cond = m.group(2)!.trim();
            final constraints = _parseConstraints(cond);
            builder.exists('exists_$type', type, constraints: constraints);
            continue;
          }
        }

        // Normal pattern without alias: e.g. FamilyMember(...)
        final withoutAlias = RegExp(r'(\w+)\s*\((.*?)\)').firstMatch(line);
        if (withoutAlias != null) {
          // create implicit alias from type name
          final type = withoutAlias.group(1)!;
          final cond = withoutAlias.group(2)!.trim();
          final constraints = _parseConstraints(cond);
          builder.when(type.toLowerCase(), type, constraints: constraints);
          continue;
        }

        // Try attempt for alias-based pattern
        final aliasMatch = RegExp(
          r'\$(\w+)\s*:\s*(\w+)\s*\((.*?)\)',
        ).firstMatch(line);
        if (aliasMatch != null) {
          final alias = aliasMatch.group(1)!;
          final type = aliasMatch.group(2)!;
          final cond = aliasMatch.group(3)!.trim();
          final constraints = _parseConstraints(cond);
          builder.when(alias, type, constraints: constraints);
        }
      }
    }
  }

  static List<Constraint> _parseConstraints(String conditions) {
    final constraints = <Constraint>[];
    if (conditions.isEmpty) return constraints;

    final parts = <String>[];
    var current = StringBuffer();
    var parenDepth = 0;
    var inQuotes = false;
    var quoteChar = '';

    for (var i = 0; i < conditions.length; i++) {
      final char = conditions[i];
      final prevChar = i > 0 ? conditions[i - 1] : '';

      if ((char == '"' || char == "'") && prevChar != r'\') {
        if (!inQuotes) {
          inQuotes = true;
          quoteChar = char;
        } else if (char == quoteChar) {
          inQuotes = false;
        }
        current.write(char);
      } else if (char == '(' && !inQuotes) {
        parenDepth++;
        current.write(char);
      } else if (char == ')' && !inQuotes) {
        parenDepth--;
        current.write(char);
      } else if (char == ',' && parenDepth == 0 && !inQuotes) {
        final part = current.toString().trim();
        if (part.isNotEmpty) parts.add(part);
        current.clear();
      } else {
        current.write(char);
      }
    }

    final lastPart = current.toString().trim();
    if (lastPart.isNotEmpty) parts.add(lastPart);

    for (var cond in parts) {
      cond = cond.trim();
      if (cond.isEmpty) continue;

      final c = _parseConstraint(cond);
      if (c != null) constraints.add(c);
    }

    return constraints;
  }

  static Constraint? _parseConstraint(String condition) {
    condition = condition.trim();
    if (condition.isEmpty) return null;

    // in operator
    if (condition.contains(' in ')) {
      final parts = condition.split(RegExp(r'\s+in\s+'));
      if (parts.length == 2) {
        final field = parts[0].trim();
        final listStr = parts[1].trim();
        final listMatch = RegExp(
          r'[\(\[]\s*(.+?)\s*[\)\]]',
          dotAll: true,
        ).firstMatch(listStr);
        if (listMatch != null) {
          final items =
              listMatch
                  .group(1)!
                  .split(',')
                  .map((s) => _parseValue(s.trim()))
                  .toList();
          return Constraint(field, Operator.inList, items);
        }
      }
    }

    final operators = {
      '>=': Operator.greaterThanOrEqual,
      '<=': Operator.lessThanOrEqual,
      '==': Operator.equals,
      '!=': Operator.notEquals,
      '>': Operator.greaterThan,
      '<': Operator.lessThan,
    };

    for (final entry in operators.entries) {
      if (condition.contains(entry.key)) {
        final parts = condition.split(RegExp(RegExp.escape(entry.key)));
        if (parts.length == 2) {
          final field = parts[0].trim();
          final value = _parseValue(parts[1].trim());
          return Constraint(field, entry.value, value);
        }
      }
    }

    // boolean checks like isDeceased == false
    if (condition.endsWith(' == true')) {
      final field = condition.replaceAll(' == true', '').trim();
      return Constraint(field, Operator.equals, true);
    }
    if (condition.endsWith(' == false')) {
      final field = condition.replaceAll(' == false', '').trim();
      return Constraint(field, Operator.equals, false);
    }
    if (condition.endsWith(' != true')) {
      final field = condition.replaceAll(' != true', '').trim();
      return Constraint(field, Operator.notEquals, true);
    }
    if (condition.endsWith(' != false')) {
      final field = condition.replaceAll(' != false', '').trim();
      return Constraint(field, Operator.notEquals, false);
    }

    return Constraint(condition, Operator.equals, true);
  }

  static dynamic _parseValue(String value) {
    value = value.trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    final numValue = num.tryParse(value);
    if (numValue != null) return numValue;
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    if (value.toLowerCase() == 'null') return null;
    return value;
  }

  // THEN execution

  static void _executeThenBlock(
    String thenContent,
    Map<String, Fact> bindings,
    RuleEngine engine,
    Function(String)? printCallback,
  ) {
    final statements = _splitStatements(thenContent);
    for (var statement in statements) {
      statement = statement.trim();
      if (statement.isEmpty) continue;
      try {
        _executeStatement(statement, bindings, engine, printCallback);
      } catch (e) {
        print('Error executing "$statement": $e');
      }
    }
  }

  static List<String> _splitStatements(String content) {
    final statements = <String>[];
    var current = StringBuffer();
    var inString = false;
    var stringChar = '';
    var braceDepth = 0;

    for (var i = 0; i < content.length; i++) {
      final char = content[i];
      final prevChar = i > 0 ? content[i - 1] : '';

      if ((char == '"' || char == "'") && prevChar != r'\') {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
        current.write(char);
        continue;
      }

      if (!inString) {
        if (char == '{') braceDepth++;
        if (char == '}') braceDepth--;

        if (char == ';' && braceDepth == 0) {
          final stmt = current.toString().trim();
          if (stmt.isNotEmpty) statements.add(stmt);
          current.clear();
          continue;
        }
      }

      current.write(char);
    }

    final stmt = current.toString().trim();
    if (stmt.isNotEmpty) statements.add(stmt);
    return statements;
  }

  static void _executeStatement(
    String statement,
    Map<String, Fact> bindings,
    RuleEngine engine,
    Function(String)? printCallback,
  ) {
    // print(...)
    if (statement.startsWith('print(')) {
      final match = RegExp(
        r'print\((.*)\)$',
        dotAll: true,
      ).firstMatch(statement);
      if (match != null) {
        final message = _evaluateExpression(match.group(1)!, bindings, engine);
        if (printCallback != null) {
          printCallback(message.toString());
        } else {
          print(message);
        }
      }
      return;
    }

    // retract($alias)
    if (statement.startsWith('retract(')) {
      final match = RegExp(r'retract\(\s*\$(\w+)\s*\)').firstMatch(statement);
      if (match != null) {
        final alias = match.group(1)!;
        if (bindings.containsKey(alias)) {
          engine.retract(bindings[alias]!);
        }
      }
      return;
    }

    // $alias.set("field", value)
    final setMatch = RegExp(
      r'\$(\w+)\.set\(\s*"([^"]+)"\s*,\s*(.+)\s*\)',
    ).firstMatch(statement);
    if (setMatch != null) {
      final alias = setMatch.group(1)!;
      final field = setMatch.group(2)!;
      final valueExpr = setMatch.group(3)!.trim();

      if (bindings.containsKey(alias)) {
        final value = _evaluateExpression(valueExpr, bindings, engine);
        bindings[alias]!.set(field, value);
      }
      return;
    }

    // global map operations & list ops
    final globalOps = _handleGlobalOperations(statement, bindings, engine);
    if (globalOps.handled) return;

    // if (...) { ... } else { ... }
    if (statement.startsWith('if ')) {
      _handleIfStatement(statement, bindings, engine, printCallback);
      return;
    }

    // for (var x : collection) { ... }
    if (statement.startsWith('for ')) {
      _handleForLoop(statement, bindings, engine, printCallback);
      return;
    }

    // assignment var = expr  -> put into globals as convenience
    final assignMatch = RegExp(r'(\w+)\s*=\s*(.+)').firstMatch(statement);
    if (assignMatch != null) {
      final varName = assignMatch.group(1)!;
      final valueExpr = assignMatch.group(2)!;
      final value = _evaluateExpression(valueExpr, bindings, engine);
      engine.setGlobal(varName, value);
      return;
    }
  }

  static _GlobalOpResult _handleGlobalOperations(
    String statement,
    Map<String, Fact> bindings,
    RuleEngine engine,
  ) {
    // Map.put(mapName.put(keyExpr, valueExpr))
    final mapPutMatch = RegExp(
      r'(\w+)\.put\(\s*(.+?)\s*,\s*(.+?)\s*\)',
    ).firstMatch(statement);
    if (mapPutMatch != null) {
      final mapName = mapPutMatch.group(1)!;
      final keyExpr = mapPutMatch.group(2)!.trim();
      final valueExpr = mapPutMatch.group(3)!.trim();

      final map = engine.getGlobal(mapName);
      if (map is Map) {
        final key = _evaluateExpression(keyExpr, bindings, engine);
        final value = _evaluateExpression(valueExpr, bindings, engine);
        map[key] = value;
      }
      return _GlobalOpResult(true);
    }

    // map[key] = value
    final mapIndexMatch = RegExp(
      r'(\w+)\s*\[\s*(.+?)\s*\]\s*=\s*(.+)',
    ).firstMatch(statement);
    if (mapIndexMatch != null) {
      final mapName = mapIndexMatch.group(1)!;
      final keyExpr = mapIndexMatch.group(2)!.trim();
      final valueExpr = mapIndexMatch.group(3)!.trim();

      final map = engine.getGlobal(mapName);
      if (map is Map) {
        final key = _evaluateExpression(keyExpr, bindings, engine);
        final value = _evaluateExpression(valueExpr, bindings, engine);
        map[key] = value;
      }
      return _GlobalOpResult(true);
    }

    // list.add(value)
    final listAddMatch = RegExp(
      r'(\w+)\.add\(\s*(.+?)\s*\)',
    ).firstMatch(statement);
    if (listAddMatch != null) {
      final listName = listAddMatch.group(1)!;
      final valueExpr = listAddMatch.group(2)!.trim();

      final list = engine.getGlobal(listName);
      if (list is List) {
        final value = _evaluateExpression(valueExpr, bindings, engine);
        list.add(value);
      }
      return _GlobalOpResult(true);
    }

    return _GlobalOpResult(false);
  }

  static void _handleIfStatement(
    String statement,
    Map<String, Fact> bindings,
    RuleEngine engine,
    Function(String)? printCallback,
  ) {
    final match = RegExp(
      r'if\s*\((.+?)\)\s*\{(.+?)\}(?:\s*else\s*\{(.+?)\})?',
      dotAll: true,
    ).firstMatch(statement);
    if (match != null) {
      final condition = match.group(1)!.trim();
      final thenBody = match.group(2)!.trim();
      final elseBody = match.group(3)?.trim();

      final result = _evaluateCondition(condition, bindings, engine);
      if (result) {
        _executeThenBlock(thenBody, bindings, engine, printCallback);
      } else if (elseBody != null) {
        _executeThenBlock(elseBody, bindings, engine, printCallback);
      }
    }
  }

  static void _handleForLoop(
    String statement,
    Map<String, Fact> bindings,
    RuleEngine engine,
    Function(String)? printCallback,
  ) {
    final match = RegExp(
      r'for\s*\(\s*(?:Object|var|final)\s+(\w+)\s*:\s*(.+?)\)\s*\{(.+?)\}',
      dotAll: true,
    ).firstMatch(statement);
    if (match != null) {
      final varName = match.group(1)!;
      final collectionExpr = match.group(2)!.trim();
      final body = match.group(3)!.trim();

      final collection = _evaluateExpression(collectionExpr, bindings, engine);

      if (collection is List) {
        for (final item in collection) {
          final loopBindings = Map<String, Fact>.from(bindings);
          if (item is Fact) {
            loopBindings[varName] = item;
          } else {
            // for non-fact items put them into engine globals temporarily so expressions can reference them
            engine.setGlobal(varName, item);
          }
          _executeThenBlock(body, loopBindings, engine, printCallback);
        }
      }
    }
  }

  static bool _evaluateCondition(
    String condition,
    Map<String, Fact> bindings,
    RuleEngine engine,
  ) {
    condition = condition.trim();

    if (condition.contains(' && ')) {
      final parts = condition.split(' && ');
      return parts.every(
        (part) => _evaluateCondition(part.trim(), bindings, engine),
      );
    }

    if (condition.contains(' || ')) {
      final parts = condition.split(' || ');
      return parts.any(
        (part) => _evaluateCondition(part.trim(), bindings, engine),
      );
    }

    if (condition.startsWith('!')) {
      return !_evaluateCondition(
        condition.substring(1).trim(),
        bindings,
        engine,
      );
    }

    final operators = {
      '==': (a, b) => a == b,
      '!=': (a, b) => a != b,
      '>=': (a, b) => (a is num && b is num) ? a >= b : false,
      '<=': (a, b) => (a is num && b is num) ? a <= b : false,
      '>': (a, b) => (a is num && b is num) ? a > b : false,
      '<': (a, b) => (a is num && b is num) ? a < b : false,
    };

    for (final entry in operators.entries) {
      if (condition.contains(entry.key)) {
        final parts = condition.split(entry.key);
        if (parts.length == 2) {
          final left = _evaluateExpression(parts[0].trim(), bindings, engine);
          final right = _evaluateExpression(parts[1].trim(), bindings, engine);
          return entry.value(left, right);
        }
      }
    }

    final result = _evaluateExpression(condition, bindings, engine);
    if (result is bool) return result;
    return false;
  }

  static dynamic _evaluateExpression(
    String expr,
    Map<String, Fact> bindings,
    RuleEngine engine,
  ) {
    expr = expr.trim();

    // concatenation with plus
    if (expr.contains(' + ')) {
      final parts = _splitByOperator(expr, '+');
      if (parts.length > 1) {
        final results =
            parts
                .map((p) => _evaluateExpression(p.trim(), bindings, engine))
                .toList();
        return results.map((r) => r?.toString() ?? '').join();
      }
    }

    // string literal
    if ((expr.startsWith('"') && expr.endsWith('"')) ||
        (expr.startsWith("'") && expr.endsWith("'"))) {
      return expr.substring(1, expr.length - 1);
    }

    // property access: $var.field
    final propMatch = RegExp(r'(\$\w+)\.(\w+)').firstMatch(expr);
    if (propMatch != null) {
      final varName = propMatch.group(1)!.substring(1);
      final propName = propMatch.group(2)!;
      if (bindings.containsKey(varName)) {
        return bindings[varName]!.get(propName);
      }
    }

    // array / map access: name[key] or $var[key]
    final indexMatch = RegExp(r'(\$?\w+)\[(.+?)\]').firstMatch(expr);
    if (indexMatch != null) {
      final objectExpr = indexMatch.group(1)!;
      final keyExpr = indexMatch.group(2)!.trim();

      dynamic object;
      if (objectExpr.startsWith(r'$')) {
        final varName = objectExpr.substring(1);
        object = bindings[varName];
      } else {
        object = engine.getGlobal(objectExpr);
      }

      if (object != null) {
        final key = _evaluateExpression(keyExpr, bindings, engine);

        if (object is Map) {
          return object[key];
        }
        if (object is List && key is int) {
          return object[key];
        }
      }

      return null;
    }

    // variable reference: $var
    if (expr.startsWith(r'$')) {
      final varName = expr.substring(1);
      if (bindings.containsKey(varName)) return bindings[varName];
      final g = engine.getGlobal(varName);
      if (g != null) return g;
      return null;
    }

    // method calls like var.size() or $list.length()
    final methodMatch = RegExp(r'(\$?\w+)\.(\w+)\((.*?)\)').firstMatch(expr);
    if (methodMatch != null) {
      final objectExpr = methodMatch.group(1)!;
      final methodName = methodMatch.group(2)!;
      final object = _evaluateExpression(objectExpr, bindings, engine);

      if (methodName == 'size' && object is List) return object.length;
      if (methodName == 'length' && (object is List || object is String))
        return object.length;
      return null;
    }

    // global variable literal (e.g. shares)
    final globalValue = engine.getGlobal(expr);
    if (globalValue != null) return globalValue;

    // numeric literal
    final numValue = num.tryParse(expr);
    if (numValue != null) return numValue;

    if (expr.toLowerCase() == 'true') return true;
    if (expr.toLowerCase() == 'false') return false;
    if (expr.toLowerCase() == 'null') return null;

    return expr;
  }

  static List<String> _splitByOperator(String expr, String operator) {
    final parts = <String>[];
    var current = StringBuffer();
    var parenDepth = 0;
    var inString = false;
    var stringChar = '';

    for (var i = 0; i < expr.length; i++) {
      final char = expr[i];
      final prevChar = i > 0 ? expr[i - 1] : '';

      if ((char == '"' || char == "'") && prevChar != r'\') {
        if (!inString) {
          inString = true;
          stringChar = char;
        } else if (char == stringChar) {
          inString = false;
        }
        current.write(char);
        continue;
      }

      if (!inString) {
        if (char == '(') parenDepth++;
        if (char == ')') parenDepth--;

        if (char == operator && parenDepth == 0) {
          parts.add(current.toString());
          current.clear();
          continue;
        }
      }

      current.write(char);
    }

    parts.add(current.toString());
    return parts;
  }
}

class _GlobalOpResult {
  final bool handled;
  _GlobalOpResult(this.handled);
}

// -----------------------------------------------------------------------------
// Decision table parser preserved (unchanged except small helper names)
// -----------------------------------------------------------------------------

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

    if (tableStartRow == -1) return rules;

    String? ruleNamePrefix;
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

      final cells = lines[i].split(',');
      if (cells.isNotEmpty) {
        final key = cells[0].toLowerCase().trim();
        final value = cells.length > 1 ? cells[1].trim() : '';

        if (key == 'name') ruleNamePrefix = value;
        if (key == 'salience') salience = int.tryParse(value) ?? 0;
        if (key == 'agenda-group') agendaGroup = value;
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
          .name(ruleNamePrefix != null ? '$ruleNamePrefix-Row$i' : 'Rule-Row$i')
          .salience(salience);

      if (agendaGroup != null) ruleBuilder.agendaGroup(agendaGroup);

      for (final idx in conditionIndices) {
        if (idx < templateRow.length &&
            idx < cells.length &&
            cells[idx].isNotEmpty) {
          final template = templateRow[idx];
          final value = cells[idx];
          _addConditionFromTemplate(ruleBuilder, template, value);
        }
      }

      final actions = <String>[];
      for (final idx in actionIndices) {
        if (idx < templateRow.length &&
            idx < cells.length &&
            cells[idx].isNotEmpty) {
          final template = templateRow[idx];
          final value = cells[idx];
          final action = template.replaceAll(RegExp(r'\$\d+'), value);
          actions.add(action);
        }
      }

      ruleBuilder.then((bindings, engine) {
        for (final action in actions) {
          // simple executor for decision table actions
          // only supports $var.set("field","value") patterns here
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

    final parts =
        replacedCondition
            .split(RegExp(r'\s*,\s*'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
    for (final p in parts) {
      final c = _parseConstraintFromTemplate(p);
      if (c != null) {
        builder.when(alias, type, constraints: [c]);
      }
    }
  }

  static Constraint? _parseConstraintFromTemplate(String condition) {
    condition = condition.trim();

    final operators = {
      '>=': Operator.greaterThanOrEqual,
      '<=': Operator.lessThanOrEqual,
      '>': Operator.greaterThan,
      '<': Operator.lessThan,
      '==': Operator.equals,
      '!=': Operator.notEquals,
    };

    for (final entry in operators.entries) {
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
    if (value.startsWith('"') && value.endsWith('"'))
      return value.substring(1, value.length - 1);
    final n = num.tryParse(value);
    if (n != null) return n;
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    return value;
  }
}
