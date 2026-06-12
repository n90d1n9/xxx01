import '../models/billing_business_domain_profile.dart';
import 'release_profile_contract.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';

/// Domain-specific release workspace composition that can extend or constrain
/// the standard billing release decks and saved views.
class BillingReleaseWorkspaceProfile {
  final String id;
  final Set<String> businessDomains;
  final Set<String> hiddenDeckIds;
  final List<BillingReleaseWorkspaceDeckDescriptor> extensions;
  final List<BillingReleaseWorkspaceSavedView> savedViews;

  factory BillingReleaseWorkspaceProfile({
    required String id,
    required Iterable<String> businessDomains,
    Iterable<String> hiddenDeckIds = const {},
    Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions = const [],
    Iterable<BillingReleaseWorkspaceSavedView> savedViews = const [],
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

    return BillingReleaseWorkspaceProfile._(
      id: normalizedId,
      businessDomains: Set.unmodifiable(normalizedDomains),
      hiddenDeckIds: Set.unmodifiable(
        _normalizedReleaseWorkspaceIds(hiddenDeckIds),
      ),
      extensions: List.unmodifiable(extensions),
      savedViews: _validatedReleaseWorkspaceSavedViews(savedViews),
    );
  }

  const BillingReleaseWorkspaceProfile._({
    required this.id,
    required this.businessDomains,
    required this.hiddenDeckIds,
    required this.extensions,
    required this.savedViews,
  });

  bool matches(String businessDomain) {
    return businessDomains.contains(billingBusinessDomainKey(businessDomain));
  }

  BillingReleaseWorkspaceRegistry buildRegistry() {
    return standardBillingReleaseWorkspaceRegistry(
      hiddenDeckIds: hiddenDeckIds,
      extensions: extensions,
    );
  }

  List<BillingReleaseWorkspaceSavedView> buildSavedViews() {
    return _mergeReleaseWorkspaceSavedViews(
      billingReleaseWorkspaceDefaultSavedViews,
      savedViews,
    );
  }

  BillingReleaseWorkspaceProfileContract buildContract() {
    return BillingReleaseWorkspaceProfileContract(
      profileId: id,
      businessDomains: businessDomains,
      registry: buildRegistry(),
      savedViews: buildSavedViews(),
      hiddenDeckIds: hiddenDeckIds,
      extensions: extensions,
      extensionSavedViews: savedViews,
    );
  }

  BillingReleaseWorkspaceProfile extend({
    Iterable<String> businessDomains = const [],
    Iterable<String> hiddenDeckIds = const {},
    Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions = const [],
    Iterable<BillingReleaseWorkspaceSavedView> savedViews = const [],
  }) {
    return BillingReleaseWorkspaceProfile(
      id: id,
      businessDomains: [...this.businessDomains, ...businessDomains],
      hiddenDeckIds: {...this.hiddenDeckIds, ...hiddenDeckIds},
      extensions: [...this.extensions, ...extensions],
      savedViews: [...this.savedViews, ...savedViews],
    );
  }
}

/// Catalog of release workspace profiles with lookup helpers for tenant
/// business domains and generated registry contracts.
class BillingReleaseWorkspaceProfileCatalog {
  final List<BillingReleaseWorkspaceProfile> profiles;

  factory BillingReleaseWorkspaceProfileCatalog({
    Iterable<BillingReleaseWorkspaceProfile> profiles = const [],
  }) {
    return BillingReleaseWorkspaceProfileCatalog._(
      _validatedReleaseWorkspaceProfiles(profiles),
    );
  }

  const BillingReleaseWorkspaceProfileCatalog._(this.profiles);

  BillingReleaseWorkspaceProfile? profileForBusinessDomain(
    String businessDomain,
  ) {
    final normalizedDomain = billingBusinessDomainKey(businessDomain);
    for (final profile in profiles) {
      if (profile.businessDomains.contains(normalizedDomain)) return profile;
    }

    return null;
  }

  BillingReleaseWorkspaceRegistry registryForBusinessDomain(
    String businessDomain,
  ) {
    return profileForBusinessDomain(businessDomain)?.buildRegistry() ??
        standardBillingReleaseWorkspaceRegistry();
  }

