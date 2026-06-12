import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_text_cluster.dart';

import '../models/project_form_draft.dart';
import '../models/project_form_focus.dart';
import 'project_form_panel.dart';

/// Scrollable project form content that adapts create and edit workflows.
class ProjectFormScreenContent extends StatelessWidget {
  const ProjectFormScreenContent({
    required this.initialDraft,
    required this.isEditing,
    required this.onSubmitted,
    this.initialFocus = ProjectFormPanelFocus.none,
    this.focusedAttributeKey,
    super.key,
  });

  static const double maxContentWidth = 1120;

  final ProjectFormDraft initialDraft;
  final bool isEditing;
  final ValueChanged<ProjectFormDraft> onSubmitted;
  final ProjectFormPanelFocus initialFocus;
  final String? focusedAttributeKey;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < 640 ? 16.0 : 24.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextCluster(
                      eyebrow: 'Project Management',
                      title: isEditing ? 'Edit Project' : 'Create Project',
                      subtitle:
                          isEditing
                              ? 'Update a locally created project while keeping its project ID and saved record.'
                              : 'A structured project intake form ready for multi-domain business work.',
                      titleStyle: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 20),
                    ProjectFormPanel(
                      initialDraft: initialDraft,
                      initialFocus: initialFocus,
                      focusedAttributeKey: focusedAttributeKey,
                      submitLabel: isEditing ? 'Save Changes' : 'Add Project',
                      onSubmitted: onSubmitted,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

@Preview(name: 'Project form screen content')
Widget projectFormScreenContentPreview() {
  return MaterialApp(
    home: Scaffold(
      body: ProjectFormScreenContent(
        initialDraft: ProjectFormDraft.initial(today: DateTime(2026, 6)),
        isEditing: false,
        onSubmitted: (_) {},
      ),
    ),
  );
}
