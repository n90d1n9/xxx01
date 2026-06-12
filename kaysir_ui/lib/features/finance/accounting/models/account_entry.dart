import 'package:uuid/uuid.dart';

import 'account_entry_line.dart';

enum EntryType { debit, credit }

class AccountingEntry {
  final String id;
  final DateTime date;
  final String description;
  final String referenceNumber;
  final List<AccountingEntryLine> lines;
  final bool isPosted;

  AccountingEntry({
    String? id,
    required this.date,
    required this.description,
    required this.referenceNumber,
    required this.lines,
    this.isPosted = false,
  }) : id = id ?? const Uuid().v4();

  double get debitTotal => lines
      .where((line) => line.entryType == EntryType.debit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get creditTotal => lines
      .where((line) => line.entryType == EntryType.credit)
      .fold(0.0, (sum, line) => sum + line.amount);

  double get balanceDifference => debitTotal - creditTotal;

  double get requiredBalancingAmount => balanceDifference.abs();

  EntryType? get requiredBalancingType {
    if (isBalanced) {
      return null;
    }
    return balanceDifference > 0 ? EntryType.credit : EntryType.debit;
  }

  int get debitLineCount =>
      lines.where((line) => line.entryType == EntryType.debit).length;

  int get creditLineCount =>
      lines.where((line) => line.entryType == EntryType.credit).length;

  bool get hasCompleteHeader =>
      referenceNumber.trim().isNotEmpty && description.trim().isNotEmpty;

  bool get isBalanced {
    return balanceDifference.abs() < 0.001;
  }

  bool get canPost => postIssues.isEmpty;

  List<String> get postIssues {
    final issues = <String>[];
    if (referenceNumber.trim().isEmpty) {
      issues.add('Add a reference number');
    }
    if (description.trim().isEmpty) {
      issues.add('Add a description');
    }
    if (lines.isEmpty) {
      issues.add('Add at least one entry line');
    }
    if (lines.isNotEmpty && !isBalanced) {
      issues.add('Balance debit and credit totals');
    }
    return issues;
  }

  AccountingEntry copyWith({
    String? id,
    DateTime? date,
    String? description,
    String? referenceNumber,
    List<AccountingEntryLine>? lines,
    bool? isPosted,
  }) {
    return AccountingEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      lines: lines ?? this.lines,
      isPosted: isPosted ?? this.isPosted,
    );
  }
}
