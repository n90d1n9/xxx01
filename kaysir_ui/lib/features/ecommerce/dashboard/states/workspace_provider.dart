import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../cart/states/cart_providers.dart';
import '../../order/states/order_fulfillment_promise_policy_provider.dart';
import '../../order/states/order_provider.dart';
import '../models/action.dart';
import '../models/channel_requirement.dart';
import '../models/channel_strategy.dart';
import '../models/destination.dart';
import '../models/health.dart';
import '../models/module.dart';
import '../models/overview.dart';
import '../models/presentation_profile.dart';
import '../models/profile_comparison.dart';
import '../models/profile_registry_overview.dart';
import '../models/product_profile.dart';
import '../models/product_profile_search.dart';
import '../models/product_profile_search_suggestion.dart';
import '../models/registry_diagnostics.dart';
import '../models/view_state.dart';
import '../repositories/workspace_profile_preferences_repository.dart';

final overviewProvider = Provider<Overview>(
  (ref) => Overview.fromState(
    orders: ref.watch(ecommerceOrdersProvider),
    cartItems: ref.watch(cartProvider),
    promisePolicyIssueCount:
        ref.watch(ecommerceOrderFulfillmentPromisePolicyIssuesProvider).length,
  ),
);

final productProfilesProvider = Provider<List<ProductProfile>>(
  (ref) => defaultProductProfiles,
);

final profileRegistryOverviewProvider = Provider<ProfileRegistryOverview>((
  ref,
) {
  return ProfileRegistryOverview.fromProfiles(
    ref.watch(productProfilesProvider),
  );
});

final profileComparisonRowsProvider = Provider<List<ProfileComparisonRow>>((
  ref,
) {
  return profileComparisonRows(ref.watch(productProfilesProvider));
});

final productProfileSearchProfilesProvider =
    Provider.family<List<ProductProfile>, String>(
      (ref, scopeId) => ref.watch(productProfilesProvider),
    );

final productProfileSearchQueryProvider = StateProvider.family<String, String>(
  (ref, scopeId) => '',
);

final productProfileSearchMatchTypesProvider =
    StateProvider.family<Set<ProductProfileSearchMatchType>, String>(
      (ref, scopeId) => const {},
    );

final productProfileSearchResultsProvider =
    Provider.family<List<ProductProfileSearchResult>, String>((ref, scopeId) {
      final query = ref.watch(productProfileSearchQueryProvider(scopeId));
      final results = productProfileSearchResults(
        profiles: ref.watch(productProfileSearchProfilesProvider(scopeId)),
        query: query,
      );
      if (normalizeProductProfileSearch(query).isEmpty) {
        return results;
      }

      return productProfileSearchResultsForMatchTypes(
        results: results,
        matchTypes: ref.watch(productProfileSearchMatchTypesProvider(scopeId)),
      );
    });

final profileSearchComparisonRowsProvider =
    Provider.family<List<ProfileComparisonRow>, String>((ref, scopeId) {
      return profileComparisonRows(
        ref
            .watch(productProfileSearchResultsProvider(scopeId))
            .map((result) => result.profile),
      );
    });

final productProfileSearchSuggestionsProvider =
    Provider.family<List<ProductProfileSearchSuggestion>, String>((
      ref,
      scopeId,
    ) {
      return productProfileSearchSuggestions(
        profiles: ref.watch(productProfileSearchProfilesProvider(scopeId)),
      );
    });

final profilePreferencesRepositoryProvider =
    Provider<ProfilePreferencesRepository>((ref) {
      return ProfilePreferencesRepository(
        store: LocalDbProfilePreferencesStore(),
      );
    });

final productProfileIdProvider =
    StateNotifierProvider<ProductProfileIdNotifier, String>((ref) {
      return ProductProfileIdNotifier(
        repository: ref.watch(profilePreferencesRepositoryProvider),
      );
    });

class ProductProfileIdNotifier extends StateNotifier<String> {
  final ProfilePreferencesRepository repository;

  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _hydrated = false;
  bool _selectionChangedBeforeHydration = false;

  ProductProfileIdNotifier({
    required this.repository,
    String initialProfileId = '',
    bool autoHydrate = true,
  }) : super(
         initialProfileId.trim().isEmpty
             ? ProductProfile.standard.id
             : initialProfileId.trim(),
       ) {
    if (autoHydrate) hydrate();
  }

  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrate();
  }

  Future<void> selectProfile(String profileId) {
    final normalizedProfileId = profileId.trim();
    if (normalizedProfileId.isEmpty || normalizedProfileId == state) {
      return Future<void>.value();
    }

    _selectionChangedBeforeHydration = !_hydrated;
    state = normalizedProfileId;

    return _persist();
  }

  Future<void> flush() {
    return _persistFuture ?? Future<void>.value();
  }

  Future<void> _hydrate() async {
    try {
      final preferences = await repository.load();
      final persistedProfileId = preferences.selectedProfileId.trim();

      if (!_selectionChangedBeforeHydration && persistedProfileId.isNotEmpty) {
        state = persistedProfileId;
      }
    } finally {
      _hydrated = true;
    }
  }

  Future<void> _persist() {
    final preferences = ProfilePreferences(selectedProfileId: state);

    return _persistFuture = repository.save(preferences).catchError((_) {});
  }
}

