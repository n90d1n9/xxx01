import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_plan_models.dart';
import '../../models/employee_directory_quality_models.dart';
import 'employee_directory_quality_plan_tiles.dart';

/// Operational cleanup plan that prioritizes remaining roster quality fixes.
class EmployeeDirectoryQualityPlanPanel extends StatelessWidget {
  final EmployeeDirectoryQualityFixPlan plan;
  final ValueChanged<String> onIssueSelected;

  const EmployeeDirectoryQualityPlanPanel({
    super.key,
    required this.plan,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-quality-plan-panel'),
      icon: Icons.route_outlined,
      title: 'Quality fix plan',
      subtitle: plan.summaryLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Open', value: '${plan.issueCount}'),
            HrisMetricStripItem(label: 'ETA', value: plan.etaLabel),
            HrisMetricStripItem(label: 'Next', value: plan.nextFocusLabel),
            HrisMetricStripItem(
              label: 'Target',
              value: '${plan.targetReadinessScore}%',
            ),
          ],
        ),
        if (plan.isClear)
          const HrisListSurface(
            child: Text('Roster cleanup plan is clear. Keep monitoring HRIS.'),
          )
        else ...[
          EmployeeDirectoryQualityPlanRecommendationTile(
            plan: plan,
            onIssueSelected: onIssueSelected,
          ),
          HrisResponsivePanelGrid(
            breakpoint: 820,
            panels:
                plan.lanes
                    .map(
                      (lane) => EmployeeDirectoryQualityPlanLaneCard(
                        key: ValueKey(
                          'employee-directory-quality-plan-lane-${lane.severity.name}',
                        ),
                        lane: lane,
                      ),
                    )
                    .toList(),
          ),
          ...plan.groups
              .take(4)
              .map(
                (group) => EmployeeDirectoryQualityPlanGroupTile(
                  key: ValueKey(
                    'employee-directory-quality-plan-group-tile-${group.type.name}',
                  ),
                  group: group,
                  onIssueSelected: onIssueSelected,
                ),
              ),
        ],
      ],
    );
  }
}

@Preview(name: 'Employee quality fix plan')
Widget employeeDirectoryQualityPlanPanelPreview() {
  final members = [
    _previewMember(id: '1', name: 'Sarah Johnson', email: 'shared@example.com'),
    _previewMember(
      id: '2',
      name: 'Maya Santoso',
      email: 'shared@example.com',
      manager: '',
    ),
    _previewMember(id: '3', name: 'Rafi Pratama'),
  ];
  final report = EmployeeDirectoryQualityReport.fromMembers(
    members: members,
    asOfDate: DateTime(2026, 6, 9),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityPlanPanel(
          plan: EmployeeDirectoryQualityFixPlan.fromReport(report),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

EmployeeDirectoryMember _previewMember({
  required String id,
  required String name,
  String email = 'person@example.com',
  String phone = '+62 812 0000 0000',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: '',
    email: email,
    phone: phone,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