  List<BillingReleaseWorkspaceSavedView> savedViewsForBusinessDomain(
    String businessDomain,
  ) {
    return profileForBusinessDomain(businessDomain)?.buildSavedViews() ??
        billingReleaseWorkspaceDefaultSavedViews;
  }

  BillingReleaseWorkspaceProfileContract? contractForBusinessDomain(
    String businessDomain,
  ) {
    return profileForBusinessDomain(businessDomain)?.buildContract();
  }

  List<BillingReleaseWorkspaceProfileContract> buildContracts() {
    return List.unmodifiable(
      profiles.map((profile) => profile.buildContract()),
    );
  }

  BillingReleaseWorkspaceProfileCatalog extendProfile({
    required String profileId,
    Iterable<String> businessDomains = const [],
    Iterable<String> hiddenDeckIds = const {},
    Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions = const [],
    Iterable<BillingReleaseWorkspaceSavedView> savedViews = const [],
  }) {
    final normalizedProfileId = profileId.trim();
    if (normalizedProfileId.isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'must not be blank');
    }

    final profileIndex = profiles.indexWhere(
      (profile) => profile.id == normalizedProfileId,
    );
    if (profileIndex == -1) {
      throw ArgumentError.value(
        profileId,
        'profileId',
        'must reference an existing billing release workspace profile',
      );
    }

    final nextProfiles = profiles.toList();
    nextProfiles[profileIndex] = nextProfiles[profileIndex].extend(
      businessDomains: businessDomains,
      hiddenDeckIds: hiddenDeckIds,
      extensions: extensions,
      savedViews: savedViews,
    );

    return BillingReleaseWorkspaceProfileCatalog(profiles: nextProfiles);
  }
}

List<BillingReleaseWorkspaceProfile> _validatedReleaseWorkspaceProfiles(
  Iterable<BillingReleaseWorkspaceProfile> profiles,
) {
  final profileList = profiles.toList();
  final profileIds = <String>{};
  final domainOwners = <String, String>{};

  for (final profile in profileList) {
    if (!profileIds.add(profile.id)) {
      throw ArgumentError.value(
        profile.id,
        'profile.id',
        'must be unique in a billing release workspace profile catalog',
      );
    }
    for (final domain in profile.businessDomains) {
      final previousProfileId = domainOwners[domain];
      if (previousProfileId != null) {
        throw ArgumentError.value(
          domain,
          'businessDomains',
          'is already assigned to $previousProfileId',
        );
      }
      domainOwners[domain] = profile.id;
    }
  }

  return List.unmodifiable(profileList);
}

Set<String> _normalizedReleaseWorkspaceIds(Iterable<String> ids) {
  return ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
}

List<BillingReleaseWorkspaceSavedView> _validatedReleaseWorkspaceSavedViews(
  Iterable<BillingReleaseWorkspaceSavedView> savedViews,
) {
  final savedViewList = savedViews.toList(growable: false);
  final ids = <String>{};

  for (final savedView in savedViewList) {
    final normalizedId = savedView.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        savedView.id,
        'savedView.id',
        'must not be blank',
      );
    }
    if (normalizedId != savedView.id) {
      throw ArgumentError.value(
        savedView.id,
        'savedView.id',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!ids.add(normalizedId)) {
      throw ArgumentError.value(
        savedView.id,
        'savedView.id',
        'must be unique in a billing release workspace profile',
      );
    }
  }

  return List.unmodifiable(savedViewList);
}

List<BillingReleaseWorkspaceSavedView> _mergeReleaseWorkspaceSavedViews(
  Iterable<BillingReleaseWorkspaceSavedView> baseSavedViews,
  Iterable<BillingReleaseWorkspaceSavedView> extensionSavedViews,
) {
  final extensionList = extensionSavedViews.toList(growable: false);
  final extensionIds = extensionList.map((view) => view.id).toSet();

  return List.unmodifiable([
    ...baseSavedViews.where((view) => !extensionIds.contains(view.id)),
    ...extensionList,
  ]);
}
