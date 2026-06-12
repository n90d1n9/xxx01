import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_follow_up_policy.dart';
import '../models/company_governance_follow_up_policy_history.dart';

/// Shows governance follow-up SLA policy changes and restore actions.
class CompanyGovernanceFollowUpPolicyHistoryPanel extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyHistory history;
  final CompanyGovernanceFollowUpPolicy currentPolicy;
  final ValueChanged<CompanyGovernanceFollowUpPolicyChangeRecord>?
  onRestorePolicy;
  final ValueChanged<String>? onAuditEventSelected;

  const CompanyGovernanceFollowUpPolicyHistoryPanel({
    super.key,
    required this.history,
    required this.currentPolicy,
    this.onRestorePolicy,
    this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_history_outlined,
      title: 'Governance SLA History',
      subtitle:
          history.isEmpty
              ? 'No policy changes yet'
              : '${history.recordCount} changes, ${history.auditedCount} audited',
      emptyMessage: 'No governance SLA policy changes',
      children:
          history.isEmpty
              ? const []
              : [
                _HistorySummaryStrip(
                  history: history,
                  currentPolicy: currentPolicy,
                ),
                for (final record in history.records)
                  _HistoryRecordTile(
                    record: record,
                    currentPolicy: currentPolicy,
                    onRestorePolicy:
                        onRestorePolicy == null ||
                                record.previousPolicy == currentPolicy
                            ? null
                            : () => onRestorePolicy!(record),
                    onAuditEventSelected:
                        onAuditEventSelected == null || !record.hasAuditEvent
                            ? null
                            : () => onAuditEventSelected!(record.auditEventId),
                  ),
              ],
    );
  }
}

/// Compact summary of current SLA history state.
class _HistorySummaryStrip extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyHistory history;
  final CompanyGovernanceFollowUpPolicy currentPolicy;

  const _HistorySummaryStrip({
    required this.history,
    required this.currentPolicy,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Changes', value: '${history.recordCount}'),
        HrisMetricStripItem(label: 'Audited', value: '${history.auditedCount}'),
        HrisMetricStripItem(label: 'Latest', value: history.latestLabel),
        HrisMetricStripItem(
          label: 'Current',
          value: currentPolicy.compactLabel,
        ),
      ],
    );
  }
}

/// One governance follow-up SLA history record.
class _HistoryRecordTile extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyChangeRecord record;
  final CompanyGovernanceFollowUpPolicy currentPolicy;
  final VoidCallback? onRestorePolicy;
  final VoidCallback? onAuditEventSelected;

  const _HistoryRecordTile({
    required this.record,
    required this.currentPolicy,
    required this.onRestorePolicy,
    required this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      record.recordedDateLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.actorName} - ${record.entityName}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(
                label: record.hasAuditEvent ? 'Audited' : 'Recorded',
                color: record.hasAuditEvent ? Colors.indigo : Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.policyChangeLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Changed',
                value: '${record.changedLaneCount}',
              ),
              HrisMetricStripItem(
                label: 'Due now',
                value: '${record.dueNowCount}',
              ),
              HrisMetricStripItem(
                label: 'No handoff',
                value: '${record.needsHandoffCount}',
              ),
              HrisMetricStripItem(
                label: 'Scheduled',
                value: '${record.scheduledCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TopChangeBanner(record: record),
          if (onRestorePolicy != null || onAuditEventSelected != null) ...[
            const SizedBox(height: 12),
            _HistoryActions(
              onRestorePolicy: onRestorePolicy,
              onAuditEventSelected: onAuditEventSelected,
            ),
          ],
        ],
      ),
    );
  }
}

/// Highlights the most important owner lane affected by a policy change.
class _TopChangeBanner extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyChangeRecord record;

  const _TopChangeBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.route_outlined, color: Colors.indigo, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              record.topChangeLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action row for restoring a prior SLA or opening its audit event.
class _HistoryActions extends StatelessWidget {
  final VoidCallback? onRestorePolicy;
  final VoidCallback? onAuditEventSelected;

  const _HistoryActions({
    required this.onRestorePolicy,
    required this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          if (onAuditEventSelected != null)
            OutlinedButton.icon(
              key: const Key('company-governance-sla-history-audit-button'),
              onPressed: onAuditEventSelected,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('View audit'),
            ),
          if (onRestorePolicy != null)
            FilledButton.icon(
              key: const Key('company-governance-sla-history-restore-button'),
              onPressed: onRestorePolicy,
              icon: const Icon(Icons.restore_outlined),
              label: const Text('Restore policy'),
            ),
        ],
      ),
    );
  }
}

@Preview(name: 'Company governance follow-up SLA history panel')
Widget companyGovernanceFollowUpPolicyHistoryPanelPreview() {
  const currentPolicy = CompanyGovernanceFollowUpPolicy(
    criticalCadenceDays: 3,
    highCadenceDays: 5,
    steadyCadenceDays: 7,
  );
  const previousPolicy = CompanyGovernanceFollowUpPolicy(
    criticalCadenceDays: 1,
    highCadenceDays: 2,
    steadyCadenceDays: 3,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceFollowUpPolicyHistoryPanel(
          currentPolicy: currentPolicy,
          history: CompanyGovernanceFollowUpPolicyHistory(
            records: [
              CompanyGovernanceFollowUpPolicyChangeRecord(
                id: 'governance-sla-001',
                previousPolicy: previousPolicy,
                nextPolicy: currentPolicy,
                entityName: 'Company Governance',
                actorName: 'People Operations',
                recordedAt: DateTime(2026, 6, 12),
                impactHeadline: '1 lane shifts timing',
                dueNowCount: 0,
                changedLaneCount: 1,
                needsHandoffCount: 2,
                scheduledCount: 1,
                topOwnerName: 'People Operations',
                topOwnerBeforeLabel: '1d overdue',
                topOwnerAfterLabel: 'Due tomorrow',
                auditEventId: 'audit-101',
              ),
            ],
          ),
          onRestorePolicy: _previewRestorePolicy,
          onAuditEventSelected: _previewAuditSelected,
        ),
      ),
    ),
  );
}

void _previewRestorePolicy(
  CompanyGovernanceFollowUpPolicyChangeRecord record,
) {}

void _previewAuditSelected(String auditEventId) {}
