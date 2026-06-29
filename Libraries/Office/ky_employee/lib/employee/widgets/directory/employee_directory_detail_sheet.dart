import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../states/employee_management_provider.dart';
import 'employee_action_activity_panel.dart';
import 'employee_action_sla_panel.dart';
import 'employee_action_workflow_panel.dart';
import 'employee_directory_styles.dart';
import 'employee_next_action_panel.dart';
import 'employee_profile_attention_summary.dart';
import 'employee_profile_sections.dart';
import 'employee_workflow_inbox_panel.dart';
import 'employee_workflow_automation_panel.dart';

class EmployeeDirectoryDetailSheet extends ConsumerStatefulWidget {
  final EmployeeDirectoryMember employee;
  final DateTime asOfDate;
  final VoidCallback onMessage;
  final VoidCallback? onEdit;
  final VoidCallback onSchedule;

  const EmployeeDirectoryDetailSheet({
    super.key,
    required this.employee,
    required this.asOfDate,
    required this.onMessage,
    this.onEdit,
    required this.onSchedule,
  });

  @override
  ConsumerState<EmployeeDirectoryDetailSheet> createState() =>
      _EmployeeDirectoryDetailSheetState();
}

class _EmployeeDirectoryDetailSheetState
    extends ConsumerState<EmployeeDirectoryDetailSheet> {
  var _selectedSection = EmployeeProfileSection.overview;

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
    final asOfDate = widget.asOfDate;
    final statusColor = employeeDirectoryStatusColor(employee.status);
    final performanceColor = employeePerformanceColor(employee.performance);
    final managementSnapshot = ref.watch(
      employeeManagementSnapshotProvider(employee.id),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HrisColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: HrisColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials(employee.name),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: HrisColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.position,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: HrisColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                HrisStatusPill(
                  label: employee.status.label,
                  color: statusColor,
                ),
                if (widget.onEdit != null) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    key: const ValueKey(
                      'employee-directory-detail-edit-icon-button',
                    ),
                    tooltip: 'Edit profile',
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            HrisMetricStrip(
              items: [
                HrisMetricStripItem(
                  label: 'Rating',
                  value: employee.performance.toStringAsFixed(1),
                ),
                HrisMetricStripItem(
                  label: 'Tenure',
                  value: '${employee.tenureMonths(asOfDate)} mo',
                ),
                HrisMetricStripItem(
                  label: 'Location',
                  value: employee.location,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _DetailRow(
              icon: Icons.apartment_outlined,
              label: 'Department',
              value: employee.department,
            ),
            _DetailRow(
              icon: Icons.supervisor_account_outlined,
              label: 'Manager',
              value: employee.manager,
            ),
            _DetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: employee.email,
            ),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: employee.phone,
            ),
            if (managementSnapshot != null) ...[
              const SizedBox(height: 8),
              EmployeeProfileAttentionSummary(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeNextActionPanel(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeWorkflowInboxPanel(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeActionWorkflowPanel(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeWorkflowAutomationPanel(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeActionSlaPanel(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeActionActivityPanel(snapshot: managementSnapshot),
              const SizedBox(height: 12),
              EmployeeProfileSectionSwitcher(
                selected: _selectedSection,
                onChanged:
                    (section) => setState(() {
                      _selectedSection = section;
                    }),
              ),
              const SizedBox(height: 12),
              EmployeeProfileSectionContent(
                section: _selectedSection,
                snapshot: managementSnapshot,
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: widget.onMessage,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Message'),
                  ),
                ),
                if (widget.onEdit != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey(
                        'employee-directory-detail-edit-button',
                      ),
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onSchedule,
                    icon: Icon(
                      Icons.event_available_outlined,
                      color: performanceColor,
                    ),
                    label: const Text('Schedule'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HrisListSurface(
        child: Row(
          children: [
            Icon(icon, size: 20, color: HrisColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
                  ),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
