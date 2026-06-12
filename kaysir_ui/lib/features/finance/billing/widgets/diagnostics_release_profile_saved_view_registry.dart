import '../models/billing_business_domain_profile.dart';
import 'diagnostics_release_profile_saved_view.dart';
import 'release_profile_contract_coverage.dart';

/// Domain-scoped saved-view contribution for release profile diagnostics.
class BillingDiagnosticsReleaseProfileSavedViewProfile {
  final String id;
  final Set<String> businessDomains;
  final List<BillingDiagnosticsReleaseProfileSavedView> extensions;
  final List<BillingDiagnosticsReleaseProfileSavedView> replacements;
  final Set<String> hiddenViewIds;

  factory BillingDiagnosticsReleaseProfileSavedViewProfile({
    required String id,
    required Iterable<String> businessDomains,
    Iterable<BillingDiagnosticsReleaseProfileSavedView> extensions = const [],
    Iterable<BillingDiagnosticsReleaseProfileSavedView> replacements = const [],
    Iterable<String> hiddenViewIds = const [],
  }) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be blank');
    }

    final normalizedDomains =
        businessDomains
            .map(billingBusinessDomainKey)
            .where((domain) => domain.isNotEmpty)
            .toSet();
    if (normalizedDomains.isEmpty) {
      throw ArgumentError.value(
        businessDomains,
        'businessDomains',
        'must include at least one non-blank domain',
      );
    }

    return BillingDiagnosticsReleaseProfileSavedViewProfile._(
      id: normalizedId,
      businessDomains: Set.unmodifiable(normalizedDomains),
      extensions: List.unmodifiable(extensions),
      replacements: List.unmodifiable(replacements),
      hiddenViewIds: Set.unmodifiable(hiddenViewIds.map((id) => id.trim())),
    );
  }

  const BillingDiagnosticsReleaseProfileSavedViewProfile._({
    required this.id,
    required this.businessDomains,
    required this.extensions,
    required this.replacements,
    required this.hiddenViewIds,
  });

  bool matches(String businessDomain) {
    return businessDomains.contains(billingBusinessDomainKey(businessDomain));
  }

  BillingDiagnosticsReleaseProfileSavedViewRegistry buildRegistry() {
    return BillingDiagnosticsReleaseProfileSavedViewRegistry.standard(
      extensions: extensions,
      replacements: replacements,
      hiddenViewIds: hiddenViewIds,
    );
  }
}

/// Catalog of domain-scoped release profile diagnostics saved-view profiles.
class BillingDiagnosticsReleaseProfileSavedViewProfileCatalog {
  final List<BillingDiagnosticsReleaseProfileSavedViewProfile> profiles;

  factory BillingDiagnosticsReleaseProfileSavedViewProfileCatalog({
    Iterable<BillingDiagnosticsReleaseProfileSavedViewProfile> profiles =
        const [],
  }) {
    return BillingDiagnosticsReleaseProfileSavedViewProfileCatalog._(
      _validatedReleaseProfileSavedViewProfiles(profiles),
    );
  }

  const BillingDiagnosticsReleaseProfileSavedViewProfileCatalog._(
    this.profiles,
  );

  BillingDiagnosticsReleaseProfileSavedViewProfile? profileForBusinessDomain(
    String businessDomain,
  ) {
    final key = billingBusinessDomainKey(businessDomain);
    for (final profile in profiles) {
      if (profile.businessDomains.contains(key)) return profile;
    }

    return null;
  }

  BillingDiagnosticsReleaseProfileSavedViewRegistry registryForBusinessDomain(
    String businessDomain,
  ) {
    return profileForBusinessDomain(businessDomain)?.buildRegistry() ??
        standardBillingDiagnosticsReleaseProfileSavedViewRegistry;
  }
}

/// Immutable registry for diagnostics release profile saved-view presets.
class BillingDiagnosticsReleaseProfileSavedViewRegistry {
  final List<BillingDiagnosticsReleaseProfileSavedView> views;

  factory BillingDiagnosticsReleaseProfileSavedViewRegistry({
    required Iterable<BillingDiagnosticsReleaseProfileSavedView> views,
  }) {
    return BillingDiagnosticsReleaseProfileSavedViewRegistry._(
      _validatedReleaseProfileSavedViews(views),
    );
  }

