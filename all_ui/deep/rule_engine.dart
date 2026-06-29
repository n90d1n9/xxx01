import 'yaml_loader.dart';

// =============================================================================
// CORE TYPES AND INTERFACES
// =============================================================================

abstract class ExpressionEvaluator {
  bool evalCondition(dynamic condition, RuleContext context);
  dynamic evalValue(dynamic expression, RuleContext context);
}

abstract class ActionExecutor {
  void execute(dynamic action, RuleContext context);
}

abstract class FactMatcher {
  bool matches(Fact fact, String predicate);
}

class RuleContext {
  final Map<String, dynamic> globals;
  final List<Fact> facts;
  final Map<String, Function> hooks;
  final List<String> executionLog;

  RuleContext({
    Map<String, dynamic>? initialGlobals,
    List<Fact>? initialFacts,
    Map<String, Function>? initialHooks,
    List<String>? initialLog,
  }) : globals = Map<String, dynamic>.from(initialGlobals ?? {}),
       facts = List<Fact>.from(initialFacts ?? []),
       hooks = Map<String, Function>.from(initialHooks ?? {}),
       executionLog = List<String>.from(initialLog ?? []);

  void log(String message) => executionLog.add(message);
  dynamic getGlobal(String key) => globals[key];
  void setGlobal(String key, dynamic value) => globals[key] = value;
}

// =============================================================================
// IMPROVED EXPRESSION EVALUATOR
// =============================================================================

class DefaultExpressionEvaluator implements ExpressionEvaluator, FactMatcher {
  static final _numericRegex = RegExp(r'^-?\d*\.?\d+$');
  static final _quotedStringRegex = RegExp(r'''^["\'](.*)["\']$''');

  @override
  bool evalCondition(dynamic condition, RuleContext context) {
    if (condition is bool) return condition;
    if (condition is num) return condition != 0;
    if (condition is String) {
      return _evalBooleanExpression(condition.trim(), context);
    }
    return false;
  }

  @override
  dynamic evalValue(dynamic expression, RuleContext context) {
    if (expression == null) return null;
    if (expression is num || expression is bool) return expression;
    if (expression is Map || expression is List) return expression;
    if (expression is String)
      return _resolveExpression(expression.trim(), context);
    return expression;
  }

  @override
  bool matches(Fact fact, String predicate) {
    return _evalPredicateOnFact(predicate, fact);
  }

  // ---------------------------------------------------------------------------
  // Private implementation
  // ---------------------------------------------------------------------------

  bool _evalBooleanExpression(String expression, RuleContext context) {
    if (expression.isEmpty) return false;

    // Handle parentheses
    if (_isParenthesized(expression)) {
      final inner = expression.substring(1, expression.length - 1).trim();
      return _evalBooleanExpression(inner, context);
    }

    // Handle NOT operator
    if (expression.startsWith('not ')) {
      return !_evalBooleanExpression(expression.substring(4).trim(), context);
    }

    // Handle OR (lowest precedence)
    final orParts = _splitByOperator(expression, ' or ');
    if (orParts.length > 1) {
      return orParts.any((part) => _evalBooleanExpression(part, context));
    }

    // Handle AND
    final andParts = _splitByOperator(expression, ' and ');
    if (andParts.length > 1) {
      return andParts.every((part) => _evalBooleanExpression(part, context));
    }

    // Handle comparisons
    for (final op in ['>=', '<=', '==', '!=', '>', '<']) {
      final index = expression.indexOf(op);
      if (index != -1) {
        final left = expression.substring(0, index).trim();
        final right = expression.substring(index + op.length).trim();
        return _evaluateComparison(left, right, op, context);
      }
    }

    // Direct value check
    final value = _resolveExpression(expression, context);
    return _isTruthy(value);
  }

