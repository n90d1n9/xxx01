import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/product_profile_search_suggestion.dart';
import 'action_chip.dart';
import 'profile_search_tone.dart';

class ProfileSearchSuggestions extends StatelessWidget {
  final List<ProductProfileSearchSuggestion> suggestions;
  final ValueChanged<String> onSuggestionSelected;

  const ProfileSearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      key: const ValueKey('profile_search_suggestions'),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions
            .map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(right: POSUiTokens.gap),
                child: _SearchSuggestionChip(
                  suggestion: suggestion,
                  onSelected: () => onSuggestionSelected(suggestion.query),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _SearchSuggestionChip extends StatelessWidget {
  final ProductProfileSearchSuggestion suggestion;
  final VoidCallback onSelected;

  const _SearchSuggestionChip({
    required this.suggestion,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = profileSearchSuggestionColors(
      Theme.of(context).colorScheme,
      suggestion.matchType,
    );

    return EcommerceWorkspaceActionChip(
      key: ValueKey('profile_search_suggestion_${suggestion.query}'),
      icon: profileSearchIcon(suggestion.matchType),
      label: suggestion.label,
      tooltip: 'Search ${suggestion.label}',
      colors: colors,
      onPressed: onSelected,
    );
  }
}
