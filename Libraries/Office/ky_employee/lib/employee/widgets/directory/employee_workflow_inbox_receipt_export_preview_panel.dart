import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_next_action_models.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_receipt_export_access_models.dart';
import '../../models/employee_workflow_inbox_receipt_export_models.dart';
import '../../models/employee_workflow_inbox_receipt_models.dart';

/// Export preview for completed employee workflow inbox action receipts.
class EmployeeWorkflowInboxReceiptExportPreviewPanel extends StatefulWidget {
  final EmployeeWorkflowInboxReceiptExportPreview preview;

  const EmployeeWorkflowInboxReceiptExportPreviewPanel({
    super.key,
    required this.preview,
  });

  @override
  State<EmployeeWorkflowInboxReceiptExportPreviewPanel> createState() =>
      _EmployeeWorkflowInboxReceiptExportPreviewPanelState();
}

/// Holds the active export scope for an employee workflow receipt preview.
class _EmployeeWorkflowInboxReceiptExportPreviewPanelState
    extends State<EmployeeWorkflowInboxReceiptExportPreviewPanel> {
  late EmployeeWorkflowInboxReceiptExportScope _selectedScope;
  EmployeeWorkflowInboxReceiptExportRole _selectedRole =
      EmployeeWorkflowInboxReceiptExportRole.peopleOperations;

  @override
  void initState() {
    super.initState();
    _selectedScope = widget.preview.scope;
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview.copyWith(scope: _selectedScope);
    final access = EmployeeWorkflowInboxReceiptExportAccessReview(
      role: _selectedRole,
      preview: preview,
    );
    final color = _statusColor(preview.status);
    final copyPermission = access.copyCsvPermission;

    return Column(
      key: const ValueKey('employee-workflow-inbox-receipt-export-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Receipt export preview',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: preview.statusLabel, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          preview.exportActionLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 10),
        EmployeeWorkflowInboxReceiptExportAccessStrip(
          access: access,
          onRoleChanged: (role) => setState(() => _selectedRole = role),
        ),
        const SizedBox(height: 10),
        EmployeeWorkflowInboxReceiptExportScopeStrip(
          preview: widget.preview,
          selected: _selectedScope,
          onChanged: (scope) => setState(() => _selectedScope = scope),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in preview.manifestItems)
              _ReceiptExportManifestChip(item: item),
          ],
        ),
        const SizedBox(height: 12),
        _ReceiptCsvSample(preview: preview),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              key: const ValueKey(
                'employee-workflow-inbox-receipt-export-copy-csv-button',
              ),
              onPressed:
                  copyPermission.allowed
                      ? () => _copyCsv(context, preview.csvContent)
                      : null,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy CSV'),
            ),
            Text(
              '${preview.fileName} - ${preview.rowCountLabel}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

/// Role selector and permission summary for receipt CSV exports.
class EmployeeWorkflowInboxReceiptExportAccessStrip extends StatelessWidget {
  final EmployeeWorkflowInboxReceiptExportAccessReview access;
  final ValueChanged<EmployeeWorkflowInboxReceiptExportRole> onRoleChanged;

  const EmployeeWorkflowInboxReceiptExportAccessStrip({
    super.key,
    required this.access,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final permission = access.copyCsvPermission;
    final statusColor =
        permission.allowed ? const Color(0xFF15803D) : HrisColors.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Role', value: access.role.shortLabel),
            HrisMetricStripItem(label: 'Access', value: access.statusLabel),
            HrisMetricStripItem(
              label: 'Copy CSV',
              value: permission.statusLabel,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<EmployeeWorkflowInboxReceiptExportRole>(
            key: const ValueKey(
              'employee-workflow-inbox-receipt-export-role-selector',
            ),
            showSelectedIcon: false,
            segments: [
              for (final role in EmployeeWorkflowInboxReceiptExportRole.values)
                ButtonSegment(
                  value: role,
                  icon: Icon(_roleIcon(role), size: 18),
                  label: Text(
                    role.shortLabel,
                    key: ValueKey(
                      'employee-workflow-inbox-receipt-export-role-${role.name}',
                    ),
                  ),
                ),
            ],
            selected: {access.role},
            onSelectionChanged: (selection) => onRoleChanged(selection.single),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withValues(alpha: 0.22)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_permissionIcon(permission), size: 20, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.reason,
                      key: const ValueKey(
                        'employee-workflow-inbox-receipt-export-copy-permission',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      access.roleGuidance,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: permission.statusLabel, color: statusColor),
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal segmented scope selector for receipt CSV exports.
class EmployeeWorkflowInboxReceiptExportScopeStrip extends StatelessWidget {
  final EmployeeWorkflowInboxReceiptExportPreview preview;
  final EmployeeWorkflowInboxReceiptExportScope selected;
  final ValueChanged<EmployeeWorkflowInboxReceiptExportScope> onChanged;

  const EmployeeWorkflowInboxReceiptExportScopeStrip({
    super.key,
    required this.preview,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<EmployeeWorkflowInboxReceiptExportScope>(
        showSelectedIcon: false,
        segments:
            EmployeeWorkflowInboxReceiptExportScope.values.map((scope) {
              return ButtonSegment(
                value: scope,
                icon: Icon(_scopeIcon(scope), size: 18),
                label: Text(
                  '${scope.label} (${preview.countFor(scope)})',
                  key: ValueKey(
                    'employee-workflow-inbox-receipt-export-scope-${scope.name}',
                  ),
                ),
              );
            }).toList(),
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox receipt export')
Widget employeeWorkflowInboxReceiptExportPreviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxReceiptExportPreviewPanel(
          preview: EmployeeWorkflowInboxReceiptExportPreview(
            profile: EmployeeWorkflowInboxReceiptProfile(
              employeeId: '4',
              employeeName: 'David Kim',
              asOfDate: DateTime(2026, 6, 1),
              receipts: [_previewReceipt, _previewPayrollReceipt],
            ),
            generatedAt: DateTime(2026, 6, 1, 12),
          ),
        ),
      ),
    ),
  );
}

/// Compact manifest value chip used by the receipt export preview.
class _ReceiptExportManifestChip extends StatelessWidget {
  final EmployeeWorkflowInboxReceiptExportManifestItem item;

  const _ReceiptExportManifestChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.label}: ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            item.value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Monospace sample block showing the first receipt export rows.
class _ReceiptCsvSample extends StatelessWidget {
  final EmployeeWorkflowInboxReceiptExportPreview preview;

  const _ReceiptCsvSample({required this.preview});

  @override
  Widget build(BuildContext context) {
    final lines = preview.csvContent.split('\n').take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CSV sample',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontFamily: 'monospace',
              ),
            ),
          if (preview.rowCount > 3) ...[
            const SizedBox(height: 4),
            Text(
              '${preview.rowCount - 3} more rows included',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _copyCsv(BuildContext context, String csvContent) async {
  await Clipboard.setData(ClipboardData(text: csvContent));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Receipt CSV copied')));
}

Color _statusColor(EmployeeWorkflowInboxReceiptExportStatus status) {
  return switch (status) {
    EmployeeWorkflowInboxReceiptExportStatus.ready => const Color(0xFF15803D),
    EmployeeWorkflowInboxReceiptExportStatus.empty => HrisColors.muted,
  };
}

IconData _scopeIcon(EmployeeWorkflowInboxReceiptExportScope scope) {
  return switch (scope) {
    EmployeeWorkflowInboxReceiptExportScope.all => Icons.receipt_long_outlined,
    EmployeeWorkflowInboxReceiptExportScope.governed =>
      Icons.verified_user_outlined,
    EmployeeWorkflowInboxReceiptExportScope.payroll => Icons.payments_outlined,
    EmployeeWorkflowInboxReceiptExportScope.actionWorkflow =>
      Icons.task_alt_outlined,
    EmployeeWorkflowInboxReceiptExportScope.profileChange =>
      Icons.rule_folder_outlined,
    EmployeeWorkflowInboxReceiptExportScope.dataCorrection =>
      Icons.edit_note_outlined,
    EmployeeWorkflowInboxReceiptExportScope.jobAssignment =>
      Icons.badge_outlined,
  };
}

IconData _roleIcon(EmployeeWorkflowInboxReceiptExportRole role) {
  return switch (role) {
    EmployeeWorkflowInboxReceiptExportRole.peopleOperations =>
      Icons.groups_outlined,
    EmployeeWorkflowInboxReceiptExportRole.payrollOfficer =>
      Icons.payments_outlined,
    EmployeeWorkflowInboxReceiptExportRole.manager =>
      Icons.supervisor_account_outlined,
    EmployeeWorkflowInboxReceiptExportRole.hrAuditor =>
      Icons.visibility_outlined,
  };
}

IconData _permissionIcon(EmployeeWorkflowInboxReceiptExportPermission value) {
  return value.allowed ? Icons.check_circle_outline : Icons.lock_outline;
}

EmployeeWorkflowInboxActionReceipt get _previewReceipt {
  return EmployeeWorkflowInboxActionReceipt(
    id: 'EWI-4-001',
    employeeId: '4',
    employeeName: 'David Kim',
    workflowItemId: 'profile-change-EPC-4-001',
    sourceRecordId: 'EPC-4-001',
    title: 'Manager change',
    source: EmployeeWorkflowInboxSource.profileChange,
    action: EmployeeWorkflowInboxAction.apply,
    area: EmployeeNextActionArea.work,
    actor: 'People Operations',
    owner: 'People Operations',
    previousStatus: 'Scheduled',
    decidedAt: DateTime(2026, 6, 1),
  );
}

EmployeeWorkflowInboxActionReceipt get _previewPayrollReceipt {
  return EmployeeWorkflowInboxActionReceipt(
    id: 'EWI-4-002',
    employeeId: '4',
    employeeName: 'David Kim',
    workflowItemId: 'action-EAW-4-001',
    sourceRecordId: 'EAW-4-001',
    title: 'Validate payroll cutoff',
    source: EmployeeWorkflowInboxSource.actionWorkflow,
    action: EmployeeWorkflowInboxAction.complete,
    area: EmployeeNextActionArea.pay,
    actor: 'Payroll Lead',
    owner: 'Payroll Lead',
    previousStatus: 'In progress',
    decidedAt: DateTime(2026, 6, 1),
  );
}
