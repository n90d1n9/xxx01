import 'billing_business_domain_blueprint_fit_matrix.dart';
import 'billing_business_domain_blueprint_launch_plan.dart';
import 'billing_product_package.dart';

enum BillingProductPackageLane { packageNow, harden, unblock, unavailable }

class BillingProductPackagePlan {
  final BillingProductPackage package;
  final List<BillingBusinessDomainBlueprintLaunchPlan> candidatePlans;
  final List<BillingBusinessDomainBlueprintFitColumn> columns;

  BillingProductPackagePlan({
    required this.package,
    required Iterable<BillingBusinessDomainBlueprintLaunchPlan> candidatePlans,
    required Iterable<BillingBusinessDomainBlueprintFitColumn> columns,
  }) : candidatePlans = List.unmodifiable(candidatePlans),
       columns = List.unmodifiable(columns);

  String get packageKey => package.key;

  List<BillingBusinessDomainBlueprintLaunchPlan> get fittedDomainPlans {
    return List.unmodifiable(candidatePlans.where(_supportsRequiredSignals));
  }

  BillingBusinessDomainBlueprintLaunchPlan? get selectedDomainPlan {
    final fitted = fittedDomainPlans.toList(growable: false);
    if (fitted.isEmpty) return null;

    fitted.sort(_compareDomainPlans);
    return fitted.first;
  }

  BillingProductPackageLane get lane {
    final selectedPlan = selectedDomainPlan;
    if (selectedPlan == null) return BillingProductPackageLane.unavailable;

    return switch (selectedPlan.lane) {
      BillingBusinessDomainBlueprintLaunchLane.packageNow =>
        BillingProductPackageLane.packageNow,
      BillingBusinessDomainBlueprintLaunchLane.harden =>
        BillingProductPackageLane.harden,
      BillingBusinessDomainBlueprintLaunchLane.unblock =>
        BillingProductPackageLane.unblock,
    };
  }

  bool get isAvailable {
    return lane != BillingProductPackageLane.unavailable;
  }

  List<String> get requiredSignalLabels {
    return List.unmodifiable(package.requiredSignals.map(_signalLabel));
  }

  List<String> get recommendedSignalLabels {
    return List.unmodifiable(package.recommendedSignals.map(_signalLabel));
  }

  List<String> get missingSignalLabels {
    return List.unmodifiable(
      package.requiredSignals
          .where(
            (signal) =>
                !candidatePlans.any((plan) => plan.fitRow.supports(signal)),
          )
          .map(_signalLabel),
    );
  }

  String get laneLabel {
    return switch (lane) {
      BillingProductPackageLane.packageNow => 'Package now',
      BillingProductPackageLane.harden => 'Harden first',
      BillingProductPackageLane.unblock => 'Resolve blockers',
      BillingProductPackageLane.unavailable => 'Needs domain fit',
    };
  }

  String get domainSummary {
    final selectedPlan = selectedDomainPlan;
    if (selectedPlan != null) return selectedPlan.domainLabel;
    return _joinLabels(package.domainKeys, emptyLabel: 'No matching domains');
  }

  String get primaryActionLabel {
    final selectedPlan = selectedDomainPlan;
    if (selectedPlan == null) return 'Add package fit signals';

    return switch (lane) {
      BillingProductPackageLane.packageNow => 'Package ${package.label}',
      BillingProductPackageLane.harden => 'Harden ${selectedPlan.domainLabel}',
      BillingProductPackageLane.unblock =>
        'Resolve ${selectedPlan.domainLabel} blockers',
      BillingProductPackageLane.unavailable => 'Add package fit signals',
    };
  }

  String get primaryActionDetail {
    final selectedPlan = selectedDomainPlan;
    if (selectedPlan == null) {
      final signalSummary = _joinLabels(
        requiredSignalLabels,
        emptyLabel: 'required signals',
      );
      return 'No registered billing domain currently supports $signalSummary '
          'for ${package.label}.';
    }

    return selectedPlan.requirePrimaryStep().detail;
  }

  bool _supportsRequiredSignals(BillingBusinessDomainBlueprintLaunchPlan plan) {
    return package.requiredSignals.every(plan.fitRow.supports);
  }

