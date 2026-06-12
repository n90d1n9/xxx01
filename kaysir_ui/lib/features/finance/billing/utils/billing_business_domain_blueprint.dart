import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../widgets/billing_domain_navigation_policy.dart';
import '../widgets/billing_navigation_coverage.dart';
import '../widgets/billing_navigation_destination.dart';
import 'billing_business_domain_module_readiness.dart';

enum BillingBusinessDomainBlueprintContractState { ready, warning, blocker }

class BillingBusinessDomainBlueprintContract {
  final String id;
  final String label;
  final String value;
  final BillingBusinessDomainBlueprintContractState state;

  const BillingBusinessDomainBlueprintContract({
    required this.id,
    required this.label,
    required this.value,
    required this.state,
  });

  bool get isReady =>
      state == BillingBusinessDomainBlueprintContractState.ready;

  bool get isWarning =>
      state == BillingBusinessDomainBlueprintContractState.warning;

  bool get isBlocker =>
      state == BillingBusinessDomainBlueprintContractState.blocker;
}

class BillingBusinessDomainBlueprint {
  final BillingBusinessDomainModule module;
  final BillingDomainModuleReadinessReport readinessReport;

  const BillingBusinessDomainBlueprint({
    required this.module,
    required this.readinessReport,
  });

  factory BillingBusinessDomainBlueprint.forModule(
    BillingBusinessDomainModule module, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingBusinessDomainBlueprint(
      module: module,
      readinessReport: BillingDomainModuleReadinessReport.forModule(
        module,
        hasTenant: hasTenant,
        surfaces: surfaces,
      ),
    );
  }

  BillingBusinessDomainProfile get profile => module.profile;

  BillingNavigationCoverageReport get navigationCoverage {
    return readinessReport.navigationCoverage;
  }

  BillingDomainNavigationSet get navigationSet {
    return navigationCoverage.navigationSet;
  }

  String get domainKey => module.key;

  String get domainLabel => profile.label;

  String get defaultSourceType => profile.defaultSourceType;

  bool get isLaunchReady => readinessReport.isReady;

  bool get hasWarnings => readinessReport.hasWarnings;

  bool get isOmniChannel {
    return supports(BillingBusinessDomainCapability.omniChannel);
  }

  int get lineItemAdapterCount => module.lineItemAdapters.length;

  int get screenCount => module.screenRegistry?.screens.length ?? 0;

  int get destinationCount => destinationIds.length;

  int get quickActionCount => quickActionIds.length;

  List<BillingBusinessDomainCapability> get capabilities {
    final sorted = profile.capabilities.toList(growable: false)
      ..sort((left, right) => left.index.compareTo(right.index));
    return List.unmodifiable(sorted);
  }

  List<BillingNavigationDestinationId> get destinationIds {
    return navigationCoverage.destinationIds;
  }

  List<BillingNavigationDestinationId> get quickActionIds {
    return navigationSet.quickActionIds;
  }

  BillingNavigationDestinationId get defaultDestinationId {
    return navigationSet.defaultDestinationId;
  }

  bool supports(BillingBusinessDomainCapability capability) {
    return module.supports(capability);
  }

  String get productModeLabel {
    if (supports(BillingBusinessDomainCapability.cartCheckout) ||
        supports(BillingBusinessDomainCapability.productCatalog)) {
      return 'Checkout-led commerce';
    }
    if (supports(BillingBusinessDomainCapability.progressBilling) ||
        supports(BillingBusinessDomainCapability.projectMilestones)) {
      return 'Project billing';
    }
    if (supports(BillingBusinessDomainCapability.recurringSubscriptions) ||
        supports(BillingBusinessDomainCapability.meteredUsage)) {
      return 'Subscription billing';
    }
    if (supports(BillingBusinessDomainCapability.retainers) ||
        supports(BillingBusinessDomainCapability.servicePeriods)) {
      return 'Service billing';
    }

    return 'Reusable billing';
  }

  String get channelLabel {
    return isOmniChannel ? 'Omni-channel ready' : 'Single-channel ready';
  }

  String get releaseStatusLabel {
    if (isLaunchReady && !hasWarnings) return 'Launch-ready';
    if (isLaunchReady) return 'Launch-ready with warnings';

    return 'Needs configuration';
  }

  List<BillingBusinessDomainBlueprintContract> get contracts {
    return List.unmodifiable([
      BillingBusinessDomainBlueprintContract(
        id: 'profile',
        label: 'Profile',
        value: profile.isValid ? 'Valid profile' : 'Invalid profile',
        state: _contractState({
          BillingDomainModuleReadinessIssueKind.profileValidation,
        }),
      ),
      BillingBusinessDomainBlueprintContract(
        id: 'line_items',
        label: 'Line item source',
        value: _lineItemAdapterValue(lineItemAdapterCount),
        state: _contractState({
          BillingDomainModuleReadinessIssueKind.missingLineItemAdapter,
        }),
      ),
      BillingBusinessDomainBlueprintContract(
        id: 'issue_policy',
        label: 'Issue policy',
        value: module.hasIssuePolicy ? 'Configured' : 'Default policy',
        state: _contractState({
          BillingDomainModuleReadinessIssueKind.missingIssuePolicy,
          BillingDomainModuleReadinessIssueKind.missingPaymentSchedulePolicy,
        }),
      ),
      BillingBusinessDomainBlueprintContract(
        id: 'navigation',
        label: 'Navigation',
        value: _destinationValue(destinationCount),
        state: _contractState({
          BillingDomainModuleReadinessIssueKind.missingNavigationPolicy,
          BillingDomainModuleReadinessIssueKind.navigationCoverage,
        }),
      ),
      BillingBusinessDomainBlueprintContract(
        id: 'screens',
        label: 'Screens',
        value: _screenValue(screenCount),
        state: _contractState({
          BillingDomainModuleReadinessIssueKind.missingScreenRegistry,
          BillingDomainModuleReadinessIssueKind.emptyScreenRegistry,
          BillingDomainModuleReadinessIssueKind.missingRegisteredScreens,
        }),
      ),
    ]);
  }

