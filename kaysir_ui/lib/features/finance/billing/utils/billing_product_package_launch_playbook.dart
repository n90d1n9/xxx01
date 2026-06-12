import 'billing_product_package.dart';
import 'billing_product_package_plan.dart';

enum BillingProductPackageLaunchActionKind {
  package,
  harden,
  unblock,
  fitSignals,
}

class BillingProductPackageLaunchAction {
  final String id;
  final String packageKey;
  final String packageLabel;
  final String label;
  final String detail;
  final BillingProductPackageLaunchActionKind kind;
  final BillingProductPackageLane lane;
  final String domainKey;
  final String domainLabel;
  final bool isPrimary;
  final int priority;

  const BillingProductPackageLaunchAction({
    required this.id,
    required this.packageKey,
    required this.packageLabel,
    required this.label,
    required this.detail,
    required this.kind,
    required this.lane,
    required this.domainKey,
    required this.domainLabel,
    required this.isPrimary,
    required this.priority,
  });

  bool get isActionable {
    return lane != BillingProductPackageLane.unavailable;
  }

  bool get isBlocking {
    return kind == BillingProductPackageLaunchActionKind.unblock ||
        kind == BillingProductPackageLaunchActionKind.fitSignals;
  }

  String get laneLabel {
    return switch (lane) {
      BillingProductPackageLane.packageNow => 'Launch now',
      BillingProductPackageLane.harden => 'Harden',
      BillingProductPackageLane.unblock => 'Blocked',
      BillingProductPackageLane.unavailable => 'Needs fit',
    };
  }

  String get kindLabel {
    return switch (kind) {
      BillingProductPackageLaunchActionKind.package => 'Package',
      BillingProductPackageLaunchActionKind.harden => 'Harden',
      BillingProductPackageLaunchActionKind.unblock => 'Unblock',
      BillingProductPackageLaunchActionKind.fitSignals => 'Fit signals',
    };
  }
}

class BillingProductPackageLaunchPlaybook {
  final List<BillingProductPackageLaunchAction> actions;

  BillingProductPackageLaunchPlaybook({
    Iterable<BillingProductPackageLaunchAction> actions = const [],
  }) : actions = List.unmodifiable(_sortActions(actions));

  factory BillingProductPackageLaunchPlaybook.forPortfolio(
    BillingProductPackagePortfolio portfolio, {
    int maxActionsPerPackage = 3,
  }) {
    return BillingProductPackageLaunchPlaybook(
      actions: portfolio.plans.expand(
        (plan) =>
            _actionsForPlan(plan, maxActionsPerPackage: maxActionsPerPackage),
      ),
    );
  }

  bool get isEmpty => actions.isEmpty;

  int get actionCount => actions.length;

  List<BillingProductPackageLaunchAction> get primaryActions {
    return List.unmodifiable(actions.where((action) => action.isPrimary));
  }

  int get packageCount => primaryActions.length;

  int get packageNowCount {
    return primaryActionsForLane(BillingProductPackageLane.packageNow).length;
  }

  int get hardenCount {
    return primaryActionsForLane(BillingProductPackageLane.harden).length;
  }

  int get blockedCount {
    return primaryActionsForLane(BillingProductPackageLane.unblock).length;
  }

  int get unavailableCount {
    return primaryActionsForLane(BillingProductPackageLane.unavailable).length;
  }

  List<BillingProductPackageLaunchAction> actionsForLane(
    BillingProductPackageLane lane,
  ) {
    return List.unmodifiable(actions.where((action) => action.lane == lane));
  }

  List<BillingProductPackageLaunchAction> primaryActionsForLane(
    BillingProductPackageLane lane,
  ) {
    return List.unmodifiable(
      primaryActions.where((action) => action.lane == lane),
    );
  }

  List<BillingProductPackageLaunchAction> actionsForPackage(String id) {
    final key = billingProductPackageKey(id);

    return List.unmodifiable(
      actions.where((action) => action.packageKey == key),
    );
  }

  BillingProductPackageLaunchAction? primaryActionForPackage(String id) {
    final key = billingProductPackageKey(id);

    for (final action in primaryActions) {
      if (action.packageKey == key) return action;
    }

    return null;
  }

