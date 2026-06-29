

-----
abstract class ActionExecutor {
  final RuleContext context;

  ActionExecutor(this.context);

  Future<void> execute(dynamic action);

  // Helper methods
  dynamic evaluate(dynamic value, EvalEnv env);
  Map<String, dynamic> normalizeArgs(dynamic raw);
  EvalEnv buildEnv();
}

abstract class ActionExecutorDecorator extends ActionExecutor {
  final ActionExecutor parent;

  ActionExecutorDecorator(this.parent) : super(parent.context);
}

// Simple registry to register and execute actions by name.
// Action handlers receive (Map<String,dynamic> args, RuleContext ctx, EvalEnv env)

import 'ast_nodes.dart';
import 'core.dart';

typedef ActionHandler =
    Future<void> Function(
      Map<String, dynamic> args,
      RuleContext ctx,
      EvalEnv env,
    );

class ActionRegistry {
  final Map<String, ActionHandler> _handlers = {};

  void register(String name, ActionHandler handler) {
    _handlers[name] = handler;
  }

  bool has(String name) => _handlers.containsKey(name);

  Future<void> execute(
    String name,
    Map<String, dynamic> args,
    RuleContext ctx,
    EvalEnv env,
  ) async {
    final handler = _handlers[name];
    if (handler == null) {
      throw StateError('No action registered for "$name"');
    }
    await handler(args, ctx, env);
  }

  List<String> registeredActions() => List.unmodifiable(_handlers.keys);
}


// AST node definitions for the expression engine.
// These nodes are evaluator-agnostic; the evaluator supplies an EvalEnv
// with a resolver to translate identifiers/paths into concrete values.

import 'core.dart';

/// Evaluation environment used by AST nodes.
class EvalEnv {
  /// The rule engine's contextual runtime (facts, globals, hooks, log).
  final RuleContext context;

  /// Resolver function. Given an identifier/path string, returns the resolved value.
  /// Example identifiers: "global.remainingShare", "facts.FamilyMember.count",
  /// "person.age", "facts.Member.where(...)" (the resolver decides supported syntax).
  final dynamic Function(String identifier) resolve;

  EvalEnv({required this.context, required this.resolve});
}

/// Base expression node.
abstract class ExprNode {
  const ExprNode();

  /// Evaluate the node under given EvalEnv.
  /// Can return bool, num, String, List, Map, or null depending on expression.
  dynamic evaluate(EvalEnv env);
}

/// Literal values

class NullLiteral extends ExprNode {
  const NullLiteral();
  @override
  dynamic evaluate(EvalEnv env) => null;
}

class NumberLiteral extends ExprNode {
  final num value;
  const NumberLiteral(this.value);
  @override
  dynamic evaluate(EvalEnv env) => value;
}

class StringLiteral extends ExprNode {
  final String value;
  const StringLiteral(this.value);
  @override
  dynamic evaluate(EvalEnv env) => value;
}

class BoolLiteral extends ExprNode {
  final bool value;
  const BoolLiteral(this.value);
  @override
  dynamic evaluate(EvalEnv env) => value;
}

/// Identifier (field path) — resolved via EvalEnv.resolve
class Identifier extends ExprNode {
  final String
  name; // e.g. 'global.remainingShare' or 'facts.FamilyMember.count'
  const Identifier(this.name);

  @override
  dynamic evaluate(EvalEnv env) {
    try {
      return env.resolve(name);
    } catch (e) {
      // Resolver errors should not crash the evaluator — return null and let
      // higher level decide how to handle missing fields.
      return null;
    }
  }
}

/// Unary operator node (like !, -)
class UnaryOp extends ExprNode {
  final String operator; // '!' or '-'
  final ExprNode operand;

  const UnaryOp(this.operator, this.operand);

  @override
  dynamic evaluate(EvalEnv env) {
    final val = operand.evaluate(env);

    switch (operator) {
      case '!':
        return !_isTruthy(val);
      case '-':
        if (val is num) return -val;
        final n = _tryParseNum(val);
        return n != null ? -n : null;
      default:
        throw UnsupportedError('Unsupported unary operator: $operator');
    }
  }
}

/// Binary operator node
class BinaryOp extends ExprNode {
  final String operator;
  final ExprNode left;
  final ExprNode right;

  const BinaryOp(this.operator, this.left, this.right);

