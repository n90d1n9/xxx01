import 'billing_product_package.dart';
import 'billing_product_package_release_manifest.dart';
import 'billing_product_release_edition_blueprint.dart';

enum BillingProductReleaseEditionState {
  publishNow,
  review,
  blocked,
  incomplete,
}

class BillingProductReleaseEditionPlan {
  final BillingProductReleaseEditionBlueprint edition;
  final BillingProductReleaseEditionState state;
  final List<BillingProductPackageReleaseManifest> requiredManifests;
  final List<BillingProductPackageReleaseManifest> optionalManifests;
  final List<String> missingRequiredPackageKeys;

  BillingProductReleaseEditionPlan({
    required this.edition,
    required this.state,
    Iterable<BillingProductPackageReleaseManifest> requiredManifests = const [],
    Iterable<BillingProductPackageReleaseManifest> optionalManifests = const [],
    Iterable<String> missingRequiredPackageKeys = const [],
  }) : requiredManifests = List.unmodifiable(requiredManifests),
       optionalManifests = List.unmodifiable(optionalManifests),
       missingRequiredPackageKeys = List.unmodifiable(
         missingRequiredPackageKeys.map(billingProductPackageKey),
       );

  factory BillingProductReleaseEditionPlan.fromManifestCatalog({
    required BillingProductReleaseEditionBlueprint edition,
    required BillingProductPackageReleaseManifestCatalog manifestCatalog,
  }) {
    final requiredManifests = <BillingProductPackageReleaseManifest>[];
    final missingPackageKeys = <String>[];

    for (final packageKey in edition.requiredPackageKeys) {
      final manifest = manifestCatalog.manifestForPackage(packageKey);
      if (manifest == null) {
        missingPackageKeys.add(packageKey);
      } else {
        requiredManifests.add(manifest);
      }
    }

    final optionalManifests =
        edition.optionalPackageKeys
            .map(manifestCatalog.manifestForPackage)
            .whereType<BillingProductPackageReleaseManifest>();

    return BillingProductReleaseEditionPlan(
      edition: edition,
      state: _stateForRequiredManifests(
        requiredManifests: requiredManifests,
        missingRequiredPackageKeys: missingPackageKeys,
      ),
      requiredManifests: requiredManifests,
      optionalManifests: optionalManifests,
      missingRequiredPackageKeys: missingPackageKeys,
    );
  }

  String get id => edition.key;

  String get label => edition.label;

  String get description => edition.description;

  String get audienceLabel => edition.audienceLabel;

  int get requiredManifestCount => requiredManifests.length;

  int get optionalManifestCount => optionalManifests.length;

  int get missingRequiredPackageCount => missingRequiredPackageKeys.length;

  int get blockedRequiredManifestCount {
    return requiredManifests
        .where((manifest) => !manifest.canStageRelease)
        .length;
  }

  int get hardeningRequiredManifestCount {
    return requiredManifests
        .where(
          (manifest) =>
              manifest.state ==
              BillingProductPackageReleaseState.needsHardening,
        )
        .length;
  }

  int get releaseReadyRequiredManifestCount {
    return requiredManifests
        .where((manifest) => manifest.isReleaseReady)
        .length;
  }

  bool get canPublish {
    return state == BillingProductReleaseEditionState.publishNow;
  }

  bool get needsReview {
    return state == BillingProductReleaseEditionState.review;
  }

  bool get isBlocked {
    return state == BillingProductReleaseEditionState.blocked;
  }

  bool get isIncomplete {
    return state == BillingProductReleaseEditionState.incomplete;
  }

  List<String> get requiredReleaseKeys {
    return List.unmodifiable(
      requiredManifests.map((manifest) => manifest.releaseKey),
    );
  }

  List<String> get optionalReleaseKeys {
    return List.unmodifiable(
      optionalManifests.map((manifest) => manifest.releaseKey),
    );
  }

  List<String> get releaseKeys {
    return List.unmodifiable([...requiredReleaseKeys, ...optionalReleaseKeys]);
  }

  String get stateLabel {
    return switch (state) {
      BillingProductReleaseEditionState.publishNow => 'Publish now',
      BillingProductReleaseEditionState.review => 'Review',
      BillingProductReleaseEditionState.blocked => 'Blocked',
      BillingProductReleaseEditionState.incomplete => 'Incomplete',
    };
  }

  String get actionLabel {
    return switch (state) {
      BillingProductReleaseEditionState.publishNow => 'Publish edition',
      BillingProductReleaseEditionState.review => 'Review hardening',
      BillingProductReleaseEditionState.blocked => 'Clear blockers',
      BillingProductReleaseEditionState.incomplete => 'Add required packages',
    };
  }

  String get actionDetail {
    return switch (state) {
      BillingProductReleaseEditionState.publishNow =>
        '$requiredManifestCount required '
            '${_plural(requiredManifestCount, 'package')} can ship.',
      BillingProductReleaseEditionState.review =>
        '$hardeningRequiredManifestCount required '
            '${_plural(hardeningRequiredManifestCount, 'package')} need '
            'hardening review.',
      BillingProductReleaseEditionState.blocked =>
        '$blockedRequiredManifestCount required '
            '${_plural(blockedRequiredManifestCount, 'package')} have '
            'blockers or fit gaps.',
      BillingProductReleaseEditionState.incomplete =>
        '$missingRequiredPackageCount required '
            '${_plural(missingRequiredPackageCount, 'package')} must be '
            'added to the manifest catalog.',
    };
  }

