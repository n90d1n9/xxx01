import '../models/billing_business_domain_module.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_business_domain_screen_registry.dart';
import '../widgets/billing_diagnostics_section_profile.dart';
import '../widgets/billing_release_gate_lane_target.dart';
import '../widgets/billing_release_workspace_profile.dart';
import '../widgets/diagnostics_release_profile_saved_view_registry.dart';
import 'billing_release_gate.dart';

/// Modular billing business-domain pack contract.
class BillingBusinessDomainPack {
  final String id;
  final BillingBusinessDomainModule module;
  final BillingDiagnosticsSectionProfile? diagnosticsProfile;
  final BillingReleaseWorkspaceProfile? releaseWorkspaceProfile;
  final BillingDiagnosticsReleaseProfileSavedViewProfile?
  releaseProfileSavedViewProfile;
  final List<BillingReleaseGateLane> releaseGateLanes;
  final List<BillingReleaseGateLaneTarget> releaseGateLaneTargets;

  BillingBusinessDomainPack({
    String? id,
    required this.module,
    this.diagnosticsProfile,
    this.releaseWorkspaceProfile,
    this.releaseProfileSavedViewProfile,
    Iterable<BillingReleaseGateLane> releaseGateLanes = const [],
    Iterable<BillingReleaseGateLaneTarget> releaseGateLaneTargets = const [],
  }) : id = _normalizePackId(id ?? module.key),
       releaseGateLanes = _validatedReleaseGateLanes(releaseGateLanes),
       releaseGateLaneTargets = _validatedReleaseGateLaneTargets(
         releaseGateLaneTargets,
         releaseGateLanes,
       ) {
    _ensureDiagnosticsProfile(module, diagnosticsProfile);
    _ensureReleaseWorkspaceProfile(module, releaseWorkspaceProfile);
    _ensureReleaseProfileSavedViewProfile(
      module,
      releaseProfileSavedViewProfile,
    );
  }

  String get domainKey => module.key;

  BillingBusinessDomainProfile get profile => module.profile;

  BillingBusinessDomainScreenRegistry? get screenRegistry {
    return module.screenRegistry;
  }

  BillingBusinessDomainPack copyWith({
    String? id,
    BillingBusinessDomainModule? module,
    Object? diagnosticsProfile = _unset,
    Object? releaseWorkspaceProfile = _unset,
    Object? releaseProfileSavedViewProfile = _unset,
    Object? releaseGateLanes = _unset,
    Object? releaseGateLaneTargets = _unset,
  }) {
    return BillingBusinessDomainPack(
      id: id ?? this.id,
      module: module ?? this.module,
      diagnosticsProfile:
          identical(diagnosticsProfile, _unset)
              ? this.diagnosticsProfile
              : diagnosticsProfile as BillingDiagnosticsSectionProfile?,
      releaseWorkspaceProfile:
          identical(releaseWorkspaceProfile, _unset)
              ? this.releaseWorkspaceProfile
              : releaseWorkspaceProfile as BillingReleaseWorkspaceProfile?,
      releaseProfileSavedViewProfile:
          identical(releaseProfileSavedViewProfile, _unset)
              ? this.releaseProfileSavedViewProfile
              : releaseProfileSavedViewProfile
                  as BillingDiagnosticsReleaseProfileSavedViewProfile?,
      releaseGateLanes:
          identical(releaseGateLanes, _unset)
              ? this.releaseGateLanes
              : releaseGateLanes as Iterable<BillingReleaseGateLane>,
      releaseGateLaneTargets:
          identical(releaseGateLaneTargets, _unset)
              ? this.releaseGateLaneTargets
              : releaseGateLaneTargets
                  as Iterable<BillingReleaseGateLaneTarget>,
    );
  }
}

/// Immutable registry for billing business-domain packs.
class BillingBusinessDomainPackRegistry {
  final List<BillingBusinessDomainPack> packs;

  BillingBusinessDomainPackRegistry({
    Iterable<BillingBusinessDomainPack> packs = const [],
  }) : packs = List.unmodifiable(_ensureUniquePacks(packs));

  bool get isEmpty => packs.isEmpty;

  List<String> get domainKeys {
    return List.unmodifiable(packs.map((pack) => pack.domainKey));
  }

  BillingBusinessDomainModuleRegistry get moduleRegistry {
    return BillingBusinessDomainModuleRegistry(
      modules: packs.map((pack) => pack.module),
    );
  }

  BillingBusinessDomainProfileRegistry get profileRegistry {
    return moduleRegistry.profileRegistry;
  }

  BillingDiagnosticsSectionProfileCatalog get diagnosticsProfileCatalog {
    return BillingDiagnosticsSectionProfileCatalog(
      profiles:
          packs
              .map((pack) => pack.diagnosticsProfile)
              .whereType<BillingDiagnosticsSectionProfile>(),
    );
  }

  BillingReleaseWorkspaceProfileCatalog get releaseWorkspaceProfileCatalog {
    return BillingReleaseWorkspaceProfileCatalog(
      profiles:
          packs
              .map((pack) => pack.releaseWorkspaceProfile)
              .whereType<BillingReleaseWorkspaceProfile>(),
    );
  }

  BillingDiagnosticsReleaseProfileSavedViewProfileCatalog
  get releaseProfileSavedViewProfileCatalog {
    return BillingDiagnosticsReleaseProfileSavedViewProfileCatalog(
      profiles:
          packs
              .map((pack) => pack.releaseProfileSavedViewProfile)
              .whereType<BillingDiagnosticsReleaseProfileSavedViewProfile>(),
    );
  }

