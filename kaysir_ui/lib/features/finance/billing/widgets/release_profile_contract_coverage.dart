import '../models/billing_business_domain_profile.dart';
import 'release_profile_contract.dart';

/// Aggregates release workspace profile contracts for diagnostics coverage,
/// including domain ownership, extension counts, and fallback guidance.
class BillingReleaseWorkspaceProfileContractCoverage {
  final List<BillingReleaseWorkspaceProfileContract> contracts;

  factory BillingReleaseWorkspaceProfileContractCoverage({
    Iterable<BillingReleaseWorkspaceProfileContract> contracts = const [],
  }) {
    return BillingReleaseWorkspaceProfileContractCoverage._(
      List.unmodifiable(contracts),
    );
  }

  const BillingReleaseWorkspaceProfileContractCoverage._(this.contracts);

  bool get isEmpty => contracts.isEmpty;

  int get profileCount => contracts.length;

  int get domainCount {
    return contracts
        .expand((contract) => contract.businessDomains)
        .toSet()
        .length;
  }

  int get deckRegistrationCount {
    return contracts.fold(0, (sum, contract) => sum + contract.deckCount);
  }

  int get savedViewRegistrationCount {
    return contracts.fold(0, (sum, contract) => sum + contract.savedViewCount);
  }

  int get extensionDeckCount {
    return contracts.fold(
      0,
      (sum, contract) => sum + contract.extensionDeckCount,
    );
  }

  int get extensionSavedViewCount {
    return contracts.fold(
      0,
      (sum, contract) => sum + contract.extensionSavedViewCount,
    );
  }

  int get hiddenDeckCount {
    return contracts.fold(0, (sum, contract) => sum + contract.hiddenDeckCount);
  }

  bool get hasCustomizations {
    return extensionDeckCount > 0 ||
        extensionSavedViewCount > 0 ||
        hiddenDeckCount > 0;
  }

  BillingReleaseWorkspaceProfileContractStatusSummary get statusSummary {
    return BillingReleaseWorkspaceProfileContractStatusSummary.fromContracts(
      contracts,
    );
  }

  /// Orders contracts for diagnostics review with the focused tenant domain
  /// first, then by release profile customization severity.
  List<BillingReleaseWorkspaceProfileContract> prioritizedContracts({
    String? focusedBusinessDomain,
    Set<BillingReleaseWorkspaceProfileContractStatus>? includedStatuses,
    String? scopedBusinessDomain,
  }) {
    final domainKey = billingBusinessDomainKey(focusedBusinessDomain ?? '');
    final scopeKey = billingBusinessDomainKey(scopedBusinessDomain ?? '');
    final indexedContracts = contracts.indexed
        .where(
          (entry) =>
              includedStatuses == null ||
              includedStatuses.contains(entry.$2.status),
        )
        .where(
          (entry) =>
              scopeKey.isEmpty || entry.$2.businessDomains.contains(scopeKey),
        )
        .map((entry) => _IndexedProfileContract(entry.$1, entry.$2))
        .toList(growable: false);

    indexedContracts.sort((left, right) {
      final focusOrder = _focusedOrder(
        left.contract,
        right.contract,
        domainKey,
      );
      if (focusOrder != 0) return focusOrder;

      final statusOrder = left.contract.status.diagnosticPriority.compareTo(
        right.contract.status.diagnosticPriority,
      );
      if (statusOrder != 0) return statusOrder;

      return left.index.compareTo(right.index);
    });

    return List.unmodifiable(indexedContracts.map((entry) => entry.contract));
  }

  BillingReleaseWorkspaceProfileContract? contractForBusinessDomain(
    String businessDomain,
  ) {
    final domainKey = billingBusinessDomainKey(businessDomain);
    if (domainKey.isEmpty) return null;

    for (final contract in contracts) {
      if (contract.businessDomains.contains(domainKey)) return contract;
    }

    return null;
  }

  BillingReleaseWorkspaceFocusedDomainCoverage focusedDomain(
    String businessDomain,
  ) {
    return BillingReleaseWorkspaceFocusedDomainCoverage(
      businessDomain: businessDomain,
      contract: contractForBusinessDomain(businessDomain),
    );
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No release workspace profiles are registered yet.';
    }

    final verb = profileCount == 1 ? 'covers' : 'cover';

    return '${_countLabel(profileCount, 'release workspace profile')} $verb '
        '${_countLabel(domainCount, 'business domain')}.';
  }

  String get customizationLabel {
    if (!hasCustomizations) {
      return 'All profiles use the standard release workspace.';
    }

    final parts = <String>[];
    if (extensionDeckCount > 0) {
      parts.add(_countLabel(extensionDeckCount, 'domain deck'));
    }
    if (extensionSavedViewCount > 0) {
      parts.add(_countLabel(extensionSavedViewCount, 'domain saved view'));
    }
    if (hiddenDeckCount > 0) {
      parts.add(_countLabel(hiddenDeckCount, 'hidden standard deck'));
    }

    final verb = _customizationVerb(
      extensionCount: extensionDeckCount + extensionSavedViewCount,
      hiddenCount: hiddenDeckCount,
    );

    return '${parts.join(' · ')} $verb release workspace behavior.';
  }
}

