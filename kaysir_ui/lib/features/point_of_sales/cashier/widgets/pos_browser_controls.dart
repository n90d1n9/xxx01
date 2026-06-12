import 'package:flutter/material.dart';

import '../utils/pos_browser_filter_search_state.dart';
import 'pos_filter_search_field.dart';
import 'pos_search_summary_notice.dart';
import 'pos_segmented_filter_bar.dart';
import 'pos_ui.dart';

class POSBrowserSearchSummary {
  final String title;
  final String message;
  final String clearActionLabel;
  final VoidCallback onClear;
  final String? recoveryActionLabel;
  final VoidCallback? onRecover;
  final Key? clearActionKey;
  final Key? recoveryActionKey;

  const POSBrowserSearchSummary({
    required this.title,
    required this.message,
    required this.clearActionLabel,
    required this.onClear,
    this.recoveryActionLabel,
    this.onRecover,
    this.clearActionKey,
    this.recoveryActionKey,
  });

  static POSBrowserSearchSummary fromFilterSearchState<T extends Object>({
    required POSBrowserFilterSearchState<T> state,
    required VoidCallback onClear,
    required ValueChanged<T> onRecoverFilter,
    Key? clearActionKey,
    Key? recoveryActionKey,
  }) {
    final recoveryFilter = state.searchRecoveryFilter;

    return POSBrowserSearchSummary(
      title: state.searchSummaryTitle,
      message: state.searchSummaryMessage,
      clearActionLabel: state.searchSummaryActionLabel,
      clearActionKey: clearActionKey,
      recoveryActionKey: recoveryActionKey,
      recoveryActionLabel:
          state.hasSearchRecoveryAction
              ? state.searchRecoveryActionLabel
              : null,
      onClear: onClear,
      onRecover:
          recoveryFilter == null ? null : () => onRecoverFilter(recoveryFilter),
    );
  }
}

class POSBrowserControls<T extends Object> extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHintText;
  final ValueChanged<String> onSearchChanged;
  final T selectedFilter;
  final List<POSSegmentedFilterOption<T>> filterOptions;
  final ValueChanged<T> onFilterSelected;
  final POSBrowserSearchSummary? searchSummary;
  final Key? filterScrollKey;

  const POSBrowserControls({
    super.key,
    required this.searchController,
    required this.searchHintText,
    required this.onSearchChanged,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterSelected,
    this.searchSummary,
    this.filterScrollKey,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = filterOptions.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasFilters) ...[
          POSSegmentedFilterBar<T>(
            scrollKey: filterScrollKey,
            selectedValue: selectedFilter,
            options: filterOptions,
            onSelected: onFilterSelected,
          ),
          const SizedBox(height: 12),
        ],
        POSFilterSearchField(
          controller: searchController,
          hintText: searchHintText,
          onChanged: onSearchChanged,
        ),
        if (searchSummary != null) ...[
          const SizedBox(height: POSUiTokens.gap),
          POSSearchSummaryNotice(
            title: searchSummary!.title,
            message: searchSummary!.message,
            clearActionLabel: searchSummary!.clearActionLabel,
            clearActionKey: searchSummary!.clearActionKey,
            recoveryActionKey: searchSummary!.recoveryActionKey,
            recoveryActionLabel: searchSummary!.recoveryActionLabel,
            onClear: searchSummary!.onClear,
            onRecover: searchSummary!.onRecover,
          ),
        ],
      ],
    );
  }
}
