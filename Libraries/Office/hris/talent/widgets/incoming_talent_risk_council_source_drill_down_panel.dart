import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_follow_up_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import '../models/incoming_talent_risk_council_sla_models.dart';
import '../models/incoming_talent_risk_council_source_drill_down.dart';
import '../models/incoming_talent_risk_council_source_pressure.dart';
import '../states/incoming_talent_risk_council_follow_up_provider.dart';
import '../states/incoming_talent_risk_council_source_drill_down_provider.dart';
import '../states/talent_provider.dart';
import 'incoming_talent_risk_council_decision_tile.dart';
import 'incoming_talent_risk_council_follow_up_tile.dart';
import 'incoming_talent_risk_council_queue_tile.dart';
import 'incoming_talent_risk_council_sla_tile.dart';
import 'talent_meta_label.dart';

/// Drill-down panel for operating one focused talent risk council source.
class IncomingTalentRiskCouncilSourceDrillDownPanel extends ConsumerWidget {
  const IncomingTalentRiskCouncilSourceDrillDownPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drillDown = ref.watch(
      incomingTalentRiskCouncilSourceDrillDownProvider,
    );
    final asOfDate = ref.watch(talentAsOfDateProvider);

    return HrisSectionPanel(
      icon: Icons.view_agenda_outlined,
      title: 'Council source drill-down',
      subtitle: drillDown.nextAction,
      emptyMessage: 'No council source drill-down',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'SLA',
              value: '${drillDown.activeSlaCount}',
            ),
            HrisMetricStripItem(
              label: 'Urgent',
              value: '${drillDown.urgentSlaCount}',
            ),
            HrisMetricStripItem(
              label: 'Queue',
              value: '${drillDown.queueItems.length}',
            ),
            HrisMetricStripItem(
              label: 'Follow-ups',
              value: '${drillDown.followUps.length}',
            ),
          ],
        ),
        _DrillDownContext(drillDown: drillDown),
        if (!drillDown.hasWork)
          HrisListSurface(child: Text(drillDown.evidenceSummary))
        else ...[
          if (drillDown.slaItems.isNotEmpty) ...[
            const _BucketHeading(
              icon: Icons.timer_outlined,
              title: 'SLA pressure',
            ),
            for (final item in drillDown.slaItems.take(2))
              IncomingTalentRiskCouncilSlaTile(item: item, asOfDate: asOfDate),
          ],
          if (drillDown.queueItems.isNotEmpty) ...[
            const _BucketHeading(
              icon: Icons.groups_2_outlined,
              title: 'Pending council decisions',
            ),
            for (final item in drillDown.queueItems.take(2))
              IncomingTalentRiskCouncilQueueTile(item: item),
          ],
          if (drillDown.decisions.isNotEmpty) ...[
            const _BucketHeading(
              icon: Icons.fact_check_outlined,
              title: 'Decisions needing follow-up',
            ),
            for (final decision in drillDown.decisions.take(2))
              IncomingTalentRiskCouncilDecisionTile(decision: decision),
          ],
          if (drillDown.followUps.isNotEmpty) ...[
            const _BucketHeading(
              icon: Icons.next_plan_outlined,
              title: 'Open follow-ups',
            ),
            for (final followUp in drillDown.followUps.take(2))
              IncomingTalentRiskCouncilFollowUpTile(
                followUp: followUp,
                onStart:
                    () => _setFollowUpStatus(
                      ref,
                      followUp,
                      IncomingTalentRiskCouncilFollowUpStatus.inProgress,
                    ),
                onBlock:
                    () => _setFollowUpStatus(
                      ref,
                      followUp,
                      IncomingTalentRiskCouncilFollowUpStatus.blocked,
                    ),
                onEscalate:
                    () => _setFollowUpStatus(
                      ref,
                      followUp,
                      IncomingTalentRiskCouncilFollowUpStatus.escalated,
                    ),
                onComplete:
                    () => _setFollowUpStatus(
                      ref,
                      followUp,
                      IncomingTalentRiskCouncilFollowUpStatus.completed,
                    ),
              ),
          ],
        ],
      ],
    );
  }

  void _setFollowUpStatus(
    WidgetRef ref,
    IncomingTalentRiskCouncilFollowUp followUp,
    IncomingTalentRiskCouncilFollowUpStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentRiskCouncilFollowUpsProvider.notifier,
    );

    switch (status) {
      case IncomingTalentRiskCouncilFollowUpStatus.inProgress:
        notifier.start(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.blocked:
        notifier.block(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.escalated:
        notifier.escalate(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.completed:
        notifier.complete(followUp.id);
      case IncomingTalentRiskCouncilFollowUpStatus.planned:
        break;
    }
  }
}

/// Compact source context summary for the drill-down panel.
class _DrillDownContext extends StatelessWidget {
  final IncomingTalentRiskCouncilSourceDrillDown drillDown;

  const _DrillDownContext({required this.drillDown});

  @override
  Widget build(BuildContext context) {
    final pressureLevel = drillDown.pressure?.level;
    final color =
        pressureLevel == null
            ? HrisColors.primary
            : _pressureLevelColor(pressureLevel);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HrisStatusPill(label: drillDown.focusLabel, color: color),
              const Spacer(),
              Text(
                drillDown.sourceLabel,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            drillDown.evidenceSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${drillDown.activeSlaCount} SLA items',
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${drillDown.urgentSlaCount} urgent',
              ),
              TalentMetaLabel(
                icon: Icons.groups_2_outlined,
                label: '${drillDown.queueItems.length} queue',
              ),
              TalentMetaLabel(
                icon: Icons.fact_check_outlined,
                label: '${drillDown.decisions.length} decisions',
              ),
              TalentMetaLabel(
                icon: Icons.next_plan_outlined,
                label: '${drillDown.followUps.length} follow-ups',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section heading used to separate drill-down work buckets.
class _BucketHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _BucketHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: HrisColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

Color _pressureLevelColor(IncomingTalentRiskCouncilSourcePressureLevel level) {
  return switch (level) {
    IncomingTalentRiskCouncilSourcePressureLevel.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentRiskCouncilSourcePressureLevel.watch => const Color(
      0xFFD97706,
    ),
    IncomingTalentRiskCouncilSourcePressureLevel.steady => const Color(
      0xFF15803D,
    ),
  };
}

@Preview(name: 'Talent risk council source drill-down panel')
Widget incomingTalentRiskCouncilSourceDrillDownPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentRiskCouncilSourceDrillDownProvider.overrideWithValue(
        _previewDrillDown,
      ),
      talentAsOfDateProvider.overrideWithValue(DateTime(2026, 6, 11)),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilSourceDrillDownPanel(),
        ),
      ),
    ),
  );
}

