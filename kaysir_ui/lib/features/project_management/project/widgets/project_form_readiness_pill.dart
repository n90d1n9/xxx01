import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

/// Compact status pill showing whether the project form draft can be saved.
class ProjectFormReadinessPill extends StatelessWidget {
  const ProjectFormReadinessPill({required this.issueCount, super.key});

  static const pillKey = ValueKey('project-form-readiness-pill');

  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReady = issueCount == 0;
    final color = isReady ? colorScheme.primary : colorScheme.error;

    return AppStatusPill(
      key: pillKey,
      label: isReady ? 'Ready to save' : _issueLabel(issueCount),
      icon: isReady ? Icons.check_circle_rounded : Icons.rule_folder_outlined,
      color: color,
      maxWidth: 180,
      tooltip:
          isReady
              ? 'All required project form fields are ready.'
              : 'Review the remaining project form fields before saving.',
    );
  }

  String _issueLabel(int count) {
    return count == 1 ? '1 item to review' : '$count items to review';
  }
}

@Preview(name: 'Project form readiness pill')
Widget projectFormReadinessPillPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ProjectFormReadinessPill(issueCount: 0),
            ProjectFormReadinessPill(issueCount: 3),
          ],
        ),
      ),
    ),
  );
}