  dynamic _resolveExpression(String expression, RuleContext context) {
    // String literals
    final quotedMatch = _quotedStringRegex.firstMatch(expression);
    if (quotedMatch != null) {
      return quotedMatch.group(1);
    }

    // Numeric literals
    if (_numericRegex.hasMatch(expression)) {
      final numVal = double.parse(expression);
      return numVal == numVal.toInt() ? numVal.toInt() : numVal;
    }

    // Boolean literals
    if (expression == 'true') return true;
    if (expression == 'false') return false;

    // Global variables
    if (expression.startsWith('global.')) {
      final key = expression.substring(7);
      return context.getGlobal(key);
    }

    // Fact queries
    if (expression.startsWith('facts.')) {
      return _resolveFactQuery(expression.substring(6), context);
    }

    // Default: return as string or try to resolve as global
    return context.getGlobal(expression) ?? expression;
  }

  dynamic _resolveFactQuery(String query, RuleContext context) {
    final dotIndex = query.indexOf('.');
    if (dotIndex == -1) {
      return context.facts.where((f) => f.type == query).toList();
    }

    final typeName = query.substring(0, dotIndex);
    final tail = query.substring(dotIndex + 1);
    final factsOfType = context.facts.where((f) => f.type == typeName).toList();

    if (tail == 'count') {
      return factsOfType.length;
    }

    if (tail.startsWith('where(')) {
      // Find the matching closing parenthesis
      int depth = 1;
      int i = 6; // Start after 'where('

      for (; i < tail.length; i++) {
        if (tail[i] == '(') depth++;
        if (tail[i] == ')') {
          depth--;
          if (depth == 0) break;
        }
      }

      if (i < tail.length) {
        final predicate = tail.substring(6, i);
        final remaining = tail.substring(i + 1);

        print('  Parsed predicate: "$predicate"');

        final filtered =
            factsOfType.where((f) => matches(f, predicate)).toList();

        if (remaining == '.count') {
          return filtered.length;
        }
        return filtered;
      }
    }

    return factsOfType;
  }

