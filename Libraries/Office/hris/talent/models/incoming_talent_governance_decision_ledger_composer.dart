import 'incoming_talent_governance_decision_ledger_item.dart';
import 'incoming_talent_governance_review_pack.dart';
import 'incoming_talent_governance_review_readiness_item.dart';

/// Builds the executive talent governance decision ledger from review signals.
List<IncomingTalentGovernanceDecisionLedgerItem>
buildIncomingTalentGovernanceDecisionLedger({
  required IncomingTalentGovernanceReviewPack reviewPack,
  required List<IncomingTalentGovernanceReviewReadinessItem> readinessItems,
  required DateTime asOfDate,
}) {
  if (reviewPack.items.isEmpty) {
    return [
      _clearLedgerItem(
        reviewItemId: 'talent-governance-review:empty',
        asOfDate: asOfDate,
      ),
    ];
  }

  final readinessByReviewItemId =
      <String, List<IncomingTalentGovernanceReviewReadinessItem>>{};
  for (final readinessItem in readinessItems) {
    readinessByReviewItemId
        .putIfAbsent(readinessItem.sourceReviewItemId, () => [])
        .add(readinessItem);
  }

  final items =
      reviewPack.items.map((reviewItem) {
          final linkedReadinessItems =
              readinessByReviewItemId[reviewItem.id] ?? const [];

          return IncomingTalentGovernanceDecisionLedgerItem(
            id: 'talent-governance-decision-ledger:${reviewItem.id}',
            reviewItemId: reviewItem.id,
            type: _typeFor(reviewItem.decisionKind),
            status: _statusFor(
              reviewItem: reviewItem,
              readinessItems: linkedReadinessItems,
            ),
            title: _titleFor(reviewItem),
            decisionRecord: reviewItem.decisionQuestion,
            commitment: _commitmentFor(reviewItem),
            evidenceExpectation: _evidenceFor(reviewItem),
            ownerName: reviewItem.ownerLabel,
            dueDate: _dueDateFor(
              reviewItem: reviewItem,
              readinessItems: linkedReadinessItems,
              asOfDate: asOfDate,
            ),
            signalCount: _signalCountFor(
              reviewItem: reviewItem,
              readinessItems: linkedReadinessItems,
            ),
            decisionCount: reviewItem.decisionCount,
            timeboxMinutes: reviewItem.timeboxMinutes,
            readinessTaskIds:
                linkedReadinessItems.map((item) => item.id).toList(),
          );
        }).toList()
        ..sort(_compareLedgerItems);

  return items;
}

IncomingTalentGovernanceDecisionLedgerItem _clearLedgerItem({
  required String reviewItemId,
  required DateTime asOfDate,
}) {
  return IncomingTalentGovernanceDecisionLedgerItem(
    id: 'talent-governance-decision-ledger:clear',
    reviewItemId: reviewItemId,
    type: IncomingTalentGovernanceDecisionLedgerType.clear,
    status: IncomingTalentGovernanceDecisionLedgerStatus.clear,
    title: 'No governance decisions to publish',
    decisionRecord:
        'Confirm talent governance is clear and keep the next review visible.',
    commitment:
        'Publish the clear governance note and maintain the next review cadence.',
    evidenceExpectation: 'Clear governance note and next review date.',
    ownerName: 'Talent Governance Office',
    dueDate: asOfDate,
    signalCount: 0,
    decisionCount: 0,
    timeboxMinutes: 0,
    readinessTaskIds: const [],
  );
}

IncomingTalentGovernanceDecisionLedgerStatus _statusFor({
  required IncomingTalentGovernanceReviewItem reviewItem,
  required List<IncomingTalentGovernanceReviewReadinessItem> readinessItems,
}) {
  if (_hasReadinessStatus(
    readinessItems,
    IncomingTalentGovernanceReviewReadinessStatus.blocked,
  )) {
    return IncomingTalentGovernanceDecisionLedgerStatus.blocked;
  }
  if (reviewItem.isUrgent) {
    return IncomingTalentGovernanceDecisionLedgerStatus.needsDecision;
  }
  if (reviewItem.ownerLabel.trim().isEmpty) {
    return IncomingTalentGovernanceDecisionLedgerStatus.needsOwner;
  }
  if (_hasReadinessStatus(
    readinessItems,
    IncomingTalentGovernanceReviewReadinessStatus.needsPrep,
  )) {
    return switch (reviewItem.decisionKind) {
      IncomingTalentGovernanceReviewDecisionKind.align ||
      IncomingTalentGovernanceReviewDecisionKind
          .allocate => IncomingTalentGovernanceDecisionLedgerStatus.needsOwner,
      IncomingTalentGovernanceReviewDecisionKind.unblock ||
      IncomingTalentGovernanceReviewDecisionKind.approve =>
        IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence,
      IncomingTalentGovernanceReviewDecisionKind.monitor =>
        IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish,
    };
  }
  return IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish;
}