  int get readyContractCount {
    return contracts.where((contract) => contract.isReady).length;
  }

  int get warningContractCount {
    return contracts.where((contract) => contract.isWarning).length;
  }

  int get blockerContractCount {
    return contracts.where((contract) => contract.isBlocker).length;
  }

  BillingBusinessDomainBlueprintContract? contractFor(String id) {
    for (final contract in contracts) {
      if (contract.id == id) return contract;
    }

    return null;
  }

  BillingBusinessDomainBlueprintContract requireContract(String id) {
    final contract = contractFor(id);
    if (contract == null) {
      throw StateError('No billing domain blueprint contract exists for $id.');
    }

    return contract;
  }

  BillingBusinessDomainBlueprintContractState _contractState(
    Set<BillingDomainModuleReadinessIssueKind> issueKinds,
  ) {
    final issues = readinessReport.issues.where(
      (issue) => issueKinds.contains(issue.kind),
    );
    if (issues.any((issue) => issue.isBlocker)) {
      return BillingBusinessDomainBlueprintContractState.blocker;
    }
    if (issues.any((issue) => issue.isWarning)) {
      return BillingBusinessDomainBlueprintContractState.warning;
    }

    return BillingBusinessDomainBlueprintContractState.ready;
  }
}

class BillingBusinessDomainBlueprintRegistry {
  final List<BillingBusinessDomainBlueprint> blueprints;

  BillingBusinessDomainBlueprintRegistry({
    Iterable<BillingBusinessDomainBlueprint> blueprints = const [],
  }) : blueprints = List.unmodifiable(blueprints);

  factory BillingBusinessDomainBlueprintRegistry.forRegistry(
    BillingBusinessDomainModuleRegistry registry, {
    bool hasTenant = true,
    Iterable<BillingNavigationSurface> surfaces =
        billingNavigationCoverageSurfaces,
  }) {
    return BillingBusinessDomainBlueprintRegistry(
      blueprints: registry.modules.map(
        (module) => BillingBusinessDomainBlueprint.forModule(
          module,
          hasTenant: hasTenant,
          surfaces: surfaces,
        ),
      ),
    );
  }

  bool get isEmpty => blueprints.isEmpty;

  bool get isLaunchReady => blockedBlueprints.isEmpty;

  bool get hasWarnings => warningBlueprints.isNotEmpty;

  int get readyContractCount {
    return blueprints.fold(
      0,
      (total, blueprint) => total + blueprint.readyContractCount,
    );
  }

  int get warningContractCount {
    return blueprints.fold(
      0,
      (total, blueprint) => total + blueprint.warningContractCount,
    );
  }

  int get blockerContractCount {
    return blueprints.fold(
      0,
      (total, blueprint) => total + blueprint.blockerContractCount,
    );
  }

  List<String> get domainKeys {
    return List.unmodifiable(
      blueprints.map((blueprint) => blueprint.domainKey),
    );
  }

  List<BillingBusinessDomainBlueprint> get launchReadyBlueprints {
    return List.unmodifiable(
      blueprints.where((blueprint) => blueprint.isLaunchReady),
    );
  }

  List<BillingBusinessDomainBlueprint> get blockedBlueprints {
    return List.unmodifiable(
      blueprints.where((blueprint) => !blueprint.isLaunchReady),
    );
  }

  List<BillingBusinessDomainBlueprint> get warningBlueprints {
    return List.unmodifiable(
      blueprints.where((blueprint) => blueprint.hasWarnings),
    );
  }

  BillingBusinessDomainBlueprint? find(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final blueprint in blueprints) {
      if (blueprint.domainKey == key) return blueprint;
    }

    return null;
  }

  BillingBusinessDomainBlueprint requireBlueprintForDomain(String domain) {
    final blueprint = find(domain);
    if (blueprint == null) {
      throw StateError('No billing domain blueprint is available for $domain.');
    }

    return blueprint;
  }

  String get summaryLabel {
    if (isEmpty) return 'No billing domain blueprints are registered.';
    if (isLaunchReady && !hasWarnings) {
      return '${blueprints.length} billing '
          '${_plural(blueprints.length, 'blueprint')} '
          '${_beVerb(blueprints.length)} launch-ready.';
    }
    if (isLaunchReady) {
      return '${blueprints.length} billing '
          '${_plural(blueprints.length, 'blueprint')} '
          '${_beVerb(blueprints.length)} launch-ready with '
          '$warningContractCount contract '
          '${_plural(warningContractCount, 'warning')}.';
    }

    return '${blockedBlueprints.length} of ${blueprints.length} billing '
        '${_plural(blueprints.length, 'blueprint')} '
        '${_needVerb(blockedBlueprints.length)} configuration.';
  }
}

String _lineItemAdapterValue(int count) {
  return count == 1 ? '1 adapter' : '$count adapters';
}

String _destinationValue(int count) {
  return count == 1 ? '1 destination' : '$count destinations';
}

String _screenValue(int count) {
  return count == 1 ? '1 screen' : '$count screens';
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