final productProfileProvider = Provider<ProductProfile>((ref) {
  return productProfileFor(
    profiles: ref.watch(productProfilesProvider),
    profileId: ref.watch(productProfileIdProvider),
  );
});

final productCapabilitiesProvider = Provider<List<ProductCapability>>(
  (ref) => ref.watch(productProfileProvider).capabilities,
);

final channelCoverageRequirementsProvider =
    Provider<List<ChannelCoverageRequirement>>(
      (ref) => ref.watch(productProfileProvider).channelCoverageRequirements,
    );

final channelStrategyProvider = Provider<ChannelStrategy>((ref) {
  final profile = ref.watch(productProfileProvider);

  return ChannelStrategy.fromProfile(
    profile,
    coverageRequirements: ref.watch(channelCoverageRequirementsProvider),
  );
});

final productProfileIssuesProvider = Provider<List<ProductProfileIssue>>((ref) {
  return validateProductProfiles(
    profiles: ref.watch(productProfilesProvider),
    selectedProfileId: ref.watch(productProfileIdProvider),
  );
});

final modulesProvider = Provider<List<Module>>(
  (ref) => ref.watch(productProfileProvider).modules,
);

final presentationProfileProvider = Provider<PresentationProfile>(
  (ref) => ref.watch(productProfileProvider).presentationProfile,
);

final moduleIssuesProvider = Provider<List<ModuleIssue>>((ref) {
  final overview = ref.watch(overviewProvider);
  final modules = ref.watch(modulesProvider);
  final capabilities = ref.watch(productCapabilitiesProvider);

  return validateModules(
    overview: overview,
    modules: modules,
    capabilities: capabilities,
  );
});

final healthProvider = Provider<HealthSummary>((ref) {
  final overview = ref.watch(overviewProvider);
  final productProfileIssues = ref.watch(productProfileIssuesProvider);
  final moduleIssues = ref.watch(moduleIssuesProvider);
  final actionRuleIssues = ref.watch(actionRuleIssuesProvider);
  final channelStrategy = ref.watch(channelStrategyProvider);

  return HealthSummary.fromWorkspace(
    overview: overview,
    productProfileIssues: productProfileIssues,
    moduleIssues: moduleIssues,
    actionRuleIssues: actionRuleIssues,
    channelCoverageGapCount: channelStrategy.coverageGapCount,
  );
});

final actionRulesProvider = Provider<List<ActionRule>>(
  (ref) => ref.watch(productProfileProvider).actionRules,
);

final actionRuleIssuesProvider = Provider<List<ActionRuleIssue>>((ref) {
  final overview = ref.watch(overviewProvider);
  final productProfileIssues = ref.watch(productProfileIssuesProvider);
  final moduleIssues = ref.watch(moduleIssuesProvider);
  final rules = ref.watch(actionRulesProvider);
  final capabilities = ref.watch(productCapabilitiesProvider);
  final channelStrategy = ref.watch(channelStrategyProvider);
  final baseHealth = HealthSummary.fromWorkspace(
    overview: overview,
    productProfileIssues: productProfileIssues,
    moduleIssues: moduleIssues,
    channelCoverageGapCount: channelStrategy.coverageGapCount,
  );

  return validateActionRules(
    overview: overview,
    health: baseHealth,
    rules: rules,
    capabilities: capabilities,
  );
});

final registryDiagnosticsProvider = Provider<RegistryDiagnostics>((ref) {
  final productProfileIssues = ref.watch(productProfileIssuesProvider);
  final moduleIssues = ref.watch(moduleIssuesProvider);
  final actionRuleIssues = ref.watch(actionRuleIssuesProvider);

  return RegistryDiagnostics.fromIssues(
    productProfileIssues: productProfileIssues,
    moduleIssues: moduleIssues,
    actionRuleIssues: actionRuleIssues,
  );
});

final actionsProvider = Provider<List<Action>>((ref) {
  final overview = ref.watch(overviewProvider);
  final health = ref.watch(healthProvider);
  final rules = ref.watch(actionRulesProvider);
  final capabilities = ref.watch(productCapabilitiesProvider);

  return actionsFor(
    overview: overview,
    health: health,
    rules: rules,
    capabilities: capabilities,
  );
});

final destinationsProvider = Provider<List<Destination>>((ref) {
  final overview = ref.watch(overviewProvider);
  final modules = ref.watch(modulesProvider);
  final capabilities = ref.watch(productCapabilitiesProvider);

  return destinationsForModules(
    overview: overview,
    modules: modules,
    capabilities: capabilities,
  );
});

final viewStateProvider = Provider<ViewState>((ref) {
  return ViewState(
    productProfile: ref.watch(productProfileProvider),
    channelStrategy: ref.watch(channelStrategyProvider),
    overview: ref.watch(overviewProvider),
    health: ref.watch(healthProvider),
    destinations: ref.watch(destinationsProvider),
    actions: ref.watch(actionsProvider),
    registryDiagnostics: ref.watch(registryDiagnosticsProvider),
  );
});