  @override
  dynamic evaluate(EvalEnv env) {
    final l = left.evaluate(env);
    final r = right.evaluate(env);

    switch (operator) {
      // Logical
      case '||':
      case 'or':
        return _isTruthy(l) ? l : r; // short-circuit style (truthy value)
      case '&&':
      case 'and':
        return _isTruthy(l) ? r : l;

      // Comparisons
      case '==':
        return _equals(l, r);
      case '!=':
        return !_equals(l, r);
      case '>':
        return _compare(l, r) > 0;
      case '<':
        return _compare(l, r) < 0;
      case '>=':
        return _compare(l, r) >= 0;
      case '<=':
        return _compare(l, r) <= 0;

      // Arithmetic
      case '+':
        return _add(l, r);
      case '-':
        return _arithmeticOp((a, b) => a - b, l, r);
      case '*':
        return _arithmeticOp((a, b) => a * b, l, r);
      case '/':
        return _arithmeticOp((a, b) => b == 0 ? null : a / b, l, r);
      case '%':
        return _arithmeticOp((a, b) => a % b, l, r);

      default:
        throw UnsupportedError('Unsupported binary operator: $operator');
    }
  }
}

/// Helper / utility functions used by AST nodes

bool _isTruthy(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.isNotEmpty;
  if (value is Iterable || value is Map) return (value as dynamic).isNotEmpty;
  return true;
}

num? _tryParseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) {
    final parsed = num.tryParse(v);
    return parsed;
  }
  return null;
}

bool _equals(dynamic a, dynamic b) {
  // Nulls equal only to null
  if (a == null || b == null) return a == b;

  // numeric equality if both numeric (or both parseable to numbers)
  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum != null && bNum != null) {
    return aNum == bNum;
  }

  // Default equality
  return a == b;
}

int _compare(dynamic a, dynamic b) {
  // Null handling: treat null as less than any non-null
  if (a == null && b == null) return 0;
  if (a == null) return -1;
  if (b == null) return 1;

  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum != null && bNum != null) {
    return aNum.compareTo(bNum);
  }

  final aStr = a.toString();
  final bStr = b.toString();
  return aStr.compareTo(bStr);
}

dynamic _arithmeticOp(num? Function(num, num) op, dynamic a, dynamic b) {
  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum == null || bNum == null) return null;
  return op(aNum, bNum);
}

dynamic _add(dynamic a, dynamic b) {
  // If both numeric -> numeric add
  final aNum = _tryParseNum(a);
  final bNum = _tryParseNum(b);
  if (aNum != null && bNum != null) return aNum + bNum;

  // If either is a string -> concatenate
  if (a is String || b is String) return '${a ?? ''}${b ?? ''}';

  // As fallback, attempt numeric add
  if (aNum != null && bNum != null) return aNum + bNum;

  return null;
}


// Simple Fact model used by the rule engine.

class Fact {
  final String type;
  final Map<String, dynamic> data;

  Fact(this.type, [Map<String, dynamic>? initialData])
    : data = Map<String, dynamic>.from(initialData ?? {});

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;

  @override
  String toString() => 'Fact<$type>${data.toString()}';
}

// Rule model used by the loader & engine.
// The `when` field is typed as List<dynamic> for compatibility:
// - it may contain parsed ExprNode objects (from parser/ast_nodes.dart)
// - or legacy string conditions
//
// `then` is List<dynamic> of action maps or strings.
class Rule {
  final String name;
  final String group;
  final int salience;
  final bool noLoop;
  final List<dynamic> when;
  final List<dynamic> then;
  final String? description;

  bool hasFired = false;

  Rule({
    required this.name,
    this.group = 'default',
    this.salience = 0,
    this.noLoop = false,
    List<dynamic>? when,
    List<dynamic>? then,
    this.description,
  }) : when = List<dynamic>.from(when ?? []),
       then = List<dynamic>.from(then ?? []);

  @override
  String toString() =>
      'Rule(name: $name, group: $group, salience: $salience, noLoop: $noLoop, when: ${when.length} conds, then: ${then.length} actions)';
}

