import 'package:uuid/uuid.dart';

import 'account_entry.dart';

class AccountingEntryLine {
  final String id;
  final String accountId;
  final String accountName;
  final EntryType entryType;
  final double amount;
  final String? memo;

  AccountingEntryLine({
    String? id,
    required this.accountId,
    required this.accountName,
    required this.entryType,
    required this.amount,
    this.memo,
  }) : id = id ?? const Uuid().v4();

  AccountingEntryLine copyWith({
    String? id,
    String? accountId,
    String? accountName,
    EntryType? entryType,
    double? amount,
    String? memo,
  }) {
    return AccountingEntryLine(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      entryType: entryType ?? this.entryType,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
    );
  }
}
