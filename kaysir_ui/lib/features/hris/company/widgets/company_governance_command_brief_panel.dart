import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_action_filter.dart';
import '../models/company_governance_action_item.dart';
import '../models/company_governance_command_brief.dart';
import '../models/company_governance_follow_up_cadence.dart';
import '../models/company_governance_saved_view.dart';

/// Shows the next best action for the active governance saved view.
class CompanyGovernanceCommandBriefPanel extends StatelessWidget {
  final CompanyGovernanceCommandBrief brief;
  final ValueChanged<String>? onOwnerSelected;
  final ValueChanged<CompanyGovernanceActionItem>? onActionSelected;
  final ValueChanged<CompanyGovernanceFollowUpLane>? onRecordFollowUp;

  const CompanyGovernanceCommandBriefPanel({
    super.key,
    required this.brief,
    this.onOwnerSelected,
    this.onActionSelected,
    this.onRecordFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.tips_and_updates_outlined,
      title: 'Governance Command Brief',
      subtitle: '${brief.selectedView.title} - ${brief.intent.label}',
      emptyMessage: 'No governance command brief',
      children: [
        _CommandBriefSummary(brief: brief),
        _CommandBriefHero(brief: brief),
        if (brief.primaryAction != null)
          _PrimaryActionCard(
            action: brief.primaryAction!,
            onActionSelected:
                onActionSelected == null
                    ? null
                    : () => onActionSelected!(brief.primaryAction!),
          ),
        _CommandBriefActions(
          brief: brief,
          onOwnerSelected:
              onOwnerSelected == null || !brief.hasOwnerScope
                  ? null
                  : () => onOwnerSelected!(brief.ownerLabel),
          onActionSelected:
              onActionSelected == null || brief.primaryAction == null
                  ? null
                  : () => onActionSelected!(brief.primaryAction!),
          onRecordFollowUp:
              onRecordFollowUp == null || !brief.canRecordFollowUp
                  ? null
                  : () => onRecordFollowUp!(brief.primaryFollowUpLane!),
        ),
      ],
    );
  }
}

/// Compact metrics that explain the active command brief scope.
class _CommandBriefSummary extends StatelessWidget {
  final CompanyGovernanceCommandBrief brief;

  const _CommandBriefSummary({required this.brief});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Actions',
          value: '${brief.visibleActionCount}',
        ),
        HrisMetricStripItem(
          label: 'Critical',
          value: '${brief.criticalActionCount}',
        ),
        HrisMetricStripItem(
          label: 'Due touches',
          value: '${brief.dueFollowUpCount}',
        ),
        HrisMetricStripItem(
          label: 'No handoff',
          value: '${brief.needsHandoffCount}',
        ),
      ],
    );
  }
}

/// Hero card for the recommended governance command.
class _CommandBriefHero extends StatelessWidget {
  final CompanyGovernanceCommandBrief brief;

  const _CommandBriefHero({required this.brief});

