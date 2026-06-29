import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_saved_view.dart';
import 'dashboard_workspace_saved_view_chip.dart';

class DashboardWorkspaceSavedViews extends StatelessWidget {
  final List<DashboardWorkspaceSavedView> views;
  final DashboardWorkspaceSavedView? activeView;
  final List<DashboardWorkspaceEntry> entries;
  final ValueChanged<DashboardWorkspaceSavedView> onSelected;

  const DashboardWorkspaceSavedViews({
    super.key,
    required this.views,
    required this.activeView,
    required this.entries,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bookmark_border_rounded,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Saved views',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                views.map((view) {
                  final isSelected = activeView?.id == view.id;
                  return DashboardWorkspaceSavedViewChip(
                    view: view,
                    count: view.visibleCountFor(entries),
                    isSelected: isSelected,
                    onSelected: () => onSelected(view),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
