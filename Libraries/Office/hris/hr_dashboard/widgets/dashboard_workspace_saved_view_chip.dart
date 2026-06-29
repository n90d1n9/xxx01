import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_saved_view.dart';

class DashboardWorkspaceSavedViewChip extends StatelessWidget {
  final DashboardWorkspaceSavedView view;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;

  const DashboardWorkspaceSavedViewChip({
    super.key,
    required this.view,
    required this.count,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? HrisColors.primary : HrisColors.ink;
    final borderColor = isSelected ? HrisColors.primary : HrisColors.border;

    return Tooltip(
      message: view.description,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onSelected,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54, maxWidth: 230),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? HrisColors.primary.withValues(alpha: 0.08)
                    : HrisColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(view.icon, color: foreground, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      view.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dashboardWorkspaceSavedViewCountLabel(count),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle_rounded,
                  color: HrisColors.primary,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String dashboardWorkspaceSavedViewCountLabel(int count) {
  return '$count ${count == 1 ? 'workspace' : 'workspaces'}';
}
