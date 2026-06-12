/// Debit or credit side for a journal line.
enum JournalSide { debit, credit }

/// Business source that produced a journal draft.
enum JournalSource {
  manualAdjustment,
  receivableInvoice,
  receivablePayment,
  payableBill,
  payablePayment,
  periodClose,
}

/// One debit or credit line prepared before posting to the ledger.
class JournalLineDraft {
  final String accountId;
  final String accountName;
  final JournalSide side;
  final double amount;
  final String? memo;

  const JournalLineDraft({
    required this.accountId,
    required this.accountName,
    required this.side,
    required this.amount,
    this.memo,
  });

  factory JournalLineDraft.fromJson(Map<String, dynamic> json) {
    return JournalLineDraft(
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      side: _journalSideFromJson(json['side'] as String?),
      amount: (json['amount'] as num).toDouble(),
      memo: json['memo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'side': side.name,
      'amount': amount,
      'memo': memo,
    };
  }
}

/// Balanced journal draft submitted for approval or direct posting.
class JournalDraft {
  final String id;
  final DateTime date;
  final String reference;
  final String description;
  final JournalSource source;
  final List<JournalLineDraft> lines;

  const JournalDraft({
    required this.id,
    required this.date,
    required this.reference,
    required this.description,
    required this.source,
    required this.lines,
  });

  factory JournalDraft.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as Iterable? ?? const [];
    return JournalDraft(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      reference: json['reference'] as String,
      description: json['description'] as String,
      source: _journalSourceFromJson(json['source'] as String?),
      lines: [
        for (final rawLine in rawLines)
          JournalLineDraft.fromJson(Map<String, dynamic>.from(rawLine as Map)),
      ],
    );
  }

  double get debitTotal => lines
      .where((line) => line.side == JournalSide.debit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get creditTotal => lines
      .where((line) => line.side == JournalSide.credit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get difference => debitTotal - creditTotal;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'reference': reference,
      'description': description,
      'source': source.name,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}

JournalSide _journalSideFromJson(String? value) {
  switch (value) {
    case 'credit':
      return JournalSide.credit;
    case 'debit':
    default:
      return JournalSide.debit;
  }
}

JournalSource _journalSourceFromJson(String? value) {
  switch (value) {
    case 'receivableInvoice':
      return JournalSource.receivableInvoice;
    case 'receivablePayment':
      return JournalSource.receivablePayment;
    case 'payableBill':
      return JournalSource.payableBill;
    case 'payablePayment':
      return JournalSource.payablePayment;
    case 'periodClose':
      return JournalSource.periodClose;
    case 'manualAdjustment':
    default:
      return JournalSource.manualAdjustment;
  }
}
