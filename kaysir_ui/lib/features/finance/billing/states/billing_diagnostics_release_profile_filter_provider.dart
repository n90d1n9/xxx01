import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_business_domain_profile.dart';
import '../widgets/release_profile_domain_filter.dart';
import '../widgets/release_profile_status_filter.dart';
import 'billing_diagnostics_screen_context_provider.dart';

/// Default query key for persisting the release profile status filter.
const billingDiagnosticsReleaseProfileStatusQueryKey = 'releaseProfileStatus';

/// Default query key for persisting the release profile business-domain filter.
const billingDiagnosticsReleaseProfileDomainQueryKey = 'releaseProfileDomain';

/// Tenant and domain key used to isolate diagnostics release profile filters.
class BillingDiagnosticsReleaseProfileFilterScope {
  final String tenantId;
  final String businessDomain;

  factory BillingDiagnosticsReleaseProfileFilterScope({
    String tenantId = '',
    String businessDomain = '',
  }) {
    return BillingDiagnosticsReleaseProfileFilterScope._(
      tenantId: tenantId.trim(),
      businessDomain: billingBusinessDomainKey(businessDomain),
    );
  }

  const BillingDiagnosticsReleaseProfileFilterScope._({
    required this.tenantId,
    required this.businessDomain,
  });

  bool get isTenantScoped => tenantId.isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is BillingDiagnosticsReleaseProfileFilterScope &&
        other.tenantId == tenantId &&
        other.businessDomain == businessDomain;
  }

  @override
  int get hashCode => Object.hash(tenantId, businessDomain);
}

/// Persisted release profile filter state for billing diagnostics surfaces.
class BillingDiagnosticsReleaseProfileFilterState {
  final BillingReleaseProfileStatusFilterOption statusOption;
  final BillingReleaseProfileDomainFilterSelection domainSelection;

  const BillingDiagnosticsReleaseProfileFilterState({
    this.statusOption = BillingReleaseProfileStatusFilterOption.all,
    this.domainSelection =
        const BillingReleaseProfileDomainFilterSelection.all(),
  });

  /// Builds filter state from route or saved-view query parameters.
  factory BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters(
    Map<String, String> queryParameters, {
    String statusQueryKey = billingDiagnosticsReleaseProfileStatusQueryKey,
    String domainQueryKey = billingDiagnosticsReleaseProfileDomainQueryKey,
  }) {
    return BillingDiagnosticsReleaseProfileFilterState(
      statusOption: _releaseProfileStatusOptionFromQuery(
        queryParameters[statusQueryKey],
      ),
      domainSelection: _releaseProfileDomainSelectionFromQuery(
        queryParameters[domainQueryKey],
      ),
    );
  }

  bool get hasActiveFilters {
    return statusOption != BillingReleaseProfileStatusFilterOption.all ||
        !domainSelection.isAll;
  }

  /// Returns a compact query representation, omitting inactive defaults.
  Map<String, String> toQueryParameters({
    String statusQueryKey = billingDiagnosticsReleaseProfileStatusQueryKey,
    String domainQueryKey = billingDiagnosticsReleaseProfileDomainQueryKey,
  }) {
    final domainKey = domainSelection.domainKey;

    return Map.unmodifiable({
      if (statusOption != BillingReleaseProfileStatusFilterOption.all)
        statusQueryKey: statusOption.name,
      if (domainKey != null) domainQueryKey: domainKey,
    });
  }

