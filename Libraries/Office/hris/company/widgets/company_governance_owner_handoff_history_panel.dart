import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_owner_handoff_history.dart';
import '../models/company_governance_owner_handoff_record.dart';

/// Displays the recorded governance handoff ledger for owner follow-through.
class CompanyGovernanceOwnerHandoffHistoryPanel extends StatelessWidget {
  final CompanyGovernanceOwnerHandoffHistory history;
  final String? selectedOwnerName;
  final ValueChanged<String>? onOwnerSelected;
  final ValueChanged<String>? onAuditEventSelected;

  const CompanyGovernanceOwnerHandoffHistoryPanel({
    super.key,
    required this.history,
    this.selectedOwnerName,
    this.onOwnerSelected,
    this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    final records = history.prioritizedRecords(selectedOwnerName);

    return HrisSectionPanel(
      icon: Icons.manage_history_outlined,
      title: 'Governance Handoff History',
      subtitle:
          history.isEmpty
              ? 'No recorded owner handoffs'
              : '${history.recordCount} records, '
                  '${history.ownerCount} owner lanes',
      emptyMessage: 'No recorded governance owner handoffs',
      children:
          history.isEmpty
              ? const []
              : [
                _HandoffHistorySummary(
                  history: history,
                  selectedOwnerName: selectedOwnerName,
                ),
                for (final record in records)
                  _HandoffHistoryRecordTile(
                    record: record,
                    isSelectedOwner: _sameOwner(
                      record.ownerLabel,
                      selectedOwnerName,
                    ),
                    onOwnerSelected:
                        onOwnerSelected == null
                            ? null
                            : () => onOwnerSelected!(record.ownerLabel),
                    onAuditEventSelected:
                        onAuditEventSelected == null || !record.hasAuditEvent
                            ? null
                            : () => onAuditEventSelected!(record.auditEventId),
                  ),
              ],
    );
  }
}

/// Compact metrics for the governance handoff ledger.
class _HandoffHistorySummary extends StatelessWidget {
  final CompanyGovernanceOwnerHandoffHistory history;
  final String? selectedOwnerName;

  const _HandoffHistorySummary({
    required this.history,
    required this.selectedOwnerName,
  });

  @override
  Widget build(BuildContext context) {
    final selectedRecordCount = history.matchingRecordCount(selectedOwnerName);
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Records', value: '${history.recordCount}'),
        HrisMetricStripItem(
          label: selectedRecordCount == 0 ? 'Owners' : 'Selected',
          value:
              selectedRecordCount == 0
                  ? '${history.ownerCount}'
                  : '$selectedRecordCount',
        ),
        HrisMetricStripItem(
          label: 'Critical',
          value: '${history.criticalCount}',
        ),
        HrisMetricStripItem(label: 'Latest', value: history.latestLabel),
      ],
    );
  }
}

/// One recorded governance owner handoff in the ledger.
class _HandoffHistoryRecordTile extends StatelessWidget {
  final CompanyGovernanceOwnerHandoffRecord record;
  final bool isSelectedOwner;
  final VoidCallback? onOwnerSelected;
  final VoidCallback? onAuditEventSelected;

  const _HandoffHistoryRecordTile({
    required this.record,
    required this.isSelectedOwner,
    required this.onOwnerSelected,
    required this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(record);
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.ownerLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (isSelectedOwner) ...[
                          const SizedBox(width: 8),
                          HrisStatusPill(
                            label: 'Scoped',
                            color: HrisColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.actorName} - ${record.sourceSummary}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: record.recordedDateLabel, color: riskColor),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Actions',
                value: '${record.actionCount}',
              ),
              HrisMetricStripItem(
                label: 'Critical',
                value: '${record.criticalCount}',
              ),
              HrisMetricStripItem(label: 'High', value: '${record.highCount}'),
              HrisMetricStripItem(label: 'Next', value: record.nextDueLabel),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: riskColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.outgoing_mail, color: riskColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    record.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onOwnerSelected != null || onAuditEventSelected != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (onAuditEventSelected != null)
                    OutlinedButton.icon(
                      key: Key(
                        'company-governance-handoff-history-audit-${record.id}',
                      ),
                      onPressed: onAuditEventSelected,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('View audit'),
                    ),
                  if (onOwnerSelected != null)
                    OutlinedButton.icon(
                      key: Key(
                        'company-governance-handoff-history-owner-${record.id}',
                      ),
                      onPressed: onOwnerSelected,
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: const Text('Review owner'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _riskColor(CompanyGovernanceOwnerHandoffRecord record) {
  if (record.criticalCount > 0) return Colors.red;
  if (record.highCount > 0) return Colors.orange;
  return Colors.green;
}

bool _sameOwner(String ownerName, String? selectedOwnerName) {
  return ownerName.trim().toLowerCase() ==
      (selectedOwnerName ?? '').trim().toLowerCase();
}

@Preview(name: 'Company governance owner handoff history panel')
Widget companyGovernanceOwnerHandoffHistoryPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceOwnerHandoffHistoryPanel(
          selectedOwnerName: 'People Operations',
          history: CompanyGovernanceOwnerHandoffHistory.fromRecords(
            records: [
              CompanyGovernanceOwnerHandoffRecord(
                id: 'governance-handoff-preview-002',
                ownerName: 'Legal Operations',
                actionCount: 1,
                criticalCount: 0,
                highCount: 1,
                sourceSummary: '1 vendor agreement',
                nextDueLabel: 'Contract ends in 12d',
                message:
                    'Legal Operations has 1 governance action across 1 vendor agreement. Priority is 1 high, next touch is Contract ends in 12d.',
                recordedAt: DateTime(2026, 6, 11),
                actorName: 'People Operations',
              ),
              CompanyGovernanceOwnerHandoffRecord(
                id: 'governance-handoff-preview-001',
                ownerName: 'People Operations',
                actionCount: 2,
                criticalCount: 1,
                highCount: 1,
                sourceSummary: '1 filing, 1 employer account',
                nextDueLabel: 'Overdue 3d',
                message:
                    'People Operations has 2 governance actions across 1 filing, 1 employer account. Priority is 1 critical, next touch is Overdue 3d.',
                recordedAt: DateTime(2026, 6, 10),
                actorName: 'People Operations',
                auditEventId: 'audit-091',
              ),
            ],
          ),
          onOwnerSelected: _previewOwnerSelected,
          onAuditEventSelected: _previewAuditEventSelected,
        ),
      ),
    ),
  );
}

void _previewOwnerSelected(String ownerName) {}

void _previewAuditEventSelected(String auditEventId) {}