  List<BillingReleaseGateLaneTarget> releaseGateLaneTargetsForBusinessDomain(
    String domain,
  ) {
    return List.unmodifiable(find(domain)?.releaseGateLaneTargets ?? const []);
  }

  List<BillingReleaseGateLane> releaseGateLanesForBusinessDomain(
    String domain,
  ) {
    return List.unmodifiable(find(domain)?.releaseGateLanes ?? const []);
  }

  BillingBusinessDomainPack? find(String domain) {
    final key = billingBusinessDomainKey(domain);

    for (final pack in packs) {
      if (pack.domainKey == key) return pack;
    }

    return null;
  }

  BillingBusinessDomainPack requirePack(String domain) {
    final pack = find(domain);
    if (pack == null) {
      throw StateError(
        'No billing business domain pack is registered for $domain.',
      );
    }

    return pack;
  }

  BillingBusinessDomainPackRegistry register(BillingBusinessDomainPack pack) {
    return BillingBusinessDomainPackRegistry(packs: [...packs, pack]);
  }

  BillingBusinessDomainPackRegistry registerAll(
    Iterable<BillingBusinessDomainPack> packs,
  ) {
    return BillingBusinessDomainPackRegistry(packs: [...this.packs, ...packs]);
  }

  static List<BillingBusinessDomainPack> _ensureUniquePacks(
    Iterable<BillingBusinessDomainPack> packs,
  ) {
    final packList = packs.toList();
    final seenIds = <String>{};
    final seenDomainKeys = <String>{};

    for (final pack in packList) {
      if (!seenIds.add(pack.id)) {
        throw StateError(
          'Duplicate billing business domain pack id: ${pack.id}.',
        );
      }
      if (!seenDomainKeys.add(pack.domainKey)) {
        throw StateError(
          'Duplicate billing business domain pack registered for '
          '${pack.domainKey}.',
        );
      }
    }

    return packList;
  }
}

void _ensureDiagnosticsProfile(
  BillingBusinessDomainModule module,
  BillingDiagnosticsSectionProfile? diagnosticsProfile,
) {
  if (diagnosticsProfile == null) return;
  if (diagnosticsProfile.matches(module.key)) return;

  throw StateError(
    'Billing domain pack ${module.key} cannot register diagnostics profile '
    '${diagnosticsProfile.id}'
    ' for a different domain.',
  );
}

void _ensureReleaseWorkspaceProfile(
  BillingBusinessDomainModule module,
  BillingReleaseWorkspaceProfile? releaseWorkspaceProfile,
) {
  if (releaseWorkspaceProfile == null) return;
  if (releaseWorkspaceProfile.matches(module.key)) return;

  throw StateError(
    'Billing domain pack ${module.key} cannot register release workspace '
    'profile ${releaseWorkspaceProfile.id} for a different domain.',
  );
}

void _ensureReleaseProfileSavedViewProfile(
  BillingBusinessDomainModule module,
  BillingDiagnosticsReleaseProfileSavedViewProfile? profile,
) {
  if (profile == null) return;
  if (profile.matches(module.key)) return;

  throw StateError(
    'Billing domain pack ${module.key} cannot register release profile '
    'saved-view profile ${profile.id} for a different domain.',
  );
}

String _normalizePackId(String value) {
  final id = value.trim();
  if (id.isEmpty) {
    throw ArgumentError.value(value, 'id', 'must not be blank');
  }

  return id;
}

List<BillingReleaseGateLane> _validatedReleaseGateLanes(
  Iterable<BillingReleaseGateLane> lanes,
) {
  final laneList = lanes.toList();
  final laneIds = <String>{};

  for (final lane in laneList) {
    final laneId = lane.id.trim();
    if (laneId.isEmpty) {
      throw ArgumentError.value(lane.id, 'lane.id', 'must not be blank');
    }
    if (laneId != lane.id) {
      throw ArgumentError.value(
        lane.id,
        'lane.id',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!laneIds.add(laneId)) {
      throw ArgumentError.value(
        lane.id,
        'lane.id',
        'must be unique in a business-domain pack',
      );
    }
    if (lane.title.trim().isEmpty) {
      throw ArgumentError.value(lane.title, 'lane.title', 'must not be blank');
    }
    if (lane.summaryLabel.trim().isEmpty) {
      throw ArgumentError.value(
        lane.summaryLabel,
        'lane.summaryLabel',
        'must not be blank',
      );
    }
  }

  return List.unmodifiable(laneList);
}

List<BillingReleaseGateLaneTarget> _validatedReleaseGateLaneTargets(
  Iterable<BillingReleaseGateLaneTarget> targets,
  Iterable<BillingReleaseGateLane> lanes,
) {
  final targetList =
      BillingReleaseGateLaneTargetRegistry(targets: targets).targets;
  if (targetList.isEmpty) return targetList;

  final laneIds = lanes.map((lane) => lane.id).toSet();
  for (final target in targetList) {
    if (!laneIds.contains(target.laneId)) {
      throw ArgumentError.value(
        target.laneId,
        'releaseGateLaneTargets',
        'must reference a release gate lane registered by this pack',
      );
    }
  }

  return targetList;
}

const _unset = Object();
