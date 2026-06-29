import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';
import 'dashboard_workspace_card_parts.dart';

class DashboardWorkspaceCard extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('workspace-card-${entry.path}'),
      color: HrisColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(entry.path),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: hrisPanelDecoration(color: Colors.transparent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardWorkspaceCardHeader(entry: entry),
              const Spacer(),
              DashboardWorkspaceCardMetrics(entry: entry),
            ],
          ),
        ),
      ),
    );
  }
}
