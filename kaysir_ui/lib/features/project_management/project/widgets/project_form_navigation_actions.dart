import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// App-bar navigation shortcuts shared by project form screen states.
class ProjectFormNavigationActions extends StatelessWidget {
  const ProjectFormNavigationActions({
    required this.onOpenProjects,
    required this.onOpenProjectTable,
    this.onOpenProjectDetail,
    super.key,
  });

  final VoidCallback onOpenProjects;
  final VoidCallback onOpenProjectTable;
  final VoidCallback? onOpenProjectDetail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onOpenProjectDetail != null)
            IconButton(
              tooltip: 'Open project detail',
              icon: const Icon(Icons.account_tree_outlined),
              onPressed: onOpenProjectDetail,
            ),
          IconButton(
            tooltip: 'Open project table',
            icon: const Icon(Icons.table_chart_outlined),
            onPressed: onOpenProjectTable,
          ),
          IconButton(
            tooltip: 'Open project dashboard',
            icon: const Icon(Icons.space_dashboard_outlined),
            onPressed: onOpenProjects,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project form navigation actions')
Widget projectFormNavigationActionsPreview() {
  return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Project Form'),
        actions: [
          ProjectFormNavigationActions(
            onOpenProjects: () {},
            onOpenProjectTable: () {},
            onOpenProjectDetail: () {},
          ),
        ],
      ),
    ),
  );
}
