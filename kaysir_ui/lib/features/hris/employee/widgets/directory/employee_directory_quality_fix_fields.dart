import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_models.dart';

/// Compact issue summary used when HR selects a roster quality finding to fix.
class EmployeeDirectoryQualityFixIssueTile extends StatelessWidget {
  final EmployeeDirectoryQualityIssue issue;

  const EmployeeDirectoryQualityFixIssueTile({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final color = employeeDirectoryQualityFixSeverityColor(issue.severity);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeeDirectoryQualityFixIssueIcon(issue.type),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${issue.type.label}: ${issue.employeeName}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: issue.severity.label, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  issue.detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality fix issue tile')
Widget employeeDirectoryQualityFixIssueTilePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: EmployeeDirectoryQualityFixIssueTile(
          issue: EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.duplicateEmail,
            severity: EmployeeDirectoryQualitySeverity.critical,
            employeeId: '2',
            employeeName: 'Maya Santoso',
            detail: 'maya@example.com appears on more than one profile.',
          ),
        ),
      ),
    ),
  );
}

/// Standard text input used by targeted quality-fix remediation forms.
class EmployeeDirectoryQualityFixTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const EmployeeDirectoryQualityFixTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

@Preview(name: 'Employee quality fix text field')
Widget employeeDirectoryQualityFixTextFieldPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityFixTextField(
          controller: TextEditingController(text: 'maya.fixed@example.com'),
          label: 'Correct email',
          icon: Icons.alternate_email_outlined,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

IconData employeeDirectoryQualityFixIssueIcon(
  EmployeeDirectoryQualityIssueType type,
) {
  switch (type) {
    case EmployeeDirectoryQualityIssueType.duplicateEmail:
      return Icons.alternate_email_outlined;
    case EmployeeDirectoryQualityIssueType.missingManager:
      return Icons.supervisor_account_outlined;
    case EmployeeDirectoryQualityIssueType.missingContact:
      return Icons.contact_mail_outlined;
    case EmployeeDirectoryQualityIssueType.missingDepartment:
      return Icons.account_tree_outlined;
    case EmployeeDirectoryQualityIssueType.missingLocation:
      return Icons.location_off_outlined;
    case EmployeeDirectoryQualityIssueType.futureStart:
      return Icons.event_available_outlined;
  }
}

Color employeeDirectoryQualityFixSeverityColor(
  EmployeeDirectoryQualitySeverity severity,
) {
  switch (severity) {
    case EmployeeDirectoryQualitySeverity.critical:
      return const Color(0xFFB91C1C);
    case EmployeeDirectoryQualitySeverity.warning:
      return const Color(0xFFD97706);
    case EmployeeDirectoryQualitySeverity.info:
      return HrisColors.primary;
  }
}
