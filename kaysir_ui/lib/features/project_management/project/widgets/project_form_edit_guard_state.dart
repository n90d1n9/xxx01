import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

/// Guard surface for edit routes that target projects outside local storage.
class ProjectFormEditGuardState extends StatelessWidget {
  const ProjectFormEditGuardState({
    required this.onOpenProjects,
    required this.onOpenProjectTable,
    this.projectId,
    super.key,
  });

  final String? projectId;
  final VoidCallback onOpenProjects;
  final VoidCallback onOpenProjectTable;

  @override
  Widget build(BuildContext context) {
    final normalizedProjectId = projectId?.trim();
    final hasProjectId =
        normalizedProjectId != null && normalizedProjectId.isNotEmpty;

    return AppEmptyState(
      icon: Icons.lock_outline_rounded,
      title: 'Project cannot be edited',
      message:
          hasProjectId
              ? 'Project "$normalizedProjectId" is not a locally created record. Open the table to choose an editable project or return to the dashboard.'
              : 'Only locally created projects can be edited. Open the table to choose an editable project or return to the dashboard.',
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          AppActionButton(
            label: 'Open Project Table',
            icon: Icons.table_chart_outlined,
            onPressed: onOpenProjectTable,
          ),
          AppActionButton(
            label: 'Back to Projects',
            icon: Icons.arrow_back_rounded,
            variant: AppActionButtonVariant.secondary,
            onPressed: onOpenProjects,
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project form edit guard state')
Widget projectFormEditGuardStatePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ProjectFormEditGuardState(
          projectId: 'retail-modernization',
          onOpenProjects: () {},
          onOpenProjectTable: () {},
        ),
      ),
    ),
  );
}
