import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';

/// Callback fired after a playbook audit export package is copied.
typedef EmployeeWorkflowInboxSlaPlaybookAuditExportDeliveryCallback =
    void Function(
      EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview,
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole role,
      EmployeeWorkflowInboxSlaPlaybookAuditExportAction action,
    );

/// Export preview for employee workflow inbox SLA playbook audit receipts.
class EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanel
    extends StatefulWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportDeliveryCallback?
  onDeliveryRecorded;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanel({
    super.key,
    required this.preview,
    this.onDeliveryRecorded,
  });

  @override
  State<EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanel>
  createState() =>
      _EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanelState();
}

/// Holds the active export scope for a workflow inbox SLA playbook package.
class _EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanelState
    extends State<EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanel> {
  late EmployeeWorkflowInboxSlaPlaybookAuditExportScope _selectedScope;
  EmployeeWorkflowInboxSlaPlaybookAuditExportRole _selectedRole =
      EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations;

  @override
  void initState() {
    super.initState();
    _selectedScope = widget.preview.scope;
  }

  @override
  Widget build(BuildContext context) {
    final selectedPreview = widget.preview.copyWith(scope: _selectedScope);
    final access = EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview(
      role: _selectedRole,
      preview: selectedPreview,
    );
    final preview = access.exportPreview;
    final scopePreview = widget.preview.copyWith(redaction: access.redaction);
    final color = _statusColor(preview.status);
    final csvPermission = access.copyCsvPermission;
    final textPermission = access.copyTextPermission;

    return HrisListSurface(
      key: const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-export-panel',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Playbook audit package',
                  key: const ValueKey(
                    'employee-workflow-inbox-sla-playbook-audit-export-heading',
                  ),
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
          EmployeeWorkflowInboxSlaPlaybookAuditExportAccessStrip(
            access: access,
            onRoleChanged: (role) => setState(() => _selectedRole = role),
          ),
          const SizedBox(height: 10),
          EmployeeWorkflowInboxSlaPlaybookAuditExportScopeStrip(
            preview: scopePreview,
            selected: _selectedScope,
            onChanged: (scope) => setState(() => _selectedScope = scope),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in preview.manifestItems)
                _PlaybookAuditExportManifestChip(item: item),
            ],
          ),
          const SizedBox(height: 12),
          _PlaybookAuditCsvSample(preview: preview),
          const SizedBox(height: 12),
          _PlaybookAuditPlainTextSample(preview: preview),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                key: const ValueKey(
                  'employee-workflow-inbox-sla-playbook-audit-export-copy-csv-button',
                ),
                onPressed:
                    csvPermission.allowed
                        ? () => _copyText(
                          context,
                          preview.csvContent,
                          widget.onDeliveryRecorded == null
                              ? 'CSV copied'
                              : 'CSV copied and delivery logged',
                          onCopied:
                              () => widget.onDeliveryRecorded?.call(
                                preview,
                                _selectedRole,
                                EmployeeWorkflowInboxSlaPlaybookAuditExportAction
                                    .copyCsv,
                              ),
                        )
                        : null,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copy CSV'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-workflow-inbox-sla-playbook-audit-export-copy-text-button',
                ),
                onPressed:
                    textPermission.allowed
                        ? () => _copyText(
                          context,
                          preview.plainTextContent,
                          widget.onDeliveryRecorded == null
                              ? 'Audit text copied'
                              : 'Audit text copied and delivery logged',
                          onCopied:
                              () => widget.onDeliveryRecorded?.call(
                                preview,
                                _selectedRole,
                                EmployeeWorkflowInboxSlaPlaybookAuditExportAction
                                    .copyText,
                              ),
                        )
                        : null,
                icon: const Icon(Icons.article_outlined),
                label: const Text('Copy text'),
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
      ),
    );
  }
}

