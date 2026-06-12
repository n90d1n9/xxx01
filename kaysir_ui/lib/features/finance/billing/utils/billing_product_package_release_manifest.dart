import 'billing_product_package.dart';
import 'billing_product_package_launch_playbook.dart';
import 'billing_product_package_plan.dart';

enum BillingProductPackageReleaseState {
  releaseReady,
  needsHardening,
  blocked,
  needsFit,
}

class BillingProductPackageReleaseManifest {
  final String packageKey;
  final String packageLabel;
  final String description;
  final String audienceLabel;
  final String channelLabel;
  final String domainKey;
  final String domainLabel;
  final BillingProductPackageReleaseState state;
  final List<String> requiredSignalLabels;
  final List<String> recommendedSignalLabels;
  final List<BillingProductPackageLaunchAction> actions;
  final String primaryActionLabel;
  final String primaryActionDetail;

  BillingProductPackageReleaseManifest({
    required this.packageKey,
    required this.packageLabel,
    required this.description,
    required this.audienceLabel,
    required this.channelLabel,
    required this.domainKey,
    required this.domainLabel,
    required this.state,
    required Iterable<String> requiredSignalLabels,
    Iterable<String> recommendedSignalLabels = const [],
    Iterable<BillingProductPackageLaunchAction> actions = const [],
    required this.primaryActionLabel,
    required this.primaryActionDetail,
  }) : requiredSignalLabels = List.unmodifiable(requiredSignalLabels),
       recommendedSignalLabels = List.unmodifiable(recommendedSignalLabels),
       actions = List.unmodifiable(actions);

  factory BillingProductPackageReleaseManifest.fromPlan({
    required BillingProductPackagePlan plan,
    required BillingProductPackageLaunchPlaybook playbook,
  }) {
    final selectedDomainPlan = plan.selectedDomainPlan;
    final primaryAction = playbook.primaryActionForPackage(plan.packageKey);

    return BillingProductPackageReleaseManifest(
      packageKey: plan.packageKey,
      packageLabel: plan.package.label,
      description: plan.package.description,
      audienceLabel: plan.package.audienceLabel,
      channelLabel: plan.package.channelLabel,
      domainKey: selectedDomainPlan?.domainKey ?? '',
      domainLabel: selectedDomainPlan?.domainLabel ?? plan.domainSummary,
      state: _stateForLane(plan.lane),
      requiredSignalLabels: plan.requiredSignalLabels,
      recommendedSignalLabels: plan.recommendedSignalLabels,
      actions: playbook.actionsForPackage(plan.packageKey),
      primaryActionLabel: primaryAction?.label ?? plan.primaryActionLabel,
      primaryActionDetail: primaryAction?.detail ?? plan.primaryActionDetail,
    );
  }

  String get releaseKey {
    final domainPart = domainKey.isEmpty ? 'unassigned' : domainKey;
    return '$packageKey:$domainPart';
  }

  bool get isReleaseReady {
    return state == BillingProductPackageReleaseState.releaseReady;
  }

  bool get canStageRelease {
    return state == BillingProductPackageReleaseState.releaseReady ||
        state == BillingProductPackageReleaseState.needsHardening;
  }

  int get actionCount => actions.length;

  int get blockingActionCount {
    return actions.where((action) => action.isBlocking).length;
  }

  String get stateLabel {
    return switch (state) {
      BillingProductPackageReleaseState.releaseReady => 'Release-ready',
      BillingProductPackageReleaseState.needsHardening => 'Harden first',
      BillingProductPackageReleaseState.blocked => 'Blocked',
      BillingProductPackageReleaseState.needsFit => 'Needs fit',
    };
  }

  String get stageLabel {
    return switch (state) {
      BillingProductPackageReleaseState.releaseReady => 'Ready to publish',
      BillingProductPackageReleaseState.needsHardening => 'Stage with review',
      BillingProductPackageReleaseState.blocked => 'Resolve blockers',
      BillingProductPackageReleaseState.needsFit => 'Map domain signals',
    };
  }

  Map<String, Object?> get payload {
    return {
      'releaseKey': releaseKey,
      'packageKey': packageKey,
      'packageLabel': packageLabel,
      'domainKey': domainKey,
      'domainLabel': domainLabel,
      'state': state.name,
      'stageLabel': stageLabel,
      'requiredSignals': requiredSignalLabels,
      'recommendedSignals': recommendedSignalLabels,
      'actions': actions
          .map(
            (action) => {
              'id': action.id,
              'kind': action.kind.name,
              'label': action.label,
              'detail': action.detail,
              'isPrimary': action.isPrimary,
            },
          )
          .toList(growable: false),
    };
  }
}

