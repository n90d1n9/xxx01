// rule_engine/core/domain_agnostic_engine.dart
import '../qonun/new/action_registry.dart';
import '../qonun/new/ast_nodes.dart';
import '../qonun/new/core.dart';
import '../qonun/new/expression_lexer.dart';
import '../qonun/new/expression_parser.dart';
import '../qonun/new/rule_engine.dart';

class DomainAgnosticRuleEngine {
  final RuleEngine _engine;
  final Map<String, dynamic> _domainConfig;

  DomainAgnosticRuleEngine({
    Map<String, dynamic> domainConfig = const {},
    List<ActionRegistry> customRegistries = const [],
  }) : _engine = RuleEngine(
         initialGlobals: {'shares': {}, 'remainingShare': 1.0},
         additionalRegistries: [
           _DomainAgnosticActionRegistry(),
           ...customRegistries,
         ],
       ),
       _domainConfig = Map.from(domainConfig);

  Future<RuleExecutionResult> executeRules({
    required Map<String, dynamic> initialFacts,
    required List<Rule> rules,
    Map<String, dynamic>? executionContext,
  }) async {
    // Reset engine state
    _engine.clearFacts();
    _engine.clearRules();
    _engine.addRules(rules);

    // Set execution context
    _engine.setGlobal('executionContext', executionContext ?? {});
    _engine.setGlobal('calculationReset', true);

    // Add facts as generic entities
    initialFacts.forEach((type, data) {
      if (data is List) {
        for (final item in data) {
          _engine.insert(
            Fact(type, item is Map ? Map.from(item) : {'value': item}),
          );
        }
      } else {
        _engine.insert(
          Fact(type, data is Map ? Map.from(data) : {'value': data}),
        );
      }
    });

    // Execute
    _engine.fireAll();

    return RuleExecutionResult(
      shares: _engine.getGlobal('shares') ?? {},
      remainingShare: _engine.getGlobal('remainingShare') ?? 0.0,
      executionLog: _engine.getExecutionLog(),
      context: _engine.context.globals,
    );
  }
}

class RuleExecutionResult {
  final Map<String, dynamic> shares;
  final double remainingShare;
  final List<String> executionLog;
  final Map<String, dynamic> context;

  RuleExecutionResult({
    required this.shares,
    required this.remainingShare,
    required this.executionLog,
    required this.context,
  });
}

// rule_engine/core/domain_agnostic_engine.dart
// rule_engine/core/domain_agnostic_engine.dart
class _DomainAgnosticActionRegistry extends ActionRegistry {
  _DomainAgnosticActionRegistry() {
    _registerDomainAgnosticActions();
  }