  BillingDiagnosticsReleaseProfileFilterState copyWith({
    BillingReleaseProfileStatusFilterOption? statusOption,
    BillingReleaseProfileDomainFilterSelection? domainSelection,
  }) {
    return BillingDiagnosticsReleaseProfileFilterState(
      statusOption: statusOption ?? this.statusOption,
      domainSelection: domainSelection ?? this.domainSelection,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BillingDiagnosticsReleaseProfileFilterState &&
        other.statusOption == statusOption &&
        other.domainSelection == domainSelection;
  }

  @override
  int get hashCode => Object.hash(statusOption, domainSelection);
}

/// Controller for diagnostics release profile status and domain filters.
class BillingDiagnosticsReleaseProfileFilterController
    extends Notifier<BillingDiagnosticsReleaseProfileFilterState> {
  final BillingDiagnosticsReleaseProfileFilterScope scope;

  BillingDiagnosticsReleaseProfileFilterController(this.scope);

  @override
  BillingDiagnosticsReleaseProfileFilterState build() {
    return const BillingDiagnosticsReleaseProfileFilterState();
  }

  void selectStatusOption(BillingReleaseProfileStatusFilterOption option) {
    state = state.copyWith(statusOption: option);
  }

  void selectDomain(BillingReleaseProfileDomainFilterSelection selection) {
    state = state.copyWith(domainSelection: selection);
  }

  void hydrate(BillingDiagnosticsReleaseProfileFilterState filterState) {
    if (state == filterState) return;

    state = filterState;
  }

  void hydrateFromQueryParameters(
    Map<String, String> queryParameters, {
    String statusQueryKey = billingDiagnosticsReleaseProfileStatusQueryKey,
    String domainQueryKey = billingDiagnosticsReleaseProfileDomainQueryKey,
  }) {
    hydrate(
      BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters(
        queryParameters,
        statusQueryKey: statusQueryKey,
        domainQueryKey: domainQueryKey,
      ),
    );
  }

  void clearFilters() {
    state = const BillingDiagnosticsReleaseProfileFilterState();
  }
}

/// Reusable state and action binding for diagnostics release profile filters.
class BillingDiagnosticsReleaseProfileFilterBinding {
  final BillingDiagnosticsReleaseProfileFilterScope scope;
  final BillingDiagnosticsReleaseProfileFilterState state;
  final void Function(BillingReleaseProfileStatusFilterOption option)
  selectStatusOption;
  final void Function(BillingReleaseProfileDomainFilterSelection selection)
  selectDomainSelection;
  final void Function() clearFilters;

  const BillingDiagnosticsReleaseProfileFilterBinding({
    required this.scope,
    required this.state,
    required this.selectStatusOption,
    required this.selectDomainSelection,
    required this.clearFilters,
  });

  bool get hasActiveFilters => state.hasActiveFilters;
}

/// Read-only release profile filter summary for compact diagnostics surfaces.
class BillingDiagnosticsReleaseProfileFilterSnapshot {
  final BillingDiagnosticsReleaseProfileFilterScope scope;
  final BillingDiagnosticsReleaseProfileFilterState state;

  const BillingDiagnosticsReleaseProfileFilterSnapshot({
    required this.scope,
    required this.state,
  });

  factory BillingDiagnosticsReleaseProfileFilterSnapshot.fromBinding(
    BillingDiagnosticsReleaseProfileFilterBinding binding,
  ) {
    return BillingDiagnosticsReleaseProfileFilterSnapshot(
      scope: binding.scope,
      state: binding.state,
    );
  }

  bool get hasActiveFilters => state.hasActiveFilters;

  int get activeFilterCount {
    var count = 0;
    if (state.statusOption != BillingReleaseProfileStatusFilterOption.all) {
      count += 1;
    }
    if (!state.domainSelection.isAll) count += 1;

    return count;
  }

  String get countLabel {
    final count = activeFilterCount;
    return count == 1 ? '1 filter' : '$count filters';
  }

  String get statusLabel {
    return switch (state.statusOption) {
      BillingReleaseProfileStatusFilterOption.all => 'All profile statuses',
      BillingReleaseProfileStatusFilterOption.tailored => 'Tailored',
      BillingReleaseProfileStatusFilterOption.constrained => 'Constrained',
      BillingReleaseProfileStatusFilterOption.extended => 'Extended',
      BillingReleaseProfileStatusFilterOption.standard => 'Standard',
    };
  }

