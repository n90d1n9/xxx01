import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

/// Empty-state loading surface used while the project form hydrates edit data.
class ProjectFormLoadingState extends StatelessWidget {
  const ProjectFormLoadingState({this.projectId, super.key});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final normalizedProjectId = projectId?.trim();
    final hasProjectId =
        normalizedProjectId != null && normalizedProjectId.isNotEmpty;

    return AppEmptyState(
      icon: Icons.hourglass_top_rounded,
      title: 'Loading project form',
      message:
          hasProjectId
              ? 'Preparing the editable record for "$normalizedProjectId".'
              : 'Preparing the project intake workspace.',
      action: const SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator.adaptive(strokeWidth: 3),
      ),
    );
  }
}

@Preview(name: 'Project form loading state')
Widget projectFormLoadingStatePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: ProjectFormLoadingState(projectId: 'campus-renovation'),
      ),
    ),
  );
}
