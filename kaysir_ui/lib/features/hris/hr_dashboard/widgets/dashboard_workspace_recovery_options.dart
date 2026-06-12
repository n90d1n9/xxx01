import 'package:flutter/material.dart';

import '../models/dashboard_workspace_empty_guidance.dart';

class DashboardWorkspaceRecoveryOptions extends StatelessWidget {
  final List<DashboardWorkspaceRecoveryOption> options;
  final VoidCallback Function(DashboardWorkspaceRecoveryAction action) onAction;

  const DashboardWorkspaceRecoveryOptions({
    super.key,
    required this.options,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options
              .map(
                (option) => Tooltip(
                  message: option.detail,
                  child: OutlinedButton.icon(
                    onPressed: onAction(option.action),
                    icon: Icon(
                      dashboardWorkspaceRecoveryIcon(option.action),
                      size: 18,
                    ),
                    label: Text(option.label),
                  ),
                ),
              )
              .toList(),
    );
  }
}

IconData dashboardWorkspaceRecoveryIcon(
  DashboardWorkspaceRecoveryAction action,
) {
  switch (action) {
    case DashboardWorkspaceRecoveryAction.clearSearch:
      return Icons.search_off_outlined;
    case DashboardWorkspaceRecoveryAction.clearFilter:
      return Icons.filter_alt_off_outlined;
    case DashboardWorkspaceRecoveryAction.clearSort:
      return Icons.sort_by_alpha_outlined;
    case DashboardWorkspaceRecoveryAction.reset:
      return Icons.restart_alt_rounded;
  }
}
