import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'project_workflow_action_bar.dart';
import 'project_workflow_queue.dart';

/// Shared submit action and queue section for project workflow panels.
class ProjectWorkflowSubmissionSection<T> extends StatelessWidget {
  const ProjectWorkflowSubmissionSection({
    required this.submitLabel,
    required this.onReset,
    required this.onSubmit,
    required this.items,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.titleFor,
    required this.subtitleFor,
    required this.iconFor,
    required this.colorFor,
    this.statusColorFor,
    this.resetLabel = 'Reset',
    this.resetIcon = Icons.restart_alt_rounded,
    this.submitIcon = Icons.playlist_add_check_outlined,
    this.maxItems = 3,
    this.queueSpacing = 12,
    super.key,
  });

  final String resetLabel;
  final String submitLabel;
  final IconData resetIcon;
  final IconData submitIcon;
  final VoidCallback onReset;
  final VoidCallback onSubmit;
  final List<T> items;
  final String emptyTitle;
  final String emptySubtitle;
  final String Function(T item) titleFor;
  final String Function(T item) subtitleFor;
  final IconData Function(T item) iconFor;
  final Color Function(BuildContext context, T item) colorFor;
  final Color? Function(BuildContext context, T item)? statusColorFor;
  final int maxItems;
  final double queueSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectWorkflowActionBar(
          resetLabel: resetLabel,
          submitLabel: submitLabel,
          resetIcon: resetIcon,
          submitIcon: submitIcon,
          onReset: onReset,
          onSubmit: onSubmit,
        ),
        SizedBox(height: queueSpacing),
        ProjectWorkflowQueue<T>.mapped(
          items: items,
          emptyTitle: emptyTitle,
          emptySubtitle: emptySubtitle,
          titleFor: titleFor,
          subtitleFor: subtitleFor,
          iconFor: iconFor,
          colorFor: colorFor,
          statusColorFor: statusColorFor,
          maxItems: maxItems,
        ),
      ],
    );
  }
}

@Preview(name: 'Project workflow submission section')
Widget projectWorkflowSubmissionSectionPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProjectWorkflowSubmissionSection<String>(
          submitLabel: 'Queue Response',
          submitIcon: Icons.health_and_safety_outlined,
          onReset: () {},
          onSubmit: () {},
          items: const ['Sponsor recovery response'],
          emptyTitle: 'Workflow queue empty',
          emptySubtitle: 'Queued responses will appear here.',
          titleFor: (item) => item,
          subtitleFor: (_) => 'Sponsor route - Owner: Risk lead',
          iconFor: (_) => Icons.priority_high_rounded,
          colorFor: (context, _) => Theme.of(context).colorScheme.error,
        ),
      ),
    ),
  );
}
