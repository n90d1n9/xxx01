import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';

/// Presentation-ready validation issue for project workflow forms.
class ProjectWorkflowIssueItem {
  const ProjectWorkflowIssueItem({required this.field, required this.message});

  final String field;
  final String message;
}

/// Shared validation issue list for project workflow forms.
class ProjectWorkflowIssueList<T> extends StatelessWidget {
  const ProjectWorkflowIssueList({required this.issues, super.key});

  /// Builds a workflow issue list from domain-specific validation issues.
  ProjectWorkflowIssueList.fromItems({
    required Iterable<T> items,
    required String Function(T item) fieldFor,
    required String Function(T item) messageFor,
    super.key,
  }) : issues = [
         for (final item in items)
           ProjectWorkflowIssueItem(
             field: fieldFor(item),
             message: messageFor(item),
           ),
       ];

  final List<ProjectWorkflowIssueItem> issues;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < issues.length; index++) ...[
          AppInfoRow(
            title: issues[index].message,
            subtitle: issues[index].field,
            icon: Icons.error_outline,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.error.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.error,
            titleMaxLines: 2,
            subtitleMaxLines: 1,
          ),
          if (index != issues.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Conditional issue section that preserves workflow spacing when issues exist.
class ProjectWorkflowIssueSection<T> extends StatelessWidget {
  const ProjectWorkflowIssueSection({
    required this.items,
    required this.fieldFor,
    required this.messageFor,
    this.spacing = 12,
    super.key,
  });

  final Iterable<T> items;
  final String Function(T item) fieldFor;
  final String Function(T item) messageFor;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final issueItems = items.toList();
    if (issueItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: spacing),
        ProjectWorkflowIssueList<T>.fromItems(
          items: issueItems,
          fieldFor: fieldFor,
          messageFor: messageFor,
        ),
      ],
    );
  }
}

@Preview(name: 'Project workflow issue list')
Widget projectWorkflowIssueListPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: ProjectWorkflowIssueList(
          issues: [
            ProjectWorkflowIssueItem(
              field: 'owner',
              message: 'Response owner is required.',
            ),
            ProjectWorkflowIssueItem(
              field: 'evidence',
              message: 'Evidence note should explain the response proof.',
            ),
          ],
        ),
      ),
    ),
  );
}

@Preview(name: 'Project workflow issue section')
Widget projectWorkflowIssueSectionPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProjectWorkflowIssueSection<Map<String, String>>(
          items: const [
            {'field': 'owner', 'message': 'Response owner is required.'},
          ],
          fieldFor: (issue) => issue['field']!,
          messageFor: (issue) => issue['message']!,
        ),
      ),
    ),
  );
}
