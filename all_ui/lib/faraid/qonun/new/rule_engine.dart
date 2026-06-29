// RuleEngine that evaluates ExprNode conditions using EvalEnv and
// FactQueryResolver, and executes actions using DefaultActionExecutor.

import 'action_registry.dart';
import 'ast_nodes.dart';
import 'core.dart';
import 'default_action_executor.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';
import 'fact_query_resolver.dart';

class RuleEngine {
  final ActionRegistry _actionRegistry = ActionRegistry();
  final RuleContext _context;
  final List<Rule> _rules = [];

  bool logExecution = false;
  int maxIterations = 1000;

  RuleEngine({
    Map<String, dynamic>? initialGlobals,
    Map<String, Function>? hooks,
    List<ActionRegistry>? additionalRegistries,
  }) : _context = RuleContext(
         initialGlobals: initialGlobals,
         initialHooks: hooks,
       ) {
    // Register built-in actions
    _registerBuiltinActions();

    // Merge additional registries
    if (additionalRegistries != null) {
      for (final registry in additionalRegistries) {
        _mergeRegistry(registry);
      }
    }
  }

  RuleContext get context => _context;
  ActionRegistry get actionRegistry => _actionRegistry;

  void _registerBuiltinActions() {
    _actionRegistry.register('log', (args, ctx, env) async {
      final message = args['message'] ?? args['value'] ?? '<no message>';
      ctx.log('LOG: $message');
    });

    _actionRegistry.register('set', (args, ctx, env) async {
      args.forEach((k, v) {
        ctx.setGlobal(k, v);
        ctx.log('set: $k = $v');
      });
    });

    // retract
    _actionRegistry.register('retract', (args, ctx, env) async {
      final type = args['type']?.toString();
      final predicate = args['predicate']?.toString();
      if (type == null) return;
      if (predicate == null) {
        ctx.facts.removeWhere((f) => f.type == type);
        ctx.log('retract: removed all facts of type $type');
        return;
      }
      // remove matching facts using predicate AST
      final lexer = Lexer(predicate);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      ExprNode predAst;
      try {
        predAst = parser.parse();
      } catch (e) {
        ctx.log('retract: invalid predicate "$predicate": $e');
        return;
      }

      ctx.facts.removeWhere((fact) {
        if (fact.type != type) return false;
        final env = EvalEnv(
          context: ctx,
          resolve: (String id) {
            final val = _getFactFieldValue(id, fact);
            if (val != null) return val;
            final g = ctx.getGlobal(id);
            if (g != null) return g;
            return null;
          },
        );
        final res = predAst.evaluate(env);
        return _isTruthy(res);
      });
      ctx.log('retract: removed facts of $type matching predicate');
    });

    // modify
    _actionRegistry.register('modify', (args, ctx, env) async {
      final type = args['type']?.toString();
      final predicate = args['predicate']?.toString();
      final changesRaw = args['changes'];
      if (type == null || changesRaw == null) return;
      Map<String, dynamic> changes = {};
      if (changesRaw is Map) {
        changesRaw.forEach((k, v) => changes[k.toString()] = v);
      } else {
        ctx.log('modify: changes should be a map');
        return;
      }

      // Parse predicate AST if present
      ExprNode? predAst;
      if (predicate != null) {
        try {
          final lexer = Lexer(predicate);
          final tokens = lexer.tokenize();
          final parser = Parser(tokens);
          predAst = parser.parse();
        } catch (e) {
          ctx.log('modify: invalid predicate "$predicate": $e');
          return;
        }
      }

      for (final fact in ctx.facts) {
        if (fact.type != type) continue;
        if (predAst != null) {
          final env = EvalEnv(
            context: ctx,
            resolve: (String id) {
              final val = _getFactFieldValue(id, fact);
              if (val != null) return val;
              final g = ctx.getGlobal(id);
              if (g != null) return g;
              return null;
            },
          );
          final res = predAst.evaluate(env);
          if (!_isTruthy(res)) continue;
        }
        // apply changes (allow expression values)
        changes.forEach((k, v) {
          final evaluated = _evalAny(v, _buildEnvWithFact(ctx, fact));
          fact.data[k] = evaluated;
        });
      }
      ctx.log('modify: applied changes to facts of $type');
    });
  }