  BillingProductPackageLaunchAction requirePrimaryActionForPackage(String id) {
    final action = primaryActionForPackage(id);
    if (action == null) {
      throw StateError(
        'No billing product package launch action exists for $id.',
      );
    }

    return action;
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product package launch actions are available.';
    }

    final blockedTotal = blockedCount + unavailableCount;
    if (blockedTotal > 0) {
      return '$blockedTotal ${_plural(blockedTotal, 'package')} need '
          'blockers or fit signals cleared.';
    }
    if (hardenCount > 0 && packageNowCount > 0) {
      return '$packageNowCount ${_plural(packageNowCount, 'package')} can '
          'launch now; $hardenCount need hardening.';
    }
    if (hardenCount > 0) {
      return '$hardenCount ${_plural(hardenCount, 'package')} need '
          'hardening before release.';
    }

    return '$packageNowCount ${_plural(packageNowCount, 'package')} can '
        'launch now.';
  }
}

List<BillingProductPackageLaunchAction> _actionsForPlan(
  BillingProductPackagePlan plan, {
  required int maxActionsPerPackage,
}) {
  final selectedPlan = plan.selectedDomainPlan;
  if (selectedPlan == null) {
    return [
      BillingProductPackageLaunchAction(
        id: '${plan.packageKey}:fit_signals',
        packageKey: plan.packageKey,
        packageLabel: plan.package.label,
        label: plan.primaryActionLabel,
        detail: plan.primaryActionDetail,
        kind: BillingProductPackageLaunchActionKind.fitSignals,
        lane: BillingProductPackageLane.unavailable,
        domainKey: '',
        domainLabel: 'No matching domains',
        isPrimary: true,
        priority: _lanePriority(BillingProductPackageLane.unavailable),
      ),
    ];
  }

  final steps = selectedPlan.steps.take(maxActionsPerPackage).toList();
  return List.unmodifiable(
    steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final kind = _kindForStep(step.id);
      final isPrimary = index == 0;

      return BillingProductPackageLaunchAction(
        id: '${plan.packageKey}:${selectedPlan.domainKey}:${step.id}:$index',
        packageKey: plan.packageKey,
        packageLabel: plan.package.label,
        label:
            isPrimary
                ? plan.primaryActionLabel
                : _labelForSecondaryStep(plan, kind),
        detail: step.detail,
        kind: kind,
        lane: plan.lane,
        domainKey: selectedPlan.domainKey,
        domainLabel: selectedPlan.domainLabel,
        isPrimary: isPrimary,
        priority: _lanePriority(plan.lane) + index,
      );
    }),
  );
}

BillingProductPackageLaunchActionKind _kindForStep(String stepId) {
  if (stepId.startsWith('unblock_')) {
    return BillingProductPackageLaunchActionKind.unblock;
  }
  if (stepId.startsWith('harden_')) {
    return BillingProductPackageLaunchActionKind.harden;
  }

  return BillingProductPackageLaunchActionKind.package;
}

String _labelForSecondaryStep(
  BillingProductPackagePlan plan,
  BillingProductPackageLaunchActionKind kind,
) {
  final domainLabel =
      plan.selectedDomainPlan?.domainLabel ?? plan.domainSummary;

  return switch (kind) {
    BillingProductPackageLaunchActionKind.package =>
      'Package ${plan.package.label}',
    BillingProductPackageLaunchActionKind.harden => 'Harden $domainLabel',
    BillingProductPackageLaunchActionKind.unblock =>
      'Resolve $domainLabel blocker',
    BillingProductPackageLaunchActionKind.fitSignals =>
      'Add package fit signals',
  };
}

List<BillingProductPackageLaunchAction> _sortActions(
  Iterable<BillingProductPackageLaunchAction> actions,
) {
  final sorted = actions.toList(growable: false);
  sorted.sort((left, right) {
    final priority = left.priority.compareTo(right.priority);
    if (priority != 0) return priority;

    final packageOrder = left.packageKey.compareTo(right.packageKey);
    if (packageOrder != 0) return packageOrder;

    return left.id.compareTo(right.id);
  });
  return sorted;
}

int _lanePriority(BillingProductPackageLane lane) {
  return switch (lane) {
    BillingProductPackageLane.packageNow => 0,
    BillingProductPackageLane.harden => 100,
    BillingProductPackageLane.unblock => 200,
    BillingProductPackageLane.unavailable => 300,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
