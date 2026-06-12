import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_command_center_models.dart';
import '../models/incoming_talent_governance_review_pack_models.dart';
import '../states/incoming_talent_governance_review_pack_provider.dart';
import 'incoming_talent_governance_review_item_tile.dart';
import 'talent_meta_label.dart';

/// Executive decision agenda generated from the talent governance command center.
class IncomingTalentGovernanceReviewPackPanel extends ConsumerWidget {
  const IncomingTalentGovernanceReviewPackPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(incomingTalentGovernanceReviewPackProvider);
    final color = incomingTalentGovernanceReviewPackStatusColor(pack.status);

    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Talent governance review pack',
      subtitle: pack.facilitationFocus,
      emptyMessage: 'No talent governance review items',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Agenda',
              value: '${pack.agendaItemCount}',
            ),
            HrisMetricStripItem(
              label: 'Urgent',
              value: '${pack.urgentItemCount}',
            ),
            HrisMetricStripItem(
              label: 'Minutes',
              value: '${pack.totalTimeboxMinutes}',
            ),
            HrisMetricStripItem(
              label: 'Questions',
              value: '${pack.decisionQuestionCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HrisStatusPill(label: pack.status.label, color: color),
                  const Spacer(),
                  Text(
                    '${pack.reviewReadinessScore}% ready',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: HrisColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              HrisProgressBar(
                value: pack.reviewReadinessRatio,
                color: color,
                label: '${pack.reviewReadinessScore}% review readiness',
              ),
              const SizedBox(height: 12),
              Text(
                pack.chairNote,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${pack.totalSignalCount} active ${_plural(pack.totalSignalCount, 'signal')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.calendar_view_week_outlined,
                    label:
                        '${pack.scheduledItemCount} scheduled ${_plural(pack.scheduledItemCount, 'item')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${pack.decisionQuestionCount} decision ${_plural(pack.decisionQuestionCount, 'question')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final item in pack.items.take(5))
          IncomingTalentGovernanceReviewItemTile(item: item),
      ],
    );
  }
}

Color incomingTalentGovernanceReviewPackStatusColor(
  IncomingTalentGovernanceReviewPackStatus status,
) {
  return switch (status) {
    IncomingTalentGovernanceReviewPackStatus.urgent => const Color(0xFFDC2626),
    IncomingTalentGovernanceReviewPackStatus.scheduled => const Color(
      0xFFD97706,
    ),
    IncomingTalentGovernanceReviewPackStatus.clear => const Color(0xFF059669),
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance review pack panel')
Widget incomingTalentGovernanceReviewPackPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceReviewPackProvider.overrideWithValue(
        _previewPack,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceReviewPackPanel(),
        ),
      ),
    ),
  );
}

const _previewItems = [
  IncomingTalentGovernanceReviewItem(
    id: 'review-pack-governance-lane-assurance',
    laneType: IncomingTalentGovernanceCommandLaneType.assurance,
    status: IncomingTalentGovernanceCommandStatus.critical,
    decisionKind: IncomingTalentGovernanceReviewDecisionKind.approve,
    title: 'Assurance',
    decisionQuestion:
        'What leadership decision removes the assurance blocker today?',
    recommendedDecision:
        'Approve immediate intervention for assurance: Unblock 1 assurance remediation execution track.',
    ownerLabel: 'People Risk and Assurance',
    evidencePrompt: 'Gaps 4 with 5 active signals.',
    dueLabel: 'Decision today',
    signalCount: 5,
    decisionCount: 3,
    timeboxMinutes: 15,
    pressureRatio: 0.74,
  ),
  IncomingTalentGovernanceReviewItem(
    id: 'review-pack-governance-lane-action-sla',
    laneType: IncomingTalentGovernanceCommandLaneType.actionSla,
    status: IncomingTalentGovernanceCommandStatus.watch,
    decisionKind: IncomingTalentGovernanceReviewDecisionKind.unblock,
    title: 'Action SLA',
    decisionQuestion:
        'Which owner and evidence keep action SLA on track this week?',
    recommendedDecision:
        'Keep action SLA on weekly governance watch and confirm the accountable owner.',
    ownerLabel: 'Talent Operations',
    evidencePrompt: 'SLAs 8 with 3 active signals.',
    dueLabel: 'Decision this week',
    signalCount: 3,
    decisionCount: 3,
    timeboxMinutes: 10,
    pressureRatio: 0.42,
  ),
];

const _previewPack = IncomingTalentGovernanceReviewPack(
  status: IncomingTalentGovernanceReviewPackStatus.urgent,
  reviewReadinessScore: 64,
  agendaItemCount: 2,
  urgentItemCount: 1,
  scheduledItemCount: 1,
  decisionQuestionCount: 6,
  totalSignalCount: 8,
  totalTimeboxMinutes: 25,
  chairNote: 'Prepare 2 governance decisions from 8 active signals.',
  facilitationFocus:
      'Start with Assurance and land the approve decision before other agenda items.',
  items: _previewItems,
);
