import 'journal_entry.dart';

class LedgerPostingLine {
  final String id;
  final String accountId;
  final String accountName;
  final JournalSide side;
  final double amount;
  final String? memo;

  const LedgerPostingLine({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.side,
    required this.amount,
    this.memo,
  });

  factory LedgerPostingLine.fromJson(Map<String, dynamic> json) {
    return LedgerPostingLine(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      side: _journalSideFromJson(json['side'] as String?),
      amount: (json['amount'] as num).toDouble(),
      memo: json['memo'] as String?,
    );
  }

  double get signedAmount => side == JournalSide.debit ? amount : -amount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountName': accountName,
      'side': side.name,
      'amount': amount,
      'memo': memo,
    };
  }
}

class LedgerPosting {
  final String id;
  final String journalId;
  final DateTime entryDate;
  final DateTime postedAt;
  final String reference;
  final String description;
  final JournalSource source;
  final List<LedgerPostingLine> lines;

  const LedgerPosting({
    required this.id,
    required this.journalId,
    required this.entryDate,
    required this.postedAt,
    required this.reference,
    required this.description,
    required this.source,
    required this.lines,
  });

  factory LedgerPosting.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as Iterable? ?? const [];
    return LedgerPosting(
      id: json['id'] as String,
      journalId: json['journalId'] as String,
      entryDate: DateTime.parse(json['entryDate'] as String),
      postedAt: DateTime.parse(json['postedAt'] as String),
      reference: json['reference'] as String,
      description: json['description'] as String,
      source: _journalSourceFromJson(json['source'] as String?),
      lines: [
        for (final rawLine in rawLines)
          LedgerPostingLine.fromJson(Map<String, dynamic>.from(rawLine as Map)),
      ],
    );
  }

  double get debitTotal => lines
      .where((line) => line.side == JournalSide.debit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get creditTotal => lines
      .where((line) => line.side == JournalSide.credit)
      .fold(0.0, (sum, line) => sum + line.amount);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journalId': journalId,
      'entryDate': entryDate.toIso8601String(),
      'postedAt': postedAt.toIso8601String(),
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