  @override
  Widget build(BuildContext context) {
    final color = _intentColor(brief.intent);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_intentIcon(brief.intent), color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        brief.headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: brief.intent.label, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  brief.recommendation,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                HrisMetricStrip(
                  items: [
                    HrisMetricStripItem(
                      label: 'View',
                      value: brief.selectedView.title,
                    ),
                    HrisMetricStripItem(
                      label: 'Queue',
                      value: brief.queueFilter.label,
                    ),
                    HrisMetricStripItem(
                      label: 'Owner',
                      value: brief.ownerLabel,
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

/// Shows the primary queue action selected by the command brief.
class _PrimaryActionCard extends StatelessWidget {
  final CompanyGovernanceActionItem action;
  final VoidCallback? onActionSelected;

  const _PrimaryActionCard({
    required this.action,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(action.severity);
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: action.severity.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Source', value: action.source.label),
              HrisMetricStripItem(label: 'Due', value: action.dueLabel),
              HrisMetricStripItem(label: 'Owner', value: action.ownerLabel),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            action.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (onActionSelected != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: Key('company-governance-brief-action-${action.id}'),
                onPressed: onActionSelected,
                icon: const Icon(Icons.task_alt_outlined),
                label: Text(action.resolveLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Action cluster for the command brief recommendation.
class _CommandBriefActions extends StatelessWidget {
  final CompanyGovernanceCommandBrief brief;
  final VoidCallback? onOwnerSelected;
  final VoidCallback? onActionSelected;
  final VoidCallback? onRecordFollowUp;

  const _CommandBriefActions({
    required this.brief,
    required this.onOwnerSelected,
    required this.onActionSelected,
    required this.onRecordFollowUp,
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
          if (onRecordFollowUp != null)
            FilledButton.icon(
              key: const Key('company-governance-brief-record-follow-up'),
              onPressed: onRecordFollowUp,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Record follow-up'),
            ),
          if (onOwnerSelected != null)
            OutlinedButton.icon(
              key: const Key('company-governance-brief-review-owner'),
              onPressed: onOwnerSelected,
              icon: const Icon(Icons.manage_accounts_outlined),
              label: Text(
                brief.intent ==
                        CompanyGovernanceCommandBriefIntent.prepareHandoff
                    ? 'Prepare handoff'
                    : 'Review owner',
              ),
            ),
          if (onActionSelected != null && onRecordFollowUp == null)
            FilledButton.icon(
              key: const Key('company-governance-brief-resolve-action'),
              onPressed: onActionSelected,
              icon: const Icon(Icons.task_alt_outlined),
              label: const Text('Resolve action'),
            ),
        ],
      ),
    );
  }
}

Color _intentColor(CompanyGovernanceCommandBriefIntent intent) {
  switch (intent) {
    case CompanyGovernanceCommandBriefIntent.resolveAction:
      return Colors.red;
    case CompanyGovernanceCommandBriefIntent.prepareHandoff:
      return Colors.deepPurple;
    case CompanyGovernanceCommandBriefIntent.recordFollowUp:
      return Colors.orange;
    case CompanyGovernanceCommandBriefIntent.monitor:
      return Colors.green;
  }
}

IconData _intentIcon(CompanyGovernanceCommandBriefIntent intent) {
  switch (intent) {
    case CompanyGovernanceCommandBriefIntent.resolveAction:
      return Icons.priority_high_outlined;
    case CompanyGovernanceCommandBriefIntent.prepareHandoff:
      return Icons.forward_to_inbox_outlined;
    case CompanyGovernanceCommandBriefIntent.recordFollowUp:
      return Icons.event_repeat_outlined;
    case CompanyGovernanceCommandBriefIntent.monitor:
      return Icons.check_circle_outline;
  }
}

Color _severityColor(CompanyGovernanceActionSeverity severity) {
  switch (severity) {
    case CompanyGovernanceActionSeverity.critical:
      return Colors.red;
    case CompanyGovernanceActionSeverity.high:
      return Colors.orange;
    case CompanyGovernanceActionSeverity.medium:
      return Colors.blueGrey;
  }
}

@Preview(name: 'Company governance command brief panel')
Widget companyGovernanceCommandBriefPanelPreview() {
  final action = CompanyGovernanceActionItem(
    id: 'filing-labor-report',
    recordId: 'filing-001',
    source: CompanyGovernanceActionSource.filing,
    severity: CompanyGovernanceActionSeverity.critical,
    resolution: CompanyGovernanceActionResolution.markFilingFiled,
    title: 'Annual WLK labor report',
    entityName: 'PT Kaysir Nusantara',
    ownerName: 'People Operations',
    dueDate: DateTime(2026, 6, 8),
    dueLabel: 'Overdue 3d',
    actionLabel: 'Submit labor report receipt',
    detail: 'Labor filing with missing evidence and an overdue due date.',
    issueLabels: const ['Filing overdue', 'Evidence missing'],
  );
  final view = CompanyGovernanceSavedView(
    type: CompanyGovernanceSavedViewType.criticalActions,
    title: 'Critical actions',
    description: 'Statutory or authority work requiring immediate action.',
    metricLabel: 'Critical',
    metricValue: 1,
    queueFilter:
        action.source == CompanyGovernanceActionSource.filing
            ? CompanyGovernanceActionFilter.critical
            : CompanyGovernanceActionFilter.all,
    clearOwnerScope: true,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceCommandBriefPanel(
          brief: CompanyGovernanceCommandBrief(
            selectedView: view,
            intent: CompanyGovernanceCommandBriefIntent.resolveAction,
            headline: 'Resolve Annual WLK labor report',
            recommendation: 'Submit labor report receipt',
            ownerName: 'People Operations',
            queueFilter: CompanyGovernanceActionFilter.critical,
            visibleActionCount: 1,
            criticalActionCount: 1,
            highActionCount: 0,
            needsHandoffCount: 0,
            dueFollowUpCount: 0,
            primaryAction: action,
          ),
          onOwnerSelected: _previewOwnerSelected,
          onActionSelected: _previewActionSelected,
          onRecordFollowUp: _previewRecordFollowUp,
        ),
      ),
    ),
  );
}

void _previewOwnerSelected(String ownerName) {}

void _previewActionSelected(CompanyGovernanceActionItem action) {}

void _previewRecordFollowUp(CompanyGovernanceFollowUpLane lane) {}