  factory BillingDiagnosticsReleaseProfileSavedViewRegistry.standard({
    Iterable<BillingDiagnosticsReleaseProfileSavedView> extensions = const [],
    Iterable<BillingDiagnosticsReleaseProfileSavedView> replacements = const [],
    Set<String> hiddenViewIds = const {},
  }) {
    return BillingDiagnosticsReleaseProfileSavedViewRegistry(
      views: _standardReleaseProfileSavedViews(
        extensions: extensions,
        replacements: replacements,
        hiddenViewIds: hiddenViewIds,
      ),
    );
  }

  const BillingDiagnosticsReleaseProfileSavedViewRegistry._(this.views);

  bool get isEmpty => views.isEmpty;

  BillingDiagnosticsReleaseProfileSavedView? viewForId(String id) {
    final normalizedId = id.trim();
    for (final view in views) {
      if (view.id == normalizedId) return view;
    }

    return null;
  }

  BillingDiagnosticsReleaseProfileSavedView requireView(String id) {
    final view = viewForId(id);
    if (view == null) {
      throw StateError(
        'No diagnostics release profile saved view is registered for $id.',
      );
    }

    return view;
  }

  List<BillingDiagnosticsReleaseProfileSavedView> availableViews({
    required BillingReleaseWorkspaceProfileContractCoverage coverage,
    String? focusedBusinessDomain,
  }) {
    return billingDiagnosticsReleaseProfileSavedViewsFor(
      coverage: coverage,
      focusedBusinessDomain: focusedBusinessDomain,
      views: views,
    );
  }
}

const standardBillingDiagnosticsReleaseProfileSavedViewRegistry =
    BillingDiagnosticsReleaseProfileSavedViewRegistry._(
      billingDiagnosticsReleaseProfileDefaultSavedViews,
    );

List<BillingDiagnosticsReleaseProfileSavedView>
_standardReleaseProfileSavedViews({
  required Iterable<BillingDiagnosticsReleaseProfileSavedView> extensions,
  required Iterable<BillingDiagnosticsReleaseProfileSavedView> replacements,
  required Set<String> hiddenViewIds,
}) {
  final hiddenIds = hiddenViewIds.map((id) => id.trim()).toSet();
  final replacementById = {for (final view in replacements) view.id: view};
  final composedViews = <BillingDiagnosticsReleaseProfileSavedView>[];

  for (final view in billingDiagnosticsReleaseProfileDefaultSavedViews) {
    if (hiddenIds.contains(view.id)) {
      replacementById.remove(view.id);
      continue;
    }

    composedViews.add(replacementById.remove(view.id) ?? view);
  }

  return [...composedViews, ...replacementById.values, ...extensions];
}

List<BillingDiagnosticsReleaseProfileSavedView>
_validatedReleaseProfileSavedViews(
  Iterable<BillingDiagnosticsReleaseProfileSavedView> views,
) {
  final viewList = views.toList();
  final ids = <String>{};

  for (final view in viewList) {
    final normalizedId = view.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(view.id, 'view.id', 'must not be blank');
    }
    if (normalizedId != view.id) {
      throw ArgumentError.value(
        view.id,
        'view.id',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!ids.add(view.id)) {
      throw ArgumentError.value(
        view.id,
        'view.id',
        'must be unique in a diagnostics release profile saved-view registry',
      );
    }
  }

  return List.unmodifiable(viewList);
}

List<BillingDiagnosticsReleaseProfileSavedViewProfile>
_validatedReleaseProfileSavedViewProfiles(
  Iterable<BillingDiagnosticsReleaseProfileSavedViewProfile> profiles,
) {
  final profileList = profiles.toList();
  final profileIds = <String>{};
  final domainOwners = <String, String>{};

  for (final profile in profileList) {
    if (!profileIds.add(profile.id)) {
      throw ArgumentError.value(
        profile.id,
        'profile.id',
        'must be unique in a diagnostics release profile saved-view catalog',
      );
    }
    for (final domain in profile.businessDomains) {
      final previousOwner = domainOwners[domain];
      if (previousOwner != null) {
        throw ArgumentError.value(
          domain,
          'businessDomains',
          'is already assigned to $previousOwner',
        );
      }
      domainOwners[domain] = profile.id;
    }
  }

  return List.unmodifiable(profileList);
}
