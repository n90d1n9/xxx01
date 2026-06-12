import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_models.dart';
import 'employee_directory_quality_tiles.dart';

class EmployeeDirectoryQualityPanel extends StatelessWidget {
  final EmployeeDirectoryQualityReport report;
  final EmployeeDirectoryQualityFilter activeFilter;
  final ValueChanged<EmployeeDirectoryQualityFilter> onFilterSelected;

  const EmployeeDirectoryQualityPanel({
    super.key,
    required this.report,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-quality-panel'),
      icon: Icons.fact_check_outlined,
      title: 'Roster quality',
      subtitle:
          '${report.readinessScore}% ready, ${report.issueCount} issues across ${report.affectedProfileCount} profiles',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Readiness',
              value: '${report.readinessScore}%',
            ),
            HrisMetricStripItem(label: 'Status', value: report.readinessLabel),
            HrisMetricStripItem(
              label: 'Critical',
              value: '${report.criticalCount}',
            ),
            HrisMetricStripItem(
              label: 'Affected',
              value: '${report.affectedProfileCount}',
            ),
          ],
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              EmployeeDirectoryQualityFilter.values.map((filter) {
                final selected = filter == activeFilter;
                return ChoiceChip(
                  key: ValueKey(
                    'employee-directory-quality-filter-${filter.name}',
                  ),
                  selected: selected,
                  avatar: Icon(
                    _filterIcon(filter),
                    size: 18,
                    color: selected ? Colors.white : HrisColors.primary,
                  ),
                  label: Text(
                    '${filter.label} (${report.countForFilter(filter)})',
                  ),
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedColor: HrisColors.primary,
                  backgroundColor: HrisColors.surfaceSubtle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: selected ? HrisColors.primary : HrisColors.border,
                    ),
                  ),
                  onSelected: (_) => onFilterSelected(filter),
                );
              }).toList(),
        ),
        if (report.topIssues.isEmpty)
          const HrisListSurface(
            child: Text('No roster quality issues in the current directory.'),
          )
        else
          ...report.topIssues.map(
            (issue) => EmployeeDirectoryQualityIssueTile(
              key: ValueKey(
                'employee-directory-quality-issue-${issue.employeeId}-${issue.type.name}',
              ),
              issue: issue,
            ),
          ),
      ],
    );
  }
}

IconData _filterIcon(EmployeeDirectoryQualityFilter filter) {
  switch (filter) {
    case EmployeeDirectoryQualityFilter.all:
      return Icons.groups_2_outlined;
    case EmployeeDirectoryQualityFilter.duplicateEmail:
      return Icons.alternate_email_outlined;
    case EmployeeDirectoryQualityFilter.missingManager:
      return Icons.supervisor_account_outlined;
    case EmployeeDirectoryQualityFilter.missingContact:
      return Icons.contact_mail_outlined;
    case EmployeeDirectoryQualityFilter.futureStart:
      return Icons.event_available_outlined;
    case EmployeeDirectoryQualityFilter.incompleteProfile:
      return Icons.rule_folder_outlined;
  }
}
