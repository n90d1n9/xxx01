import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_follow_up_cadence.dart';
import '../models/company_governance_owner_load.dart';

/// Shows next-touch governance follow-up cadence for owner handoffs.
class CompanyGovernanceFollowUpCadencePanel extends StatelessWidget {
  final List<CompanyGovernanceFollowUpLane> lanes;
  final DateTime asOfDate;
  final ValueChanged<String>? onOwnerSelected;
  final ValueChanged<String>? onAuditEventSelected;
  final ValueChanged<CompanyGovernanceFollowUpLane>? onRecordFollowUp;

  const CompanyGovernanceFollowUpCadencePanel({
    super.key,
    required this.lanes,
    required this.asOfDate,
    this.onOwnerSelected,
    this.onAuditEventSelected,
    this.onRecordFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final needsHandoffCount =
        lanes
            .where(
              (lane) =>
                  lane.state == CompanyGovernanceFollowUpState.needsHandoff,
            )
            .length;
    final overdueCount =
        lanes
            .where(
              (lane) => lane.state == CompanyGovernanceFollowUpState.overdue,
            )
            .length;

    return HrisSectionPanel(
      icon: Icons.event_repeat_outlined,
      title: 'Governance Follow-up Cadence',
      subtitle:
          lanes.isEmpty
              ? 'No governance follow-up lanes'
              : '$needsHandoffCount need handoff, $overdueCount overdue',
      emptyMessage: 'No governance follow-up cadence',
      children:
          lanes.isEmpty
              ? const []
              : [
                _CadenceSummaryStrip(lanes: lanes),
                for (final lane in lanes)
                  _CadenceLaneTile(
                    lane: lane,
                    asOfDate: asOfDate,
                    onOwnerSelected:
                        onOwnerSelected == null
                            ? null
                            : () => onOwnerSelected!(lane.ownerLabel),
                    onAuditEventSelected:
                        onAuditEventSelected == null || !lane.hasAuditEvent
                            ? null
                            : () => onAuditEventSelected!(lane.auditEventId),
                    onRecordFollowUp:
                        onRecordFollowUp == null || !lane.canRecordFollowUp
                            ? null
                            : () => onRecordFollowUp!(lane),
                  ),
              ],
    );
  }
}

/// Compact summary of follow-up cadence risk.
class _CadenceSummaryStrip extends StatelessWidget {
  final List<CompanyGovernanceFollowUpLane> lanes;

  const _CadenceSummaryStrip({required this.lanes});

  @override
  Widget build(BuildContext context) {
    final needsHandoffCount = _countState(
      lanes,
      CompanyGovernanceFollowUpState.needsHandoff,
    );
    final overdueCount = _countState(
      lanes,
      CompanyGovernanceFollowUpState.overdue,
    );
    final dueTodayCount = _countState(
      lanes,
      CompanyGovernanceFollowUpState.dueToday,
    );
    final scheduledCount = _countState(
      lanes,
      CompanyGovernanceFollowUpState.scheduled,
    );

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Lanes', value: '${lanes.length}'),
        HrisMetricStripItem(label: 'No handoff', value: '$needsHandoffCount'),
        HrisMetricStripItem(label: 'Overdue', value: '$overdueCount'),
        HrisMetricStripItem(
          label: dueTodayCount == 0 ? 'Scheduled' : 'Due today',
          value: dueTodayCount == 0 ? '$scheduledCount' : '$dueTodayCount',
        ),
      ],
    );
  }
}

/// One governance owner follow-up cadence row.
class _CadenceLaneTile extends StatelessWidget {
  final CompanyGovernanceFollowUpLane lane;
  final DateTime asOfDate;
  final VoidCallback? onOwnerSelected;
  final VoidCallback? onAuditEventSelected;
  final VoidCallback? onRecordFollowUp;

  const _CadenceLaneTile({
    required this.lane,
    required this.asOfDate,
    required this.onOwnerSelected,
    required this.onAuditEventSelected,
    required this.onRecordFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(lane.state);
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
                      lane.ownerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lane.sourceSummary} - ${lane.queueDueLabel}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(label: lane.state.label, color: stateColor),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: lane.risk.label,
                    color: _riskColor(lane.risk),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Next touch',
                value: lane.nextTouchLabel(asOfDate),
              ),
              HrisMetricStripItem(
                label: 'Last touch',
                value: lane.lastTouchLabel(asOfDate),
              ),
              HrisMetricStripItem(
                label: 'Actions',
                value: '${lane.actionCount}',
              ),
              HrisMetricStripItem(
                label: 'Follow-ups',
                value: '${lane.followUpCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final rationale = _CadenceRationale(
                lane: lane,
                color: stateColor,
              );
              final actions = _CadenceActions(
                lane: lane,
                onOwnerSelected: onOwnerSelected,
                onAuditEventSelected: onAuditEventSelected,
                onRecordFollowUp: onRecordFollowUp,
              );

              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [rationale, const SizedBox(height: 12), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: rationale),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: actions,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Explains why the governance follow-up lane is in its current state.
class _CadenceRationale extends StatelessWidget {
  final CompanyGovernanceFollowUpLane lane;
  final Color color;

