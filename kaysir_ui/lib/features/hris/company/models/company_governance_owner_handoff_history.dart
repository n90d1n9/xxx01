import 'company_governance_owner_handoff_record.dart';

/// Read model that turns recorded governance handoffs into a ledger summary.
class CompanyGovernanceOwnerHandoffHistory {
  final List<CompanyGovernanceOwnerHandoffRecord> records;

  const CompanyGovernanceOwnerHandoffHistory({required this.records});

  factory CompanyGovernanceOwnerHandoffHistory.fromRecords({
    required List<CompanyGovernanceOwnerHandoffRecord> records,
  }) {
    final sortedRecords = [...records]..sort(_compareNewestFirst);
    return CompanyGovernanceOwnerHandoffHistory(records: sortedRecords);
  }

  bool get isEmpty => records.isEmpty;

  int get recordCount => records.length;

  int get ownerCount {
    return records
        .map((record) => _normalize(record.ownerLabel))
        .toSet()
        .length;
  }

  int get criticalCount {
    return records.fold<int>(
      0,
      (total, record) => total + record.criticalCount,
    );
  }

  int get highCount {
    return records.fold<int>(0, (total, record) => total + record.highCount);
  }

  CompanyGovernanceOwnerHandoffRecord? get latestRecord {
    return records.isEmpty ? null : records.first;
  }

  String get latestLabel {
    return latestRecord?.recordedDateLabel ?? 'None';
  }

  int matchingRecordCount(String? ownerName) {
    final normalizedOwnerName = _normalize(ownerName);
    if (normalizedOwnerName.isEmpty) return 0;

    return records
        .where((record) => _normalize(record.ownerLabel) == normalizedOwnerName)
        .length;
  }

  List<CompanyGovernanceOwnerHandoffRecord> prioritizedRecords(
    String? ownerName,
  ) {
    final normalizedOwnerName = _normalize(ownerName);
    if (normalizedOwnerName.isEmpty) return records;

    final matchingRecords = <CompanyGovernanceOwnerHandoffRecord>[];
    final remainingRecords = <CompanyGovernanceOwnerHandoffRecord>[];
    for (final record in records) {
      if (_normalize(record.ownerLabel) == normalizedOwnerName) {
        matchingRecords.add(record);
      } else {
        remainingRecords.add(record);
      }
    }

    return [...matchingRecords, ...remainingRecords];
  }
}

int _compareNewestFirst(
  CompanyGovernanceOwnerHandoffRecord a,
  CompanyGovernanceOwnerHandoffRecord b,
) {
  final dateComparison = b.recordedAt.compareTo(a.recordedAt);
  if (dateComparison != 0) return dateComparison;

  return b.id.compareTo(a.id);
}

String _normalize(String? value) {
  return (value ?? '').trim().toLowerCase();
}
