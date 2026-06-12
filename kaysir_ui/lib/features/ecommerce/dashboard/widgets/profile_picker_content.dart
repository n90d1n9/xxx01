import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_filter_search_field.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile.dart';
import '../models/product_profile_search.dart';
import '../models/product_profile_search_suggestion.dart';
import 'active_profile_summary.dart';
import 'profile_search_match_type_filter_bar.dart';
import 'profile_search_results_panel.dart';
import 'profile_search_suggestions.dart';

class ProfilePickerContent extends StatelessWidget {
  const ProfilePickerContent({
    required this.searchController,
    required this.activeProfile,
    required this.profiles,
    required this.query,
    required this.selectedMatchTypes,
    required this.results,
    required this.suggestions,
    required this.onQueryChanged,
    required this.onMatchTypesChanged,
    required this.onProfileSelected,
    this.onProfileDetailsRequested,
    super.key,
  });

  final TextEditingController searchController;
  final ProductProfile activeProfile;
  final List<ProductProfile> profiles;
  final String query;
  final Set<ProductProfileSearchMatchType> selectedMatchTypes;
  final List<ProductProfileSearchResult> results;
  final List<ProductProfileSearchSuggestion> suggestions;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Set<ProductProfileSearchMatchType>> onMatchTypesChanged;
  final ValueChanged<String> onProfileSelected;
  final ValueChanged<String>? onProfileDetailsRequested;

  @override
  Widget build(BuildContext context) {
    final showMatchFilters = query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActiveProfileSummary(profile: activeProfile),
        const SizedBox(height: POSUiTokens.gapLarge),
        POSFilterSearchField(
          key: const ValueKey('profile_search'),
          controller: searchController,
          hintText: 'Search profiles, channels, rules, or playbooks',
          onChanged: onQueryChanged,
        ),
        if (query.trim().isEmpty && suggestions.isNotEmpty) ...[
          const SizedBox(height: POSUiTokens.gap),
          ProfileSearchSuggestions(
            suggestions: suggestions,
            onSuggestionSelected: _selectSuggestion,
          ),
        ],
        if (showMatchFilters) ...[
          const SizedBox(height: POSUiTokens.gap),
          ProfileSearchMatchTypeFilterBar(
            selectedTypes: selectedMatchTypes,
            onChanged: onMatchTypesChanged,
          ),
        ],
        const SizedBox(height: POSUiTokens.gapLarge),
        Expanded(
          child: ProfileSearchResultsPanel(
            results: results,
            totalProfileCount: profiles.length,
            activeProfileId: activeProfile.id,
            query: query,
            onProfileSelected: onProfileSelected,
            onProfileDetailsRequested: onProfileDetailsRequested,
          ),
        ),
      ],
    );
  }

  void _selectSuggestion(String query) {
    searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    onQueryChanged(query);
  }
}
