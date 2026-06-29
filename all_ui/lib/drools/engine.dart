import 'dart:math';

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
  endsWith,
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
        return (value as List).contains(fieldValue);
      case Operator.notInList:
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

  Pattern(
    this.alias,
    this.type, {
    this.constraints = const [],
    this.customPredicate,
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
typedef ActionFunction =
    void Function(Map<String, Fact> bindings, RuleEngine engine);

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

  Rule copyWith({
    String? name,
    String? description,
    int? salience,
    String? agendaGroup,
    String? activationGroup,
    bool? noLoop,
    bool? lockOnActive,
    List<Pattern>? when,
    ActionFunction? then,
    bool? enabled,
  }) {
    return Rule(
      name: name ?? this.name,
      description: description ?? this.description,
      salience: salience ?? this.salience,
      agendaGroup: agendaGroup ?? this.agendaGroup,
      activationGroup: activationGroup ?? this.activationGroup,
      noLoop: noLoop ?? this.noLoop,
      lockOnActive: lockOnActive ?? this.lockOnActive,
      when: when ?? this.when,
      then: then ?? this.then,
      enabled: enabled ?? this.enabled,
    );
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
  /// Remove a rule by name
  bool removeRule(String name) {
    final initialCount = _rules.length;
    _rules.removeWhere((r) => r.name == name);
    final finalCount = _rules.length;
    return finalCount < initialCount;
  }

  /// Enable/disable a rule
  void setRuleEnabled(String name, bool enabled) {
    final rule = _rules.firstWhere((r) => r.name == name);
    rule.enabled = enabled;
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

  /// Update a fact (retract and re-insert)
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

  /// Get execution log
  List<String> getExecutionLog() => List.unmodifiable(_executionLog);

  /// Clear execution log
  void clearLog() {
    _executionLog.clear();
  }

  /// Set current agenda group
  void setFocus(String? agendaGroup) {
    _currentAgendaGroup = agendaGroup;
  }

  /// Execute all matching rules
  void fireAllRules() {
    _executionLog.clear();
    _firedActivationGroups.clear();
    var iterations = 0;
    var totalFired = 0;
    const maxIterations = 3; // Very conservative limit
    final firedRules = <String>{}; // Track which rules have fired

    while (iterations < maxIterations) {
      final fired = _fireOnce(firedRules);
      totalFired += fired;

      if (fired == 0) break;
      iterations++;
    }

    _performRetractions();
    print('Total rules fired: $totalFired in $iterations iterations');
  }

  /// Fire until a condition is met
  /*   void fireUntilHalt(bool Function() haltCondition) {
    var iterations = 0;

    while (iterations < maxExecutions && !haltCondition()) {
      final fired = _fireOnce(firedRules);
      if (fired == 0) break;
      iterations++;
    }

    _performRetractions();
  } */

  /// Fire rules once
  int _fireOnce(Set<String> firedRules) {
    var firedCount = 0;
    final eligibleRules = _getEligibleRules();

    print('🔍 Checking ${eligibleRules.length} eligible rules');
    print('📝 Already fired rules: $firedRules');

    for (final rule in eligibleRules) {
      print('🔍 Evaluating rule: ${rule.name}');

      if (!rule.enabled) {
        print('⏭️  Rule disabled: ${rule.name}');
        continue;
      }

      if (firedRules.contains(rule.name)) {
        print('⏭️  Rule already fired: ${rule.name}');
        continue;
      }

      final matches = _findMatches(rule);
      print('🔍 Rule ${rule.name} has ${matches.length} matches');

      if (matches.isEmpty) continue;

      for (final bindings in matches.take(1)) {
        print('🔥 FIRING RULE: ${rule.name}');

        rule.executionCount++;
        rule.lastFired = DateTime.now();
        rule.then(bindings, this);
        firedCount++;

        firedRules.add(rule.name);
        print('✅ Marked rule as fired: ${rule.name}');
        print('📝 Updated fired rules: $firedRules');

        break;
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

  /// Get statistics
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

  RuleBuilder noLoop(bool value) {
    _noLoop = value;
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

  RuleBuilder lockOnActive(bool value) {
    _lockOnActive = value;
    return this;
  }

  RuleBuilder when(
    String alias,
    String type, {
    List<Constraint>? constraints,
    bool Function(Fact, Map<String, Fact>)? predicate,
  }) {
    _patterns.add(
      Pattern(
        alias,
        type,
        constraints: constraints ?? [],
        customPredicate: predicate,
      ),
    );
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
      noLoop: _noLoop, // Use the builder value
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
  static List<Rule> parse(String drl) {
    final rules = <Rule>[];
    final ruleBlocks = _extractRuleBlocks(drl);

    for (final block in ruleBlocks) {
      try {
        final rule = _parseRule(block);
        if (rule != null) {
          rules.add(rule);
        }
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
    var inRule = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('//')) continue;

      if (line.startsWith('rule ')) {
        if (currentBlock != null) {
          blocks.add(currentBlock);
        }
        currentBlock = line;
        inRule = true;
      } else if (line == 'end' && inRule) {
        if (currentBlock != null) {
          currentBlock += '\n$line';
          blocks.add(currentBlock);
          currentBlock = null;
        }
        inRule = false;
      } else if (inRule && currentBlock != null) {
        currentBlock += '\n$line';
      }
    }

    if (currentBlock != null) {
      blocks.add(currentBlock);
    }

    return blocks;
  }

  static Rule? _parseRule(String block) {
    final builder = RuleBuilder();

    // Parse rule name
    final nameMatch = RegExp(r'rule\s+"([^"]+)"').firstMatch(block);
    if (nameMatch == null) return null;
    builder.name(nameMatch.group(1)!);

    // Parse salience
    final salienceMatch = RegExp(r'salience\s+(\d+)').firstMatch(block);
    if (salienceMatch != null) {
      builder.salience(int.parse(salienceMatch.group(1)!));
    }

    // Parse agenda-group
    final agendaMatch = RegExp(r'agenda-group\s+"([^"]+)"').firstMatch(block);
    if (agendaMatch != null) {
      builder.agendaGroup(agendaMatch.group(1)!);
    }

    // Parse when section
    final whenMatch = RegExp(
      r'when\s+(.*?)\s+then',
      dotAll: true,
    ).firstMatch(block);
    if (whenMatch != null) {
      final whenContent = whenMatch.group(1)!;
      _parseWhenConditions(whenContent, builder);
    }

    // Parse then section
    final thenMatch = RegExp(
      r'then\s+(.*?)\s+end',
      dotAll: true,
    ).firstMatch(block);
    if (thenMatch != null) {
      final thenContent = thenMatch.group(1)!;
      builder.then((bindings, engine) {
        _executeThenBlock(thenContent, bindings, engine);
      });
    }

    return builder.build();
  }

  static void _parseWhenConditions(String whenContent, RuleBuilder builder) {
    final patterns = RegExp(
      r'\$(\w+)\s*:\s*(\w+)\s*\(([^)]*)\)',
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
          if (cond.isEmpty) continue;

          final constraint = _parseSimpleConstraint(cond);
          if (constraint != null) {
            constraints.add(constraint);
          }
        }
      }

      builder.when(alias, type, constraints: constraints);
    }
  }

  static Constraint? _parseSimpleConstraint(String condition) {
    condition = condition.trim();

    // Handle "in" operator
    if (condition.contains(' in [')) {
      final inMatch = RegExp(
        r'(\w+)\s+in\s+\[([^\]]+)\]',
      ).firstMatch(condition);
      if (inMatch != null) {
        final field = inMatch.group(1)!;
        final values =
            inMatch
                .group(2)!
                .split(',')
                .map((v) => v.trim().replaceAll('"', ''))
                .toList();
        return Constraint(field, Operator.inList, values);
      }
    }

    // Handle == operator
    if (condition.contains('==')) {
      final parts = condition.split('==');
      if (parts.length == 2) {
        final field = parts[0].trim();
        final value = _parseValue(parts[1].trim());
        return Constraint(field, Operator.equals, value);
      }
    }

    // Handle != operator
    if (condition.contains('!=')) {
      final parts = condition.split('!=');
      if (parts.length == 2) {
        final field = parts[0].trim();
        final value = _parseValue(parts[1].trim());
        return Constraint(field, Operator.notEquals, value);
      }
    }

    return null;
  }

  static List<String> _splitConditions(String conditions) {
    final parts = <String>[];
    var current = '';
    var parenCount = 0;

    for (var i = 0; i < conditions.length; i++) {
      final char = conditions[i];

      if (char == '(') parenCount++;
      if (char == ')') parenCount--;

      if (char == ',' && parenCount == 0) {
        parts.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }

    if (current.trim().isNotEmpty) {
      parts.add(current.trim());
    }

    return parts;
  }

  static List<Constraint> _parseConditionString(String conditions) {
    final constraints = <Constraint>[];
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

  static Constraint? _parseConstraint(String condition) {
    condition = condition.trim();

    // Handle "in" operator for lists
    if (condition.contains(' in [')) {
      final inMatch = RegExp(
        r'(\w+)\s+in\s+\[([^\]]+)\]',
      ).firstMatch(condition);
      if (inMatch != null) {
        final field = inMatch.group(1)!;
        final values =
            inMatch
                .group(2)!
                .split(',')
                .map((v) => v.trim().replaceAll('"', ''))
                .toList();
        return Constraint(field, Operator.inList, values);
      }
    }

    // Handle standard operators
    final operatorPatterns = {
      '==': Operator.equals,
      '!=': Operator.notEquals,
      '>=': Operator.greaterThanOrEqual,
      '<=': Operator.lessThanOrEqual,
      '>': Operator.greaterThan,
      '<': Operator.lessThan,
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

    // Remove quotes
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }

    // Parse boolean
    if (value == 'true') return true;
    if (value == 'false') return false;

    return value;
  }

  static void _executeThenBlock(
    String thenContent,
    Map<String, Fact> bindings,
    RuleEngine engine,
  ) {
    final lines = thenContent.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Handle print statements
      if (line.startsWith('print(')) {
        final printMatch = RegExp(
          r'print\("([^"]+)"\s*\+\s*([^)]+)\)',
        ).firstMatch(line);
        if (printMatch != null) {
          final message = printMatch.group(1)!;
          final variable = printMatch.group(2)!;
          final fact = _getFactFromVariable(variable, bindings);
          if (fact != null) {
            print('$message${fact.get("name")}');
          }
        }
      }

      // Handle share assignments
      final shareMatch = RegExp(
        r'shares\[([^]]+)\] = ([0-9.]+)',
      ).firstMatch(line);
      if (shareMatch != null) {
        final variable = shareMatch
            .group(1)!
            .replaceAll('\$', '')
            .replaceAll('.id', '');
        final value = double.parse(shareMatch.group(2)!);

        final shares = engine.getGlobal('shares') as Map<String, double>;
        final fact = bindings[variable];
        if (fact != null) {
          shares[fact.get('id')] = value;
          print('✅ ASSIGNED SHARE: ${fact.get("name")} gets $value');
        }
      }

      // Handle reason assignments
      final reasonMatch = RegExp(
        r'reasons\[([^]]+)\] = "([^"]+)"',
      ).firstMatch(line);
      if (reasonMatch != null) {
        final variable = reasonMatch
            .group(1)!
            .replaceAll('\$', '')
            .replaceAll('.id', '');
        final reason = reasonMatch.group(2)!;

        final reasons = engine.getGlobal('reasons') as Map<String, String>;
        final fact = bindings[variable];
        if (fact != null) {
          reasons[fact.get('id')] = reason;
        }
      }

      // Handle executionLog additions
      if (line.startsWith('executionLog.add(')) {
        final logMatch = RegExp(
          r'executionLog.add\("([^"]+)"\)',
        ).firstMatch(line);
        if (logMatch != null) {
          final message = logMatch.group(1)!;
          final log = engine.getGlobal('executionLog') as List<String>;
          log.add(message);
        }
      }
    }
  }

  static Fact? _getFactFromVariable(
    String variable,
    Map<String, Fact> bindings,
  ) {
    variable = variable.replaceAll('\$', '').replaceAll('.name', '');
    return bindings[variable];
  }
}

// ============================================================================
// DECISION TABLE PARSER (Excel/CSV Format)
// ============================================================================

class DecisionTableParser {
  /// Parse CSV decision table
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

  /// Parse table structure
  static List<Rule> _parseTable(List<String> lines) {
    final rules = <Rule>[];

    // Find RuleTable keyword
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

    // Parse metadata rows
    String? ruleName;
    int salience = 0;
    String? agendaGroup;

    var headerRow = tableStartRow + 1;

    // Look for metadata
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

      // Check for name, salience, etc.
      if (lines[i].toLowerCase().contains('name')) {
        ruleName = lines[i].split(',').skip(1).first.trim();
      }
      if (lines[i].toLowerCase().contains('salience')) {
        salience = int.tryParse(lines[i].split(',').skip(1).first.trim()) ?? 0;
      }
    }

    // Parse header
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

    // Parse template row (patterns)
    if (headerRow + 1 >= lines.length) return rules;

    final templateRow =
        lines[headerRow + 1].split(',').map((c) => c.trim()).toList();

    // Parse data rows
    for (var i = headerRow + 2; i < lines.length; i++) {
      final cells = lines[i].split(',').map((c) => c.trim()).toList();
      if (cells.isEmpty || cells[0].isEmpty) continue;

      final ruleBuilder = RuleBuilder()
          .name(ruleName != null ? '$ruleName-$i' : 'Rule-$i')
          .salience(salience);

      if (agendaGroup != null) {
        ruleBuilder.agendaGroup(agendaGroup);
      }

      // Build conditions
      for (final idx in conditionIndices) {
        if (idx < cells.length && cells[idx].isNotEmpty) {
          final template = templateRow[idx];
          final value = cells[idx];

          _addConditionFromTemplate(ruleBuilder, template, value);
        }
      }

      // Build actions
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
    // Parse template like: $customer: Customer(age > $1)
    final match = RegExp(r'\$(\w+):\s*(\w+)\((.*?)\)').firstMatch(template);
    if (match == null) return;

    final alias = match.group(1)!;
    final type = match.group(2)!;
    final condition = match.group(3)!;

    // Replace $1, $2, etc. with actual values
    final replacedCondition = condition.replaceAll(RegExp(r'\$\d+'), value);

    // Parse the condition
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
    // Simple action execution
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
