import 'expression.dart';
import 'fact.dart';
import 'yaml_loader.dart';

class RuleEngine {
  final List<Rule> _rules = [];
  final Map<String, dynamic> _globals = {};
  final List<Fact> _facts = [];
  final Map<String, Function> _hooks = {};
  bool logExecution = false;

  RuleEngine() {
    _globals.putIfAbsent('executionLog', () => <String>[]);
  }

  // --- REGISTRATION ----------------------------------------------------------
  void registerHook(String name, Function fn) => _hooks[name] = fn;

  void setGlobal(String key, dynamic value) => _globals[key] = value;

  dynamic getGlobal(String key) => _globals[key];

  void addRule(Rule r) => _rules.add(r);

  void addRules(List<Rule> list) => _rules.addAll(list);

  void clearRules() => _rules.clear();

  void insert(Fact f) => _facts.add(f);

  void clearFacts() => _facts.clear();

  /// Remove facts by type and optional predicate (predicate is a lambda-like string
  /// evaluated against each fact).
  void retract(String type, {String? predicate}) {
    _facts.removeWhere((f) {
      if (f.type != type) return false;
      if (predicate == null) return true;
      return Expression.evalPredicateOnFact(predicate, f);
    });
  }

  void modify(
    String type, {
    required Map<String, dynamic> changes,
    String? predicate,
  }) {
    for (var f in _facts) {
      if (f.type != type) continue;
      if (predicate != null && !Expression.evalPredicateOnFact(predicate, f))
        continue;
      f.data.addAll(changes);
    }
  }

  List<Fact> getFactsByType(String type, {String? predicate}) {
    final list = _facts.where((f) => f.type == type).toList();
    if (predicate == null) return list;
    return list
        .where((f) => Expression.evalPredicateOnFact(predicate, f))
        .toList();
  }

  List<Fact> getAllFacts() => List.unmodifiable(_facts);

  void loadRulesFromYamlString(String yamlString) {
    final rules = YamlRuleLoader.load(yamlString);
    addRules(rules);
  }

  // --- EXECUTION -------------------------------------------------------------

  void fireAll() {
    int safetyCounter = 200; // avoids infinite loops
    if (logExecution) {
      _globals['executionLog'] ??= <String>[];
      (_globals['executionLog'] as List).add('=== START FIREALL ===');
    }
    while (safetyCounter-- > 0) {
      bool firedAny = _fireOnce();
      if (!firedAny) break;
    }
    if (logExecution) {
      (_globals['executionLog'] as List).add('=== END FIREALL ===');
    }
  }

  bool _fireOnce() {
    // group -> List<Rule>
    final Map<String, List<Rule>> grouped = {};

    for (var r in _rules) {
      grouped.putIfAbsent(r.group, () => []).add(r);
    }

    bool fired = false;

    for (var group in grouped.keys) {
      final groupRules = grouped[group]!;
      groupRules.sort((a, b) => b.salience.compareTo(a.salience));

      for (var rule in groupRules) {
        if (rule.noLoop && rule._hasFired) continue;

        if (_evalConditions(rule)) {
          if (logExecution) {
            (_globals['executionLog'] as List).add('Firing rule: ${rule.name}');
          }
          _executeActions(rule);
          rule._hasFired = true;
          fired = true;
          break; // re-evaluate groups after a firing (conflict resolution)
        } else {
          if (logExecution) {
            (_globals['executionLog'] as List).add(
              'Rule not matched: ${rule.name}',
            );
          }
        }
      }
    }

    return fired;
  }

  bool _evalConditions(Rule rule) {
    for (var cond in rule.when) {
      final success = Expression.eval(cond, this);
      if (!success) return false;
    }
    return true;
  }

  void _executeActions(Rule rule) {
    for (var action in rule.then) {
      // set
      if (action is Map && action.containsKey('set')) {
        final kv = action['set'] as Map;
        kv.forEach((k, v) {
          _globals[k] = Expression.evalValue(v, this);
        });
      }

      // call
      if (action is Map && action.containsKey('call')) {
        final callSpec = action['call'];
        if (callSpec is String) {
          final hook = _hooks[callSpec];
          if (hook != null) hook(this);
        } else if (callSpec is Map) {
          final fnName = callSpec['fn'];
          final args = callSpec['args'] ?? {};
          final hook = _hooks[fnName];
          if (hook != null) hook(this, args);
        }
      } else if (action is String && action.startsWith('call:')) {
        final fnName = action.substring(5).trim();
        final hook = _hooks[fnName];
        if (hook != null) hook(this);
      }

      // log
      if (action is Map && action.containsKey('log')) {
        final message =
            Expression.evalValue(action['log'], this)?.toString() ?? '';
        (_globals['executionLog'] as List).add(message);
      }

      // retract
      if (action is Map && action.containsKey('retract')) {
        final r = action['retract'];
        if (r is Map) {
          final type = r['type'];
          final predicate = r['predicate'];
          if (type != null) retract(type, predicate: predicate);
        }
      }

      // modify
      if (action is Map && action.containsKey('modify')) {
        final m = action['modify'];
        if (m is Map) {
          final type = m['type'];
          final predicate = m['predicate'];
          final changes = m['changes'] as Map<String, dynamic>? ?? {};
          if (type != null)
            modify(type, changes: changes, predicate: predicate);
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// RULE STRUCT
// ---------------------------------------------------------------------------

class Rule {
  final String name;
  final String group;
  final int salience;
  final bool noLoop;
  final List<dynamic> when;
  final List<dynamic> then;

  bool _hasFired = false;

  Rule({
    required this.name,
    required this.group,
    required this.salience,
    required this.noLoop,
    required this.when,
    required this.then,
  });
}