/// Role selector and permission summary for playbook audit package exports.
class EmployeeWorkflowInboxSlaPlaybookAuditExportAccessStrip
    extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportAccessReview access;
  final ValueChanged<EmployeeWorkflowInboxSlaPlaybookAuditExportRole>
  onRoleChanged;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportAccessStrip({
    super.key,
    required this.access,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final csvPermission = access.copyCsvPermission;
    final textPermission = access.copyTextPermission;
    final statusColor =
        access.allowedCount > 0 ? const Color(0xFF15803D) : HrisColors.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Role', value: access.role.shortLabel),
            HrisMetricStripItem(label: 'Access', value: access.statusLabel),
            HrisMetricStripItem(label: 'CSV', value: csvPermission.statusLabel),
            HrisMetricStripItem(
              label: 'Text',
              value: textPermission.statusLabel,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<
            EmployeeWorkflowInboxSlaPlaybookAuditExportRole
          >(
            key: const ValueKey(
              'employee-workflow-inbox-sla-playbook-audit-export-role-selector',
            ),
            showSelectedIcon: false,
            segments: [
              for (final role
                  in EmployeeWorkflowInboxSlaPlaybookAuditExportRole.values)
                ButtonSegment(
                  value: role,
                  icon: Icon(_roleIcon(role), size: 18),
                  label: Text(
                    role.shortLabel,
                    key: ValueKey(
                      'employee-workflow-inbox-sla-playbook-audit-export-role-${role.name}',
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
              Icon(
                _permissionIcon(csvPermission),
                size: 20,
                color: statusColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      csvPermission.reason,
                      key: const ValueKey(
                        'employee-workflow-inbox-sla-playbook-audit-export-copy-permission',
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
                      access.isRedacted
                          ? '${access.roleGuidance} Correction receipts and previous reasons are removed from copied exports.'
                          : access.roleGuidance,
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
              HrisStatusPill(label: access.statusLabel, color: statusColor),
            ],
          ),
        ),
      ],
    );
  }
}

/// Horizontal segmented scope selector for playbook audit exports.
class EmployeeWorkflowInboxSlaPlaybookAuditExportScopeStrip
    extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview;
  final EmployeeWorkflowInboxSlaPlaybookAuditExportScope selected;
  final ValueChanged<EmployeeWorkflowInboxSlaPlaybookAuditExportScope>
  onChanged;

  const EmployeeWorkflowInboxSlaPlaybookAuditExportScopeStrip({
    super.key,
    required this.preview,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<EmployeeWorkflowInboxSlaPlaybookAuditExportScope>(
        showSelectedIcon: false,
        segments:
            EmployeeWorkflowInboxSlaPlaybookAuditExportScope.values.map((
              scope,
            ) {
              return ButtonSegment(
                value: scope,
                icon: Icon(_scopeIcon(scope), size: 18),
                label: Text(
                  '${scope.label} (${preview.countFor(scope)})',
                  key: ValueKey(
                    'employee-workflow-inbox-sla-playbook-audit-export-scope-${scope.name}',
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

@Preview(name: 'Employee workflow inbox SLA playbook audit export')
Widget employeeWorkflowInboxSlaPlaybookAuditExportPreviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaPlaybookAuditExportPreviewPanel(
          preview: EmployeeWorkflowInboxSlaPlaybookAuditExportPreview(
            profile: _previewProfile,
            generatedAt: DateTime(2026, 6, 1, 12),
          ),
        ),
      ),
    ),
  );
}

/// Compact manifest value chip used by the playbook audit export preview.
class _PlaybookAuditExportManifestChip extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportManifestItem item;

  const _PlaybookAuditExportManifestChip({required this.item});

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

/// Monospace sample block showing the first playbook audit export rows.
class _PlaybookAuditCsvSample extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview;

  const _PlaybookAuditCsvSample({required this.preview});

  @override
  Widget build(BuildContext context) {
    final lines = preview.csvContent.split('\n').take(4).toList();

    return _ExportSampleBlock(
      title: 'CSV audit sample',
      lines: lines,
      emptyMessage: 'No audit rows available',
    );
  }
}

/// Monospace sample block showing a plain-text audit package preview.
class _PlaybookAuditPlainTextSample extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditExportPreview preview;

  const _PlaybookAuditPlainTextSample({required this.preview});

  @override
  Widget build(BuildContext context) {
    final lines = preview.plainTextContent.split('\n').take(7).toList();

    return _ExportSampleBlock(
      title: 'Plain-text package',
      lines: lines,
      emptyMessage: 'No audit text available',
    );
  }
}

/// Shared sample renderer for playbook audit package previews.
class _ExportSampleBlock extends StatelessWidget {
  final String title;
  final List<String> lines;
  final String emptyMessage;

  const _ExportSampleBlock({
    required this.title,
    required this.lines,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
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
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            lines.isEmpty ? emptyMessage : lines.join('\n'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontFamily: 'monospace',
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

EmployeeWorkflowInboxSlaPlaybookActionProfile get _previewProfile {
  return EmployeeWorkflowInboxSlaPlaybookActionProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-002',
        receiptKind:
            EmployeeWorkflowInboxSlaPlaybookActionReceiptKind.reasonCorrection,
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'ready',
        stepTitle: 'Clear ready inbox actions',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
        actor: 'HR Auditor',
        owner: 'People Operations',
        itemCount: 2,
        sources: const [EmployeeWorkflowInboxSource.profileChange],
        reason: 'Ready queue assigned to HR lead for same-day closure',
        previousReason: 'Recovery started to prevent SLA drift',
        correctedReceiptId: 'EWP-4-001',
        decidedAt: DateTime(2026, 6, 1, 9),
      ),
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'ready',
        stepTitle: 'Clear ready inbox actions',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
        actor: 'People Operations',
        owner: 'People Operations',
        itemCount: 2,
        sources: const [EmployeeWorkflowInboxSource.profileChange],
        reason: 'Recovery started to prevent SLA drift',
        decidedAt: DateTime(2026, 6, 1, 8),
      ),
    ],
  );
}

Color _statusColor(EmployeeWorkflowInboxSlaPlaybookAuditExportStatus status) {
  return switch (status) {
    EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.empty => HrisColors.muted,
    EmployeeWorkflowInboxSlaPlaybookAuditExportStatus.ready => const Color(
      0xFF15803D,
    ),
  };
}

IconData _scopeIcon(EmployeeWorkflowInboxSlaPlaybookAuditExportScope scope) {
  return switch (scope) {
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.all =>
      Icons.inventory_2_outlined,
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.actions =>
      Icons.task_alt_outlined,
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.corrections =>
      Icons.edit_note_outlined,
    EmployeeWorkflowInboxSlaPlaybookAuditExportScope.reasoned =>
      Icons.notes_outlined,
  };
}

IconData _roleIcon(EmployeeWorkflowInboxSlaPlaybookAuditExportRole role) {
  return switch (role) {
    EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations =>
      Icons.admin_panel_settings_outlined,
    EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager =>
      Icons.supervisor_account_outlined,
    EmployeeWorkflowInboxSlaPlaybookAuditExportRole.hrAuditor =>
      Icons.fact_check_outlined,
  };
}

IconData _permissionIcon(
  EmployeeWorkflowInboxSlaPlaybookAuditExportPermission permission,
) {
  return permission.allowed ? Icons.verified_user_outlined : Icons.lock_outline;
}

Future<void> _copyText(
  BuildContext context,
  String value,
  String message, {
  VoidCallback? onCopied,
}) async {
  await Clipboard.setData(ClipboardData(text: value));
  onCopied?.call();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
