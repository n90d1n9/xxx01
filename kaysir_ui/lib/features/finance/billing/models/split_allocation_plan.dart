import 'billing_policy_capability.dart';

/// Severity for split allocation issues detected by policy planning.
enum BillingSplitAllocationIssueSeverity { blocker, warning }

/// Stable issue kinds emitted while evaluating split billing allocation.
enum BillingSplitAllocationIssueKind {
  splitBillingDisabled,
  multiPayerDisabled,
  invalidAmount,
  missingRecipient,
  invalidRecipient,
  tooManyRecipients,
  invalidShareTotal,
}

/// Requested recipient share for a split billing allocation plan.
class BillingSplitAllocationRecipient {
  final String id;
  final String label;
  final double share;

  const BillingSplitAllocationRecipient({
    required this.id,
    required this.label,
    required this.share,
  });

  bool get isValid => validationErrors.isEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    if (id.trim().isEmpty) {
      errors.add('Recipient id is required.');
    }
    if (label.trim().isEmpty) {
      errors.add('Recipient label is required.');
    }
    if (share <= 0 || share > 1) {
      errors.add('Recipient share must be greater than 0 and at most 100%.');
    }

    return List.unmodifiable(errors);
  }
}

/// Allocated amount for one split billing recipient.
class BillingSplitAllocationLine {
  final String recipientId;
  final String label;
  final double share;
  final double amount;

  const BillingSplitAllocationLine({
    required this.recipientId,
    required this.label,
    required this.share,
    required this.amount,
  });

  String get shareLabel {
    final percentage = share * 100;
    final rounded = percentage.roundToDouble();
    if ((percentage - rounded).abs() < 0.01) {
      return '${rounded.toStringAsFixed(0)}%';
    }

    return '${percentage.toStringAsFixed(1)}%';
  }
}

/// Explains one blocker or warning discovered in a split allocation plan.
class BillingSplitAllocationIssue {
  final BillingSplitAllocationIssueKind kind;
  final BillingSplitAllocationIssueSeverity severity;
  final String message;
  final List<String> details;

  BillingSplitAllocationIssue({
    required this.kind,
    required this.severity,
    required this.message,
    Iterable<String> details = const [],
  }) : details = List.unmodifiable(details);

  bool get isBlocker => severity == BillingSplitAllocationIssueSeverity.blocker;

  bool get isWarning => severity == BillingSplitAllocationIssueSeverity.warning;
}

/// Evaluated split billing allocation plan for a billing workspace.
class BillingSplitAllocationPlan {
  final double totalAmount;
  final int maxRecipientCount;
  final List<BillingSplitAllocationRecipient> recipients;
  final List<BillingSplitAllocationLine> lines;
  final Set<BillingPolicyCapabilityId> requiredCapabilityIds;
  final Set<BillingPolicyCapabilityId> missingCapabilityIds;
  final List<BillingSplitAllocationIssue> issues;

  BillingSplitAllocationPlan({
    required this.totalAmount,
    required this.maxRecipientCount,
    Iterable<BillingSplitAllocationRecipient> recipients = const [],
    Iterable<BillingSplitAllocationLine> lines = const [],
    Iterable<BillingPolicyCapabilityId> requiredCapabilityIds = const [],
    Iterable<BillingPolicyCapabilityId> missingCapabilityIds = const [],
    Iterable<BillingSplitAllocationIssue> issues = const [],
  }) : recipients = List.unmodifiable(recipients),
       lines = List.unmodifiable(lines),
       requiredCapabilityIds = Set.unmodifiable(requiredCapabilityIds),
       missingCapabilityIds = Set.unmodifiable(missingCapabilityIds),
       issues = List.unmodifiable(issues);

  int get recipientCount => recipients.length;

  double get shareTotal {
    return recipients.fold<double>(
      0,
      (sum, recipient) => sum + recipient.share,
    );
  }

  double get allocatedAmount {
    return lines.fold<double>(0, (sum, line) => sum + line.amount);
  }

  double get unallocatedAmount => totalAmount - allocatedAmount;

  bool get hasIssues => issues.isNotEmpty;

  bool get hasBlockers => blockerIssues.isNotEmpty;

  bool get isConfigured =>
      !missingCapabilityIds.contains(BillingPolicyCapabilityId.splitBilling);

  bool get isWithinRecipientLimit => recipientCount <= maxRecipientCount;

  bool get isBalanced => (shareTotal - 1).abs() <= 0.0001;

  bool get isActionable => !hasBlockers;

  List<BillingSplitAllocationIssue> get blockerIssues {
    return List.unmodifiable(issues.where((issue) => issue.isBlocker));
  }

  List<BillingSplitAllocationIssue> get warningIssues {
    return List.unmodifiable(issues.where((issue) => issue.isWarning));
  }

  String get statusLabel {
    if (!isConfigured) {
      return 'Needs capability';
    }
    if (hasBlockers) {
      return 'Needs correction';
    }
    return 'Ready';
  }

  String get summaryLabel {
    if (!isConfigured) {
      return 'Enable split billing before allocation can be used.';
    }
    if (hasBlockers) {
      return 'Split allocation has ${blockerIssues.length} '
          '${blockerIssues.length == 1 ? 'blocker' : 'blockers'}.';
    }

    return '$recipientCount ${recipientCount == 1 ? 'recipient' : 'recipients'} '
        'share $shareTotalLabel of the billed amount.';
  }

  String get shareTotalLabel {
    return '${(shareTotal * 100).toStringAsFixed(0)}%';
  }

  bool hasIssueKind(BillingSplitAllocationIssueKind kind) {
    return issues.any((issue) => issue.kind == kind);
  }
}