/// Indexed contract entry used to keep diagnostics sorting stable.
class _IndexedProfileContract {
  final int index;
  final BillingReleaseWorkspaceProfileContract contract;

  const _IndexedProfileContract(this.index, this.contract);
}

/// Count summary for release workspace profile contract statuses.
class BillingReleaseWorkspaceProfileContractStatusSummary {
  final Map<BillingReleaseWorkspaceProfileContractStatus, int> _counts;

  factory BillingReleaseWorkspaceProfileContractStatusSummary.fromContracts(
    Iterable<BillingReleaseWorkspaceProfileContract> contracts,
  ) {
    final counts = {
      for (final status in BillingReleaseWorkspaceProfileContractStatus.values)
        status: 0,
    };

    for (final contract in contracts) {
      counts[contract.status] = (counts[contract.status] ?? 0) + 1;
    }

    return BillingReleaseWorkspaceProfileContractStatusSummary._(
      Map.unmodifiable(counts),
    );
  }

  const BillingReleaseWorkspaceProfileContractStatusSummary._(this._counts);

  int countFor(BillingReleaseWorkspaceProfileContractStatus status) {
    return _counts[status] ?? 0;
  }

  int get totalCount {
    return _counts.values.fold(0, (sum, count) => sum + count);
  }

  bool get isEmpty => totalCount == 0;

  Iterable<BillingReleaseWorkspaceProfileContractStatus> get activeStatuses {
    return BillingReleaseWorkspaceProfileContractStatus.values.where(
      (status) => countFor(status) > 0,
    );
  }

  String get summaryLabel {
    if (isEmpty) return 'No release workspace profile statuses yet.';

    final parts = activeStatuses.map((status) {
      return '${countFor(status)} ${status.label.toLowerCase()}';
    });

    return 'Profile status: ${parts.join(' · ')}.';
  }
}

/// Focused coverage result for one tenant business domain, including fallback
/// messaging when no domain-specific release profile exists.
class BillingReleaseWorkspaceFocusedDomainCoverage {
  final String businessDomain;
  final String domainKey;
  final BillingReleaseWorkspaceProfileContract? contract;

  BillingReleaseWorkspaceFocusedDomainCoverage({
    required String businessDomain,
    this.contract,
  }) : businessDomain = businessDomain.trim(),
       domainKey = billingBusinessDomainKey(businessDomain);

  bool get isCovered => contract != null;

  BillingReleaseWorkspaceCoverageRemediationAction? get remediationAction {
    if (isCovered || domainKey.isEmpty) return null;

    return BillingReleaseWorkspaceCoverageRemediationAction(
      id: '$domainKey:release-workspace-profile',
      domainKey: domainKey,
      domainLabel: domainLabel,
      label: 'Register $domainLabel release workspace profile',
      detail:
          '$domainLabel is using the standard release workspace. Register a '
          'domain-specific profile when release decks, saved views, or launch '
          'behavior should differ from standard billing.',
    );
  }

  String get domainLabel {
    final source = businessDomain.isNotEmpty ? businessDomain : domainKey;
    if (source.isEmpty) return 'Default domain';

    return source
        .split(RegExp(r'[-_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String get statusLabel {
    return isCovered ? 'Covered' : 'Standard fallback';
  }

  String get summaryLabel {
    final profileId = contract?.profileId;
    if (profileId != null) {
      return '$domainLabel uses the $profileId release workspace profile.';
    }

    return '$domainLabel uses the standard release workspace until a '
        'domain-specific profile is registered.';
  }
}

/// Suggested action when a tenant domain is relying on the standard release
/// workspace fallback instead of a dedicated profile.
class BillingReleaseWorkspaceCoverageRemediationAction {
  final String id;
  final String domainKey;
  final String domainLabel;
  final String label;
  final String detail;

  const BillingReleaseWorkspaceCoverageRemediationAction({
    required this.id,
    required this.domainKey,
    required this.domainLabel,
    required this.label,
    required this.detail,
  });
}

String _countLabel(int count, String noun) {
  final suffix = count == 1 ? noun : '${noun}s';
  return '$count $suffix';
}

int _focusedOrder(
  BillingReleaseWorkspaceProfileContract left,
  BillingReleaseWorkspaceProfileContract right,
  String domainKey,
) {
  if (domainKey.isEmpty) return 0;

  final leftFocused = left.businessDomains.contains(domainKey);
  final rightFocused = right.businessDomains.contains(domainKey);
  if (leftFocused == rightFocused) return 0;

  return leftFocused ? -1 : 1;
}

String _customizationVerb({
  required int extensionCount,
  required int hiddenCount,
}) {
  final totalCount = extensionCount + hiddenCount;
  if (hiddenCount > 0 && extensionCount > 0) {
    return totalCount == 1 ? 'tailors' : 'tailor';
  }
  if (hiddenCount > 0) {
    return hiddenCount == 1 ? 'constrains' : 'constrain';
  }

  return extensionCount == 1 ? 'extends' : 'extend';
}
