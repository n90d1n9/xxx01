import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile_search.dart';
import 'empty_state.dart';
import 'profile_option_tile.dart';

class ProfileSearchResultsPanel extends StatelessWidget {
  final List<ProductProfileSearchResult> results;
  final int totalProfileCount;
  final String activeProfileId;
  final String query;
  final ValueChanged<String> onProfileSelected;
  final ValueChanged<String>? onProfileDetailsRequested;

  const ProfileSearchResultsPanel({
    super.key,
    required this.results,
    required this.totalProfileCount,
    required this.activeProfileId,
    required this.query,
    required this.onProfileSelected,
    this.onProfileDetailsRequested,
  }) : assert(totalProfileCount >= 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileSearchCountLabel(
          visibleCount: results.length,
          totalCount: totalProfileCount,
          query: query,
        ),
        const SizedBox(height: POSUiTokens.gap),
        Expanded(
          child:
              results.isEmpty
                  ? EmptyProfileSearch(query: query)
                  : ProfileSearchResultList(
                    results: results,
                    activeProfileId: activeProfileId,
                    onProfileSelected: onProfileSelected,
                    onProfileDetailsRequested: onProfileDetailsRequested,
                  ),
        ),
      ],
    );
  }
}

class ProfileSearchResultList extends StatelessWidget {
  final List<ProductProfileSearchResult> results;
  final String activeProfileId;
  final ValueChanged<String> onProfileSelected;
  final ValueChanged<String>? onProfileDetailsRequested;

  const ProfileSearchResultList({
    super.key,
    required this.results,
    required this.activeProfileId,
    required this.onProfileSelected,
    this.onProfileDetailsRequested,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('profile_search_result_list'),
      child: Column(
        children: results
            .map((result) {
              final profile = result.profile;
              final selected = profile.id == activeProfileId;

              return ProfileOptionTile(
                key: ValueKey('profile_option_${profile.id}'),
                profile: profile,
                selected: selected,
                searchMatch: result.primaryMatch,
                onSelected:
                    selected ? null : () => onProfileSelected(profile.id),
                onDetailsRequested:
                    onProfileDetailsRequested == null
                        ? null
                        : () => onProfileDetailsRequested!(profile.id),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class ProfileSearchCountLabel extends StatelessWidget {
  final int visibleCount;
  final int totalCount;
  final String query;

  const ProfileSearchCountLabel({
    super.key,
    required this.visibleCount,
    required this.totalCount,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasQuery = query.trim().isNotEmpty;
    final label =
        hasQuery
            ? '$visibleCount of $totalCount profiles'
            : '$totalCount profile presets';

    return Text(
      label,
      key: const ValueKey('profile_result_count'),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class EmptyProfileSearch extends StatelessWidget {
  final String query;

  const EmptyProfileSearch({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    final label =
        trimmedQuery.isEmpty
            ? 'No profile presets available.'
            : 'No profiles match "$trimmedQuery".';

    return EmptyState(
      key: const ValueKey('profile_empty_search'),
      message: label,
      centered: true,
      prominent: true,
    );
  }
}
