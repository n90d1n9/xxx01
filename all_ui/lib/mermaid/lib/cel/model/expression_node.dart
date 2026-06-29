import 'cel_context.dart';
import 'node_type.dart';
import 'validation_result.dart';

class ExpressionNode {
  final String id;
  final NodeType type;
  String? operator;
  dynamic value;
  List<ExpressionNode> children;
  String? comment;
  Map<String, dynamic>? metadata;

  ExpressionNode({
    required this.id,
    required this.type,
    this.operator,
    this.value,
    List<ExpressionNode>? children,
    this.comment,
    this.metadata,
  }) : children = children ?? [];

  String toCEL() {
    switch (type) {
      case NodeType.literal:
        if (value is String) return '"$value"';
        return value.toString();

      case NodeType.variable:
        return value.toString();

      case NodeType.member:
        if (children.isEmpty) return value.toString();
        return '${children[0].toCEL()}.$value';

      case NodeType.comparison:
        if (children.length != 2) return '';
        final left = children[0].toCEL();
        final right = children[1].toCEL();
        return '($left $operator $right)';

      case NodeType.logical:
        if (operator == '!') {
          return '!(${children[0].toCEL()})';
        }
        if (children.length < 2) return '';
        return '(${children.map((c) => c.toCEL()).join(' $operator ')})';

      case NodeType.arithmetic:
        if (children.length != 2) return '';
        return '(${children[0].toCEL()} $operator ${children[1].toCEL()})';

      case NodeType.function:
        final args = children.map((c) => c.toCEL()).join(', ');
        return '$value($args)';

      case NodeType.list:
        final items = children.map((c) => c.toCEL()).join(', ');
        return '[$items]';

      case NodeType.map:
        final entries = <String>[];
        for (var i = 0; i < children.length; i += 2) {
          if (i + 1 < children.length) {
            entries.add('${children[i].toCEL()}: ${children[i + 1].toCEL()}');
          }
        }
        return '{${entries.join(', ')}}';

      case NodeType.ternary:
        if (children.length != 3) return '';
        return '${children[0].toCEL()} ? ${children[1].toCEL()} : ${children[2].toCEL()}';

      default:
        return '';
    }
  }

  CELValidationResult validate(CELContext context) {
    switch (type) {
      case NodeType.variable:
        if (value == null || value.toString().isEmpty) {
          return CELValidationResult.failure('Variable name cannot be empty');
        }
        final varName = value.toString().split('.').first;
        if (!context.variables.containsKey(varName)) {
          return CELValidationResult.failure('Undefined variable: $varName');
        }
        break;

      case NodeType.function:
        if (value == null || value.toString().isEmpty) {
          return CELValidationResult.failure('Function name cannot be empty');
        }
        if (!context.availableFunctions.contains(value.toString())) {
          return CELValidationResult.success([
            'Unknown function: ${value.toString()}',
          ]);
        }
        break;

      case NodeType.comparison:
      case NodeType.logical:
      case NodeType.arithmetic:
        if (operator == null || operator!.isEmpty) {
          return CELValidationResult.failure('Operator cannot be empty');
        }
        if (operator != '!' && children.length < 2) {
          return CELValidationResult.failure(
            'Binary operator requires two operands',
          );
        }
        break;

      case NodeType.ternary:
        if (children.length != 3) {
          return CELValidationResult.failure(
            'Ternary operator requires condition, true value, and false value',
          );
        }
        break;
      case NodeType.literal:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.member:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.list:
        // TODO: Handle this case.
        throw UnimplementedError();
      case NodeType.map:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    // Validate children
    final warnings = <String>[];
    for (final child in children) {
      final result = child.validate(context);
      if (!result.isValid) return result;
      warnings.addAll(result.warnings);
    }

    return CELValidationResult.success(warnings);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'operator': operator,
    'value': value,
    'children': children.map((c) => c.toJson()).toList(),
    'comment': comment,
    'metadata': metadata,
  };

  factory ExpressionNode.fromJson(Map<String, dynamic> json) {
    return ExpressionNode(
      id: json['id'],
      type: NodeType.values.firstWhere((e) => e.name == json['type']),
      operator: json['operator'],
      value: json['value'],
      comment: json['comment'],
      metadata: json['metadata'],
      children: (json['children'] as List?)
          ?.map((c) => ExpressionNode.fromJson(c))
          .toList(),
    );
  }

  ExpressionNode copyWith({
    String? id,
    NodeType? type,
    String? operator,
    dynamic value,
    List<ExpressionNode>? children,
    String? comment,
    Map<String, dynamic>? metadata,
  }) {
    return ExpressionNode(
      id: id ?? this.id,
      type: type ?? this.type,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      children: children ?? this.children,
      comment: comment ?? this.comment,
      metadata: metadata ?? this.metadata,
    );
  }
}
