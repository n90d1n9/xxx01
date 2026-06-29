import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_workspace_entry.dart';
import 'dashboard_workspace_list_item_parts.dart';

class DashboardWorkspaceListItem extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const DashboardWorkspaceListItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('workspace-list-${entry.path}'),
      color: HrisColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(entry.path),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: HrisColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 720) {
                return _CompactWorkspaceListContent(entry: entry);
              }

              return _WideWorkspaceListContent(entry: entry);
            },
          ),
        ),
      ),
    );
  }
}

class _WideWorkspaceListContent extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const _WideWorkspaceListContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DashboardWorkspaceListIcon(entry: entry),
        const SizedBox(width: 12),
        Expanded(child: DashboardWorkspaceListCopy(entry: entry)),
        const SizedBox(width: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: DashboardWorkspaceListMetrics(entry: entry),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: HrisColors.muted),
      ],
    );
  }
}

class _CompactWorkspaceListContent extends StatelessWidget {
  final DashboardWorkspaceEntry entry;

  const _CompactWorkspaceListContent({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DashboardWorkspaceListIcon(entry: entry),
            const SizedBox(width: 12),
            Expanded(child: DashboardWorkspaceListCopy(entry: entry)),
            const Icon(Icons.chevron_right, color: HrisColors.muted),
          ],
        ),
        const SizedBox(height: 12),
        DashboardWorkspaceListMetrics(entry: entry),
      ],
    );
  }
}
