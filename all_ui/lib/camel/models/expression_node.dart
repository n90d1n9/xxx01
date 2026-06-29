// Expression Builder
class ExpressionNode {
  final String type; // 'literal', 'variable', 'function', 'operator'
  final String value;
  final List<ExpressionNode> children;

  ExpressionNode({
    required this.type,
    required this.value,
    this.children = const [],
  });

  String toExpression() {
    switch (type) {
      case 'literal':
        return value;
      case 'variable':
        return '\${$value}';
      case 'function':
        final args = children.map((c) => c.toExpression()).join(', ');
        return '$value($args)';
      case 'operator':
        if (children.length == 2) {
          return '${children[0].toExpression()} $value ${children[1].toExpression()}';
        }
        return value;
      default:
        return value;
    }
  }
}
