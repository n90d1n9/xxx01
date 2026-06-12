import 'incoming_talent_career_path_support_action.dart';

class IncomingTalentCareerPathSupportActionSummary {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int criticalCount;
  final int dueSoonCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentCareerPathSupportActionSummary({
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.criticalCount,
    required this.dueSoonCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentCareerPathSupportActionSummary.fromActions({
    required List<IncomingTalentCareerPathSupportAction> actions,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final openCount = _countStatus(
      actions,
      IncomingTalentCareerPathSupportActionStatus.open,
    );
    final inProgressCount = _countStatus(
      actions,
      IncomingTalentCareerPathSupportActionStatus.inProgress,
    );
    final resolvedCount = _countStatus(
      actions,
      IncomingTalentCareerPathSupportActionStatus.resolved,
    );
    final criticalCount =
        actions
            .where(
              (action) =>
                  action.priority ==
                  IncomingTalentCareerPathSupportActionPriority.critical,
            )
            .length;
    final dueSoonCount =
        actions
            .where(
              (action) =>
                  !action.isClosed && !action.dueDate.isAfter(dueThreshold),
            )
            .length;
    final attentionCount =
        actions.where((action) => action.needsAttention).length;

    return IncomingTalentCareerPathSupportActionSummary(
      totalCount: actions.length,
      openCount: openCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
      criticalCount: criticalCount,
      dueSoonCount: dueSoonCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalCount: actions.length,
        openCount: openCount,
        criticalCount: criticalCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countStatus(
  List<IncomingTalentCareerPathSupportAction> actions,
  IncomingTalentCareerPathSupportActionStatus status,
) {
  return actions.where((action) => action.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int openCount,
  required int criticalCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Create support actions from blocked reviews.';
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical career support actions.';
  }
  if (dueSoonCount > 0) {
    return 'Follow up $dueSoonCount career support actions due soon.';
  }
  if (openCount > 0) return 'Start $openCount open career support actions.';
  return 'Keep career support actions moving to resolution.';
}
