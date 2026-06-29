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