  int _compareDomainPlans(
    BillingBusinessDomainBlueprintLaunchPlan left,
    BillingBusinessDomainBlueprintLaunchPlan right,
  ) {
    final laneOrder = _lanePriority(
      left.lane,
    ).compareTo(_lanePriority(right.lane));
    if (laneOrder != 0) return laneOrder;

    return package.domainKeys
        .indexOf(left.domainKey)
        .compareTo(package.domainKeys.indexOf(right.domainKey));
  }
}

class BillingProductPackagePortfolio {
  final List<BillingProductPackagePlan> plans;

  BillingProductPackagePortfolio({
    Iterable<BillingProductPackagePlan> plans = const [],
  }) : plans = List.unmodifiable(plans);

  factory BillingProductPackagePortfolio.forLaunchPortfolio({
    required BillingProductPackageRegistry registry,
    required BillingBusinessDomainBlueprintLaunchPortfolio launchPortfolio,
    Iterable<BillingBusinessDomainBlueprintFitColumn> columns =
        standardBillingBusinessDomainBlueprintFitColumns,
  }) {
    final resolvedColumns = columns.toList(growable: false);

    return BillingProductPackagePortfolio(
      plans: registry.packages.map(
        (package) => BillingProductPackagePlan(
          package: package,
          candidatePlans:
              package.domainKeys
                  .map(launchPortfolio.planForDomain)
                  .whereType<BillingBusinessDomainBlueprintLaunchPlan>(),
          columns: resolvedColumns,
        ),
      ),
    );
  }

  bool get isEmpty => plans.isEmpty;

  int get packageCount => plans.length;

  int get packageNowCount =>
      plansForLane(BillingProductPackageLane.packageNow).length;

  int get hardenCount => plansForLane(BillingProductPackageLane.harden).length;

  int get blockedCount =>
      plansForLane(BillingProductPackageLane.unblock).length;

  int get unavailableCount =>
      plansForLane(BillingProductPackageLane.unavailable).length;

  List<String> get packageKeys {
    return List.unmodifiable(plans.map((plan) => plan.packageKey));
  }

  List<BillingProductPackagePlan> plansForLane(BillingProductPackageLane lane) {
    return List.unmodifiable(plans.where((plan) => plan.lane == lane));
  }

  BillingProductPackagePlan? planForPackage(String id) {
    final key = billingProductPackageKey(id);

    for (final plan in plans) {
      if (plan.packageKey == key) return plan;
    }

    return null;
  }

  BillingProductPackagePlan requirePlanForPackage(String id) {
    final plan = planForPackage(id);
    if (plan == null) {
      throw StateError('No billing product package plan exists for $id.');
    }

    return plan;
  }

  String get summaryLabel {
    if (isEmpty) return 'No billing product packages are registered.';
    if (unavailableCount > 0) {
      return '$unavailableCount of $packageCount billing product '
          '${_plural(packageCount, 'package')} need domain fit.';
    }
    if (blockedCount > 0) {
      return '$blockedCount of $packageCount billing product '
          '${_plural(packageCount, 'package')} need blockers resolved.';
    }
    if (hardenCount > 0) {
      return '$packageCount billing product '
          '${_plural(packageCount, 'package')} are mapped with '
          '$hardenCount hardening ${_plural(hardenCount, 'action')}.';
    }

    return '$packageCount billing product '
        '${_plural(packageCount, 'package')} are ready to package.';
  }
}

int _lanePriority(BillingBusinessDomainBlueprintLaunchLane lane) {
  return switch (lane) {
    BillingBusinessDomainBlueprintLaunchLane.packageNow => 0,
    BillingBusinessDomainBlueprintLaunchLane.harden => 1,
    BillingBusinessDomainBlueprintLaunchLane.unblock => 2,
  };
}

String _signalLabel(BillingBusinessDomainBlueprintFitSignal signal) {
  for (final column in standardBillingBusinessDomainBlueprintFitColumns) {
    if (column.signal == signal) return column.label;
  }

  return signal.name;
}

String _joinLabels(List<String> labels, {required String emptyLabel}) {
  if (labels.isEmpty) return emptyLabel;
  if (labels.length == 1) return labels.first;
  if (labels.length == 2) return '${labels.first} and ${labels.last}';

  return '${labels.take(labels.length - 1).join(', ')}, and ${labels.last}';
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
