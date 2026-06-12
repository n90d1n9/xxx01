import 'package:flutter/material.dart';

/// Lays out panel controls, empty states, and filtered results consistently.
class RestaurantFilteredPanelBody extends StatelessWidget {
  const RestaurantFilteredPanelBody({
    super.key,
    required this.hasItems,
    required this.hasVisibleItems,
    required this.emptyState,
    required this.controls,
    required this.emptyResultsState,
    required this.results,
    this.resultsSpacing = 16,
  });

  final bool hasItems;
  final bool hasVisibleItems;
  final Widget emptyState;
  final Widget controls;
  final Widget emptyResultsState;
  final Widget results;
  final double resultsSpacing;

  @override
  Widget build(BuildContext context) {
    if (!hasItems) return emptyState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controls,
        SizedBox(height: resultsSpacing),
        if (hasVisibleItems) results else emptyResultsState,
      ],
    );
  }
}
