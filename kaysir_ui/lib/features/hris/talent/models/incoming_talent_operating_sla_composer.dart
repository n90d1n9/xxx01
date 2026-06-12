import 'incoming_talent_operating_assurance_execution.dart';
import 'incoming_talent_operating_inbox_item.dart';
import 'incoming_talent_operating_sla_item.dart';

/// Builds normalized SLA monitor items from active talent operating work.
List<IncomingTalentOperatingSlaItem> buildIncomingTalentOperatingSlaItems({
  required List<IncomingTalentOperatingInboxItem> inboxItems,
  required List<IncomingTalentOperatingAssuranceExecutionTrack> executionTracks,
  required DateTime asOfDate,
}) {
  final items = [
    for (final item in inboxItems)
      _slaItemFromInboxItem(item: item, asOfDate: asOfDate),
    for (final track in executionTracks)
      _slaItemFromExecutionTrack(track: track, asOfDate: asOfDate),
  ]..sort(_compareSlaItems);

  return items;
}

IncomingTalentOperatingSlaItem _slaItemFromInboxItem({
  required IncomingTalentOperatingInboxItem item,
  required DateTime asOfDate,
}) {
  final daysUntilDue = item.daysUntilDue(asOfDate);
  final status = _statusForInboxItem(item: item, daysUntilDue: daysUntilDue);

  return IncomingTalentOperatingSlaItem(
    id: 'operating-sla-inbox-${item.id}',
    referenceId: item.id,
    source: _slaSourceForInboxSource(item.source),
    status: status,
    title: item.title,
    subjectName: item.subjectName,
    department: item.department,
    ownerName: _ownerName(item.ownerName),
    workstreamLabel: _workstreamLabelForInboxSource(item.source),
    priorityLabel: item.priority.label,
    nextAction: item.nextAction,
    dueDate: item.dueDate,
    daysUntilDue: daysUntilDue,
    slaPressureRatio: _pressureForInboxItem(
      item: item,
      status: status,
      daysUntilDue: daysUntilDue,
    ),
    evidenceCount: 0,
    referenceIds: [item.id],
  );
}

IncomingTalentOperatingSlaItem _slaItemFromExecutionTrack({
  required IncomingTalentOperatingAssuranceExecutionTrack track,
  required DateTime asOfDate,
}) {
  final daysUntilDue = _daysUntilDue(track.dueDate, asOfDate);
  final status = _statusForExecutionTrack(track);

  return IncomingTalentOperatingSlaItem(
    id: 'operating-sla-assurance-${track.id}',
    referenceId: track.id,
    source: IncomingTalentOperatingSlaSource.assurance,
    status: status,
    title: track.title,
    subjectName: track.workstreamLabel,
    department: 'Talent assurance',
    ownerName: _ownerName(track.ownerName),
    workstreamLabel: 'Assurance - ${track.workstreamLabel}',
    priorityLabel: track.priority.label,
    nextAction: track.nextStep,
    dueDate: track.dueDate,
    daysUntilDue: daysUntilDue,
    slaPressureRatio: _pressureForExecutionTrack(track: track, status: status),
    evidenceCount: track.completionEvidence.length,
    referenceIds: track.gapIds,
  );
}

IncomingTalentOperatingSlaStatus _statusForInboxItem({
  required IncomingTalentOperatingInboxItem item,
  required int daysUntilDue,
}) {
  if (daysUntilDue < 0) return IncomingTalentOperatingSlaStatus.overdue;
  if (daysUntilDue == 0) return IncomingTalentOperatingSlaStatus.dueToday;
  if (daysUntilDue <= 7 ||
      item.priority != IncomingTalentOperatingInboxPriority.routine) {
    return IncomingTalentOperatingSlaStatus.atRisk;
  }
  return IncomingTalentOperatingSlaStatus.onTrack;
}