final _previewDrillDown = IncomingTalentRiskCouncilSourceDrillDown(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  isAutoFocused: true,
  pressure: _previewPressure,
  queueItems: [_previewQueueItem],
  decisions: [_previewDecision],
  followUps: [_previewFollowUp],
  slaItems: [_previewSlaItem],
);

final _previewPressure = IncomingTalentRiskCouncilSourcePressure.fromItems(
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  items: [_previewSlaItem],
);

final _previewSlaItem = IncomingTalentRiskCouncilSlaItem(
  id: 'sla-preview:promotion-resolution-review',
  source: IncomingTalentRiskCouncilSlaSource.councilDecision,
  councilSource: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  status: IncomingTalentRiskCouncilSlaStatus.dueSoon,
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  ownerName: 'People Operations Talent Partner',
  title: 'Promotion resolution review risk',
  nextAction:
      'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
  dueDate: DateTime(2026, 6, 17),
  requiresAttention: true,
);

final _previewQueueItem = IncomingTalentRiskCouncilQueueItem(
  id: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  severity: IncomingTalentRiskCouncilQueueSeverity.watch,
  title: 'Promotion resolution review risk',
  detail: '1 promotion resolution review still carries residual role risk.',
  recommendedAction:
      'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
  dueDate: DateTime(2026, 6, 17),
  signalCount: 1,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
);

final _previewDecision = IncomingTalentRiskCouncilDecision(
  id: 'talent-risk-council-decision-preview',
  queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  decisionMakerName: 'Talent Council',
  ownerName: 'People Operations Promotion Stabilization Partner',
  decisionDate: DateTime(2026, 6, 11),
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  commitmentSummary:
      'Council will monitor promotion stabilization risk at the next talent risk council.',
  minutesNote:
      'Residual role-risk evidence needs manager checkpoint and closure disposition.',
  followUpDate: DateTime(2026, 7, 11),
  createdAt: DateTime(2026, 6, 11),
  signalCount: 1,
);

final _previewFollowUp = IncomingTalentRiskCouncilFollowUp(
  id: 'talent-risk-council-follow-up-preview',
  decisionId: 'talent-risk-council-decision-preview',
  queueItemId: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  decisionMakerName: 'Talent Council',
  followUpOwnerName: 'People Operations Promotion Stabilization Partner',
  outcome: IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  sourceSeverity: IncomingTalentRiskCouncilQueueSeverity.watch,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
  followUpType: IncomingTalentRiskCouncilFollowUpType.monitoringReview,
  status: IncomingTalentRiskCouncilFollowUpStatus.inProgress,
  dueDate: DateTime(2026, 7, 11),
  actionPlan:
      'Review promotion stabilization evidence and decide whether monitoring can close.',
  successCriteria:
      'Role-risk evidence, manager checkpoint, and council disposition are recorded.',
  blockerNote: '',
  escalationReason: '',
  createdAt: DateTime(2026, 6, 11),
  signalCount: 1,
);
