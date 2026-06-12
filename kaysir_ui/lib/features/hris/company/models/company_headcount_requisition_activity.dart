import 'company_headcount_requisition.dart';

/// Activity type recorded against a headcount requisition.
enum CompanyHeadcountRequisitionActivityType {
  submitted('Submitted'),
  approved('Approved'),
  recruitingOpened('Recruiting opened'),
  filled('Filled');

  final String label;

  const CompanyHeadcountRequisitionActivityType(this.label);
}

/// Auditable activity record for one headcount requisition workflow step.
class CompanyHeadcountRequisitionActivityRecord {
  final String id;
  final String requisitionId;
  final String roleTitle;
  final CompanyHeadcountRequisitionActivityType type;
  final String actorName;
  final DateTime happenedAt;
  final String note;

  const CompanyHeadcountRequisitionActivityRecord({
    required this.id,
    required this.requisitionId,
    required this.roleTitle,
    required this.type,
    required this.actorName,
    required this.happenedAt,
    required this.note,
  });

  factory CompanyHeadcountRequisitionActivityRecord.fromRequisition({
    required String id,
    required CompanyHeadcountRequisition requisition,
    required CompanyHeadcountRequisitionActivityType type,
    required DateTime happenedAt,
    String actorName = 'People Operations',
    String note = '',
  }) {
    return CompanyHeadcountRequisitionActivityRecord(
      id: id,
      requisitionId: requisition.id,
      roleTitle: requisition.roleTitle,
      type: type,
      actorName:
          actorName.trim().isEmpty ? 'People Operations' : actorName.trim(),
      happenedAt: happenedAt,
      note: note.trim().isEmpty ? type.label : note.trim(),
    );
  }

  String get happenedAtLabel => _dateLabel(happenedAt);
}

/// Timeline read model for headcount requisition workflow activity.
class CompanyHeadcountRequisitionActivityTimeline {
  final List<CompanyHeadcountRequisitionActivityRecord> records;

  const CompanyHeadcountRequisitionActivityTimeline({required this.records});

  bool get isEmpty => records.isEmpty;

  int get submittedCount {
    return records
        .where(
          (record) =>
              record.type == CompanyHeadcountRequisitionActivityType.submitted,
        )
        .length;
  }

  int get approvalCount {
    return records
        .where(
          (record) =>
              record.type == CompanyHeadcountRequisitionActivityType.approved,
        )
        .length;
  }

  int get recruitingCount {
    return records
        .where(
          (record) =>
              record.type ==
              CompanyHeadcountRequisitionActivityType.recruitingOpened,
        )
        .length;
  }

  int get filledCount {
    return records
        .where(
          (record) =>
              record.type == CompanyHeadcountRequisitionActivityType.filled,
        )
        .length;
  }

  List<CompanyHeadcountRequisitionActivityRecord> get recentRecords {
    return [...records]..sort(_compareRecords);
  }
}

int _compareRecords(
  CompanyHeadcountRequisitionActivityRecord a,
  CompanyHeadcountRequisitionActivityRecord b,
) {
  final dateComparison = b.happenedAt.compareTo(a.happenedAt);
  if (dateComparison != 0) return dateComparison;
  return b.id.compareTo(a.id);
}

String _dateLabel(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
