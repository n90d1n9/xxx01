import 'billing_product_package_release_manifest.dart';

enum BillingProductPackageReleaseBundleState { publishNow, review, blocked }

class BillingProductPackageReleaseBundle {
  final String id;
  final String label;
  final String description;
  final BillingProductPackageReleaseBundleState state;
  final List<BillingProductPackageReleaseManifest> manifests;

  BillingProductPackageReleaseBundle({
    required this.id,
    required this.label,
    required this.description,
    required this.state,
    Iterable<BillingProductPackageReleaseManifest> manifests = const [],
  }) : manifests = List.unmodifiable(_sortManifests(manifests)) {
    if (id.trim().isEmpty) {
      throw StateError(
        'Billing product package release bundle id is required.',
      );
    }
    if (label.trim().isEmpty) {
      throw StateError(
        'Billing product package release bundle $id needs a label.',
      );
    }
    if (this.manifests.isEmpty) {
      throw StateError(
        'Billing product package release bundle $id needs manifests.',
      );
    }
  }

  int get manifestCount => manifests.length;

  int get stageableCount {
    return manifests.where((manifest) => manifest.canStageRelease).length;
  }

  int get blockingManifestCount {
    return manifests.where((manifest) => !manifest.canStageRelease).length;
  }

  bool get canPublish {
    return state == BillingProductPackageReleaseBundleState.publishNow &&
        blockingManifestCount == 0;
  }

  bool get needsReview {
    return state == BillingProductPackageReleaseBundleState.review;
  }

  bool get isBlocked {
    return state == BillingProductPackageReleaseBundleState.blocked;
  }

  List<String> get releaseKeys {
    return List.unmodifiable(manifests.map((manifest) => manifest.releaseKey));
  }

  String get stateLabel {
    return switch (state) {
      BillingProductPackageReleaseBundleState.publishNow => 'Publish now',
      BillingProductPackageReleaseBundleState.review => 'Review',
      BillingProductPackageReleaseBundleState.blocked => 'Blocked',
    };
  }

  String get actionLabel {
    return switch (state) {
      BillingProductPackageReleaseBundleState.publishNow => 'Publish bundle',
      BillingProductPackageReleaseBundleState.review => 'Review hardening',
      BillingProductPackageReleaseBundleState.blocked => 'Clear blockers',
    };
  }

  String get actionDetail {
    return switch (state) {
      BillingProductPackageReleaseBundleState.publishNow =>
        '$manifestCount ${_plural(manifestCount, 'manifest')} can be '
            'released together.',
      BillingProductPackageReleaseBundleState.review =>
        '$manifestCount ${_plural(manifestCount, 'manifest')} can be staged '
            'after hardening review.',
      BillingProductPackageReleaseBundleState.blocked =>
        '$manifestCount ${_plural(manifestCount, 'manifest')} need blockers '
            'or fit gaps cleared.',
    };
  }

  Map<String, Object?> get payload {
    return {
      'id': id,
      'label': label,
      'state': state.name,
      'stateLabel': stateLabel,
      'releaseKeys': releaseKeys,
      'manifestCount': manifestCount,
      'stageableCount': stageableCount,
      'blockingManifestCount': blockingManifestCount,
      'manifests': manifests
          .map((manifest) => manifest.payload)
          .toList(growable: false),
    };
  }
}

class BillingProductPackageReleaseBundleCatalog {
  final List<BillingProductPackageReleaseBundle> bundles;

  BillingProductPackageReleaseBundleCatalog({
    Iterable<BillingProductPackageReleaseBundle> bundles = const [],
  }) : bundles = List.unmodifiable(_sortBundles(bundles));

  factory BillingProductPackageReleaseBundleCatalog.forManifestCatalog(
    BillingProductPackageReleaseManifestCatalog manifestCatalog,
  ) {
    final ready = manifestCatalog.manifestsForState(
      BillingProductPackageReleaseState.releaseReady,
    );
    final review = manifestCatalog.manifestsForState(
      BillingProductPackageReleaseState.needsHardening,
    );
    final blocked = [
      ...manifestCatalog.manifestsForState(
        BillingProductPackageReleaseState.blocked,
      ),
      ...manifestCatalog.manifestsForState(
        BillingProductPackageReleaseState.needsFit,
      ),
    ];

    return BillingProductPackageReleaseBundleCatalog(
      bundles: [
        if (ready.isNotEmpty)
          BillingProductPackageReleaseBundle(
            id: 'publish_now',
            label: 'Publish now',
            description: 'Release-ready product packages grouped for launch.',
            state: BillingProductPackageReleaseBundleState.publishNow,
            manifests: ready,
          ),
        if (review.isNotEmpty)
          BillingProductPackageReleaseBundle(
            id: 'review_before_release',
            label: 'Review before release',
            description:
                'Stageable product packages that still need hardening.',
            state: BillingProductPackageReleaseBundleState.review,
            manifests: review,
          ),
        if (blocked.isNotEmpty)
          BillingProductPackageReleaseBundle(
            id: 'blocked_release',
            label: 'Blocked release',
            description: 'Product packages waiting on blockers or fit signals.',
            state: BillingProductPackageReleaseBundleState.blocked,
            manifests: blocked,
          ),
      ],
    );
  }

