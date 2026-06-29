// RuleEngine that evaluates ExprNode conditions using EvalEnv and
// FactQueryResolver, and executes actions using DefaultActionExecutor.

import 'ast_nodes.dart';
import 'core.dart';
import 'default_action_executor.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';
import 'fact_query_resolver.dart';

class RuleEngine {
  final List<Rule> _rules = [];
  final RuleContext _context;
  late final DefaultActionExecutor _executor;

  bool logExecution = false;
  int maxIterations = 1000;

  RuleEngine({
    Map<String, dynamic>? initialGlobals,
    Map<String, Function>? hooks,
  }) : _context = RuleContext(
         initialGlobals: initialGlobals,
         initialHooks: hooks,
       ) {
    _context.setGlobal('executionLog', _context.executionLog);
    _context.setGlobal('shares', <String, dynamic>{});
    _context.setGlobal('remainingShare', 1.0);
    _executor = DefaultActionExecutor(_context);
  }

  // Basic API
  void addRule(Rule r) => _rules.add(r);
  void addRules(List<Rule> rules) => _rules.addAll(rules);
  void clearRules() => _rules.clear();
  void insert(Fact f) => _context.facts.add(f);
  void clearFacts() => _context.facts.clear();
  dynamic getGlobal(String k) => _context.getGlobal(k);
  void setGlobal(String k, dynamic v) => _context.setGlobal(k, v);
  List<Fact> getAllFacts() => List.unmodifiable(_context.facts);
  List<String> getExecutionLog() => List.unmodifiable(_context.executionLog);

  void registerHook(String name, Function fn) => _context.hooks[name] = fn;

  void loadRules(List<Rule> rules) => addRules(rules);

  // Execution
  void fireAll() {
    if (logExecution) _context.log('=== START FIREALL ===');

    int iterations = 0;
    bool firedAny;

    do {
      firedAny = _fireOnce();
      iterations++;
      if (iterations >= maxIterations) {
        _context.log('Warning: reached max iterations ($maxIterations)');
        break;
      }
    } while (firedAny);

    if (logExecution) _context.log('=== END FIREALL ===');
  }

  bool _fireOnce() {
    // Group by group name, then sort by salience desc inside each group
    final groups = <String, List<Rule>>{};
    for (final r in _rules) {
      groups.putIfAbsent(r.group, () => []).add(r);
    }
    for (final gr in groups.keys) {
      groups[gr]!.sort((a, b) => b.salience.compareTo(a.salience));
    }

    // Iterate groups in insertion order
    for (final group in groups.keys) {
      final groupRules = groups[group]!;
      for (final rule in groupRules) {
        if (rule.noLoop && rule.hasFired) continue;
        final matched = _evaluateRule(rule);
        if (matched) {
          _executeRule(rule);
          rule.hasFired = true;
          return true; // re-evaluate from top after a rule fired
        } else if (logExecution) {
          _context.log('Rule not matched: ${rule.name}');
        }
      }
    }

    return false;
  }

  bool _evaluateRule(Rule rule) {
    // rule.when elements may be ExprNode (parsed) or legacy string/other
    for (final cond in rule.when) {
      if (cond is ExprNode) {
        final resolver = FactQueryResolver(_context);
        final env = EvalEnv(
          context: _context,
          resolve: (id) => resolver.resolve(id),
        );
        final res = cond.evaluate(env);
        if (!_isTruthy(res)) return false;
      } else {
        // fallback: if user provided string condition or other type, attempt to evaluate truthiness
        try {
          if (cond is String) {
            final resolver = FactQueryResolver(_context);
            final env = EvalEnv(
              context: _context,
              resolve: (id) => resolver.resolve(id),
            );
            final lexer = Lexer(cond);
            final tokens = lexer.tokenize();
            final parser = Parser(tokens);
            final node = parser.parse();
            final res = node.evaluate(env);
            if (!_isTruthy(res)) return false;
          } else if (cond is bool) {
            if (!cond) return false;
          } else {
            // unknown condition type — treat as false
            return false;
          }
        } catch (e) {
          _context.log('Condition evaluation error in rule ${rule.name}: $e');
          return false;
        }
      }
    }
    return true;
  }

  void _executeRule(Rule rule) {
    if (logExecution) _context.log('Firing rule: ${rule.name}');
    for (final action in rule.then) {
      try {
        _executor.execute(action);
      } catch (e) {
        _context.log('Error executing action in ${rule.name}: $e');
      }
    }
  }

  // small helpers
  bool _isTruthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.isNotEmpty;
    if (v is Iterable || v is Map) return (v as dynamic).isNotEmpty;
    return true;
  }
}
