import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_empty_guidance.dart';
import '../models/dashboard_workspace_query.dart';
import 'dashboard_workspace_active_discovery_chips.dart';
import 'dashboard_workspace_recovery_options.dart';

class DashboardWorkspaceEmptyState extends StatelessWidget {
  final DashboardWorkspaceQuery query;
  final VoidCallback onReset;
  final VoidCallback onClearSearch;
  final VoidCallback onClearFilter;
  final VoidCallback onClearSort;

  const DashboardWorkspaceEmptyState({
    super.key,
    required this.query,
    required this.onReset,
    required this.onClearSearch,
    required this.onClearFilter,
    required this.onClearSort,
  });

  @override
  Widget build(BuildContext context) {
    final guidance = DashboardWorkspaceEmptyGuidance.fromQuery(query);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.manage_search_outlined,
                  color: HrisColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guidance.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      guidance.message,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (guidance.options.isNotEmpty) ...[
            const SizedBox(height: 14),
            DashboardWorkspaceRecoveryOptions(
              options: guidance.options,
              onAction: _handleRecoveryAction,
            ),
          ],
          if (query.hasActiveDiscovery) ...[
            const SizedBox(height: 12),
            DashboardWorkspaceActiveDiscoveryChips(
              query: query,
              onClearSearch: onClearSearch,
              onClearFilter: onClearFilter,
              onClearSort: onClearSort,
            ),
          ],
        ],
      ),
    );
  }

  VoidCallback _handleRecoveryAction(DashboardWorkspaceRecoveryAction action) {
    switch (action) {
      case DashboardWorkspaceRecoveryAction.clearSearch:
        return onClearSearch;
      case DashboardWorkspaceRecoveryAction.clearFilter:
        return onClearFilter;
      case DashboardWorkspaceRecoveryAction.clearSort:
        return onClearSort;
      case DashboardWorkspaceRecoveryAction.reset:
        return onReset;
    }
  }
}
