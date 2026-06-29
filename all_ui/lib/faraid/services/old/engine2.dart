// Production-Ready Rule Engine Implementation in Dart (Drools-like)
// Optimized for Islamic Inheritance (Faraid) Calculations
// Supports DRL, Excel/CSV Decision Tables

import 'dart:convert';
import 'dart:math';

// ============================================================================
// CORE MODELS
// ============================================================================

/// Represents a fact in the working memory
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
  
  /// Call a method on the fact (for DRL compatibility)
  dynamic call(String method, [List<dynamic> args = const []]) {
    if (method == 'set' && args.length == 2) {
      set(args[0].toString(), args[1]);
      return null;
    }
    return null;
  }

  @override
  String toString() => 'Fact($type, $attributes)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Operators for conditions
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
  endsWith
}

/// Represents a single condition constraint
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
        return fieldValue.toString().contains(value.toString());
      case Operator.notContains:
        if (fieldValue is List) return !fieldValue.contains(value);
        return !fieldValue.toString().contains(value.toString());
      case Operator.matches:
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
        return fieldValue.toString().startsWith(value.toString());
      case Operator.endsWith:
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

/// Represents a pattern to match facts
class Pattern {
  final String alias;
  final String type;
  final List<Constraint> constraints;
  final bool Function(Fact, Map<String, Fact>)? customPredicate;
  final bool isNegated; // For "not exists"
  final bool isExists; // For "exists"

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

    // Evaluate constraints
    for (final constraint in constraints) {
      if (!constraint.evaluate(fact)) return false;
    }

    // Evaluate custom predicate
    if (customPredicate != null) {
      bindings[alias] = fact;
      return customPredicate!(fact, bindings);
    }

    return true;
  }
}

/// Action function type
typedef ActionFunction = void Function(
  Map<String, Fact> bindings,
  RuleEngine engine,
);

/// Represents a rule in the engine
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
    final key = bindings.entries.map((e) => '${e.key}:${e.value.id}').join(',');
    return _firedForBindings.contains(key);
  }

  void markFiredForBindings(Map<String, Fact> bindings) {
    final key = bindings.entries.map((e) => '${e.key}:${e.value.id}').join(',');
    _firedForBindings.add(key);
  }

  void resetFiredBindings() {
    _firedForBindings.clear();
  }

  @override
  String toString() => 'Rule($name, salience: $salience, enabled: $enabled)';
}

// ============================================================================
// RULE ENGINE
// ============================================================================

class RuleEngine {
  final List<Rule> _rules = [];
  final List<Fact> _workingMemory = [];
  final Set<Fact> _factsToRetract = {};
  final List<String> _executionLog = [];
  final Map<String, dynamic> _globals = {};
  final Set<String> _firedActivationGroups = {};
  String? _currentAgendaGroup;

  /// Configuration
  int maxExecutions = 1000;
  bool logExecution = true;
  bool enableTruthMaintenance = false;

  /// Add a rule to the engine
  void addRule(Rule rule) {
    _rules.add(rule);
    _sortRules();
  }

  /// Add multiple rules
  void addRules(List<Rule> rules) {
    _rules.addAll(rules);
    _sortRules();
  }

  /// Remove a rule by name
  bool removeRule(String name) {
    final removed = _rules.removeWhere((r) => r.name == name);
    return removed > 0;
  }

  /// Enable/disable a rule
  void setRuleEnabled(String name, bool enabled) {
    try {
      final rule = _rules.firstWhere((r) => r.name == name);
      rule.enabled = enabled;
    } catch (e) {
      print('Warning: Rule "$name" not found');
    }
  }

  /// Set a global variable
  void setGlobal(String name, dynamic value) {
    _globals[name] = value;
    _log('Set global: $name = $value');
  }

  /// Get a global variable
  dynamic getGlobal(String name) => _globals[name];

  /// Add a fact to working memory
  Fact insert(Fact fact) {
    _workingMemory.add(fact);
    _log('Inserted fact: ${fact.type} ${fact.attributes}');
    return fact;
  }

  /// Update a fact (for modify operations)
  void update(Fact fact) {
    _log('Updated fact: ${fact.type} ${fact.attributes}');
  }

