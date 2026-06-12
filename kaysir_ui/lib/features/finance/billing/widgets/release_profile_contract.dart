import '../models/billing_business_domain_profile.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';

/// Describes how far a release workspace profile diverges from the standard
/// billing release workspace.
enum BillingReleaseWorkspaceProfileContractStatus {
  standard,
  extended,
  constrained,
  tailored,
}

/// Presentation labels for release workspace profile contract statuses.
extension BillingReleaseWorkspaceProfileContractStatusPresentation
    on BillingReleaseWorkspaceProfileContractStatus {
  String get label {
    return switch (this) {
      BillingReleaseWorkspaceProfileContractStatus.standard => 'Standard',
      BillingReleaseWorkspaceProfileContractStatus.extended => 'Extended',
      BillingReleaseWorkspaceProfileContractStatus.constrained => 'Constrained',
      BillingReleaseWorkspaceProfileContractStatus.tailored => 'Tailored',
    };
  }

  /// Sort priority for diagnostics surfaces, where lower values need earlier
  /// visibility in profile review lists.
  int get diagnosticPriority {
    return switch (this) {
      BillingReleaseWorkspaceProfileContractStatus.tailored => 0,
      BillingReleaseWorkspaceProfileContractStatus.constrained => 1,
      BillingReleaseWorkspaceProfileContractStatus.extended => 2,
      BillingReleaseWorkspaceProfileContractStatus.standard => 3,
    };
  }
}

/// Immutable registration contract for one release workspace profile,
/// including its domain ownership, visible decks, saved views, and extensions.
class BillingReleaseWorkspaceProfileContract {
  final String profileId;
  final Set<String> businessDomains;
  final List<String> deckIds;
  final List<String> savedViewIds;
  final Set<String> hiddenDeckIds;
  final List<String> extensionDeckIds;
  final List<String> extensionSavedViewIds;

  factory BillingReleaseWorkspaceProfileContract({
    required String profileId,
    required Iterable<String> businessDomains,
    required BillingReleaseWorkspaceRegistry registry,
    required Iterable<BillingReleaseWorkspaceSavedView> savedViews,
    Iterable<String> hiddenDeckIds = const {},
    Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions = const [],
    Iterable<BillingReleaseWorkspaceSavedView> extensionSavedViews = const [],
  }) {
    final normalizedProfileId = profileId.trim();
    if (normalizedProfileId.isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'must not be blank');
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

    return BillingReleaseWorkspaceProfileContract._(
      profileId: normalizedProfileId,
      businessDomains: Set.unmodifiable(normalizedDomains),
      deckIds: List.unmodifiable(registry.deckIds),
      savedViewIds: List.unmodifiable(savedViews.map((view) => view.id)),
      hiddenDeckIds: Set.unmodifiable(_normalizedIds(hiddenDeckIds)),
      extensionDeckIds: List.unmodifiable(_extensionDeckIds(extensions)),
      extensionSavedViewIds: List.unmodifiable(
        _extensionSavedViewIds(extensionSavedViews),
      ),
    );
  }

  const BillingReleaseWorkspaceProfileContract._({
    required this.profileId,
    required this.businessDomains,
    required this.deckIds,
    required this.savedViewIds,
    required this.hiddenDeckIds,
    required this.extensionDeckIds,
    required this.extensionSavedViewIds,
  });

  int get deckCount => deckIds.length;

  int get savedViewCount => savedViewIds.length;

  int get hiddenDeckCount => hiddenDeckIds.length;

  int get extensionDeckCount => extensionDeckIds.length;

  int get extensionSavedViewCount => extensionSavedViewIds.length;

  bool get hasHiddenDecks => hiddenDeckIds.isNotEmpty;

  bool get hasExtensionDecks => extensionDeckIds.isNotEmpty;

  bool get hasExtensionSavedViews => extensionSavedViewIds.isNotEmpty;

  bool get hasExtensions => hasExtensionDecks || hasExtensionSavedViews;

  bool get hasCustomizations => hasExtensions || hasHiddenDecks;

  BillingReleaseWorkspaceProfileContractStatus get status {
    if (hasExtensions && hasHiddenDecks) {
      return BillingReleaseWorkspaceProfileContractStatus.tailored;
    }
    if (hasExtensions) {
      return BillingReleaseWorkspaceProfileContractStatus.extended;
    }
    if (hasHiddenDecks) {
      return BillingReleaseWorkspaceProfileContractStatus.constrained;
    }

    return BillingReleaseWorkspaceProfileContractStatus.standard;
  }

  String get statusLabel {
    return status.label;
  }

  String get statusDetail {
    return switch (status) {
      BillingReleaseWorkspaceProfileContractStatus.standard =>
        'Uses the baseline release workspace without domain-specific deck or '
            'saved view changes.',
      BillingReleaseWorkspaceProfileContractStatus.extended =>
        'Adds domain-specific deck or saved view registrations to the standard '
            'release workspace.',
      BillingReleaseWorkspaceProfileContractStatus.constrained =>
        'Hides one or more standard deck registrations for this release '
            'workspace profile.',
      BillingReleaseWorkspaceProfileContractStatus.tailored =>
        'Adds domain-specific registrations and hides standard decks for a '
            'tailored release workspace profile.',
    };
  }

  String get summaryLabel {
    return '$profileId · ${_countLabel(deckCount, 'deck')} · '
        '${_countLabel(savedViewCount, 'view')}';
  }

  String get compositionLabel {
    final parts = <String>[];
    if (hasExtensionDecks) {
      parts.add(_countLabel(extensionDeckCount, 'domain deck'));
    }
    if (hasExtensionSavedViews) {
      parts.add(_countLabel(extensionSavedViewCount, 'domain saved view'));
    }
    if (hasHiddenDecks) {
      parts.add(_countLabel(hiddenDeckCount, 'hidden standard deck'));
    }

    if (parts.isEmpty) return 'Standard release workspace profile';

    return parts.join(' · ');
  }

  bool containsDeck(String deckId) {
    return deckIds.contains(deckId.trim());
  }

  bool containsSavedView(String savedViewId) {
    return savedViewIds.contains(savedViewId.trim());
  }
}

Set<String> _normalizedIds(Iterable<String> ids) {
  return ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
}

Iterable<String> _extensionDeckIds(
  Iterable<BillingReleaseWorkspaceDeckDescriptor> extensions,
) {
  return extensions
      .map((descriptor) => descriptor.id.trim())
      .where((id) => id.isNotEmpty);
}

Iterable<String> _extensionSavedViewIds(
  Iterable<BillingReleaseWorkspaceSavedView> savedViews,
) {
  return savedViews.map((view) => view.id.trim()).where((id) => id.isNotEmpty);
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}