  Map<String, Object?> get payload {
    return {
      'id': id,
      'label': label,
      'state': state.name,
      'stateLabel': stateLabel,
      'audienceLabel': audienceLabel,
      'requiredPackageKeys': edition.requiredPackageKeys,
      'optionalPackageKeys': edition.optionalPackageKeys,
      'requiredReleaseKeys': requiredReleaseKeys,
      'optionalReleaseKeys': optionalReleaseKeys,
      'missingRequiredPackageKeys': missingRequiredPackageKeys,
      'requiredManifestCount': requiredManifestCount,
      'optionalManifestCount': optionalManifestCount,
    };
  }
}

class BillingProductReleaseEditionCatalog {
  final List<BillingProductReleaseEditionPlan> plans;

  BillingProductReleaseEditionCatalog({
    Iterable<BillingProductReleaseEditionPlan> plans = const [],
  }) : plans = List.unmodifiable(_sortPlans(plans));

  factory BillingProductReleaseEditionCatalog.forManifestCatalog({
    required BillingProductReleaseEditionRegistry registry,
    required BillingProductPackageReleaseManifestCatalog manifestCatalog,
  }) {
    return BillingProductReleaseEditionCatalog(
      plans: registry.editions.map(
        (edition) => BillingProductReleaseEditionPlan.fromManifestCatalog(
          edition: edition,
          manifestCatalog: manifestCatalog,
        ),
      ),
    );
  }

  bool get isEmpty => plans.isEmpty;

  int get editionCount => plans.length;

  int get publishNowCount {
    return plansForState(BillingProductReleaseEditionState.publishNow).length;
  }

  int get reviewCount {
    return plansForState(BillingProductReleaseEditionState.review).length;
  }

  int get blockedCount {
    return plansForState(BillingProductReleaseEditionState.blocked).length;
  }

  int get incompleteCount {
    return plansForState(BillingProductReleaseEditionState.incomplete).length;
  }

  int get blockedOrIncompleteCount => blockedCount + incompleteCount;

  List<String> get editionIds {
    return List.unmodifiable(plans.map((plan) => plan.id));
  }

  List<BillingProductReleaseEditionPlan> plansForState(
    BillingProductReleaseEditionState state,
  ) {
    return List.unmodifiable(plans.where((plan) => plan.state == state));
  }

  BillingProductReleaseEditionPlan? planForEdition(String id) {
    final key = billingProductReleaseEditionKey(id);

    for (final plan in plans) {
      if (plan.id == key) return plan;
    }

    return null;
  }

  BillingProductReleaseEditionPlan requirePlanForEdition(String id) {
    final plan = planForEdition(id);
    if (plan == null) {
      throw StateError('No billing product release edition plan for $id.');
    }

    return plan;
  }

  Map<String, Object?> get payload {
    return {
      'editionCount': editionCount,
      'publishNowCount': publishNowCount,
      'reviewCount': reviewCount,
      'blockedCount': blockedCount,
      'incompleteCount': incompleteCount,
      'plans': plans.map((plan) => plan.payload).toList(growable: false),
    };
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product release editions are available.';
    }

    if (incompleteCount > 0) {
      return '$incompleteCount ${_plural(incompleteCount, 'edition')} need '
          'required packages added before release.';
    }
    if (blockedCount > 0) {
      return '$blockedCount ${_plural(blockedCount, 'edition')} need blockers '
          'cleared before release.';
    }
    if (publishNowCount > 0 && reviewCount > 0) {
      return '$publishNowCount ${_plural(publishNowCount, 'edition')} can '
          'publish; $reviewCount need review.';
    }
    if (reviewCount > 0) {
      return '$reviewCount ${_plural(reviewCount, 'edition')} need review '
          'before release.';
    }

    return '$publishNowCount ${_plural(publishNowCount, 'edition')} can '
        'publish now.';
  }
}

BillingProductReleaseEditionState _stateForRequiredManifests({
  required List<BillingProductPackageReleaseManifest> requiredManifests,
  required List<String> missingRequiredPackageKeys,
}) {
  if (missingRequiredPackageKeys.isNotEmpty) {
    return BillingProductReleaseEditionState.incomplete;
  }
  if (requiredManifests.any((manifest) => !manifest.canStageRelease)) {
    return BillingProductReleaseEditionState.blocked;
  }
  if (requiredManifests.any(
    (manifest) =>
        manifest.state == BillingProductPackageReleaseState.needsHardening,
  )) {
    return BillingProductReleaseEditionState.review;
  }

  return BillingProductReleaseEditionState.publishNow;
}

List<BillingProductReleaseEditionPlan> _sortPlans(
  Iterable<BillingProductReleaseEditionPlan> plans,
) {
  final sorted = plans.toList(growable: false);
  sorted.sort((left, right) {
    final stateOrder = _statePriority(
      left.state,
    ).compareTo(_statePriority(right.state));
    if (stateOrder != 0) return stateOrder;

    return left.id.compareTo(right.id);
  });
  return sorted;
}

int _statePriority(BillingProductReleaseEditionState state) {
  return switch (state) {
    BillingProductReleaseEditionState.publishNow => 0,
    BillingProductReleaseEditionState.review => 1,
    BillingProductReleaseEditionState.blocked => 2,
    BillingProductReleaseEditionState.incomplete => 3,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
