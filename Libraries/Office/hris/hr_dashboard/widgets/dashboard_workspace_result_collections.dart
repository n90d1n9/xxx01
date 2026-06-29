import 'package:flutter/material.dart';

import '../models/dashboard_workspace_entry.dart';
import 'dashboard_workspace_card.dart';
import 'dashboard_workspace_list_item.dart';

class DashboardWorkspaceGridLayout {
  final int columns;
  final double aspectRatio;

  const DashboardWorkspaceGridLayout({
    required this.columns,
    required this.aspectRatio,
  });

  factory DashboardWorkspaceGridLayout.fromMaxWidth(double maxWidth) {
    final columns =
        maxWidth >= 1180
            ? 3
            : maxWidth >= 760
            ? 2
            : 1;
    final aspectRatio =
        columns == 1
            ? 1.45
            : columns == 2
            ? 1.55
            : 1.48;

    return DashboardWorkspaceGridLayout(
      columns: columns,
      aspectRatio: aspectRatio,
    );
  }
}

class DashboardWorkspaceGrid extends StatelessWidget {
  final List<DashboardWorkspaceEntry> entries;
  final double maxWidth;

  const DashboardWorkspaceGrid({
    super.key,
    required this.entries,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final layout = DashboardWorkspaceGridLayout.fromMaxWidth(maxWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: layout.aspectRatio,
      ),
      itemCount: entries.length,
      itemBuilder:
          (context, index) => DashboardWorkspaceCard(entry: entries[index]),
    );
  }
}

class DashboardWorkspaceList extends StatelessWidget {
  final List<DashboardWorkspaceEntry> entries;

  const DashboardWorkspaceList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder:
          (context, index) => DashboardWorkspaceListItem(entry: entries[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: entries.length,
    );
  }
}
