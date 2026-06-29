import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_models.dart';

class EmployeeDirectoryQualityIssueTile extends StatelessWidget {
  final EmployeeDirectoryQualityIssue issue;

  const EmployeeDirectoryQualityIssueTile({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(issue.severity);

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
            child: Icon(_issueIcon(issue.type), color: color, size: 20),
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

IconData _issueIcon(EmployeeDirectoryQualityIssueType type) {
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

Color _severityColor(EmployeeDirectoryQualitySeverity severity) {
  switch (severity) {
    case EmployeeDirectoryQualitySeverity.critical:
      return const Color(0xFFB91C1C);
    case EmployeeDirectoryQualitySeverity.warning:
      return const Color(0xFFD97706);
    case EmployeeDirectoryQualitySeverity.info:
      return HrisColors.primary;
  }
}
