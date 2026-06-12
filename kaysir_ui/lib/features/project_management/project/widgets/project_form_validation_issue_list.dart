import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../services/project_form_validation_service.dart';

/// Alert panel that summarizes project form issues before submission.
class ProjectFormValidationIssueList extends StatelessWidget {
  const ProjectFormValidationIssueList({required this.issues, super.key});

  static const listKey = ValueKey('project-form-validation-issue-list');
  static const countKey = ValueKey('project-form-validation-issue-count');

  final List<ProjectFormIssue> issues;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final countLabel =
        issues.length == 1
            ? '1 item needs attention'
            : '${issues.length} items need attention';

    return Semantics(
      container: true,
      label: '$countLabel before saving',
      child: DecoratedBox(
        key: listKey,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.32)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: colorScheme.error,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before saving',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          countLabel,
                          key: countKey,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final issue in issues)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_right_rounded,
                        color: colorScheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          issue.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Project form validation issues')
Widget projectFormValidationIssueListPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: ProjectFormValidationIssueList(
          issues: [
            ProjectFormIssue(
              field: 'name',
              message: 'Project name is required.',
            ),
            ProjectFormIssue(
              field: 'summary',
              message: 'Summary should explain the business outcome.',
            ),
          ],
        ),
      ),
    ),
  );
}
