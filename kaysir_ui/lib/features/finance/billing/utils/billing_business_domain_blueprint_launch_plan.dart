import '../models/billing_business_domain_profile.dart';
import 'billing_business_domain_blueprint.dart';
import 'billing_business_domain_blueprint_fit_matrix.dart';

enum BillingBusinessDomainBlueprintLaunchLane { packageNow, harden, unblock }

class BillingBusinessDomainBlueprintLaunchStep {
  final String id;
  final String label;
  final String detail;

  const BillingBusinessDomainBlueprintLaunchStep({
    required this.id,
    required this.label,
    required this.detail,
  });
}

class BillingBusinessDomainBlueprintLaunchPlan {
  final BillingBusinessDomainBlueprintFitRow fitRow;
  final List<BillingBusinessDomainBlueprintFitColumn> columns;
  final BillingBusinessDomainBlueprintLaunchLane lane;
  final List<BillingBusinessDomainBlueprintLaunchStep> steps;

  BillingBusinessDomainBlueprintLaunchPlan({
    required this.fitRow,
    required Iterable<BillingBusinessDomainBlueprintFitColumn> columns,
    required this.lane,
    Iterable<BillingBusinessDomainBlueprintLaunchStep> steps = const [],
  }) : columns = List.unmodifiable(columns),
       steps = List.unmodifiable(steps);

  BillingBusinessDomainBlueprint get blueprint => fitRow.blueprint;

  String get domainKey => fitRow.domainKey;

  String get domainLabel => fitRow.domainLabel;

  String get productModeLabel => fitRow.productModeLabel;

  String get channelLabel => blueprint.channelLabel;

  bool get isBlocked {
    return lane == BillingBusinessDomainBlueprintLaunchLane.unblock;
  }

  bool get needsHardening {
    return lane == BillingBusinessDomainBlueprintLaunchLane.harden;
  }

  bool get canPackageNow {
    return lane == BillingBusinessDomainBlueprintLaunchLane.packageNow;
  }

  List<BillingBusinessDomainBlueprintFitColumn> get supportedColumns {
    return List.unmodifiable(
      columns.where((column) => fitRow.supports(column.signal)),
    );
  }

  List<String> get supportedSignalLabels {
    return List.unmodifiable(supportedColumns.map((column) => column.label));
  }

  String get supportedSignalSummary {
    return _joinLabels(supportedSignalLabels, emptyLabel: 'No fit signals');
  }

  BillingBusinessDomainBlueprintLaunchStep? get primaryStep {
    return steps.isEmpty ? null : steps.first;
  }

  BillingBusinessDomainBlueprintLaunchStep requirePrimaryStep() {
    final step = primaryStep;
    if (step == null) {
      throw StateError('No launch step exists for $domainKey.');
    }

    return step;
  }

  String get laneLabel {
    return switch (lane) {
      BillingBusinessDomainBlueprintLaunchLane.packageNow => 'Package now',
      BillingBusinessDomainBlueprintLaunchLane.harden => 'Harden first',
      BillingBusinessDomainBlueprintLaunchLane.unblock => 'Resolve blockers',
    };
  }
}

class BillingBusinessDomainBlueprintLaunchPortfolio {
  final List<BillingBusinessDomainBlueprintLaunchPlan> plans;

  BillingBusinessDomainBlueprintLaunchPortfolio({
    Iterable<BillingBusinessDomainBlueprintLaunchPlan> plans = const [],
  }) : plans = List.unmodifiable(plans);

  factory BillingBusinessDomainBlueprintLaunchPortfolio.fromMatrix(
    BillingBusinessDomainBlueprintFitMatrix matrix,
  ) {
    return BillingBusinessDomainBlueprintLaunchPortfolio(
      plans: matrix.rows.map(
        (row) => BillingBusinessDomainBlueprintLaunchPlan(
          fitRow: row,
          columns: matrix.columns,
          lane: _laneFor(row.blueprint),
          steps: _stepsFor(row, matrix.columns),
        ),
      ),
    );
  }

  bool get isEmpty => plans.isEmpty;

  int get domainCount => plans.length;

  int get packageCount {
    return plansForLane(
      BillingBusinessDomainBlueprintLaunchLane.packageNow,
    ).length;
  }

  int get hardenCount {
    return plansForLane(BillingBusinessDomainBlueprintLaunchLane.harden).length;
  }

  int get blockedCount {
    return plansForLane(
      BillingBusinessDomainBlueprintLaunchLane.unblock,
    ).length;
  }

