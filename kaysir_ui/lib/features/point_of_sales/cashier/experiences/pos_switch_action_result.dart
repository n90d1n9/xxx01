typedef POSSwitchActionResultListener =
    void Function(POSSwitchActionResult result);

enum POSSwitchActionKind { mode, runtimePack, commerceChannel }

enum POSSwitchActionOutcome { applied, blocked, cancelled }

class POSSwitchActionResult {
  final POSSwitchActionKind kind;
  final POSSwitchActionOutcome outcome;
  final String targetId;
  final String targetLabel;
  final String? reason;

  const POSSwitchActionResult({
    required this.kind,
    required this.outcome,
    required this.targetId,
    required this.targetLabel,
    this.reason,
  });

  const POSSwitchActionResult.applied({
    required this.kind,
    required this.targetId,
    required this.targetLabel,
  }) : outcome = POSSwitchActionOutcome.applied,
       reason = null;

  const POSSwitchActionResult.blocked({
    required this.kind,
    required this.targetId,
    required this.targetLabel,
    required this.reason,
  }) : outcome = POSSwitchActionOutcome.blocked;

  const POSSwitchActionResult.cancelled({
    required this.kind,
    required this.targetId,
    required this.targetLabel,
    required this.reason,
  }) : outcome = POSSwitchActionOutcome.cancelled;

  bool get applied => outcome == POSSwitchActionOutcome.applied;

  bool get blocked => outcome == POSSwitchActionOutcome.blocked;

  bool get cancelled => outcome == POSSwitchActionOutcome.cancelled;

  bool get requiresAttention => blocked;

  String get kindLabel {
    switch (kind) {
      case POSSwitchActionKind.mode:
        return 'POS mode';
      case POSSwitchActionKind.runtimePack:
        return 'Runtime pack';
      case POSSwitchActionKind.commerceChannel:
        return 'Commerce channel';
    }
  }

  String get outcomeLabel {
    switch (outcome) {
      case POSSwitchActionOutcome.applied:
        return 'Applied';
      case POSSwitchActionOutcome.blocked:
        return 'Blocked';
      case POSSwitchActionOutcome.cancelled:
        return 'Cancelled';
    }
  }

  String get summaryLabel => '$outcomeLabel $kindLabel: $targetLabel';

  Iterable<String> get searchTerms sync* {
    yield kind.name;
    yield kindLabel;
    yield outcome.name;
    yield outcomeLabel;
    yield targetId;
    yield targetLabel;
    final reasonText = reason;
    if (reasonText != null && reasonText.isNotEmpty) yield reasonText;
  }
}
