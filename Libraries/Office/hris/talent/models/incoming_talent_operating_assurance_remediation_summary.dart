import 'incoming_talent_operating_assurance_remediation.dart';

/// Summary of owner-assigned talent assurance remediation work.
class IncomingTalentOperatingAssuranceRemediationSummary {
  final int actionCount;
  final int criticalActionCount;
  final int highActionCount;
  final int standardActionCount;
  final int overdueActionCount;
  final int dueTodayActionCount;
  final int ownerCount;
  final int workstreamCount;
  final int totalGapCount;
  final int linkedEscalationCount;
  final String nextAction;

  const IncomingTalentOperatingAssuranceRemediationSummary({
    required this.actionCount,
    required this.criticalActionCount,
    required this.highActionCount,
    required this.standardActionCount,
    required this.overdueActionCount,
    required this.dueTodayActionCount,
    required this.ownerCount,
    required this.workstreamCount,
    required this.totalGapCount,
    required this.linkedEscalationCount,
    required this.nextAction,
  });

  factory IncomingTalentOperatingAssuranceRemediationSummary.fromActions(
    List<IncomingTalentOperatingAssuranceRemediationAction> actions,
  ) {
    final criticalActionCount = _countByPriority(
      actions,
      IncomingTalentOperatingAssuranceRemediationPriority.critical,
    );
    final highActionCount = _countByPriority(
      actions,
      IncomingTalentOperatingAssuranceRemediationPriority.high,
    );
    final standardActionCount = _countByPriority(
      actions,
      IncomingTalentOperatingAssuranceRemediationPriority.standard,
    );
    final overdueActionCount =
        actions.where((action) => action.overdueGapCount > 0).length;
    final dueTodayActionCount =
        actions.where((action) => action.dueTodayGapCount > 0).length;
    final ownerCount = actions.map((action) => action.ownerName).toSet().length;
    final workstreamCount =
        actions.map((action) => action.workstreamLabel).toSet().length;
    final totalGapCount = actions.fold<int>(
      0,
      (total, action) => total + action.gapCount,
    );
    final linkedEscalationCount = actions.fold<int>(
      0,
      (total, action) => total + action.linkedEscalationCount,
    );

    return IncomingTalentOperatingAssuranceRemediationSummary(
      actionCount: actions.length,
      criticalActionCount: criticalActionCount,
      highActionCount: highActionCount,
      standardActionCount: standardActionCount,
      overdueActionCount: overdueActionCount,
      dueTodayActionCount: dueTodayActionCount,
      ownerCount: ownerCount,
      workstreamCount: workstreamCount,
      totalGapCount: totalGapCount,
      linkedEscalationCount: linkedEscalationCount,
      nextAction: _nextAction(
        actionCount: actions.length,
        criticalActionCount: criticalActionCount,
        overdueActionCount: overdueActionCount,
        dueTodayActionCount: dueTodayActionCount,
        linkedEscalationCount: linkedEscalationCount,
      ),
    );
  }
}

int _countByPriority(
  List<IncomingTalentOperatingAssuranceRemediationAction> actions,
  IncomingTalentOperatingAssuranceRemediationPriority priority,
) {
  return actions.where((action) => action.priority == priority).length;
}

String _nextAction({
  required int actionCount,
  required int criticalActionCount,
  required int overdueActionCount,
  required int dueTodayActionCount,
  required int linkedEscalationCount,
}) {
  if (actionCount == 0) return 'Talent assurance remediation is clear.';
  if (criticalActionCount > 0) {
    return 'Complete $criticalActionCount critical assurance remediation ${_plural(criticalActionCount, 'action')}.';
  }
  if (overdueActionCount > 0) {
    return 'Recover $overdueActionCount overdue assurance remediation ${_plural(overdueActionCount, 'action')}.';
  }
  if (dueTodayActionCount > 0) {
    return 'Close $dueTodayActionCount assurance remediation ${_plural(dueTodayActionCount, 'action')} due today.';
  }
  if (linkedEscalationCount > 0) {
    return 'Clear evidence for $linkedEscalationCount linked talent ${_plural(linkedEscalationCount, 'escalation')}.';
  }
  return 'Track $actionCount active assurance remediation ${_plural(actionCount, 'action')}.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