  /// Mark a fact for retraction
  void retract(Fact fact) {
    _factsToRetract.add(fact);
    _log('Marked for retraction: ${fact.type}');
  }

  /// Get facts by type
  List<Fact> getFactsByType(String type) {
    return _workingMemory.where((f) => f.type == type).toList();
  }

  /// Get all facts
  List<Fact> getAllFacts() => List.unmodifiable(_workingMemory);

  /// Clear all facts from working memory
  void clearFacts() {
    _workingMemory.clear();
    _factsToRetract.clear();
  }

  /// Clear all rules
  void clearRules() {
    _rules.clear();
  }

  /// Reset all rules (clear execution history)
  void resetRules() {
    for (final rule in _rules) {
      rule.executionCount = 0;
      rule.lastFired = null;
      rule.resetFiredBindings();
    }
  }

  /// Get execution log
  List<String> getExecutionLog() => List.unmodifiable(_executionLog);

  /// Clear execution log
  void clearLog() {
    _executionLog.clear();
  }

  /// Set current agenda group
  void setFocus(String? agendaGroup) {
    _currentAgendaGroup = agendaGroup;
    _log('Focus set to: ${agendaGroup ?? "default"}');
  }

  /// Execute all matching rules
  void fireAllRules() {
    _executionLog.clear();
    _firedActivationGroups.clear();
    
    // Reset rule execution tracking
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
      
      // Perform retractions after each iteration
      _performRetractions();
    }

    _log('Total rules fired: $totalFired in $iterations iterations');
  }

  /// Fire until a condition is met
  void fireUntilHalt(bool Function() haltCondition) {
    var iterations = 0;
    
    while (iterations < maxExecutions && !haltCondition()) {
      final fired = _fireOnce();
      if (fired == 0) break;
      iterations++;
      _performRetractions();
    }
  }

  /// Fire rules once
  int _fireOnce() {
    var firedCount = 0;
    final eligibleRules = _getEligibleRules();

    for (final rule in eligibleRules) {
      if (!rule.enabled) continue;

      // Check activation group
      if (rule.activationGroup != null) {
        if (_firedActivationGroups.contains(rule.activationGroup)) continue;
      }

      final matches = _findMatches(rule);

      for (final bindings in matches) {
        // Check no-loop
        if (rule.noLoop && rule.hasBeenFiredForBindings(bindings)) {
          continue;
        }
        
        _log('Firing rule: ${rule.name}');
        
        rule.executionCount++;
        rule.lastFired = DateTime.now();
        rule.markFiredForBindings(bindings);
        
        rule.then(bindings, this);
        firedCount++;

        // Mark activation group as fired
        if (rule.activationGroup != null) {
          _firedActivationGroups.add(rule.activationGroup!);
        }
      }
    }

    return firedCount;
  }

  /// Get rules eligible for current agenda group
  List<Rule> _getEligibleRules() {
    if (_currentAgendaGroup == null) {
      return _rules.where((r) => r.agendaGroup == null).toList();
    }
    return _rules.where((r) => r.agendaGroup == _currentAgendaGroup).toList();
  }

  /// Find all fact combinations that match a rule's patterns
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
    
    // Handle "not exists" pattern
    if (pattern.isNegated) {
      final factsOfType = _workingMemory
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
      
      // Only continue if NO match was found
      if (!foundMatch) {
        _findMatchesRecursive(patterns, patternIndex + 1, currentBindings, matches);
      }
      return;
    }
    
    // Handle "exists" pattern
    if (pattern.isExists) {
      final factsOfType = _workingMemory
          .where((fact) => fact.type == pattern.type)
          .where((fact) => !_factsToRetract.contains(fact))
          .toList();
      
      for (final fact in factsOfType) {
        final newBindings = Map<String, Fact>.from(currentBindings);
        if (pattern.matches(fact, newBindings)) {
          // Found at least one match, continue
          _findMatchesRecursive(patterns, patternIndex + 1, currentBindings, matches);
          return;
        }
      }
      // No match found, stop here
      return;
    }

    // Normal pattern matching
    final factsOfType = _workingMemory
        .where((fact) => fact.type == pattern.type)
        .where((fact) => !_factsToRetract.contains(fact))
        .toList();

    for (final fact in factsOfType) {
      final newBindings = Map<String, Fact>.from(currentBindings);

      if (pattern.matches(fact, newBindings)) {
        newBindings[pattern.alias] = fact;
        _findMatchesRecursive(
          patterns,
          patternIndex + 1,
          newBindings,
          matches,
        );
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

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalRules': _rules.length,
      'enabledRules': _rules.where((r) => r.enabled).length,
      'totalFacts': _workingMemory.length,
      'globals': _globals.keys.toList(),
      'ruleExecutions': _rules.map((r) => {
        'name': r.name,
        'executions': r.executionCount,
        'lastFired': r.lastFired?.toIso8601String(),
      }).toList(),
    };
  }

  @override
  String toString() {
    return 'RuleEngine(rules: ${_rules.length}, facts: ${_workingMemory.length})';
  }
}