  void _mergeRegistry(ActionRegistry other) {
    for (final actionName in other.registeredActions()) {
      _actionRegistry.register(actionName, (args, ctx, env) async {
        await other.execute(actionName, args, ctx, env);
      });
    }
  }

  void addActionRegistry(ActionRegistry registry) {
    _mergeRegistry(registry);
  }

  dynamic _evalAny(dynamic v, EvalEnv env) {
    // If the argument is already a literal (num/bool/list/map) return as-is
    if (v == null) return null;
    if (v is num || v is bool || v is List || v is Map) return v;

    if (v is String) {
      final s = v.trim();
      // If looks like a quoted string literal -> remove quotes
      if ((s.startsWith('"') && s.endsWith('"')) ||
          (s.startsWith("'") && s.endsWith("'"))) {
        return s.substring(1, s.length - 1);
      }

      // Try parse with lexer/parser -> produce AST -> evaluate
      try {
        final lexer = Lexer(s);
        final tokens = lexer.tokenize();
        final parser = Parser(tokens);
        final node = parser.parse();
        final result = node.evaluate(env);
        return result;
      } catch (_) {
        // Fallback: return the raw string
        return s;
      }
    }
    // fallback
    return v;
  }

  // Helper: allow evaluating expressions referencing the single fact (for modify)
  EvalEnv _buildEnvWithFact(RuleContext ctx, Fact fact) {
    final resolver = FactQueryResolver(ctx);
    return EvalEnv(
      context: ctx,
      resolve: (String id) {
        final val = _getFactFieldValue(id, fact);
        if (val != null) return val;
        return resolver.resolve(id);
      },
    );
  }

  // Helper: extract nested field value from fact
  dynamic _getFactFieldValue(String fieldPath, Fact fact) {
    var path = fieldPath;
    if (path.startsWith('data.')) path = path.substring(5);
    if (path.startsWith('fact.')) path = path.substring(5);
    final parts = path.split('.');
    dynamic current = fact.data;
    for (final part in parts) {
      if (current == null) return null;
      if (current is Map) {
        final dyn = current as Map<dynamic, dynamic>;
        if (dyn.containsKey(part)) {
          current = dyn[part];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
    return current;
  }

  // Helpers used above
  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is Iterable || value is Map) return (value as dynamic).isNotEmpty;
    return true;
  }

  //---

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

  // ADD the rule execution logic:
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
        // Handle string conditions or other types
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
        _executeAction(action);
      } catch (e) {
        _context.log('Error executing action in ${rule.name}: $e');
      }
    }
  }

  Future<void> _executeAction(dynamic action) async {
    // Use the RuleEngine's merged action registry instead of DefaultActionExecutor
    if (action is String) {
      await _actionRegistry.execute(
        'log',
        {'message': action},
        _context,
        _buildEnv(),
      );
      return;
    }

    if (action is Map) {
      for (final rawKey in action.keys) {
        final key = rawKey.toString();
        final val = action[rawKey];
        final args = _normalizeActionArgs(val);
        await _actionRegistry.execute(key, args, _context, _buildEnv());
      }
    }
  }

  Map<String, dynamic> _normalizeActionArgs(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      final m = <String, dynamic>{};
      raw.forEach((k, v) => m[k.toString()] = v);
      return m;
    }
    return {'value': raw};
  }

  EvalEnv _buildEnv() {
    final resolver = FactQueryResolver(_context);
    return EvalEnv(
      context: _context,
      resolve: (String id) => resolver.resolve(id),
    );
  }
}
