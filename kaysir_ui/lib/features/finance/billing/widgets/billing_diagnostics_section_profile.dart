import 'billing_diagnostics_section_registry.dart';

class BillingDiagnosticsSectionProfile {
  final String id;
  final Set<String> businessDomains;
  final Set<String> hiddenSectionIds;
  final List<BillingDiagnosticsSectionDescriptor> extensions;

  factory BillingDiagnosticsSectionProfile({
    required String id,
    required Iterable<String> businessDomains,
    Iterable<String> hiddenSectionIds = const {},
    Iterable<BillingDiagnosticsSectionDescriptor> extensions = const [],
  }) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be blank');
    }

    final normalizedDomains =
        businessDomains
            .map(_normalizeDiagnosticsBusinessDomain)
            .where((domain) => domain.isNotEmpty)
            .toSet();
    if (normalizedDomains.isEmpty) {
      throw ArgumentError.value(
        businessDomains,
        'businessDomains',
        'must include at least one non-blank domain',
      );
    }

    return BillingDiagnosticsSectionProfile._(
      id: normalizedId,
      businessDomains: Set.unmodifiable(normalizedDomains),
      hiddenSectionIds: Set.unmodifiable(hiddenSectionIds),
      extensions: List.unmodifiable(extensions),
    );
  }

  const BillingDiagnosticsSectionProfile._({
    required this.id,
    required this.businessDomains,
    required this.hiddenSectionIds,
    required this.extensions,
  });

  bool matches(String businessDomain) {
    return businessDomains.contains(
      _normalizeDiagnosticsBusinessDomain(businessDomain),
    );
  }

  BillingDiagnosticsSectionRegistry buildRegistry() {
    return BillingDiagnosticsSectionRegistry.standard(
      hiddenSectionIds: hiddenSectionIds,
      extensions: extensions,
    );
  }

  BillingDiagnosticsSectionProfile extend({
    Iterable<String> businessDomains = const [],
    Iterable<String> hiddenSectionIds = const {},
    Iterable<BillingDiagnosticsSectionDescriptor> extensions = const [],
  }) {
    return BillingDiagnosticsSectionProfile(
      id: id,
      businessDomains: [...this.businessDomains, ...businessDomains],
      hiddenSectionIds: {...this.hiddenSectionIds, ...hiddenSectionIds},
      extensions: [...this.extensions, ...extensions],
    );
  }
}

class BillingDiagnosticsSectionProfileCatalog {
  final List<BillingDiagnosticsSectionProfile> profiles;

  factory BillingDiagnosticsSectionProfileCatalog({
    Iterable<BillingDiagnosticsSectionProfile> profiles = const [],
  }) {
    return BillingDiagnosticsSectionProfileCatalog._(
      _validatedDiagnosticsSectionProfiles(profiles),
    );
  }

  const BillingDiagnosticsSectionProfileCatalog._(this.profiles);

  BillingDiagnosticsSectionProfile? profileForBusinessDomain(
    String businessDomain,
  ) {
    final normalizedDomain = _normalizeDiagnosticsBusinessDomain(
      businessDomain,
    );
    for (final profile in profiles) {
      if (profile.businessDomains.contains(normalizedDomain)) return profile;
    }

    return null;
  }

  BillingDiagnosticsSectionRegistry registryForBusinessDomain(
    String businessDomain,
  ) {
    return profileForBusinessDomain(businessDomain)?.buildRegistry() ??
        BillingDiagnosticsSectionRegistry.standard();
  }

  BillingDiagnosticsSectionProfileCatalog extendProfile({
    required String profileId,
    Iterable<String> businessDomains = const [],
    Iterable<String> hiddenSectionIds = const {},
    Iterable<BillingDiagnosticsSectionDescriptor> extensions = const [],
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
        'must reference an existing billing diagnostics profile',
      );
    }

    final nextProfiles = profiles.toList();
    nextProfiles[profileIndex] = nextProfiles[profileIndex].extend(
      businessDomains: businessDomains,
      hiddenSectionIds: hiddenSectionIds,
      extensions: extensions,
    );

    return BillingDiagnosticsSectionProfileCatalog(profiles: nextProfiles);
  }
}

List<BillingDiagnosticsSectionProfile> _validatedDiagnosticsSectionProfiles(
  Iterable<BillingDiagnosticsSectionProfile> profiles,
) {
  final profileList = profiles.toList();
  final profileIds = <String>{};
  final domainOwners = <String, String>{};

  for (final profile in profileList) {
    if (!profileIds.add(profile.id)) {
      throw ArgumentError.value(
        profile.id,
        'profile.id',
        'must be unique in a billing diagnostics profile catalog',
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

String _normalizeDiagnosticsBusinessDomain(String businessDomain) {
  return businessDomain.trim().toLowerCase();
}
