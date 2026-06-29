import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_discovery_scope.dart';

class DashboardWorkspaceScopeMeter extends StatelessWidget {
  final DashboardWorkspaceDiscoveryScope scope;

  const DashboardWorkspaceScopeMeter({super.key, required this.scope});

  @override
  Widget build(BuildContext context) {
    final color = scope.isRiskFocused ? Colors.red[700]! : HrisColors.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 42, maxWidth: 360),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              scope.isRiskFocused
                  ? Icons.track_changes_outlined
                  : Icons.manage_search_outlined,
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scope.modeLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: scope.coverage,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  scope.detailLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
