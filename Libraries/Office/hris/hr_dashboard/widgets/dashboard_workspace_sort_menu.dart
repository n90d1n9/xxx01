import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_sort.dart';

class DashboardWorkspaceSortMenu extends StatelessWidget {
  final DashboardWorkspaceSort selectedSort;
  final ValueChanged<DashboardWorkspaceSort> onChanged;

  const DashboardWorkspaceSortMenu({
    super.key,
    required this.selectedSort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DashboardWorkspaceSort>(
      tooltip: 'Sort workspaces',
      initialValue: selectedSort,
      onSelected: onChanged,
      itemBuilder:
          (context) =>
              DashboardWorkspaceSort.values
                  .map(
                    (sort) => PopupMenuItem<DashboardWorkspaceSort>(
                      value: sort,
                      child: _SortMenuItem(
                        sort: sort,
                        isSelected: sort == selectedSort,
                      ),
                    ),
                  )
                  .toList(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: HrisColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HrisColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_sortIcon(selectedSort), size: 18, color: HrisColors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sort: ${selectedSort.label}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more_rounded, color: HrisColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortMenuItem extends StatelessWidget {
  final DashboardWorkspaceSort sort;
  final bool isSelected;

  const _SortMenuItem({required this.sort, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? HrisColors.primary : HrisColors.muted;

    return Row(
      children: [
        Icon(_sortIcon(sort), size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            sort.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        if (isSelected)
          const Icon(Icons.check_rounded, size: 18, color: HrisColors.primary),
      ],
    );
  }
}

IconData _sortIcon(DashboardWorkspaceSort sort) {
  switch (sort) {
    case DashboardWorkspaceSort.recommended:
      return Icons.auto_awesome_outlined;
    case DashboardWorkspaceSort.risk:
      return Icons.warning_amber_outlined;
    case DashboardWorkspaceSort.name:
      return Icons.sort_by_alpha_rounded;
    case DashboardWorkspaceSort.category:
      return Icons.category_outlined;
  }
}