IncomingTalentGovernanceDecisionLedgerType _typeFor(
  IncomingTalentGovernanceReviewDecisionKind kind,
) {
  return switch (kind) {
    IncomingTalentGovernanceReviewDecisionKind.unblock =>
      IncomingTalentGovernanceDecisionLedgerType.executiveUnblock,
    IncomingTalentGovernanceReviewDecisionKind.allocate =>
      IncomingTalentGovernanceDecisionLedgerType.capacityCommitment,
    IncomingTalentGovernanceReviewDecisionKind.approve =>
      IncomingTalentGovernanceDecisionLedgerType.approvalDecision,
    IncomingTalentGovernanceReviewDecisionKind.align =>
      IncomingTalentGovernanceDecisionLedgerType.ownerAlignment,
    IncomingTalentGovernanceReviewDecisionKind.monitor =>
      IncomingTalentGovernanceDecisionLedgerType.monitoringRecord,
  };
}

String _titleFor(IncomingTalentGovernanceReviewItem reviewItem) {
  return switch (reviewItem.decisionKind) {
    IncomingTalentGovernanceReviewDecisionKind.unblock =>
      'Publish ${reviewItem.title.toLowerCase()} unblock decision',
    IncomingTalentGovernanceReviewDecisionKind.allocate =>
      'Publish ${reviewItem.title.toLowerCase()} capacity commitment',
    IncomingTalentGovernanceReviewDecisionKind.approve =>
      'Publish ${reviewItem.title.toLowerCase()} approval decision',
    IncomingTalentGovernanceReviewDecisionKind.align =>
      'Publish ${reviewItem.title.toLowerCase()} owner alignment',
    IncomingTalentGovernanceReviewDecisionKind.monitor =>
      'Publish ${reviewItem.title.toLowerCase()} monitoring note',
  };
}

String _commitmentFor(IncomingTalentGovernanceReviewItem reviewItem) {
  return switch (reviewItem.decisionKind) {
    IncomingTalentGovernanceReviewDecisionKind.unblock =>
      'Capture the unblock decision, accountable owner, and recovery date.',
    IncomingTalentGovernanceReviewDecisionKind.allocate =>
      'Capture the approved capacity commitment and owner cadence.',
    IncomingTalentGovernanceReviewDecisionKind.approve =>
      'Capture the approval decision and conditions for closure.',
    IncomingTalentGovernanceReviewDecisionKind.align =>
      'Capture owner alignment, next review date, and success signal.',
    IncomingTalentGovernanceReviewDecisionKind.monitor =>
      'Record the monitoring note and confirm monthly review cadence.',
  };
}

String _evidenceFor(IncomingTalentGovernanceReviewItem reviewItem) {
  return '${reviewItem.recommendedDecision} Evidence: ${reviewItem.evidencePrompt}';
}

DateTime _dueDateFor({
  required IncomingTalentGovernanceReviewItem reviewItem,
  required List<IncomingTalentGovernanceReviewReadinessItem> readinessItems,
  required DateTime asOfDate,
}) {
  final readinessDueDates =
      readinessItems.map((item) => item.dueDate).toList()..sort();
  if (readinessDueDates.isNotEmpty) return readinessDueDates.first;

  if (reviewItem.isUrgent) return asOfDate;
  return asOfDate.add(Duration(days: reviewItem.status.sortRank + 2));
}

int _signalCountFor({
  required IncomingTalentGovernanceReviewItem reviewItem,
  required List<IncomingTalentGovernanceReviewReadinessItem> readinessItems,
}) {
  final readinessSignalCount = readinessItems.fold<int>(
    0,
    (total, item) => total + item.signalCount,
  );
  if (reviewItem.signalCount > readinessSignalCount) {
    return reviewItem.signalCount;
  }
  return readinessSignalCount;
}

bool _hasReadinessStatus(
  List<IncomingTalentGovernanceReviewReadinessItem> items,
  IncomingTalentGovernanceReviewReadinessStatus status,
) {
  return items.any((item) => item.status == status);
}

int _compareLedgerItems(
  IncomingTalentGovernanceDecisionLedgerItem left,
  IncomingTalentGovernanceDecisionLedgerItem right,
) {
  final urgency = left.urgencyRank.compareTo(right.urgencyRank);
  if (urgency != 0) return urgency;

  final dueDate = left.dueDate.compareTo(right.dueDate);
  if (dueDate != 0) return dueDate;

  final signals = right.signalCount.compareTo(left.signalCount);
  if (signals != 0) return signals;

  return left.title.compareTo(right.title);
}
