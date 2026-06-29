// rule_engine/runtime/default_action_executor.dart
//
// DefaultActionExecutor that evaluates action arguments using the expression
// parser/evaluator and calls registered handlers from ActionRegistry.
// Also registers builtin faraid actions for convenience.

import 'dart:async';

import 'action_registry.dart';
import 'ast_nodes.dart';
import 'core.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';
import 'fact_query_resolver.dart';

class DefaultActionExecutor {
  final ActionRegistry registry;
  final RuleContext context;

  DefaultActionExecutor(this.context) : registry = ActionRegistry() {
    _registerBuiltins();
  }

  // Public API: execute a "raw" action (string or map)
  Future<void> execute(dynamic action) async {
    if (action == null) return;

    if (action is String) {
      // allow "log: message" or "message" -> treat as log
      final msg = action;
      await registry.execute('log', {'message': msg}, context, _buildEnv());
      return;
    }

    if (action is Map) {
      // Expect single top-level key being action name
      if (action.keys.isEmpty) return;
      // if action map contains multiple keys, execute each as individual actions
      for (final rawKey in action.keys) {
        final key = rawKey.toString();
        final val = action[rawKey];
        final args = _normalizeArgs(val);
        await registry.execute(key, args, context, _buildEnv());
      }
    }
  }

  // Normalize action payload into a Map<String, dynamic>
  Map<String, dynamic> _normalizeArgs(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) {
      final m = <String, dynamic>{};
      raw.forEach((k, v) => m[k.toString()] = v);
      return m;
    }
    // if raw is primitive -> store as value
    return {'value': raw};
  }

  EvalEnv _buildEnv() {
    final resolver = FactQueryResolver(context);
    return EvalEnv(
      context: context,
      resolve: (String id) => resolver.resolve(id),
    );
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

  // ---------------------------
  // Builtin action registrations
  // ---------------------------

  void _registerBuiltins() {
    // assignShare
    registry.register('assignShare', (args, ctx, env) async {
      final heir = args['heir']?.toString();
      final rawShare = args['share'];
      if (heir == null || rawShare == null) return;

      final evaluated = _evalAny(rawShare, env);
      final shareVal = _normalizeShare(evaluated);
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      if (shares is! Map) {
        ctx.setGlobal('shares', <String, dynamic>{});
      }
      final map = Map<String, dynamic>.from(ctx.getGlobal('shares') ?? {});
      map[heir] = shareVal;
      ctx.setGlobal('shares', map);
      ctx.log('assignShare: $heir -> $shareVal');
    });

    // set
    registry.register('set', (args, ctx, env) async {
      // set can be map of key->value or single key 'key': 'value'
      if (args.isEmpty) return;
      args.forEach((k, v) {
        final eval = _evalAny(v, env);
        ctx.setGlobal(k, eval);
        ctx.log('set: $k = $eval');
      });
    });

    // computeRemaining
    registry.register('computeRemaining', (args, ctx, env) async {
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      double total = 0.0;
      if (shares is Map) {
        shares.forEach((k, v) {
          if (v is num) total += v.toDouble();
        });
      }
      final remaining = 1.0 - total;
      ctx.setGlobal('remainingShare', remaining > 0 ? remaining : 0.0);
      ctx.log(
        'computeRemaining: remainingShare=${ctx.getGlobal('remainingShare')}',
      );
    });

    // applyAwl
    registry.register('applyAwl', (args, ctx, env) async {
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      double total = 0.0;
      if (shares is Map) {
        shares.forEach((k, v) {
          if (v is num) total += v.toDouble();
        });
      }
      if (total > 1.0 && shares is Map) {
        final normalized = <String, dynamic>{};
        shares.forEach((k, v) {
          if (v is num) {
            normalized[k] = (v.toDouble() / total);
          } else {
            normalized[k] = v;
          }
        });
        ctx.setGlobal('shares', normalized);
        ctx.setGlobal('remainingShare', 0.0);
        ctx.log('applyAwl: normalized shares (AWL) applied');
      }
    });

    // applyRadd
    registry.register('applyRadd', (args, ctx, env) async {
      final remaining = ctx.getGlobal('remainingShare') ?? 0.0;
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      if (remaining is num && remaining > 0 && shares is Map) {
        double totalAssigned = 0.0;
        shares.forEach((k, v) {
          if (v is num) totalAssigned += v.toDouble();
        });
        if (totalAssigned > 0) {
          final multiplier = 1.0 / totalAssigned;
          final newShares = <String, dynamic>{};
          shares.forEach((k, v) {
            if (v is num) {
              newShares[k] = v * multiplier;
            } else {
              newShares[k] = v;
            }
          });
          ctx.setGlobal('shares', newShares);
          ctx.setGlobal('remainingShare', 0.0);
          ctx.log('applyRadd: Radd applied');
        }
      }
    });

    // log
    registry.register('log', (args, ctx, env) async {
      final message = args['message'] ?? args['value'] ?? '<no message>';
      final evaluated = _evalAny(message, env);
      ctx.log('LOG: $evaluated');
    });

    // retract
    registry.register('retract', (args, ctx, env) async {
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
    registry.register('modify', (args, ctx, env) async {
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

  double _normalizeShare(dynamic v) {
    // Accept number, fraction string like "1/8", or expression result
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim();
      if (s.contains('/')) {
        final parts = s.split('/');
        if (parts.length == 2) {
          final n = double.tryParse(parts[0]);
          final d = double.tryParse(parts[1]);
          if (n != null && d != null && d != 0) return n / d;
        }
      }
      // try parse as double
      final numv = double.tryParse(s);
      if (numv != null) return numv;
    }
    // fallback 0
    return 0.0;
  }
}