  dynamic _getFactFieldValue(String fieldPath, Fact fact) {
    final parts = fieldPath.split('.');
    dynamic current = fact.data;

    for (final part in parts) {
      if (current is Map) {
        // Use dynamic key access for maps
        final dynamicMap = current as Map<dynamic, dynamic>;
        if (dynamicMap.containsKey(part)) {
          current = dynamicMap[part];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return current;
  }

  bool _evaluateComparison(
    String leftExpr,
    String rightExpr,
    String operator,
    RuleContext context,
  ) {
    final left = _resolveExpression(leftExpr, context);
    final right = _resolveExpression(rightExpr, context);

    final comparison = _compareValues(left, right);

    switch (operator) {
      case '==':
        return left == right;
      case '!=':
        return left != right;
      case '>':
        return comparison > 0;
      case '<':
        return comparison < 0;
      case '>=':
        return comparison >= 0;
      case '<=':
        return comparison <= 0;
      default:
        return false;
    }
  }

  int _compareValues(dynamic a, dynamic b) {
    // Numeric comparison
    if (a is num && b is num) {
      return a.compareTo(b);
    }

    // Try to parse strings as numbers
    final aNum = _tryParseNumber(a);
    final bNum = _tryParseNumber(b);
    if (aNum != null && bNum != null) {
      return aNum.compareTo(bNum);
    }

    // String comparison
    return a.toString().compareTo(b.toString());
  }

  double? _tryParseNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  bool _evalPredicateOnFact(String predicate, Fact fact) {
    predicate = predicate.trim();
    if (predicate.isEmpty) return false;

    // Handle parentheses first
    if (_isParenthesized(predicate)) {
      final inner = predicate.substring(1, predicate.length - 1).trim();
      return _evalPredicateOnFact(inner, fact);
    }

    // Handle NOT operator
    if (predicate.startsWith('not ')) {
      return !_evalPredicateOnFact(predicate.substring(4).trim(), fact);
    }

    // Handle OR (check this first for correct precedence)
    final orParts = _splitByOperator(predicate, ' or ');
    if (orParts.length > 1) {
      for (final part in orParts) {
        if (_evalPredicateOnFact(part, fact)) {
          return true;
        }
      }
      return false;
    }

    // Handle AND
    final andParts = _splitByOperator(predicate, ' and ');
    if (andParts.length > 1) {
      for (final part in andParts) {
        if (!_evalPredicateOnFact(part, fact)) {
          return false;
        }
      }
      return true;
    }

    // Handle comparisons
    for (final op in ['>=', '<=', '==', '!=', '>', '<']) {
      final index = predicate.indexOf(op);
      if (index != -1) {
        final left = predicate.substring(0, index).trim();
        final right = predicate.substring(index + op.length).trim();
        return _evaluateFactComparison(left, right, op, fact);
      }
    }

    // Direct field check
    final value = _getFactFieldValue(predicate, fact);
    return _isTruthy(value);
  }

  bool _evaluateFactComparison(
    String left,
    String right,
    String operator,
    Fact fact,
  ) {
    final leftValue = _getFactFieldValue(left, fact);
    final rightValue = _parseLiteral(right);

    return _evaluateComparisonValues(leftValue, rightValue, operator);
  }

  bool _evaluateComparisonValues(dynamic left, dynamic right, String operator) {
    switch (operator) {
      case '==':
        return left == right;
      case '!=':
        return left != right;
      case '>':
        return _compareValues(left, right) > 0;
      case '<':
        return _compareValues(left, right) < 0;
      case '>=':
        return _compareValues(left, right) >= 0;
      case '<=':
        return _compareValues(left, right) <= 0;
      default:
        return false;
    }
  }

  dynamic _parseLiteral(String value) {
    value = value.trim();

    if (value == 'true') return true;
    if (value == 'false') return false;

    final numVal = _tryParseNumber(value);
    if (numVal != null) return numVal;

    // Remove quotes from string literals
    final quotedMatch = _quotedStringRegex.firstMatch(value);
    if (quotedMatch != null) {
      return quotedMatch.group(1);
    }

    return value;
  }

  // ---------------------------------------------------------------------------
  // Utility methods
  // ---------------------------------------------------------------------------

  bool _isParenthesized(String expression) {
    if (!expression.startsWith('(') || !expression.endsWith(')')) return false;

    int depth = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') depth++;
      if (expression[i] == ')') depth--;
      if (depth == 0 && i < expression.length - 1) return false;
    }
    return depth == 0;
  }

  List<String> _splitByOperator(String expression, String operator) {
    final parts = <String>[];
    int depth = 0;
    int start = 0;

    for (int i = 0; i <= expression.length - operator.length; i++) {
      if (expression[i] == '(') depth++;
      if (expression[i] == ')') depth--;

      // Check for operator with proper word boundaries
      if (depth == 0 &&
          expression.startsWith(operator, i) &&
          (i == 0 || expression[i - 1] == ' ') &&
          (i + operator.length == expression.length ||
              expression[i + operator.length] == ' ')) {
        parts.add(expression.substring(start, i).trim());
        start = i + operator.length;
        i = start - 1;
      }
    }

    final lastPart = expression.substring(start).trim();
    if (lastPart.isNotEmpty) {
      parts.add(lastPart);
    }

    return parts.length > 1 ? parts : [expression];
  }

  String _extractParenthesizedContent(String expression) {
    int depth = 1;
    int i = 0;

    for (; i < expression.length; i++) {
      if (expression[i] == '(') depth++;
      if (expression[i] == ')') {
        depth--;
        if (depth == 0) break;
      }
    }

    return expression.substring(0, i);
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return value != null;
  }
}

// =============================================================================
// IMPROVED ACTION EXECUTOR
// =============================================================================
class DefaultActionExecutor implements ActionExecutor {
  final ExpressionEvaluator evaluator;

  DefaultActionExecutor(this.evaluator);

  @override
  void execute(dynamic action, RuleContext context) {
    if (action is Map<dynamic, dynamic>) {
      _executeMapAction(action, context);
    } else if (action is String) {
      _executeStringAction(action, context);
    }
  }

  void _executeMapAction(Map<dynamic, dynamic> action, RuleContext context) {
    final stringAction = _convertToStringKeyedMap(action);

    if (stringAction.containsKey('set')) {
      _executeSet(stringAction['set'], context);
    } else if (stringAction.containsKey('assignShare')) {
      _executeAssignShare(stringAction['assignShare'], context);
    } else if (stringAction.containsKey('computeRemaining')) {
      _executeComputeRemaining(context);
    } else if (stringAction.containsKey('applyAwl')) {
      _executeApplyAwl(context);
    } else if (stringAction.containsKey('applyRadd')) {
      _executeApplyRadd(context);
    } else if (stringAction.containsKey('log')) {
      _executeLog(stringAction['log'], context);
    } else if (stringAction.containsKey('retract')) {
      _executeRetract(stringAction['retract'], context);
    } else if (stringAction.containsKey('modify')) {
      _executeModify(stringAction['modify'], context);
    }
    // Add more direct actions as needed
  }

  void _executeAssignShare(
    Map<String, dynamic> assignAction,
    RuleContext context,
  ) {
    final heir = assignAction['heir']?.toString();
    final share = assignAction['share'];

    if (heir != null && share != null) {
      final shares = context.getGlobal('shares') ?? {};
      final evaluatedShare = _evaluateShare(share, context);
      shares[heir] = evaluatedShare;
      context.setGlobal('shares', shares);
    }
  }

  void _executeComputeRemaining(RuleContext context) {
    final shares = context.getGlobal('shares') ?? {};
    double totalAssigned = 0.0;

    shares.forEach((key, value) {
      if (value is num) {
        totalAssigned += value.toDouble();
      }
    });

    final remaining = 1.0 - totalAssigned;
    context.setGlobal('remainingShare', remaining > 0 ? remaining : 0.0);
  }

  void _executeApplyAwl(RuleContext context) {
    final shares = context.getGlobal('shares') ?? {};
    double totalAssigned = 0.0;

    shares.forEach((key, value) {
      if (value is num) {
        totalAssigned += value.toDouble();
      }
    });

    if (totalAssigned > 1.0) {
      shares.forEach((key, value) {
        if (value is num) {
          shares[key] = value / totalAssigned;
        }
      });
      context.setGlobal('shares', shares);
      context.setGlobal('remainingShare', 0.0);
      context.log('AWL applied: shares reduced proportionally');
    }
  }

  void _executeApplyRadd(RuleContext context) {
    final remaining = context.getGlobal('remainingShare') ?? 0.0;
    final shares = context.getGlobal('shares') ?? {};

    if (remaining > 0) {
      double totalAssigned = 0.0;
      shares.forEach((key, value) {
        if (value is num) {
          totalAssigned += value.toDouble();
        }
      });

      if (totalAssigned > 0) {
        final multiplier = 1.0 / totalAssigned;
        shares.forEach((key, value) {
          if (value is num) {
            shares[key] = value * multiplier;
          }
        });
        context.setGlobal('shares', shares);
        context.setGlobal('remainingShare', 0.0);
        context.log('Radd applied: shares increased proportionally');
      }
    }
  }

  dynamic _evaluateShare(dynamic share, RuleContext context) {
    if (share is num) return share;
    if (share is String) {
      switch (share) {
        case '1/8':
          return 1 / 8;
        case '1/6':
          return 1 / 6;
        case '1/4':
          return 1 / 4;
        case '1/3':
          return 1 / 3;
        case '1/2':
          return 1 / 2;
        case '2/3':
          return 2 / 3;
        default:
          // Try to evaluate as expression
          return evaluator.evalValue(share, context);
      }
    }
    return share;
  }

  Map<String, dynamic> _convertToStringKeyedMap(
    Map<dynamic, dynamic> original,
  ) {
    final result = <String, dynamic>{};
    original.forEach((key, value) {
      final stringKey = key.toString();
      if (value is Map<dynamic, dynamic>) {
        result[stringKey] = _convertToStringKeyedMap(value);
      } else {
        result[stringKey] = value;
      }
    });
    return result;
  }

  void _executeStringAction(String action, RuleContext context) {
    // Handle simple string actions
    if (action.startsWith('log:')) {
      final message = action.substring(4).trim();
      context.log(message);
    }
  }

  void _executeSet(dynamic setAction, RuleContext context) {
    if (setAction is Map<dynamic, dynamic>) {
      final stringKeyedMap = _convertToStringKeyedMap(setAction);
      stringKeyedMap.forEach((key, value) {
        final evaluatedValue = evaluator.evalValue(value, context);
        context.setGlobal(key, evaluatedValue);
      });
    }
  }

  void _executeLog(dynamic logAction, RuleContext context) {
    final message = evaluator.evalValue(logAction, context)?.toString() ?? '';
    context.log(message);
  }

  void _executeRetract(dynamic retractAction, RuleContext context) {
    if (retractAction is Map<dynamic, dynamic>) {
      final stringKeyedMap = _convertToStringKeyedMap(retractAction);
      final type = stringKeyedMap['type']?.toString();
      final predicate = stringKeyedMap['predicate']?.toString();

      if (type != null) {
        context.facts.removeWhere((fact) {
          if (fact.type != type) return false;
          if (predicate == null) return true;
          return evaluator is FactMatcher
              ? (evaluator as FactMatcher).matches(fact, predicate)
              : DefaultExpressionEvaluator().matches(fact, predicate);
        });
      }
    }
  }

  void _executeModify(dynamic modifyAction, RuleContext context) {
    if (modifyAction is Map<dynamic, dynamic>) {
      final stringKeyedMap = _convertToStringKeyedMap(modifyAction);
      final type = stringKeyedMap['type']?.toString();
      final predicate = stringKeyedMap['predicate']?.toString();
      final changes = _convertToStringKeyedMap(stringKeyedMap['changes'] ?? {});

      if (type != null) {
        for (final fact in context.facts) {
          if (fact.type != type) continue;
          if (predicate != null) {
            final matches =
                evaluator is FactMatcher
                    ? (evaluator as FactMatcher).matches(fact, predicate)
                    : DefaultExpressionEvaluator().matches(fact, predicate);
            if (!matches) continue;
          }
          fact.data.addAll(changes);
        }
      }
    }
  }
}

// =============================================================================
// ENHANCED RULE ENGINE
// =============================================================================

class RuleEngine {
  final List<Rule> _rules = [];
  final RuleContext _context;
  final ExpressionEvaluator _evaluator;
  final ActionExecutor _executor;

  bool logExecution = false;
  int maxIterations = 1000;

  RuleEngine({
    ExpressionEvaluator? evaluator,
    ActionExecutor? executor,
    Map<String, dynamic>? initialGlobals,
    Map<String, Function>? hooks,
  }) : _evaluator = evaluator ?? DefaultExpressionEvaluator(),
       _executor =
           executor ??
           DefaultActionExecutor(evaluator ?? DefaultExpressionEvaluator()),
       _context = RuleContext(
         initialGlobals: initialGlobals,
         initialHooks: hooks,
       ) {
    _context.setGlobal('executionLog', _context.executionLog);
    _context.setGlobal('shares', <String, dynamic>{});
    _context.setGlobal('remainingShare', 1.0);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  void registerHook(String name, Function function) {
    _context.hooks[name] = function;
  }

  void setGlobal(String key, dynamic value) {
    _context.setGlobal(key, value);
  }

  dynamic getGlobal(String key) => _context.getGlobal(key);

  void addRule(Rule rule) => _rules.add(rule);

  void addRules(List<Rule> rules) => _rules.addAll(rules);

  void clearRules() => _rules.clear();

  void insert(Fact fact) => _context.facts.add(fact);

  void clearFacts() => _context.facts.clear();

  List<Fact> getFactsByType(String type, {String? predicate}) {
    var facts = _context.facts.where((f) => f.type == type).toList();

    if (predicate != null) {
      facts =
          facts
              .where(
                (f) =>
                    _evaluator is FactMatcher
                        ? (_evaluator as FactMatcher).matches(f, predicate)
                        : DefaultExpressionEvaluator().matches(f, predicate),
              )
              .toList();
    }

    return facts;
  }

  List<Fact> getAllFacts() => List.unmodifiable(_context.facts);

  List<String> getExecutionLog() => List.unmodifiable(_context.executionLog);

  void loadRulesFromYaml(String yamlString) {
    final rules = YamlRuleLoader.load(yamlString);
    addRules(rules);
  }

  // ---------------------------------------------------------------------------
  // Rule Execution
  // ---------------------------------------------------------------------------

  void fireAll() {
    if (logExecution) {
      _context.log('=== START FIREALL ===');
    }

    int iterations = 0;
    bool firedAny;

    do {
      firedAny = _fireOnce();
      iterations++;

      if (iterations >= maxIterations) {
        _context.log('Warning: Maximum iterations ($maxIterations) reached');
        break;
      }
    } while (firedAny);

    if (logExecution) {
      _context.log('=== END FIREALL ===');
    }
  }

  bool _fireOnce() {
    final rulesByGroup = _groupRulesByGroup();
    bool firedAny = false;

    for (final group in rulesByGroup.keys) {
      final groupRules = rulesByGroup[group]!;
      final firedInGroup = _fireGroup(groupRules);

      if (firedInGroup) {
        firedAny = true;
        break; // Re-evaluate from highest priority group
      }
    }

    return firedAny;
  }

  Map<String, List<Rule>> _groupRulesByGroup() {
    final groups = <String, List<Rule>>{};

    for (final rule in _rules) {
      groups.putIfAbsent(rule.group, () => []).add(rule);
    }

    // Sort rules within each group by salience (descending)
    for (final groupRules in groups.values) {
      groupRules.sort((a, b) => b.salience.compareTo(a.salience));
    }

    return groups;
  }

  bool _fireGroup(List<Rule> groupRules) {
    for (final rule in groupRules) {
      if (rule.noLoop && rule.hasFired) continue;

      if (_evaluateRule(rule)) {
        _executeRule(rule);
        rule.hasFired = true;
        return true;
      } else if (logExecution) {
        _context.log('Rule not matched: ${rule.name}');
      }
    }

    return false;
  }

  bool _evaluateRule(Rule rule) {
    for (final condition in rule.when) {
      if (!_evaluator.evalCondition(condition, _context)) {
        return false;
      }
    }
    return true;
  }

  void _executeRule(Rule rule) {
    if (logExecution) {
      _context.log('Firing rule: ${rule.name}');
    }

    for (final action in rule.then) {
      try {
        _executor.execute(action, _context);
      } catch (e) {
        _context.log('Error executing action in rule ${rule.name}: $e');
        // Continue with next action
      }
    }
  }
}

// =============================================================================
// RULE AND FACT CLASSES (mostly unchanged but with minor improvements)
// =============================================================================

class Fact {
  final String type;
  final Map<String, dynamic> data;

  Fact(this.type, [Map<String, dynamic>? initialData])
    : data = Map<String, dynamic>.from(initialData ?? {});

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;

  @override
  String toString() => 'Fact<$type>$data';
}

class Rule {
  final String name;
  final String group;
  final int salience;
  final bool noLoop;
  final List<dynamic> when;
  final List<dynamic> then;

  bool hasFired = false;

  Rule({
    required this.name,
    required this.group,
    required this.salience,
    required this.noLoop,
    required this.when,
    required this.then,
  });
}
