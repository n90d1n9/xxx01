import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_discovery_scope.dart';
import '../models/dashboard_workspace_query.dart';
import 'dashboard_workspace_active_discovery_chips.dart';
import 'dashboard_workspace_scope_meter.dart';

class DashboardWorkspaceResultsSummary extends StatelessWidget {
  final int visibleCount;
  final int totalCount;
  final DashboardWorkspaceQuery query;
  final VoidCallback onReset;
  final VoidCallback onClearSearch;
  final VoidCallback onClearFilter;
  final VoidCallback onClearSort;

  const DashboardWorkspaceResultsSummary({
    super.key,
    required this.visibleCount,
    required this.totalCount,
    required this.query,
    required this.onReset,
    required this.onClearSearch,
    required this.onClearFilter,
    required this.onClearSort,
  });

  @override
  Widget build(BuildContext context) {
    final scope = DashboardWorkspaceDiscoveryScope.fromQuery(
      query: query,
      visibleCount: visibleCount,
      totalCount: totalCount,
    );

    return HrisListSurface(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DashboardWorkspaceScopeMeter(scope: scope),
          _ResultCount(visibleCount: visibleCount, totalCount: totalCount),
          if (query.hasActiveDiscovery)
            DashboardWorkspaceActiveDiscoveryChips(
              query: query,
              emphasized: true,
              onClearSearch: onClearSearch,
              onClearFilter: onClearFilter,
              onClearSort: onClearSort,
            ),
          if (query.hasActiveDiscovery)
            Tooltip(
              message: 'Reset workspace discovery',
              child: TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('Reset'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  final int visibleCount;
  final int totalCount;

  const _ResultCount({required this.visibleCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: Text(
        'Showing $visibleCount of $totalCount workspaces',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: HrisColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
