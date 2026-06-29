import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_delivery_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_export_access_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_audit_export_models.dart';

/// Delivery history for copied workflow inbox SLA playbook audit packages.
class EmployeeWorkflowInboxSlaPlaybookAuditDeliveryHistory
    extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile profile;
  final int maxItems;

  const EmployeeWorkflowInboxSlaPlaybookAuditDeliveryHistory({
    super.key,
    required this.profile,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final latest = profile.latest.take(maxItems).toList();

    return HrisListSurface(
      key: const ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-delivery-history',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Audit export delivery history',
                  key: const ValueKey(
                    'employee-workflow-inbox-sla-playbook-audit-delivery-heading',
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: '${profile.totalCount} logged',
                color: _historyColor(profile.totalCount),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            profile.nextAction,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Deliveries',
                value: '${profile.totalCount}',
              ),
              HrisMetricStripItem(label: 'CSV', value: '${profile.csvCount}'),
              HrisMetricStripItem(label: 'Text', value: '${profile.textCount}'),
              HrisMetricStripItem(
                label: 'Redacted',
                value: '${profile.redactedCount}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (latest.isEmpty)
            const HrisEmptyState(message: 'No audit export deliveries yet')
          else
            ...latest.map(
              (delivery) => _AuditDeliveryReceiptTile(delivery: delivery),
            ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox SLA playbook audit delivery history')
Widget employeeWorkflowInboxSlaPlaybookAuditDeliveryHistoryPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaPlaybookAuditDeliveryHistory(
          profile: _previewDeliveryProfile,
        ),
      ),
    ),
  );
}

/// Compact tile for one copied playbook audit export package.
class _AuditDeliveryReceiptTile extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt delivery;

  const _AuditDeliveryReceiptTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final statusColor = _deliveryColor(delivery);

    return Container(
      key: ValueKey(
        'employee-workflow-inbox-sla-playbook-audit-delivery-${delivery.id}',
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_deliveryIcon(delivery), color: statusColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        delivery.summaryLabel,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(
                      label: delivery.statusLabel,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  delivery.packageLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _AuditDeliveryMetaChip(
                      icon: Icons.person_outline,
                      label: delivery.roleLabel,
                    ),
                    _AuditDeliveryMetaChip(
                      icon: Icons.rule_folder_outlined,
                      label: delivery.scopeLabel,
                    ),
                    _AuditDeliveryMetaChip(
                      icon:
                          delivery.isRedacted
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                      label: delivery.redactionLabel,
                    ),
                    _AuditDeliveryMetaChip(
                      icon: Icons.schedule_outlined,
                      label: delivery.deliveredAtLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small metadata chip used inside an audit export delivery receipt tile.
class _AuditDeliveryMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AuditDeliveryMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile
get _previewDeliveryProfile {
  return EmployeeWorkflowInboxSlaPlaybookAuditDeliveryProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    deliveries: [
      EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt(
        id: 'EWPA-4-002',
        employeeId: '4',
        employeeName: 'David Kim',
        role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.manager,
        action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyText,
        scope: EmployeeWorkflowInboxSlaPlaybookAuditExportScope.actions,
        redaction:
            EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.managerSafe,
        status: EmployeeWorkflowInboxSlaPlaybookAuditDeliveryStatus.copied,
        fileName:
            'employee-4-workflow-inbox-playbook-audit-actions-manager-redacted.csv',
        rowCount: 1,
        generatedAt: DateTime(2026, 6, 1, 12),
        deliveredAt: DateTime(2026, 6, 1, 12, 15),
      ),
      EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt(
        id: 'EWPA-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        role: EmployeeWorkflowInboxSlaPlaybookAuditExportRole.peopleOperations,
        action: EmployeeWorkflowInboxSlaPlaybookAuditExportAction.copyCsv,
        scope: EmployeeWorkflowInboxSlaPlaybookAuditExportScope.all,
        redaction: EmployeeWorkflowInboxSlaPlaybookAuditExportRedaction.none,
        status: EmployeeWorkflowInboxSlaPlaybookAuditDeliveryStatus.copied,
        fileName: 'employee-4-workflow-inbox-playbook-audit-full.csv',
        rowCount: 2,
        generatedAt: DateTime(2026, 6, 1, 12),
        deliveredAt: DateTime(2026, 6, 1, 12, 5),
      ),
    ],
  );
}

Color _historyColor(int totalCount) {
  return totalCount == 0 ? HrisColors.muted : const Color(0xFF15803D);
}

Color _deliveryColor(
  EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt delivery,
) {
  return delivery.isRedacted
      ? const Color(0xFF7C3AED)
      : const Color(0xFF15803D);
}

IconData _deliveryIcon(
  EmployeeWorkflowInboxSlaPlaybookAuditDeliveryReceipt delivery,
) {
  if (delivery.isCsv) return Icons.table_chart_outlined;
  return Icons.article_outlined;
}