IncomingTalentOperatingSlaStatus _statusForExecutionTrack(
  IncomingTalentOperatingAssuranceExecutionTrack track,
) {
  return switch (track.dueHealth) {
    IncomingTalentOperatingAssuranceExecutionDueHealth.overdue =>
      IncomingTalentOperatingSlaStatus.overdue,
    IncomingTalentOperatingAssuranceExecutionDueHealth.dueToday =>
      IncomingTalentOperatingSlaStatus.dueToday,
    IncomingTalentOperatingAssuranceExecutionDueHealth.upcoming =>
      track.needsAttention
          ? IncomingTalentOperatingSlaStatus.atRisk
          : IncomingTalentOperatingSlaStatus.onTrack,
  };
}

IncomingTalentOperatingSlaSource _slaSourceForInboxSource(
  IncomingTalentOperatingInboxSource source,
) {
  return switch (source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision ||
    IncomingTalentOperatingInboxSource
        .riskCouncilFollowUp => IncomingTalentOperatingSlaSource.recruitment,
    IncomingTalentOperatingInboxSource.trainingSession =>
      IncomingTalentOperatingSlaSource.training,
    IncomingTalentOperatingInboxSource.careerPathReview =>
      IncomingTalentOperatingSlaSource.careerPath,
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      IncomingTalentOperatingSlaSource.succession,
    IncomingTalentOperatingInboxSource.promotionStabilization =>
      IncomingTalentOperatingSlaSource.promotion,
  };
}

String _workstreamLabelForInboxSource(
  IncomingTalentOperatingInboxSource source,
) {
  return switch (source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision =>
      'Recruitment decision',
    IncomingTalentOperatingInboxSource.riskCouncilFollowUp =>
      'Recruitment follow-up',
    IncomingTalentOperatingInboxSource.trainingSession => 'Training',
    IncomingTalentOperatingInboxSource.careerPathReview => 'Career path',
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      'Succession',
    IncomingTalentOperatingInboxSource.promotionStabilization => 'Promotion',
  };
}

String _ownerName(String value) {
  final ownerName = value.trim();
  return ownerName.isEmpty ? 'Unassigned owner' : ownerName;
}

double _pressureForInboxItem({
  required IncomingTalentOperatingInboxItem item,
  required IncomingTalentOperatingSlaStatus status,
  required int daysUntilDue,
}) {
  final statusScore = switch (status) {
    IncomingTalentOperatingSlaStatus.overdue => 7,
    IncomingTalentOperatingSlaStatus.dueToday => 6,
    IncomingTalentOperatingSlaStatus.atRisk => 4,
    IncomingTalentOperatingSlaStatus.onTrack => 1,
  };
  final priorityScore = switch (item.priority) {
    IncomingTalentOperatingInboxPriority.critical => 3,
    IncomingTalentOperatingInboxPriority.watch => 2,
    IncomingTalentOperatingInboxPriority.routine => 0,
  };
  final dueScore = daysUntilDue < 0 ? daysUntilDue.abs().clamp(1, 7) : 0;
  final ratio = (statusScore + priorityScore + dueScore) / 17;

  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

double _pressureForExecutionTrack({
  required IncomingTalentOperatingAssuranceExecutionTrack track,
  required IncomingTalentOperatingSlaStatus status,
}) {
  final statusScore = switch (status) {
    IncomingTalentOperatingSlaStatus.overdue => 0.38,
    IncomingTalentOperatingSlaStatus.dueToday => 0.3,
    IncomingTalentOperatingSlaStatus.atRisk => 0.2,
    IncomingTalentOperatingSlaStatus.onTrack => 0.08,
  };
  final evidenceScore = (track.completionEvidence.length / 12).clamp(0, 0.2);
  final ratio =
      statusScore + track.normalizedExecutionRatio + evidenceScore.toDouble();

  if (ratio < 0) return 0;
  if (ratio > 1) return 1;
  return ratio;
}

int _daysUntilDue(DateTime dueDate, DateTime asOfDate) {
  final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return due.difference(start).inDays;
}

int _compareSlaItems(
  IncomingTalentOperatingSlaItem left,
  IncomingTalentOperatingSlaItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final pressure = right.normalizedSlaPressureRatio.compareTo(
    left.normalizedSlaPressureRatio,
  );
  if (pressure != 0) return pressure;

  return left.title.compareTo(right.title);
}
