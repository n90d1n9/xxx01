import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_fix_models.dart';
import '../../models/employee_directory_quality_gate_models.dart';
import '../../models/employee_directory_quality_models.dart';
import 'employee_directory_quality_fix_fields.dart';

/// Next-action tile for the roster readiness gate.
class EmployeeDirectoryQualityGateActionTile extends StatelessWidget {
  final EmployeeDirectoryQualityGate gate;
  final ValueChanged<String> onIssueSelected;

  const EmployeeDirectoryQualityGateActionTile({
    super.key,
    required this.gate,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    final issue = gate.nextIssue;
    final color = _gateColor(gate.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GateIcon(icon: _gateIcon(gate.status), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gate.nextActionLabel,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: gate.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  gate.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                if (issue != null) ...[
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    key: const ValueKey(
                      'employee-directory-quality-gate-focus-button',
                    ),
                    onPressed: () => onIssueSelected(issue.fixKey),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Focus gate blocker'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality gate action')
Widget employeeDirectoryQualityGateActionTilePreview() {
  const issue = EmployeeDirectoryQualityIssue(
    type: EmployeeDirectoryQualityIssueType.duplicateEmail,
    severity: EmployeeDirectoryQualitySeverity.critical,
    employeeId: '2',
    employeeName: 'Maya Santoso',
    detail: 'maya@example.com appears on more than one profile.',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityGateActionTile(
          gate: const EmployeeDirectoryQualityGate(
            status: EmployeeDirectoryQualityGateStatus.blocked,
            memberCount: 3,
            readinessScore: 33,
            blockerCount: 2,
            reviewCount: 1,
            advisoryCount: 0,
            nextIssue: issue,
            checks: [],
          ),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Checklist tile showing whether one roster readiness gate has cleared.
class EmployeeDirectoryQualityGateCheckTile extends StatelessWidget {
  final EmployeeDirectoryQualityGateCheck check;
  final ValueChanged<String> onIssueSelected;

  const EmployeeDirectoryQualityGateCheckTile({
    super.key,
    required this.check,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        check.isPassed
            ? const Color(0xFF15803D)
            : employeeDirectoryQualityFixSeverityColor(check.severity);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GateIcon(
            icon:
                check.isPassed
                    ? Icons.check_circle_outline
                    : employeeDirectoryQualityFixIssueIcon(
                      check.firstIssue!.type,
                    ),
            color: color,
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
                        check.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: check.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  check.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                if (!check.isPassed && check.firstIssue != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    key: ValueKey(
                      'employee-directory-quality-gate-check-${check.id}',
                    ),
                    onPressed: () => onIssueSelected(check.firstIssue!.fixKey),
                    icon: const Icon(Icons.center_focus_strong_outlined),
                    label: const Text('Focus check'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality gate check')
Widget employeeDirectoryQualityGateCheckTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityGateCheckTile(
          check: const EmployeeDirectoryQualityGateCheck(
            id: 'identityContact',
            title: 'Identity and contact',
            detail:
                'Unique emails and required communication channels are present.',
            issueTypes: [
              EmployeeDirectoryQualityIssueType.duplicateEmail,
              EmployeeDirectoryQualityIssueType.missingContact,
            ],
            issues: [
              EmployeeDirectoryQualityIssue(
                type: EmployeeDirectoryQualityIssueType.duplicateEmail,
                severity: EmployeeDirectoryQualitySeverity.critical,
                employeeId: '2',
                employeeName: 'Maya Santoso',
                detail: 'maya@example.com appears on more than one profile.',
              ),
            ],
          ),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Reusable icon surface for readiness gate tiles.
class _GateIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _GateIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

IconData _gateIcon(EmployeeDirectoryQualityGateStatus status) {
  return switch (status) {
    EmployeeDirectoryQualityGateStatus.blocked => Icons.lock_clock_outlined,
    EmployeeDirectoryQualityGateStatus.review => Icons.rate_review_outlined,
    EmployeeDirectoryQualityGateStatus.ready => Icons.verified_outlined,
  };
}

Color _gateColor(EmployeeDirectoryQualityGateStatus status) {
  return switch (status) {
    EmployeeDirectoryQualityGateStatus.blocked => const Color(0xFFB91C1C),
    EmployeeDirectoryQualityGateStatus.review => const Color(0xFFD97706),
    EmployeeDirectoryQualityGateStatus.ready => const Color(0xFF15803D),
  };
}