  void _registerDomainAgnosticActions() {
    // Generic assignment action
    register('assign', (args, ctx, env) async {
      final target = args['target']?.toString();
      final value = await _evaluateValue(args['value'], ctx, env);
      final mode = args['mode']?.toString() ?? 'set'; // set, add, multiply

      if (target == null) return;

      final current = ctx.getGlobal(target);
      dynamic newValue;

      switch (mode) {
        case 'add':
          newValue = (current ?? 0) + value;
          break;
        case 'multiply':
          newValue = (current ?? 1) * value;
          break;
        case 'set':
        default:
          newValue = value;
          break;
      }

      ctx.setGlobal(target, newValue);
      ctx.log('assign: $target = $newValue (mode: $mode)');
    });

    // Generic calculation action
    register('calculate', (args, ctx, env) async {
      final expression = args['expression']?.toString();
      final target = args['target']?.toString();

      if (expression == null || target == null) return;

      try {
        final result = await _evaluateExpression(expression, ctx, env);
        ctx.setGlobal(target, result);
        ctx.log('calculate: $target = $result (expression: "$expression")');
      } catch (e) {
        ctx.log('calculate: Error evaluating expression "$expression": $e');
      }
    });

    // Generic condition execution
    register('when', (args, ctx, env) async {
      final condition = args['condition'];
      final thenActions = args['then'];
      final elseActions = args['else'];

      final conditionResult = await _evaluateCondition(condition, ctx, env);

      if (conditionResult) {
        await _executeActions(thenActions, ctx, env);
      } else if (elseActions != null) {
        await _executeActions(elseActions, ctx, env);
      }
    });

    // Generic iteration
    register('forEach', (args, ctx, env) async {
      final collection = args['collection']?.toString();
      final itemName = args['item']?.toString() ?? 'item';
      final actions = args['actions'];

      if (collection == null || actions == null) return;

      final items = ctx.getGlobal(collection);
      if (items is List) {
        for (final item in items) {
          ctx.setGlobal('_current_$itemName', item);
          await _executeActions(actions, ctx, env);
        }
        ctx.setGlobal('_current_$itemName', null);
      }
    });

    // Helper functions - FIXED: Make them async and set results in context
    register('check_conditions', (args, ctx, env) async {
      final conditions = args['conditions'];
      final result = await _evaluateConditionsList(conditions, ctx, env);
      ctx.setGlobal('_last_check_conditions_result', result);
    });

    register('calculate_fixed_share', (args, ctx, env) async {
      final share = args['share'];
      final result = _normalizeShare(share);
      ctx.setGlobal('_last_calculate_fixed_share_result', result);
    });

    register('sum_object_values', (args, ctx, env) async {
      final obj = args['object'];
      final result = await _calculateSum(obj);
      ctx.setGlobal('_last_sum_object_values_result', result);
    });
  }

  Future<dynamic> _evaluateValue(
    dynamic value,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    if (value is String && value.startsWith('=')) {
      return await _evaluateExpression(value.substring(1), ctx, env);
    }
    return value;
  }

  Future<dynamic> _evaluateExpression(
    String expression,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    try {
      final lexer = Lexer(expression);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      final node = parser.parse();
      return node.evaluate(env);
    } catch (e) {
      ctx.log('Expression evaluation error: "$expression" - $e');
      return null;
    }
  }

  Future<bool> _evaluateCondition(
    dynamic condition,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    if (condition is bool) return condition;
    if (condition is String) {
      final result = await _evaluateExpression(condition, ctx, env);
      return result == true;
    }
    return false;
  }

  Future<bool> _evaluateConditionsList(
    dynamic conditions,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    if (conditions is List) {
      for (final condition in conditions) {
        if (!await _evaluateCondition(condition, ctx, env)) {
          return false;
        }
      }
      return true;
    }
    return await _evaluateCondition(conditions, ctx, env);
  }

  Future<double> _calculateSum(dynamic obj) async {
    if (obj is Map) {
      double total = 0.0;
      obj.forEach((key, value) {
        if (value is num) total += value.toDouble();
      });
      return total;
    }
    return 0.0;
  }

  Future<void> _executeActions(
    dynamic actions,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    if (actions is List) {
      for (final action in actions) {
        await _executeSingleAction(action, ctx, env);
      }
    } else {
      await _executeSingleAction(actions, ctx, env);
    }
  }

  Future<void> _executeSingleAction(
    dynamic action,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    if (action is Map) {
      for (final entry in action.entries) {
        await execute(entry.key, _normalizeArgs(entry.value), ctx, env);
      }
    } else if (action is String) {
      await execute('log', {'message': action}, ctx, env);
    }
  }

  Map<String, dynamic> _normalizeArgs(dynamic args) {
    if (args is Map) {
      final normalized = <String, dynamic>{};
      args.forEach((k, v) => normalized[k.toString()] = v);
      return normalized;
    }
    return {'value': args};
  }

  double _normalizeShare(dynamic share) {
    if (share is num) return share.toDouble();
    if (share is String) {
      if (share.contains('/')) {
        final parts = share.split('/');
        if (parts.length == 2) {
          final n = double.tryParse(parts[0]);
          final d = double.tryParse(parts[1]);
          if (n != null && d != null && d != 0) return n / d;
        }
      }
      return double.tryParse(share) ?? 0.0;
    }
    return 0.0;
  }
}