  String get domainLabel {
    final domain = state.domainSelection.domainKey;
    if (domain == null) return 'All domains';

    return _releaseProfileDomainLabel(domain);
  }

  List<String> get activeFilterLabels {
    final labels = <String>[];

    if (state.statusOption != BillingReleaseProfileStatusFilterOption.all) {
      labels.add('Status: $statusLabel');
    }
    if (!state.domainSelection.isAll) {
      labels.add('Domain: $domainLabel');
    }

    return List.unmodifiable(labels);
  }

  String get summaryLabel {
    if (!hasActiveFilters) return 'All release profiles';

    return activeFilterLabels
        .map((label) => label.split(': ').last)
        .join(' · ');
  }

  String get detailLabel {
    if (!hasActiveFilters) return 'No release profile filters active.';

    return '$countLabel active: ${activeFilterLabels.join('; ')}.';
  }
}

/// Provides persisted release profile filter state for diagnostics screens.
final billingDiagnosticsReleaseProfileFilterProvider = NotifierProvider.family<
  BillingDiagnosticsReleaseProfileFilterController,
  BillingDiagnosticsReleaseProfileFilterState,
  BillingDiagnosticsReleaseProfileFilterScope
>(BillingDiagnosticsReleaseProfileFilterController.new);

/// Provides the release profile filter scope for the active diagnostics context.
final billingDiagnosticsReleaseProfileFilterScopeProvider =
    Provider<BillingDiagnosticsReleaseProfileFilterScope>((ref) {
      final screenContext = ref.watch(billingDiagnosticsScreenContextProvider);

      return BillingDiagnosticsReleaseProfileFilterScope(
        tenantId: screenContext.selectedTenant?.id ?? '',
        businessDomain: screenContext.overview.businessDomain,
      );
    });

/// Provides the current diagnostics release profile filter state and actions.
final billingDiagnosticsReleaseProfileFilterBindingProvider = Provider<
  BillingDiagnosticsReleaseProfileFilterBinding
>((ref) {
  final scope = ref.watch(billingDiagnosticsReleaseProfileFilterScopeProvider);
  final filterProvider = billingDiagnosticsReleaseProfileFilterProvider(scope);
  final state = ref.watch(filterProvider);
  final controller = ref.read(filterProvider.notifier);

  return BillingDiagnosticsReleaseProfileFilterBinding(
    scope: scope,
    state: state,
    selectStatusOption: controller.selectStatusOption,
    selectDomainSelection: controller.selectDomain,
    clearFilters: controller.clearFilters,
  );
});

/// Provides compact active-filter metadata for diagnostics shell UI.
final billingDiagnosticsReleaseProfileFilterSnapshotProvider =
    Provider<BillingDiagnosticsReleaseProfileFilterSnapshot>((ref) {
      final binding = ref.watch(
        billingDiagnosticsReleaseProfileFilterBindingProvider,
      );

      return BillingDiagnosticsReleaseProfileFilterSnapshot.fromBinding(
        binding,
      );
    });

String _releaseProfileDomainLabel(String businessDomain) {
  final key = billingBusinessDomainKey(businessDomain);
  if (key.isEmpty) return 'All domains';

  return key
      .split(RegExp(r'[-_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

BillingReleaseProfileStatusFilterOption _releaseProfileStatusOptionFromQuery(
  String? value,
) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return BillingReleaseProfileStatusFilterOption.all;
  }

  for (final option in BillingReleaseProfileStatusFilterOption.values) {
    if (option.name == normalized) return option;
  }

  return BillingReleaseProfileStatusFilterOption.all;
}

BillingReleaseProfileDomainFilterSelection
_releaseProfileDomainSelectionFromQuery(String? value) {
  final normalized = billingBusinessDomainKey(value ?? '');
  if (normalized.isEmpty) {
    return const BillingReleaseProfileDomainFilterSelection.all();
  }

  return BillingReleaseProfileDomainFilterSelection.domain(normalized);
}
