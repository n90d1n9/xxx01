class CELEvaluationException implements Exception {
  final String message;
  final String? expression;
  final int? position;

  CELEvaluationException(this.message, {this.expression, this.position});

  @override
  String toString() =>
      'CELEvaluationException: $message'
      '${expression != null ? ' in "$expression"' : ''}'
      '${position != null ? ' at position $position' : ''}';
}
