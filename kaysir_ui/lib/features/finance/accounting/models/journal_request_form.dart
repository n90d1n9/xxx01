import '../accounting_core/models/journal_entry.dart';

/// One editable journal form line before it becomes a journal draft line.
class JournalRequestLineInput {
  const JournalRequestLineInput({
    required this.accountId,
    required this.side,
    required this.amount,
    this.memo,
  });

  final String? accountId;
  final JournalSide side;
  final double amount;
  final String? memo;

  bool get hasAccount => accountId?.trim().isNotEmpty ?? false;
}

/// Header and lines captured by the journal request form.
class JournalRequestInput {
  const JournalRequestInput({
    required this.reference,
    required this.description,
    required this.source,
    required this.preparerName,
    required this.reviewerName,
    required this.lines,
    this.evidenceReference,
  });

  final String reference;
  final String description;
  final JournalSource source;
  final String preparerName;
  final String reviewerName;
  final String? evidenceReference;
  final List<JournalRequestLineInput> lines;

  double get debitTotal => lines
      .where((line) => line.side == JournalSide.debit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get creditTotal => lines
      .where((line) => line.side == JournalSide.credit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get difference => debitTotal - creditTotal;
}

/// One validation issue raised while preparing a journal approval request.
class JournalRequestValidationIssue {
  const JournalRequestValidationIssue(this.message);

  final String message;
}

/// Validation result for a journal request form submission.
class JournalRequestValidationResult {
  const JournalRequestValidationResult({required this.issues});

  final List<JournalRequestValidationIssue> issues;

  bool get isValid => issues.isEmpty;
}
