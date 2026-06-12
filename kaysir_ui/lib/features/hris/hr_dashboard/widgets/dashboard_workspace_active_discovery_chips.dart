import 'package:flutter/material.dart';

import '../models/dashboard_workspace_filter.dart';
import '../models/dashboard_workspace_query.dart';
import '../models/dashboard_workspace_sort.dart';
import 'dashboard_workspace_discovery_chip.dart';

class DashboardWorkspaceActiveDiscoveryChips extends StatelessWidget {
  final DashboardWorkspaceQuery query;
  final VoidCallback onClearSearch;
  final VoidCallback onClearFilter;
  final VoidCallback onClearSort;
  final bool emphasized;

  const DashboardWorkspaceActiveDiscoveryChips({
    super.key,
    required this.query,
    required this.onClearSearch,
    required this.onClearFilter,
    required this.onClearSort,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (query.hasSearch)
          DashboardWorkspaceDiscoveryChip(
            icon: Icons.search_outlined,
            label: 'Search: ${query.searchText.trim()}',
            emphasized: emphasized,
            clearTooltip: 'Remove search constraint',
            onClear: onClearSearch,
          ),
        if (query.hasActiveFilter)
          DashboardWorkspaceDiscoveryChip(
            icon: Icons.filter_alt_outlined,
            label: 'Filter: ${query.filter.nameLabel}',
            emphasized: emphasized,
            clearTooltip: 'Remove workspace filter',
            onClear: onClearFilter,
          ),
        if (query.hasActiveSort)
          DashboardWorkspaceDiscoveryChip(
            icon: Icons.sort_rounded,
            label: '${query.sort.label} order',
            emphasized: emphasized,
            clearTooltip: 'Remove workspace sort',
            onClear: onClearSort,
          ),
      ],
    );
  }
}
