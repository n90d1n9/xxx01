import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'models/profile_comparison.dart';
import 'models/profile_registry_overview.dart';
import 'models/product_profile.dart';
import 'models/product_profile_search.dart';
import 'models/product_profile_search_suggestion.dart';
import 'states/workspace_provider.dart';
import 'widgets/adaptive_two_pane.dart';
import 'widgets/product_profile_details_dialog.dart';
import 'widgets/profile_registry_control_panel.dart';
import 'widgets/profile_search_results_panel.dart';

const _profileRegistrySearchScopeId = 'profile_registry';

class ProfileRegistryScreen extends ConsumerStatefulWidget {
  static const routePath = Routes.profileRegistryPath;

  const ProfileRegistryScreen({super.key});

  @override
  ConsumerState<ProfileRegistryScreen> createState() =>
      _ProfileRegistryScreenState();
}

class _ProfileRegistryScreenState extends ConsumerState<ProfileRegistryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref
        .read(
          productProfileSearchQueryProvider(
            _profileRegistrySearchScopeId,
          ).notifier,
        )
        .state = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registryOverview = ref.watch(profileRegistryOverviewProvider);
    final comparisonRows = ref.watch(
      profileSearchComparisonRowsProvider(_profileRegistrySearchScopeId),
    );
    final activeProfile = ref.watch(productProfileProvider);
    final activeProfileId = ref.watch(productProfileIdProvider);
    final query = ref.watch(
      productProfileSearchQueryProvider(_profileRegistrySearchScopeId),
    );
    final selectedMatchTypes = ref.watch(
      productProfileSearchMatchTypesProvider(_profileRegistrySearchScopeId),
    );
    final results = ref.watch(
      productProfileSearchResultsProvider(_profileRegistrySearchScopeId),
    );
    final suggestions = ref.watch(
      productProfileSearchSuggestionsProvider(_profileRegistrySearchScopeId),
    );

    return Scaffold(
      key: const ValueKey('profile_registry_screen'),
      appBar: AppBar(
        title: const Text(
          'Profile Registry',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _RegistryResponsiveLayout(
            activeProfile: activeProfile,
            activeProfileId: activeProfileId,
            registryOverview: registryOverview,
            comparisonRows: comparisonRows,
            query: query,
            selectedMatchTypes: selectedMatchTypes,
            results: results,
            suggestions: suggestions,
            searchController: _searchController,
            onQueryChanged: _setQuery,
            onMatchTypesChanged: _setMatchTypes,
            onSuggestionSelected: _selectSuggestion,
            onProfileSelected: _selectProfile,
            onProfileDetailsRequested: _showProfileDetails,
          ),
        ),
      ),
    );
  }

  void _selectProfile(String profileId) {
    ref.read(productProfileIdProvider.notifier).selectProfile(profileId);
  }

  void _showProfileDetails(String profileId) {
    final profile = productProfileFor(
      profiles: ref.read(productProfilesProvider),
      profileId: profileId,
    );
    final activeProfileId = ref.read(productProfileIdProvider);

    showProductProfileDetailsDialog(
      context: context,
      profile: profile,
      selected: profile.id == activeProfileId,
      onProfileSelected: _selectProfile,
      onOpenOrderWorkspace: _openOrderWorkspace,
    );
  }

  void _openOrderWorkspace(String routePath) {
    context.go(routePath);
  }

  void _selectSuggestion(String query) {
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _setQuery(query);
  }

  void _setQuery(String query) {
    ref
        .read(
          productProfileSearchQueryProvider(
            _profileRegistrySearchScopeId,
          ).notifier,
        )
        .state = query;
  }

  void _setMatchTypes(Set<ProductProfileSearchMatchType> matchTypes) {
    ref
        .read(
          productProfileSearchMatchTypesProvider(
            _profileRegistrySearchScopeId,
          ).notifier,
        )
        .state = matchTypes;
  }
}

class _RegistryResponsiveLayout extends StatelessWidget {
  final ProductProfile activeProfile;
  final String activeProfileId;
  final ProfileRegistryOverview registryOverview;
  final List<ProfileComparisonRow> comparisonRows;
  final String query;
  final Set<ProductProfileSearchMatchType> selectedMatchTypes;
  final List<ProductProfileSearchResult> results;
  final List<ProductProfileSearchSuggestion> suggestions;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Set<ProductProfileSearchMatchType>> onMatchTypesChanged;
  final ValueChanged<String> onSuggestionSelected;
  final ValueChanged<String> onProfileSelected;
  final ValueChanged<String> onProfileDetailsRequested;

  const _RegistryResponsiveLayout({
    required this.activeProfile,
    required this.activeProfileId,
    required this.registryOverview,
    required this.comparisonRows,
    required this.query,
    required this.selectedMatchTypes,
    required this.results,
    required this.suggestions,
    required this.searchController,
    required this.onQueryChanged,
    required this.onMatchTypesChanged,
    required this.onSuggestionSelected,
    required this.onProfileSelected,
    required this.onProfileDetailsRequested,
  });

  @override
  Widget build(BuildContext context) {
    final controlPanel = ProfileRegistryControlPanel(
      activeProfile: activeProfile,
      activeProfileId: activeProfileId,
      registryOverview: registryOverview,
      comparisonRows: comparisonRows,
      query: query,
      selectedMatchTypes: selectedMatchTypes,
      searchController: searchController,
      suggestions: suggestions,
      onQueryChanged: onQueryChanged,
      onMatchTypesChanged: onMatchTypesChanged,
      onSuggestionSelected: onSuggestionSelected,
      onProfileSelected: onProfileSelected,
      onProfileDetailsRequested: onProfileDetailsRequested,
    );
    final resultsPanel = ProfileSearchResultsPanel(
      results: results,
      totalProfileCount: registryOverview.profileCount,
      activeProfileId: activeProfileId,
      query: query,
      onProfileSelected: onProfileSelected,
      onProfileDetailsRequested: onProfileDetailsRequested,
    );

    return AdaptiveTwoPane(
      key: const ValueKey('profile_registry_layout'),
      leadingPane: controlPanel,
      mainPane: resultsPanel,
    );
  }
}
