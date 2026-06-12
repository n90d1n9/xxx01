import 'incoming_talent_governance_command_center.dart';
import 'incoming_talent_governance_review_pack.dart';
import 'incoming_talent_governance_review_readiness_item.dart';

/// Builds preparation tasks for the executive talent governance review.
List<IncomingTalentGovernanceReviewReadinessItem>
buildIncomingTalentGovernanceReviewReadiness({
  required IncomingTalentGovernanceReviewPack reviewPack,
  required DateTime asOfDate,
}) {
  final items =
      reviewPack.items
          .map((item) => _readinessItemFromReviewItem(item, asOfDate))
          .toList()
        ..sort(_compareReadinessItems);

  if (items.isEmpty) {
    return [
      IncomingTalentGovernanceReviewReadinessItem(
        id: 'talent-governance-review-readiness:clear',
        sourceReviewItemId: 'clear',
        category:
            IncomingTalentGovernanceReviewReadinessCategory.facilitationPlan,
        status: IncomingTalentGovernanceReviewReadinessStatus.ready,
        title: 'Governance review prep is ready',
        detail:
            'No executive talent governance decisions need additional meeting preparation.',
        ownerName: 'Talent Governance Office',
        evidencePrompt: reviewPack.chairNote,
        dueDate: asOfDate,
        signalCount: 0,
        decisionCount: 0,
        timeboxMinutes: 0,
      ),
    ];
  }

  return items;
}

IncomingTalentGovernanceReviewReadinessItem _readinessItemFromReviewItem(
  IncomingTalentGovernanceReviewItem item,
  DateTime asOfDate,
) {
  final status = _statusForReviewItem(item);
  final category = _categoryForDecisionKind(item.decisionKind);

  return IncomingTalentGovernanceReviewReadinessItem(
    id: 'talent-governance-review-readiness:${item.id}',
    sourceReviewItemId: item.id,
    category: category,
    status: status,
    title: _titleForItem(item, category),
    detail:
        '${item.decisionQuestion} Evidence required: ${item.evidencePrompt}',
    ownerName: item.ownerLabel,
    evidencePrompt: item.evidencePrompt,
    dueDate: _dueDateForStatus(
      status: status,
      itemStatus: item.status,
      asOfDate: asOfDate,
    ),
    signalCount: item.signalCount,
    decisionCount: item.decisionCount,
    timeboxMinutes: item.timeboxMinutes,
  );
}

IncomingTalentGovernanceReviewReadinessStatus _statusForReviewItem(
  IncomingTalentGovernanceReviewItem item,
) {
  if (item.status == IncomingTalentGovernanceCommandStatus.critical &&
      item.normalizedPressureRatio >= 0.65) {
    return IncomingTalentGovernanceReviewReadinessStatus.blocked;
  }
  if (item.status == IncomingTalentGovernanceCommandStatus.critical ||
      item.status == IncomingTalentGovernanceCommandStatus.watch) {
    return IncomingTalentGovernanceReviewReadinessStatus.needsPrep;
  }
  return IncomingTalentGovernanceReviewReadinessStatus.ready;
}

IncomingTalentGovernanceReviewReadinessCategory _categoryForDecisionKind(
  IncomingTalentGovernanceReviewDecisionKind kind,
) {
  return switch (kind) {
    IncomingTalentGovernanceReviewDecisionKind.unblock =>
      IncomingTalentGovernanceReviewReadinessCategory.escalationPrep,
    IncomingTalentGovernanceReviewDecisionKind.allocate =>
      IncomingTalentGovernanceReviewReadinessCategory.capacityPlan,
    IncomingTalentGovernanceReviewDecisionKind.approve =>
      IncomingTalentGovernanceReviewReadinessCategory.decisionBrief,
    IncomingTalentGovernanceReviewDecisionKind.align =>
      IncomingTalentGovernanceReviewReadinessCategory.ownerConfirmation,
    IncomingTalentGovernanceReviewDecisionKind.monitor =>
      IncomingTalentGovernanceReviewReadinessCategory.facilitationPlan,
  };
}

String _titleForItem(
  IncomingTalentGovernanceReviewItem item,
  IncomingTalentGovernanceReviewReadinessCategory category,
) {
  final subject = item.title.toLowerCase();

  return switch (category) {
    IncomingTalentGovernanceReviewReadinessCategory.decisionBrief =>
      'Prepare $subject decision brief',
    IncomingTalentGovernanceReviewReadinessCategory.escalationPrep =>
      'Prepare $subject unblock path',
    IncomingTalentGovernanceReviewReadinessCategory.capacityPlan =>
      'Confirm $subject capacity commitment',
    IncomingTalentGovernanceReviewReadinessCategory.ownerConfirmation =>
      'Confirm $subject owner alignment',
    IncomingTalentGovernanceReviewReadinessCategory.evidencePack =>
      'Assemble $subject evidence pack',
    IncomingTalentGovernanceReviewReadinessCategory.facilitationPlan =>
      'Schedule $subject governance readout',
  };
}

DateTime _dueDateForStatus({
  required IncomingTalentGovernanceReviewReadinessStatus status,
  required IncomingTalentGovernanceCommandStatus itemStatus,
  required DateTime asOfDate,
}) {
  return switch (status) {
    IncomingTalentGovernanceReviewReadinessStatus.blocked => asOfDate,
    IncomingTalentGovernanceReviewReadinessStatus.needsPrep =>
      itemStatus == IncomingTalentGovernanceCommandStatus.critical
          ? asOfDate.add(const Duration(days: 1))
          : asOfDate.add(const Duration(days: 3)),
    IncomingTalentGovernanceReviewReadinessStatus.ready => asOfDate.add(
      const Duration(days: 14),
    ),
  };
}

int _compareReadinessItems(
  IncomingTalentGovernanceReviewReadinessItem left,
  IncomingTalentGovernanceReviewReadinessItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  return left.title.compareTo(right.title);
}
