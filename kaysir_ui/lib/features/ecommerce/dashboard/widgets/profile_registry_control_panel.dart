import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_filter_search_field.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/profile_comparison.dart';
import '../models/profile_registry_overview.dart';
import '../models/product_profile.dart';
import '../models/product_profile_search.dart';
import '../models/product_profile_search_suggestion.dart';
import '../models/product_profile_signal_visibility.dart';
import 'chip_tone.dart';
import 'panel_header.dart';
import 'panel_surface.dart';
import 'profile_comparison_matrix.dart';
import 'product_profile_summary.dart';
import 'profile_registry_insights.dart';
import 'profile_registry_overview_strip.dart';
import 'profile_search_match_type_filter_bar.dart';
import 'profile_search_suggestions.dart';
import 'text_badge.dart';
import 'tone.dart';

class ProfileRegistryControlPanel extends StatelessWidget {
  final ProductProfile activeProfile;
  final String activeProfileId;
  final ProfileRegistryOverview registryOverview;
  final List<ProfileComparisonRow> comparisonRows;
  final String query;
  final Set<ProductProfileSearchMatchType> selectedMatchTypes;
  final TextEditingController searchController;
  final List<ProductProfileSearchSuggestion> suggestions;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Set<ProductProfileSearchMatchType>> onMatchTypesChanged;
  final ValueChanged<String> onSuggestionSelected;
  final ValueChanged<String> onProfileSelected;
  final ValueChanged<String>? onProfileDetailsRequested;

  const ProfileRegistryControlPanel({
    super.key,
    required this.activeProfile,
    required this.activeProfileId,
    required this.registryOverview,
    required this.comparisonRows,
    required this.query,
    required this.selectedMatchTypes,
    required this.searchController,
    required this.suggestions,
    required this.onQueryChanged,
    required this.onMatchTypesChanged,
    required this.onSuggestionSelected,
    required this.onProfileSelected,
    this.onProfileDetailsRequested,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showSuggestions = query.trim().isEmpty && suggestions.isNotEmpty;
    final showMatchFilters = query.trim().isNotEmpty;

    return PanelSurface(
      key: const ValueKey('profile_registry_control_panel'),
      padding: const EdgeInsets.all(16),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          PanelHeader(
            icon: Icons.view_quilt_outlined,
            title: 'Product profiles',
            subtitle:
                'Reusable commerce behavior presets for channels, checkout, fulfillment, and layouts.',
            tone: VisualTone.primary,
            trailing: _ProfileCountBadge(
              profileCount: registryOverview.profileCount,
            ),
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          ProfileRegistryOverviewStrip(overview: registryOverview),
          const SizedBox(height: POSUiTokens.gapLarge),
          POSFilterSearchField(
            key: const ValueKey('profile_registry_search'),
            controller: searchController,
            hintText: 'Search profiles, channels, rules, or playbooks',
            onChanged: onQueryChanged,
          ),
          if (showSuggestions) ...[
            const SizedBox(height: POSUiTokens.gap),
            ProfileSearchSuggestions(
              suggestions: suggestions,
              onSuggestionSelected: onSuggestionSelected,
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
          ProfileComparisonMatrix(
            rows: comparisonRows,
            activeProfileId: activeProfileId,
            totalProfileCount: registryOverview.profileCount,
            query: query,
            onProfileSelected: onProfileSelected,
            onProfileDetailsRequested: onProfileDetailsRequested,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          Divider(height: 1, color: theme.dividerColor),
          const SizedBox(height: POSUiTokens.gapLarge),
          ProductProfileSummary(
            profile: activeProfile,
            eyebrow: 'Current profile',
            chipLimits: ProductProfileChipLimits.active,
            signalVisibility: ProductProfileSignalVisibility.detailed,
            titleMaxLines: 2,
            descriptionMaxLines: 3,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          ProfileRegistryInsights(profile: activeProfile),
        ],
      ),
    );
  }
}

class _ProfileCountBadge extends StatelessWidget {
  final int profileCount;

  const _ProfileCountBadge({required this.profileCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = tonalChipColors(
      theme.colorScheme,
      VisualTone.primary,
      backgroundAlpha: 0.1,
      borderAlpha: 0.18,
      backgroundSource: ToneBackgroundSource.foreground,
    );

    return TextBadge(
      label: '$profileCount presets',
      colors: colors,
      fontWeight: FontWeight.w900,
    );
  }
}
