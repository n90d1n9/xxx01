class PostingValidationResult {
  final double debitTotal;
  final double creditTotal;
  final List<String> issues;

  const PostingValidationResult({
    required this.debitTotal,
    required this.creditTotal,
    required this.issues,
  });

  bool get isValid => issues.isEmpty;

  double get difference => debitTotal - creditTotal;
}