  bool get isEmpty => bundles.isEmpty;

  int get bundleCount => bundles.length;

  int get manifestCount {
    return bundles.fold(0, (total, bundle) => total + bundle.manifestCount);
  }

  int get publishNowManifestCount {
    return manifestsForState(
      BillingProductPackageReleaseBundleState.publishNow,
    ).length;
  }

  int get reviewManifestCount {
    return manifestsForState(
      BillingProductPackageReleaseBundleState.review,
    ).length;
  }

  int get blockedManifestCount {
    return manifestsForState(
      BillingProductPackageReleaseBundleState.blocked,
    ).length;
  }

  int get stageableManifestCount {
    return bundles.fold(0, (total, bundle) => total + bundle.stageableCount);
  }

  List<String> get bundleIds {
    return List.unmodifiable(bundles.map((bundle) => bundle.id));
  }

  List<BillingProductPackageReleaseManifest> get manifests {
    return List.unmodifiable(bundles.expand((bundle) => bundle.manifests));
  }

  List<BillingProductPackageReleaseManifest> manifestsForState(
    BillingProductPackageReleaseBundleState state,
  ) {
    return List.unmodifiable(
      bundles
          .where((bundle) => bundle.state == state)
          .expand((bundle) => bundle.manifests),
    );
  }

  BillingProductPackageReleaseBundle? bundleForState(
    BillingProductPackageReleaseBundleState state,
  ) {
    for (final bundle in bundles) {
      if (bundle.state == state) return bundle;
    }

    return null;
  }

  BillingProductPackageReleaseBundle requireBundleForState(
    BillingProductPackageReleaseBundleState state,
  ) {
    final bundle = bundleForState(state);
    if (bundle == null) {
      throw StateError('No billing product package release bundle for $state.');
    }

    return bundle;
  }

  Map<String, Object?> get payload {
    return {
      'bundleCount': bundleCount,
      'manifestCount': manifestCount,
      'stageableManifestCount': stageableManifestCount,
      'blockedManifestCount': blockedManifestCount,
      'bundles': bundles
          .map((bundle) => bundle.payload)
          .toList(growable: false),
    };
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product package release bundles are available.';
    }

    if (blockedManifestCount > 0) {
      return '$blockedManifestCount ${_plural(blockedManifestCount, 'manifest')} '
          'need blockers cleared before release.';
    }
    if (reviewManifestCount > 0 && publishNowManifestCount > 0) {
      return '$publishNowManifestCount '
          '${_plural(publishNowManifestCount, 'manifest')} can publish; '
          '$reviewManifestCount need review.';
    }
    if (reviewManifestCount > 0) {
      return '$reviewManifestCount '
          '${_plural(reviewManifestCount, 'manifest')} need review before '
          'release.';
    }

    return '$publishNowManifestCount '
        '${_plural(publishNowManifestCount, 'manifest')} can publish now.';
  }
}

List<BillingProductPackageReleaseManifest> _sortManifests(
  Iterable<BillingProductPackageReleaseManifest> manifests,
) {
  final sorted = manifests.toList(growable: false);
  sorted.sort((left, right) => left.releaseKey.compareTo(right.releaseKey));
  return sorted;
}

List<BillingProductPackageReleaseBundle> _sortBundles(
  Iterable<BillingProductPackageReleaseBundle> bundles,
) {
  final sorted = bundles.toList(growable: false);
  sorted.sort((left, right) {
    final stateOrder = _statePriority(
      left.state,
    ).compareTo(_statePriority(right.state));
    if (stateOrder != 0) return stateOrder;

    return left.id.compareTo(right.id);
  });
  return sorted;
}

int _statePriority(BillingProductPackageReleaseBundleState state) {
  return switch (state) {
    BillingProductPackageReleaseBundleState.publishNow => 0,
    BillingProductPackageReleaseBundleState.review => 1,
    BillingProductPackageReleaseBundleState.blocked => 2,
  };
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
