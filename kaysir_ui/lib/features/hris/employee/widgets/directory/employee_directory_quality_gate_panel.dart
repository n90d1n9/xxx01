import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_quality_models.dart';
import 'employee_directory_quality_gate_tiles.dart';

/// Readiness gate that explains whether roster quality can pass cutoff.
class EmployeeDirectoryQualityGatePanel extends StatelessWidget {
  final EmployeeDirectoryQualityGate gate;
  final ValueChanged<String> onIssueSelected;

  const EmployeeDirectoryQualityGatePanel({
    super.key,
    required this.gate,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-quality-gate-panel'),
      icon: Icons.verified_user_outlined,
      title: 'Roster readiness gate',
      subtitle: gate.summaryLabel,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Gate', value: gate.status.label),
            HrisMetricStripItem(
              label: 'Blockers',
              value: '${gate.blockerCount}',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${gate.reviewCount + gate.advisoryCount}',
            ),
            HrisMetricStripItem(
              label: 'Checks',
              value: '${gate.completionPercent}%',
            ),
          ],
        ),
        if (gate.isReady)
          const HrisListSurface(
            child: Text('Roster quality gate is clear for cutoff actions.'),
          )
        else
          EmployeeDirectoryQualityGateActionTile(
            gate: gate,
            onIssueSelected: onIssueSelected,
          ),
        HrisResponsivePanelGrid(
          breakpoint: 820,
          panels:
              gate.checks
                  .map(
                    (check) => EmployeeDirectoryQualityGateCheckTile(
                      key: ValueKey(
                        'employee-directory-quality-gate-check-tile-${check.id}',
                      ),
                      check: check,
                      onIssueSelected: onIssueSelected,
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

@Preview(name: 'Employee quality gate')
Widget employeeDirectoryQualityGatePanelPreview() {
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
        child: EmployeeDirectoryQualityGatePanel(
          gate: EmployeeDirectoryQualityGate.fromReport(report),
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
