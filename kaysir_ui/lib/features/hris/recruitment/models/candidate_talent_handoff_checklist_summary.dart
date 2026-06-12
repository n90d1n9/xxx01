import 'candidate_talent_handoff_checklist_item.dart';

class CandidateTalentHandoffChecklistSummary {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int completedCount;
  final int blockedCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const CandidateTalentHandoffChecklistSummary({
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.blockedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory CandidateTalentHandoffChecklistSummary.fromItems({
    required List<CandidateTalentHandoffChecklistItem> items,
    required DateTime asOfDate,
  }) {
    final openCount =
        items
            .where(
              (item) =>
                  item.status == CandidateTalentHandoffChecklistStatus.open,
            )
            .length;
    final inProgressCount =
        items
            .where(
              (item) =>
                  item.status ==
                  CandidateTalentHandoffChecklistStatus.inProgress,
            )
            .length;
    final completedCount =
        items
            .where(
              (item) =>
                  item.status ==
                  CandidateTalentHandoffChecklistStatus.completed,
            )
            .length;
    final blockedCount =
        items
            .where(
              (item) =>
                  item.status == CandidateTalentHandoffChecklistStatus.blocked,
            )
            .length;
    final dueSoonCount = items.where((item) => item.isDueSoon(asOfDate)).length;
    final overdueCount = items.where((item) => item.isOverdue(asOfDate)).length;

    return CandidateTalentHandoffChecklistSummary(
      totalCount: items.length,
      openCount: openCount,
      inProgressCount: inProgressCount,
      completedCount: completedCount,
      blockedCount: blockedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _summaryNextAction(
        totalCount: items.length,
        openCount: openCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _summaryNextAction({
  required int totalCount,
  required int openCount,
  required int blockedCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalCount == 0) return 'Create handoff checklist tasks.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount handoff checklist tasks.';
  }
  if (overdueCount > 0) {
    return 'Close $overdueCount overdue handoff checklist tasks.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount checklist tasks due soon.';
  }
  if (openCount > 0) return 'Start $openCount handoff checklist tasks.';
  return 'Handoff checklist is complete.';
}