  int get omniChannelCount {
    return plans
        .where(
          (plan) => plan.fitRow.supports(
            BillingBusinessDomainBlueprintFitSignal.omniChannel,
          ),
        )
        .length;
  }

  List<String> get domainKeys {
    return List.unmodifiable(plans.map((plan) => plan.domainKey));
  }

  List<BillingBusinessDomainBlueprintLaunchPlan> plansForLane(
    BillingBusinessDomainBlueprintLaunchLane lane,
  ) {
    return List.unmodifiable(plans.where((plan) => plan.lane == lane));
  }

  BillingBusinessDomainBlueprintLaunchPlan? planForDomain(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final plan in plans) {
      if (plan.domainKey == key) return plan;
    }

    return null;
  }

  BillingBusinessDomainBlueprintLaunchPlan requirePlanForDomain(String domain) {
    final plan = planForDomain(domain);
    if (plan == null) {
      throw StateError('No billing blueprint launch plan exists for $domain.');
    }

    return plan;
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product launch plans are available.';
    }
    if (blockedCount > 0) {
      return '$blockedCount of $domainCount billing product '
          '${_plural(domainCount, 'domain')} '
          '${_needVerb(blockedCount)} blockers resolved before packaging.';
    }
    if (hardenCount > 0) {
      return '$hardenCount of $domainCount billing product '
          '${_plural(domainCount, 'domain')} '
          '${_needVerb(hardenCount)} hardening before packaging.';
    }

    return '$domainCount billing product ${_plural(domainCount, 'domain')} '
        '${_beVerb(domainCount)} ready to package.';
  }
}

BillingBusinessDomainBlueprintLaunchLane _laneFor(
  BillingBusinessDomainBlueprint blueprint,
) {
  if (!blueprint.isLaunchReady) {
    return BillingBusinessDomainBlueprintLaunchLane.unblock;
  }
  if (blueprint.hasWarnings) {
    return BillingBusinessDomainBlueprintLaunchLane.harden;
  }

  return BillingBusinessDomainBlueprintLaunchLane.packageNow;
}

List<BillingBusinessDomainBlueprintLaunchStep> _stepsFor(
  BillingBusinessDomainBlueprintFitRow row,
  List<BillingBusinessDomainBlueprintFitColumn> columns,
) {
  final blueprint = row.blueprint;
  final steps = <BillingBusinessDomainBlueprintLaunchStep>[];

  var blockerIndex = 0;
  for (final issue in blueprint.readinessReport.blockerIssues) {
    steps.add(
      BillingBusinessDomainBlueprintLaunchStep(
        id: 'unblock_${issue.kind.name}_${blockerIndex++}',
        label: 'Resolve blocker',
        detail: issue.message,
      ),
    );
  }

  var warningIndex = 0;
  for (final issue in blueprint.readinessReport.warningIssues) {
    steps.add(
      BillingBusinessDomainBlueprintLaunchStep(
        id: 'harden_${issue.kind.name}_${warningIndex++}',
        label: 'Harden warning',
        detail: issue.message,
      ),
    );
  }

  steps.add(_packageStep(row, columns));
  return List.unmodifiable(steps);
}

BillingBusinessDomainBlueprintLaunchStep _packageStep(
  BillingBusinessDomainBlueprintFitRow row,
  List<BillingBusinessDomainBlueprintFitColumn> columns,
) {
  final supportedSignals = _supportedSignalLabels(row, columns);
  final signalSummary = _joinLabels(
    supportedSignals,
    emptyLabel: 'explicit product behavior signals',
  );

  return BillingBusinessDomainBlueprintLaunchStep(
    id: 'package_supported_signals',
    label: 'Package ${_decapitalize(row.productModeLabel)}',
    detail:
        'Use $signalSummary as the reusable behavior set for '
        '${row.domainLabel}.',
  );
}

List<String> _supportedSignalLabels(
  BillingBusinessDomainBlueprintFitRow row,
  List<BillingBusinessDomainBlueprintFitColumn> columns,
) {
  return List.unmodifiable(
    columns
        .where((column) => row.supports(column.signal))
        .map((column) => column.label),
  );
}

String _joinLabels(List<String> labels, {required String emptyLabel}) {
  if (labels.isEmpty) return emptyLabel;
  if (labels.length == 1) return labels.first;
  if (labels.length == 2) return '${labels.first} and ${labels.last}';

  return '${labels.take(labels.length - 1).join(', ')}, and ${labels.last}';
}

String _decapitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toLowerCase()}${value.substring(1)}';
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}

String _beVerb(int count) {
  return count == 1 ? 'is' : 'are';
}

String _needVerb(int count) {
  return count == 1 ? 'needs' : 'need';
}