// ============================================================================
// RULE BUILDER (Fluent API)
// ============================================================================

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

  RuleBuilder when(String alias, String type, {
    List<Constraint>? constraints,
    bool Function(Fact, Map<String, Fact>)? predicate,
  }) {
    _patterns.add(Pattern(
      alias,
      type,
      constraints: constraints ?? [],
      customPredicate: predicate,
    ));
    return this;
  }
  
  RuleBuilder notExists(String alias, String type, {
    List<Constraint>? constraints,
  }) {
    _patterns.add(Pattern(
      alias,
      type,
      constraints: constraints ?? [],
      isNegated: true,
    ));
    return this;
  }
  
  RuleBuilder exists(String alias, String type, {
    List<Constraint>? constraints,
  }) {
    _patterns.add(Pattern(
      alias,
      type,
      constraints: constraints ?? [],
      isExists: true,
    ));
    return this;
  }

  RuleBuilder then(ActionFunction action) {
    _action = action;
    return this;
  }

  Rule build() {
    if (_name == null) throw StateError('Rule name is required');
    if (_action == null) throw StateError('Rule action is required');

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

// ============================================================================
// DRL PARSER (Drools Rule Language)
// ============================================================================

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
        print('Block: $block');
      }
    }

    return rules;
  }

  static List<String> _extractRuleBlocks(String drl) {
    final blocks = <String>[];
    final buffer = StringBuffer();
    var inRule = false;
    var braceCount = 0;

    for (var line in drl.split('\n')) {
      line = line.trim();
      
      // Skip empty lines and comments outside rules
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
        
        // Count braces to detect end of rule
        if (line.contains('end')) {
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
    final activationMatch = RegExp(r'activation-group\s+"([^"]+)"').firstMatch(block);
    if (activationMatch != null) {
      builder.activationGroup(activationMatch.group(1)!);
    }

    // Parse no-loop
    if (block.contains('no-loop true') || block.contains('no-loop\n')) {
      builder.noLoop(true);
    }

    // Parse when section
    final whenMatch = RegExp(r'when\s+(.*?)\s+then', dotAll: true).firstMatch(block);
    if (whenMatch != null) {
      final whenContent = whenMatch.group(1)!;
      _parseWhenConditions(whenContent, builder);
    }

    // Parse then section
    final thenMatch = RegExp(r'then\s+(.*?)\s+end', dotAll: true).firstMatch(block);
    if (thenMatch != null) {
      final thenContent = thenMatch.group(1)!.trim();
      builder.then((bindings, engine) {
        _executeThenBlock(thenContent, bindings, engine, printCallback);
      });
    }

    return builder.build();
  }

  static void _parseWhenConditions(String whenContent, RuleBuilder builder) {
    // Clean up the content
    whenContent = whenContent.trim();
    
    // Split by lines and process each condition
    final lines = whenContent.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    
    for (var line in lines) {
      // Handle "not exists" pattern
      if (line.startsWith('not exists') || line.startsWith('not FamilyMember')) {
        _parseNotExistsPattern(line, builder);
        continue;
      }
      
      // Handle "exists" pattern
      if (line.startsWith('exists')) {
        _parseExistsPattern(line, builder);
        continue;
      }
      
      // Handle normal pattern
      _parseNormalPattern(line, builder);
    }
  }
  
  static void _parseNotExistsPattern(String line, RuleBuilder builder) {
    // Extract pattern: not exists FamilyMember(relationName == "spouse", ...)
    final match = RegExp(r'not\s+(?:exists\s+)?(\w+)\s*\((.*?)\)').firstMatch(line);
    if (match == null) return;
    
    final type = match.group(1)!;
    final conditions = match.group(2)!.trim();
    
    final constraints = _parseConstraints(conditions);
    builder.notExists('not_$type', type, constraints: constraints);
  }
  
  static void _parseExistsPattern(String line, RuleBuilder builder) {
    final match = RegExp(r'exists\s+(\w+)\s*\((.*?)\)').firstMatch(line);
    if (match == null) return;
    
    final type = match.group(1)!;
    final conditions = match.group(2)!.trim();
    
    final constraints = _parseConstraints(conditions);
    builder.exists('exists_$type', type, constraints: constraints);
  }
  
  static void _parseNormalPattern(String line, RuleBuilder builder) {
    // Extract pattern: $variable: Type(conditions)
    final match = RegExp(r'\$(\w+)\s*:\s*(\w+)\s*\((.*?)\)').firstMatch(line);
    if (match == null) return;
    
    final alias = match.group(1)!;
    final type = match.group(2)!;
    final conditions = match.group(3)!.trim();
    
    final constraints = _parseConstraints(conditions);
    builder.when(alias, type, constraints: constraints);
  }
  
  static List<Constraint> _parseConstraints(String conditions) {
    final constraints = <Constraint>[];
    
    if (conditions.isEmpty) return constraints;
    
    // Split by comma, but respect nested parentheses and quotes
    final parts = _splitConditions(conditions);
    
    for (var cond in parts) {
      cond = cond.trim();
      if (cond.isEmpty) continue;
      
      final constraint = _parseConstraint(cond);
      if (constraint != null) {
        constraints.add(constraint);
      }
    }
    
    return constraints;
  }
  
  static List<String> _splitConditions(String conditions) {
    final parts = <String>[];
    var current = StringBuffer();
    var parenDepth = 0;
    var inQuotes = false;
    
    for (var i = 0; i < conditions.length; i++) {
      final char = conditions[i];
      
      if (char == '"' && (i == 0 || conditions[i-1] != '\\')) {
        inQuotes = !inQuotes;
        current.write(char);
      } else if (char == '(' && !inQuotes) {
        parenDepth++;
        current.write(char);
      } else if (char == ')' && !inQuotes) {
        parenDepth--;
        current.write(char);
      } else if (char == ',' && parenDepth == 0 && !inQuotes) {
        parts.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    
    if (current.isNotEmpty) {
      parts.add(current.toString().trim());
    }
    
    return parts;
  }

  static Constraint? _parseConstraint(String condition) {
    condition = condition.trim();

    // Handle "in" operator - check for list
    if (condition.contains(' in ')) {
      final parts = condition.split(' in ');
      if (parts.length == 2) {
        final field = parts[0].trim();
        final listStr = parts[1].trim();
        
        // Parse list: ("value1", "value2") or ['value1', 'value2']
        final listMatch = RegExp(r'[\(\[](.+?)[\)\]]').firstMatch(listStr);
        if (listMatch != null) {
          final items = listMatch.group(1)!.split(',').map((s) => _parseValue(s.trim())).toList();
          return Constraint(field, Operator.inList, items);
        }
      }
    }

    // Handle different operators
    final operators = {
      '==': Operator.equals,
      '!=': Operator.notEquals,
      '>=': Operator.greaterThanOrEqual,
      '<=': Operator.lessThanOrEqual,
      '>': Operator.greaterThan,
      '<': Operator.lessThan,
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

    // Handle special functions
    if (condition.contains('contains')) {
      final match = RegExp(r'(\w+)\s+contains\s+(.+)').firstMatch(condition);
      if (match != null) {
        return Constraint(match.group(1)!, Operator.contains, _parseValue(match.group(2)!));
      }
    }

    return null;
  }

  static dynamic _parseValue(String value) {
    value = value.trim();
    
    // Remove quotes
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }
    
    // Parse number
    final numValue = num.tryParse(value);
    if (numValue != null) return numValue;
    
    // Parse boolean
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    
    // Parse null
    if (value.toLowerCase() == 'null') return null;
    
    return value;
  }

  static void _executeThenBlock(
    String thenContent,
    Map<String, Fact> bindings,
    RuleEngine engine,
    Function(String)? printCallback,