// RuleContext (execution context) for the rule engine.
// Holds facts, globals, hooks and execution log.

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

  void log(String message) {
    final ts = DateTime.now().toIso8601String();
    executionLog.add('[$ts] $message');
  }

  dynamic getGlobal(String key) => globals[key];

  void setGlobal(String key, dynamic value) => globals[key] = value;

  /// Find facts by type name
  List<Fact> factsOfType(String type) =>
      facts.where((f) => f.type == type).toList();

  /// Convenience: clear logs
  void clearLog() => executionLog.clear();

  @override
  String toString() =>
      'RuleContext(globals: ${globals.keys.toList()}, facts: ${facts.length}, hooks: ${hooks.keys.toList()})';
}

// rule_engine/runtime/default_action_executor.dart
//
// DefaultActionExecutor that evaluates action arguments using the expression
// parser/evaluator and calls registered handlers from ActionRegistry.
// Also registers builtin faraid actions for convenience.

import 'dart:async';

import 'action_executor.dart';
import 'action_registry.dart';
import 'ast_nodes.dart';
import 'core.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';
import 'fact_query_resolver.dart';

class DefaultActionExecutor extends ActionExecutor {
  final ActionRegistry registry;

  DefaultActionExecutor(super.context) : registry = ActionRegistry() {
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

  dynamic evaluate(dynamic value, EvalEnv env) => _evalAny(value, env);

  Map<String, dynamic> normalizeArgs(dynamic raw) => _normalizeArgs(raw);

  EvalEnv buildEnv() => _buildEnv();

  void _registerBuiltins() {
    // Keep only domain-agnostic actions: log, set, retract, modify
    registry.register('log', (args, ctx, env) async {
      final message = args['message'] ?? args['value'] ?? '<no message>';
      final evaluated = evaluate(message, env);
      ctx.log('LOG: $evaluated');
    });

    registry.register('set', (args, ctx, env) async {
      args.forEach((k, v) {
        final eval = evaluate(v, env);
        ctx.setGlobal(k, eval);
        ctx.log('set: $k = $eval');
      });
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

// Tokenizer for expression parsing. Converts a raw string into Tokens.
// Supports identifiers, numbers, string literals, logical operators,
// comparison operators, arithmetic operators, parentheses, keywords,
// and dot-path identifiers like "facts.Member.count".

enum TokenType {
  identifier,
  number,
  string,
  boolean,
  nullValue,
  lParen,
  rParen,
  comma,

  // operators
  plus,
  minus,
  star,
  slash,
  percent,
  bang,

  andOp,
  orOp,
  notOp,

  eq, // ==
  neq, // !=
  gt, // >
  lt, // <
  gte, // >=
  lte, // <=

  eof,
}

class Token {
  final TokenType type;
  final String lexeme; // raw text
  final dynamic literal; // parsed literal value (num, string, bool)
  final int position;

  Token(this.type, this.lexeme, this.literal, this.position);

  @override
  String toString() =>
      'Token(type: $type, lexeme: "$lexeme", literal: $literal, pos: $position)';
}

class Lexer {
  final String source;
  int _start = 0;
  int _current = 0;

  Lexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _start = _current;
      final token = _scanToken();
      if (token != null) tokens.add(token);
    }

    tokens.add(Token(TokenType.eof, '', null, _current));
    return tokens;
  }

  Token? _scanToken() {
    final c = _advance();

    switch (c) {
      case ' ':
      case '\r':
      case '\t':
      case '\n':
        return null; // ignore whitespace

      case '(':
        return _token(TokenType.lParen);
      case ')':
        return _token(TokenType.rParen);
      case ',':
        return _token(TokenType.comma);

      case '+':
        return _token(TokenType.plus);
      case '-':
        return _token(TokenType.minus);
      case '*':
        return _token(TokenType.star);
      case '/':
        return _token(TokenType.slash);
      case '%':
        return _token(TokenType.percent);

      case '!':
        if (_match('=')) return _token(TokenType.neq, '!=');
        return _token(TokenType.bang);

      case '=':
        if (_match('=')) return _token(TokenType.eq, '==');
        throw _error('Unexpected "=" — did you mean "=="?');

      case '>':
        if (_match('=')) return _token(TokenType.gte, '>=');
        return _token(TokenType.gt);

      case '<':
        if (_match('=')) return _token(TokenType.lte, '<=');
        return _token(TokenType.lt);

      case '&':
        if (_match('&')) return _token(TokenType.andOp, '&&');
        throw _error('Unexpected "&" — did you mean "&&"?');

      case '|':
        if (_match('|')) return _token(TokenType.orOp, '||');
        throw _error('Unexpected "|" — did you mean "||"?');

      case '"':
      case "'":
        return _string(c);
    }

    if (_isDigit(c)) return _number();
    if (_isAlpha(c)) return _identifier();

    throw _error('Unexpected character: "$c"');
  }

  Token _token(TokenType type, [String? lex]) {
    final text = lex ?? source.substring(_start, _current);
    return Token(type, text, null, _start);
  }

  /// Handle string literal: single or double quotes.
  Token _string(String quote) {
    while (!_isAtEnd() && _peek() != quote) {
      _advance();
    }

    if (_isAtEnd()) throw _error('Unterminated string literal');

    // closing quote
    _advance();

    final value = source.substring(_start + 1, _current - 1);
    return Token(TokenType.string, value, value, _start);
  }

  /// Number literal (supports int & double)
  Token _number() {
    while (_isDigit(_peek())) _advance();

    // decimal fraction
    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance();
      while (_isDigit(_peek())) _advance();
    }

    final text = source.substring(_start, _current);
    final value = num.tryParse(text);
    return Token(TokenType.number, text, value, _start);
  }

  /// Identifier, boolean literal, null literal,
  /// OR keyword `and`, `or`, `not`.
  Token _identifier() {
    while (_isAlphaNumeric(_peek()) || _peek() == '.') {
      _advance();
    }

    final text = source.substring(_start, _current).trim();

    switch (text) {
      case 'true':
        return Token(TokenType.boolean, text, true, _start);
      case 'false':
        return Token(TokenType.boolean, text, false, _start);
      case 'null':
        return Token(TokenType.nullValue, text, null, _start);
      case 'and':
        return Token(TokenType.andOp, text, null, _start);
      case 'or':
        return Token(TokenType.orOp, text, null, _start);
      case 'not':
        return Token(TokenType.notOp, text, null, _start);
    }

    return Token(TokenType.identifier, text, text, _start);
  }

  String _advance() => source[_current++];

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (source[_current] != expected) return false;
    _current++;
    return true;
  }

  String _peek() => _isAtEnd() ? '\u0000' : source[_current];
  String _peekNext() {
    if (_current + 1 >= source.length) return '\u0000';
    return source[_current + 1];
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        (c == '_');
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  bool _isAtEnd() => _current >= source.length;

  Exception _error(String msg) => FormatException('$msg at $_current');
}


// Recursive-descent expression parser that converts tokens into ExprNode AST.
// Depends on expression_lexer.dart and ast_nodes.dart
//
// Usage:
//   final lexer = Lexer('global.x > 0 && facts.Member.count > 0');
//   final tokens = lexer.tokenize();
//   final parser = Parser(tokens);
//   final expr = parser.parse(); // ExprNode
//   final result = expr.evaluate(env);

import 'expression_lexer.dart';
import 'ast_nodes.dart';

class Parser {
  final List<Token> _tokens;
  int _current = 0;

  Parser(this._tokens);

  ExprNode parse() {
    if (_tokens.isEmpty) {
      throw FormatException('Empty token list');
    }
    _current = 0;
    final expr = _parseExpression();
    if (!_isAtEnd()) {
      throw FormatException('Unexpected token at end: ${_peek().lexeme}');
    }
    return expr;
  }

  // -----------------------------------------------------------------------
  // Grammar (higher-level entry)
  // expression -> or
  // or -> and ( ( "||" | "or" ) and )*
  // and -> equality ( ( "&&" | "and" ) equality )*
  // equality -> comparison ( ( "==" | "!=" ) comparison )*
  // comparison -> term ( ( ">" | "<" | ">=" | "<=" ) term )*
  // term -> factor ( ( "+" | "-" ) factor )*
  // factor -> unary ( ( "*" | "/" | "%" ) unary )*
  // unary -> ( "!" | "not" | "-" ) unary | primary
  // primary -> NUMBER | STRING | BOOLEAN | NULL | IDENTIFIER | "(" expression ")"
  // -----------------------------------------------------------------------

  ExprNode _parseExpression() => _parseOr();

  ExprNode _parseOr() {
    var expr = _parseAnd();

    while (_match([TokenType.orOp])) {
      final opToken = _previous();
      final right = _parseAnd();
      expr = BinaryOp('||', expr, right);
    }

    return expr;
  }

  ExprNode _parseAnd() {
    var expr = _parseEquality();

    while (_match([TokenType.andOp])) {
      final opToken = _previous();
      final right = _parseEquality();
      expr = BinaryOp('&&', expr, right);
    }

    return expr;
  }

  ExprNode _parseEquality() {
    var expr = _parseComparison();

    while (_match([TokenType.eq, TokenType.neq])) {
      final op = _previous();
      final right = _parseComparison();
      final opStr = op.type == TokenType.eq ? '==' : '!=';
      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseComparison() {
    var expr = _parseTerm();

    while (_match([TokenType.gt, TokenType.lt, TokenType.gte, TokenType.lte])) {
      final op = _previous();
      final right = _parseTerm();

      String opStr;
      switch (op.type) {
        case TokenType.gt:
          opStr = '>';
          break;
        case TokenType.lt:
          opStr = '<';
          break;
        case TokenType.gte:
          opStr = '>=';
          break;
        case TokenType.lte:
          opStr = '<=';
          break;
        default:
          opStr = op.lexeme;
      }

      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseTerm() {
    var expr = _parseFactor();

    while (_match([TokenType.plus, TokenType.minus])) {
      final op = _previous();
      final right = _parseFactor();
      final opStr = op.type == TokenType.plus ? '+' : '-';
      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseFactor() {
    var expr = _parseUnary();

    while (_match([TokenType.star, TokenType.slash, TokenType.percent])) {
      final op = _previous();
      final right = _parseUnary();
      String opStr;
      switch (op.type) {
        case TokenType.star:
          opStr = '*';
          break;
        case TokenType.slash:
          opStr = '/';
          break;
        case TokenType.percent:
          opStr = '%';
          break;
        default:
          opStr = op.lexeme;
      }
      expr = BinaryOp(opStr, expr, right);
    }

    return expr;
  }

  ExprNode _parseUnary() {
    if (_match([TokenType.bang, TokenType.notOp])) {
      // unary NOT
      final op = _previous();
      final right = _parseUnary();
      return UnaryOp('!', right);
    }

    if (_match([TokenType.minus])) {
      final right = _parseUnary();
      return UnaryOp('-', right);
    }

    return _parsePrimary();
  }

  ExprNode _parsePrimary() {
    if (_match([TokenType.number])) {
      final lit = _previous().literal;
      if (lit is num) return NumberLiteral(lit);
      // fallback parse
      final parsed = num.tryParse(_previous().lexeme);
      if (parsed != null) return NumberLiteral(parsed);
      throw FormatException('Invalid numeric literal: ${_previous().lexeme}');
    }

    if (_match([TokenType.string])) {
      final lit = _previous().literal;
      return StringLiteral(lit?.toString() ?? '');
    }

    if (_match([TokenType.boolean])) {
      final lit = _previous().literal;
      return BoolLiteral(lit == true);
    }

    if (_match([TokenType.nullValue])) {
      return NullLiteral();
    }

    if (_match([TokenType.identifier])) {
      final name = _previous().lexeme;
      return Identifier(name);
    }

    if (_match([TokenType.lParen])) {
      final expr = _parseExpression();
      if (!_match([TokenType.rParen])) {
        throw FormatException('Expected closing ")" after expression');
      }
      return expr;
    }

    throw FormatException('Unexpected token: ${_peek().lexeme}');
  }

  // -----------------------------------------------------------------------
  // Token helpers
  // -----------------------------------------------------------------------

  bool _match(List<TokenType> types) {
    for (final t in types) {
      if (_check(t)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;

  Token _peek() => _tokens[_current];
  Token _previous() => _tokens[_current - 1];
}


// Resolves identifier strings to runtime values based on RuleContext.
// Supports:
//  - global.<key>
//  - facts.<Type>.count
//  - facts.<Type>                     -> List<Fact>
//  - facts.<Type>.where(<predicate>).count
//  - facts.<Type>.where(<predicate>)  -> List<Fact>
//  - simple facts field access is handled by predicate evaluator
//
// Uses the expression parser (Lexer + Parser) to parse the predicate inside where(...)
// and evaluates predicate AST against each Fact using EvalEnv that resolves field names
// from the fact's data and global variables from RuleContext.

import 'ast_nodes.dart';
import 'core.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';

class FactQueryResolver {
  final RuleContext context;

  FactQueryResolver(this.context);

  /// Main entry. Given an identifier like "global.remainingShare" or
  /// "facts.FamilyMember.where(relationName=='son').count" returns a value.
  dynamic resolve(String identifier) {
    if (identifier.trim().isEmpty) return null;
    if (identifier.startsWith('global.')) {
      final key = identifier.substring('global.'.length);
      return context.getGlobal(key);
    }

    if (identifier.startsWith('facts.')) {
      final tail = identifier.substring('facts.'.length);
      // handle patterns:
      // Type
      // Type.count
      // Type.where(<predicate>).count
      final dotIndex = tail.indexOf('.');
      if (dotIndex == -1) {
        // just type: return list of facts of that type
        return _factsOfType(tail);
      } else {
        final typeName = tail.substring(0, dotIndex);
        final rest = tail.substring(dotIndex + 1);
        if (rest == 'count') {
          return _factsOfType(typeName).length;
        }

        if (rest.startsWith('where(')) {
          final predicateText = _extractWherePredicate(rest);
          final filtered = _filterFacts(typeName, predicateText);
          // check for trailing .count
          final afterWhere =
              rest.substring('where('.length + predicateText.length + 1).trim();
          if (afterWhere.startsWith('.count')) {
            return filtered.length;
          }
          return filtered;
        }

        // allow facts.Type.fieldName to return list of that field values
        if (!_hasParen(rest)) {
          // e.g. facts.Type.field -> return list of field values from facts of that type
          final facts = _factsOfType(typeName);
          final values = facts.map((f) => _getFactFieldValue(rest, f)).toList();
          return values;
        }
      }
    }

    // Attempt to resolve as global key fallback
    return context.getGlobal(identifier);
  }

  List<Fact> _factsOfType(String type) =>
      context.facts.where((f) => f.type == type).toList();

  bool _hasParen(String s) => s.contains('(') || s.contains(')');

  String _extractWherePredicate(String rest) {
    // rest starts with where(
    // extract content inside the first balanced parentheses
    final start = rest.indexOf('(');
    if (start == -1) return '';

    int depth = 0;
    final buf = StringBuffer();
    for (int i = start; i < rest.length; i++) {
      final ch = rest[i];
      if (ch == '(') {
        depth++;
        if (depth == 1) continue; // skip opening
      } else if (ch == ')') {
        depth--;
        if (depth == 0) break;
      }
      if (depth >= 1) buf.write(ch);
    }
    return buf.toString().trim();
  }

  List<Fact> _filterFacts(String typeName, String predicateText) {
    final facts = _factsOfType(typeName);
    if (predicateText.isEmpty) return facts;

    // parse predicate into ExprNode
    final lexer = Lexer(predicateText);
    final tokens = lexer.tokenize();
    final parser = Parser(tokens);
    ExprNode predicateAst;
    try {
      predicateAst = parser.parse();
    } catch (e) {
      // invalid predicate -> treat as no match
      context.log('Predicate parse error for "$predicateText": $e');
      return [];
    }

    final filtered = <Fact>[];
    for (final fact in facts) {
      final evalEnv = EvalEnv(
        context: context,
        resolve: (String id) {
          // When evaluating predicate AST, identifiers refer first to fact fields,
          // then to globals. Support field paths like 'relationName' or 'data.age'
          final val = _getFactFieldValue(id, fact);
          if (val != null) return val;
          if (id.startsWith('global.')) {
            return context.getGlobal(id.substring(7));
          }
          final g = context.getGlobal(id);
          if (g != null) return g;
          return null;
        },
      );

      dynamic res;
      try {
        res = predicateAst.evaluate(evalEnv);
      } catch (e) {
        context.log(
          'Predicate evaluation error for "$predicateText" on fact $fact: $e',
        );
        res = false;
      }

      if (_isTruthy(res)) filtered.add(fact);
    }
    return filtered;
  }

  dynamic _getFactFieldValue(String fieldPath, Fact fact) {
    var path = fieldPath;
    // Accept optional leading 'data.' or 'fact.' prefixes
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
          continue;
        } else {
          return null;
        }
      } else {
        // cannot dig deeper
        return null;
      }
    }
    return current;
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.isNotEmpty;
    if (value is Iterable) return (value as dynamic).isNotEmpty;
    if (value is Map) return (value as dynamic).isNotEmpty;
    return true;
  }
}

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


// rule_engine/loader/yaml_rule_loader.dart
//
// Loads YAML rules, validates them, and converts into runtime Rule objects.
// Uses the Parser to parse string expressions into ExprNode ASTs.
// Returns a list of LoadedRule which contains parsed when-expressions as ExprNode.

import 'package:yaml/yaml.dart';

import 'ast_nodes.dart';
import 'core.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';
import 'yaml_validator.dart';

class LoadedRule {
  final String name;
  final String group;
  final int salience;
  final bool noLoop;
  final List<ExprNode> when; // parsed AST expressions
  final List<dynamic> then; // raw action maps (Map<String,dynamic>) or strings
  final String? description;

  LoadedRule({
    required this.name,
    required this.group,
    required this.salience,
    required this.noLoop,
    required this.when,
    required this.then,
    this.description,
  });

  Rule toRule() {
    // Convert LoadedRule to the previous Rule shape if needed (keeping when as strings would
    // lose the AST; choose to store AST in rule.when as dynamic)
    return Rule(
      name: name,
      group: group,
      salience: salience,
      noLoop: noLoop,
      when: when, // note: now contains ExprNode objects
      then: then,
    );
  }
}
// rule_engine/loader/yaml_rule_loader.dart

class YamlRuleLoader {
  /// Load rules from a YAML string.
  /// Throws FormatException if YAML invalid or validation fails.
  static List<Rule> load(String yamlString, {bool validate = true}) {
    final doc = loadYaml(yamlString);
    if (doc == null || doc is! YamlMap) return [];

    if (validate) {
      final errors = YamlValidator.validate(doc);
      if (errors.isNotEmpty) {
        final msgs = errors.map((e) => e.toString()).join('\n');
        throw FormatException('YAML validation failed:\n$msgs');
      }
    }

    final rulesNode = doc['rules'];
    if (rulesNode is! YamlList) return [];

    final rules = <Rule>[];

    for (final r in rulesNode) {
      if (r is! YamlMap) continue;

      final name = r['name']?.toString() ?? 'Unnamed Rule';
      final group = r['group']?.toString() ?? 'default';
      final salience =
          (r['salience'] is num)
              ? (r['salience'] as num).toInt()
              : int.tryParse(r['salience']?.toString() ?? '') ?? 0;
      final noLoop = r['no_loop'] == true || r['noLoop'] == true;
      final description = r['description']?.toString();

      final whenList = <dynamic>[];
      if (r.containsKey('when')) {
        final whenNode = r['when'];
        if (whenNode is YamlList) {
          for (final cond in whenNode) {
            if (cond is String) {
              // parse to ExprNode
              final lexer = Lexer(cond);
              final tokens = lexer.tokenize();
              final parser = Parser(tokens);
              final expr = parser.parse();
              whenList.add(expr);
            } else {
              whenList.add(cond);
            }
          }
        } else if (whenNode is String) {
          final lexer = Lexer(whenNode);
          final tokens = lexer.tokenize();
          final parser = Parser(tokens);
          final expr = parser.parse();
          whenList.add(expr);
        }
      }

      final thenList = <dynamic>[];
      if (r.containsKey('then')) {
        final thenNode = r['then'];
        if (thenNode is YamlList) {
          for (final act in thenNode) {
            if (act is YamlMap) {
              // convert YamlMap -> Map<String, dynamic>
              final m = <String, dynamic>{};
              for (final k in act.keys) {
                m[k.toString()] = _convertYamlValue(act[k]);
              }
              thenList.add(m);
            } else if (act is String) {
              thenList.add(act);
            }
          }
        }
      }

      final rule = Rule(
        name: name,
        group: group,
        salience: salience,
        noLoop: noLoop,
        when: whenList,
        then: thenList,
        description: description,
      );

      rules.add(rule);
    }

    return rules;
  }

  static dynamic _convertYamlValue(dynamic v) {
    if (v is YamlMap) {
      final m = <String, dynamic>{};
      for (final k in v.keys) {
        m[k.toString()] = _convertYamlValue(v[k]);
      }
      return m;
    } else if (v is YamlList) {
      return v.map(_convertYamlValue).toList();
    }
    return v;
  }
}

// rule_engine/validators/yaml_validator.dart
//
// Validates YAML rule documents for basic schema correctness and expression parseability.
import 'package:yaml/yaml.dart';
import 'expression_lexer.dart';
import 'expression_parser.dart';

class YamlValidationError {
  final String ruleName;
  final String message;
  YamlValidationError(this.ruleName, this.message);

  @override
  String toString() => 'Rule "$ruleName": $message';
}

class YamlValidator {
  /// Allowed action keys at top-level inside a 'then' map. Extendable.
  static const allowedActionKeys = <String>{
    // Default actions
    'log', 'set', 'retract', 'modify',
    // Faraid actions
    'assignFixedShare', 'assignRemainingShare', 'assignToSonsAndDaughters',
    'computeRemaining', 'applyAwl', 'applyRadd',
    // Domain-agnostic actions
    'assign', 'calculate', 'when', 'forEach', 'check_conditions',
    'calculate_fixed_share', 'sum_object_values',
    // Synonyms
    'apply',
  };

  /// Validate the YAML document loaded by [loadYaml].
  /// Returns a list of YamlValidationError; empty list means valid.
  static List<YamlValidationError> validate(YamlMap doc) {
    final errors = <YamlValidationError>[];

    if (!doc.containsKey('rules')) {
      errors.add(YamlValidationError('', 'Top-level "rules" key not found'));
      return errors;
    }

    final rulesNode = doc['rules'];
    if (rulesNode is! YamlList) {
      errors.add(YamlValidationError('', '"rules" must be a list'));
      return errors;
    }

    for (final r in rulesNode) {
      if (r is! YamlMap) {
        errors.add(YamlValidationError('', 'Each rule must be a map'));
        continue;
      }

      final name = r['name']?.toString() ?? '<unnamed>';
      if (!r.containsKey('then')) {
        errors.add(YamlValidationError(name, 'Missing "then" actions'));
      }

      // Validate "when" block: support list of string expressions or a single string
      if (r.containsKey('when')) {
        final when = r['when'];
        if (when is YamlList) {
          for (final cond in when) {
            if (cond is! String) {
              errors.add(
                YamlValidationError(
                  name,
                  'Each condition in "when" must be a string expression',
                ),
              );
            } else {
              _validateExpression(cond, name, errors);
            }
          }
        } else if (when is String) {
          _validateExpression(when, name, errors);
        } else {
          errors.add(
            YamlValidationError(
              name,
              '"when" must be a string or list of strings',
            ),
          );
        }
      }

      // Validate then actions
      if (r.containsKey('then')) {
        final thenNode = r['then'];
        if (thenNode is! YamlList) {
          errors.add(YamlValidationError(name, '"then" must be a list'));
        } else {
          for (final action in thenNode) {
            if (action is String) {
              // allow simple "log: message" string? better if map or string with "log:..."
              continue;
            } else if (action is YamlMap) {
              // each action map should have one top-level key in allowedActionKeys
              if (action.keys.isEmpty) {
                errors.add(YamlValidationError(name, 'Action map is empty'));
                continue;
              }
              for (final k in action.keys) {
                final key = k.toString();
                if (!allowedActionKeys.contains(key)) {
                  errors.add(
                    YamlValidationError(name, 'Unknown action key "$key"'),
                  );
                }
                // Basic argument type checks for common actions
                final val = action[k];
                if ((key == 'assignShare' ||
                        key == 'set' ||
                        key == 'modify' ||
                        key == 'retract') &&
                    val is! YamlMap) {
                  errors.add(
                    YamlValidationError(name, '"$key" action must be a map'),
                  );
                }
              }
            } else {
              errors.add(
                YamlValidationError(
                  name,
                  'Actions must be either string or map',
                ),
              );
            }
          }
        }
      }
    }

    return errors;
  }

  static void _validateExpression(
    String expr,
    String ruleName,
    List<YamlValidationError> errors,
  ) {
    try {
      final lexer = Lexer(expr);
      final tokens = lexer.tokenize();
      final parser = Parser(tokens);
      parser.parse();
    } catch (e) {
      errors.add(
        YamlValidationError(ruleName, 'Invalid expression "$expr": $e'),
      );
    }
  }
}