  const _CadenceRationale({required this.lane, required this.color});

  @override
  Widget build(BuildContext context) {
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
          Icon(Icons.notification_important_outlined, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lane.rationale,
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
    );
  }
}

/// Action cluster for a governance follow-up lane.
class _CadenceActions extends StatelessWidget {
  final CompanyGovernanceFollowUpLane lane;
  final VoidCallback? onOwnerSelected;
  final VoidCallback? onAuditEventSelected;
  final VoidCallback? onRecordFollowUp;

  const _CadenceActions({
    required this.lane,
    required this.onOwnerSelected,
    required this.onAuditEventSelected,
    required this.onRecordFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (onAuditEventSelected != null)
          OutlinedButton.icon(
            key: Key('company-governance-follow-up-audit-${lane.ownerLabel}'),
            onPressed: onAuditEventSelected,
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('View audit'),
          ),
        if (onOwnerSelected != null)
          OutlinedButton.icon(
            key: Key('company-governance-follow-up-owner-${lane.ownerLabel}'),
            onPressed: onOwnerSelected,
            icon: const Icon(Icons.manage_accounts_outlined),
            label: const Text('Review owner'),
          ),
        if (onRecordFollowUp != null)
          FilledButton.icon(
            key: Key('company-governance-follow-up-record-${lane.ownerLabel}'),
            onPressed: onRecordFollowUp,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Record follow-up'),
          ),
      ],
    );
  }
}

int _countState(
  List<CompanyGovernanceFollowUpLane> lanes,
  CompanyGovernanceFollowUpState state,
) {
  return lanes.where((lane) => lane.state == state).length;
}

Color _stateColor(CompanyGovernanceFollowUpState state) {
  switch (state) {
    case CompanyGovernanceFollowUpState.needsHandoff:
      return Colors.deepPurple;
    case CompanyGovernanceFollowUpState.overdue:
      return Colors.red;
    case CompanyGovernanceFollowUpState.dueToday:
      return Colors.orange;
    case CompanyGovernanceFollowUpState.scheduled:
      return Colors.green;
  }
}

Color _riskColor(CompanyGovernanceOwnerLoadRisk risk) {
  switch (risk) {
    case CompanyGovernanceOwnerLoadRisk.critical:
      return Colors.red;
    case CompanyGovernanceOwnerLoadRisk.high:
      return Colors.orange;
    case CompanyGovernanceOwnerLoadRisk.steady:
      return Colors.green;
  }
}

@Preview(name: 'Company governance follow-up cadence panel')
Widget companyGovernanceFollowUpCadencePanelPreview() {
  final asOfDate = DateTime(2026, 6, 11);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceFollowUpCadencePanel(
          asOfDate: asOfDate,
          lanes: [
            CompanyGovernanceFollowUpLane(
              ownerName: 'People Operations',
              risk: CompanyGovernanceOwnerLoadRisk.critical,
              actionCount: 2,
              criticalCount: 1,
              highCount: 1,
              sourceSummary: '1 filing, 1 account',
              primaryActionLabel: 'Submit labor report receipt',
              queueDueLabel: 'Overdue 3d',
              handoffRecordId: 'governance-handoff-preview',
              handoffAuditEventId: 'audit-091',
              lastHandoffAt: DateTime(2026, 6, 10),
              nextTouchDate: DateTime(2026, 6, 11),
              state: CompanyGovernanceFollowUpState.dueToday,
              rationale:
                  'Critical load with 2 active actions across 1 filing, 1 account. Follow-up is due today.',
            ),
            CompanyGovernanceFollowUpLane(
              ownerName: 'Legal Operations',
              risk: CompanyGovernanceOwnerLoadRisk.high,
              actionCount: 1,
              criticalCount: 0,
              highCount: 1,
              sourceSummary: '1 vendor',
              primaryActionLabel: 'Renew e-signature agreement',
              queueDueLabel: 'Contract ends in 12d',
              nextTouchDate: asOfDate,
              state: CompanyGovernanceFollowUpState.needsHandoff,
              rationale:
                  'Legal Operations has 1 active governance action and no recorded handoff.',
            ),
          ],
          onOwnerSelected: _previewOwnerSelected,
          onAuditEventSelected: _previewAuditEventSelected,
          onRecordFollowUp: _previewRecordFollowUp,
        ),
      ),
    ),
  );
}

void _previewOwnerSelected(String ownerName) {}

void _previewAuditEventSelected(String auditEventId) {}

void _previewRecordFollowUp(CompanyGovernanceFollowUpLane lane) {}