class BillingProductPackageReleaseManifestCatalog {
  final List<BillingProductPackageReleaseManifest> manifests;

  BillingProductPackageReleaseManifestCatalog({
    Iterable<BillingProductPackageReleaseManifest> manifests = const [],
  }) : manifests = List.unmodifiable(_sortManifests(manifests));

  factory BillingProductPackageReleaseManifestCatalog.forPortfolio({
    required BillingProductPackagePortfolio portfolio,
    required BillingProductPackageLaunchPlaybook playbook,
  }) {
    return BillingProductPackageReleaseManifestCatalog(
      manifests: portfolio.plans.map(
        (plan) => BillingProductPackageReleaseManifest.fromPlan(
          plan: plan,
          playbook: playbook,
        ),
      ),
    );
  }

  bool get isEmpty => manifests.isEmpty;

  int get manifestCount => manifests.length;

  int get releaseReadyCount {
    return manifestsForState(
      BillingProductPackageReleaseState.releaseReady,
    ).length;
  }

  int get hardeningCount {
    return manifestsForState(
      BillingProductPackageReleaseState.needsHardening,
    ).length;
  }

  int get blockedCount {
    return manifestsForState(BillingProductPackageReleaseState.blocked).length;
  }

  int get fitGapCount {
    return manifestsForState(BillingProductPackageReleaseState.needsFit).length;
  }

  int get stageableCount {
    return manifests.where((manifest) => manifest.canStageRelease).length;
  }

  List<String> get releaseKeys {
    return List.unmodifiable(manifests.map((manifest) => manifest.releaseKey));
  }

  List<BillingProductPackageReleaseManifest> manifestsForState(
    BillingProductPackageReleaseState state,
  ) {
    return List.unmodifiable(
      manifests.where((manifest) => manifest.state == state),
    );
  }

  BillingProductPackageReleaseManifest? manifestForPackage(String id) {
    final key = billingProductPackageKey(id);

    for (final manifest in manifests) {
      if (manifest.packageKey == key) return manifest;
    }

    return null;
  }

  BillingProductPackageReleaseManifest requireManifestForPackage(String id) {
    final manifest = manifestForPackage(id);
    if (manifest == null) {
      throw StateError(
        'No billing product package release manifest exists for $id.',
      );
    }

    return manifest;
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product package release manifests are available.';
    }

    final blockedTotal = blockedCount + fitGapCount;
    if (blockedTotal > 0) {
      return '$blockedTotal ${_plural(blockedTotal, 'manifest')} need '
          'blockers or fit gaps cleared.';
    }
    if (hardeningCount > 0 && releaseReadyCount > 0) {
      return '$releaseReadyCount ${_plural(releaseReadyCount, 'manifest')} '
          'ready; $hardeningCount need hardening.';
    }
    if (hardeningCount > 0) {
      return '$hardeningCount ${_plural(hardeningCount, 'manifest')} need '
          'hardening before release.';
    }

    return '$releaseReadyCount ${_plural(releaseReadyCount, 'manifest')} '
        'ready to release.';
  }
}

BillingProductPackageReleaseState _stateForLane(
  BillingProductPackageLane lane,
) {
  return switch (lane) {
    BillingProductPackageLane.packageNow =>
      BillingProductPackageReleaseState.releaseReady,
    BillingProductPackageLane.harden =>
      BillingProductPackageReleaseState.needsHardening,
    BillingProductPackageLane.unblock =>
      BillingProductPackageReleaseState.blocked,
    BillingProductPackageLane.unavailable =>
      BillingProductPackageReleaseState.needsFit,
  };
}

List<BillingProductPackageReleaseManifest> _sortManifests(
  Iterable<BillingProductPackageReleaseManifest> manifests,
) {
  final sorted = manifests.toList(growable: false);
  sorted.sort((left, right) {
    final stateOrder = _statePriority(
      left.state,
    ).compareTo(_statePriority(right.state));
    if (stateOrder != 0) return stateOrder;

    return left.releaseKey.compareTo(right.releaseKey);
  });
  return sorted;
}

int _statePriority(BillingProductPackageReleaseState state) {
  return switch (state) {
    BillingProductPackageReleaseState.releaseReady => 0,
    BillingProductPackageReleaseState.needsHardening => 1,
    BillingProductPackageReleaseState.blocked => 2,
    BillingProductPackageReleaseState.needsFit => 3,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
