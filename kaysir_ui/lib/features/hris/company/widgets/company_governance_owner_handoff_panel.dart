import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_owner_handoff.dart';
import '../models/company_governance_owner_handoff_record.dart';

/// Shows an owner-specific brief for handing off governance remediation.
class CompanyGovernanceOwnerHandoffPanel extends StatelessWidget {
  final CompanyGovernanceOwnerHandoff? handoff;
  final CompanyGovernanceOwnerHandoffRecord? lastRecord;
  final ValueChanged<CompanyGovernanceOwnerHandoff>? onRecordHandoff;

  const CompanyGovernanceOwnerHandoffPanel({
    super.key,
    required this.handoff,
    this.lastRecord,
    this.onRecordHandoff,
  });

  @override
  Widget build(BuildContext context) {
    final handoff = this.handoff;
    return HrisSectionPanel(
      icon: Icons.forward_to_inbox_outlined,
      title: 'Governance Owner Handoff',
      subtitle:
          handoff == null
              ? 'Select an owner lane to prepare a handoff'
              : '${handoff.actionCount} actions for ${handoff.ownerLabel}',
      emptyMessage: 'Select a governance owner to prepare a handoff',
      children:
          handoff == null
              ? const []
              : [
                _HandoffSummary(handoff: handoff),
                if (lastRecord != null)
                  _HandoffRecordStatus(record: lastRecord!),
                _HandoffMessage(handoff: handoff),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('company-governance-owner-handoff-record'),
                    onPressed:
                        onRecordHandoff == null
                            ? null
                            : () => onRecordHandoff!(handoff),
                    icon: const Icon(Icons.outgoing_mail),
                    label: const Text('Record handoff'),
                  ),
                ),
                for (final action in handoff.actions)
                  _HandoffActionTile(action: action),
              ],
    );
  }
}

/// Shows the latest recorded handoff status for the selected owner.
class _HandoffRecordStatus extends StatelessWidget {
  final CompanyGovernanceOwnerHandoffRecord record;

  const _HandoffRecordStatus({required this.record});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Last recorded ${record.recordedDateLabel} by ${record.actorName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          HrisStatusPill(
            label: '${record.actionCount} actions',
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

/// Compact metrics for an owner governance handoff.
class _HandoffSummary extends StatelessWidget {
  final CompanyGovernanceOwnerHandoff handoff;

  const _HandoffSummary({required this.handoff});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Actions', value: '${handoff.actionCount}'),
        HrisMetricStripItem(
          label: 'Critical',
          value: '${handoff.criticalCount}',
        ),
        HrisMetricStripItem(label: 'High', value: '${handoff.highCount}'),
        HrisMetricStripItem(label: 'Next', value: handoff.nextDueLabel),
      ],
    );
  }
}

/// Generated owner handoff message for governance routing.
class _HandoffMessage extends StatelessWidget {
  final CompanyGovernanceOwnerHandoff handoff;

  const _HandoffMessage({required this.handoff});

  @override
  Widget build(BuildContext context) {
    final color = handoff.hasCriticalActions ? Colors.red : Colors.orange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.outgoing_mail, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handoff.ownerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  handoff.handoffMessage,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One top action included in the owner handoff.
class _HandoffActionTile extends StatelessWidget {
  final CompanyGovernanceOwnerHandoffAction action;

  const _HandoffActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color =
        action.severityLabel == 'Critical' ? Colors.red : Colors.orange;
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  action.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: action.sourceLabel, color: Colors.indigo),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Priority',
                value: action.severityLabel,
              ),
              HrisMetricStripItem(label: 'Timing', value: action.dueLabel),
              HrisMetricStripItem(label: 'Resolve', value: action.resolveLabel),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            action.actionLabel,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Company governance owner handoff panel')
Widget companyGovernanceOwnerHandoffPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceOwnerHandoffPanel(
          lastRecord: CompanyGovernanceOwnerHandoffRecord(
            id: 'governance-handoff-preview',
            ownerName: 'People Operations',
            actionCount: 2,
            criticalCount: 1,
            highCount: 1,
            sourceSummary: '1 filing, 1 employer account',
            nextDueLabel: 'Overdue 3d',
            message:
                'People Operations has 2 governance actions across 1 filing, 1 employer account.',
            recordedAt: DateTime(2026, 6, 10),
            actorName: 'People Operations',
          ),
          handoff: CompanyGovernanceOwnerHandoff(
            ownerName: 'People Operations',
            actionCount: 2,
            criticalCount: 1,
            highCount: 1,
            sourceSummary: '1 filing, 1 employer account',
            nextDueLabel: 'Overdue 3d',
            handoffMessage:
                'People Operations has 2 governance actions across 1 filing, 1 employer account. Priority is 1 critical, next touch is Overdue 3d. Start with: Submit labor report receipt.',
            actions: const [
              CompanyGovernanceOwnerHandoffAction(
                id: 'filing-labor-report',
                title: 'Annual WLK labor report',
                sourceLabel: 'Filing',
                severityLabel: 'Critical',
                dueLabel: 'Overdue 3d',
                resolveLabel: 'Mark filed',
                actionLabel: 'Submit labor report receipt',
              ),
            ],
          ),
          onRecordHandoff: _previewRecordHandoff,
        ),
      ),
    ),
  );
}

void _previewRecordHandoff(CompanyGovernanceOwnerHandoff handoff) {}
