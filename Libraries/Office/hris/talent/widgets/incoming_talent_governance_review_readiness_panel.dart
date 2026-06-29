import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_review_readiness_models.dart';
import '../states/incoming_talent_governance_review_readiness_provider.dart';
import 'incoming_talent_governance_review_readiness_tile.dart';
import 'talent_meta_label.dart';

/// Readiness checklist for executive talent governance review preparation.
class IncomingTalentGovernanceReviewReadinessPanel extends ConsumerWidget {
  const IncomingTalentGovernanceReviewReadinessPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentGovernanceReviewReadinessItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentGovernanceReviewReadinessSummaryProvider,
    );
    final color = incomingTalentGovernanceReviewReadinessSummaryColor(summary);

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_circle_outlined,
      title: 'Talent governance review readiness',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance review readiness tasks',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Ready', value: '${summary.readyCount}'),
            HrisMetricStripItem(
              label: 'Prep',
              value: '${summary.needsPrepCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(
              label: 'Minutes',
              value: '${summary.totalTimeboxMinutes}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.readinessRatio,
                color: color,
                label:
                    '${(summary.readinessRatio * 100).round()}% governance review ready',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${summary.totalSignalCount} active ${_plural(summary.totalSignalCount, 'signal')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${summary.decisionQuestionCount} decision ${_plural(summary.decisionQuestionCount, 'question')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.assignment_late_outlined,
                    label:
                        '${summary.attentionCount} prep ${_plural(summary.attentionCount, 'task')} need attention',
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final item in items.take(5))
          IncomingTalentGovernanceReviewReadinessTile(item: item),
      ],
    );
  }
}

Color incomingTalentGovernanceReviewReadinessSummaryColor(
  IncomingTalentGovernanceReviewReadinessSummary summary,
) {
  if (summary.blockedCount > 0) {
    return const Color(0xFFDC2626);
  }
  if (summary.needsPrepCount > 0) {
    return const Color(0xFFD97706);
  }
  return const Color(0xFF059669);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance review readiness panel')
Widget incomingTalentGovernanceReviewReadinessPanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceReviewReadinessItemsProvider.overrideWithValue(
        _previewItems,
      ),
      incomingTalentGovernanceReviewReadinessSummaryProvider.overrideWithValue(
        _previewSummary,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceReviewReadinessPanel(),
        ),
      ),
    ),
  );
}

final _previewItems = [
  IncomingTalentGovernanceReviewReadinessItem(
    id:
        'talent-governance-review-readiness:review-pack-governance-lane-assurance',
    sourceReviewItemId: 'review-pack-governance-lane-assurance',
    category: IncomingTalentGovernanceReviewReadinessCategory.decisionBrief,
    status: IncomingTalentGovernanceReviewReadinessStatus.blocked,
    title: 'Prepare assurance decision brief',
    detail:
        'What leadership decision removes the assurance blocker today? Evidence required: Gaps 4 with 5 active signals.',
    ownerName: 'People Risk and Assurance',
    evidencePrompt: 'Gaps 4 with 5 active signals.',
    dueDate: DateTime(2026, 6, 11),
    signalCount: 5,
    decisionCount: 3,
    timeboxMinutes: 15,
  ),
  IncomingTalentGovernanceReviewReadinessItem(
    id:
        'talent-governance-review-readiness:review-pack-governance-lane-action-sla',
    sourceReviewItemId: 'review-pack-governance-lane-action-sla',
    category: IncomingTalentGovernanceReviewReadinessCategory.escalationPrep,
    status: IncomingTalentGovernanceReviewReadinessStatus.needsPrep,
    title: 'Prepare action SLA unblock path',
    detail:
        'Which owner and evidence keep action SLA on track this week? Evidence required: SLAs 8 with 3 active signals.',
    ownerName: 'Talent Operations',
    evidencePrompt: 'SLAs 8 with 3 active signals.',
    dueDate: DateTime(2026, 6, 14),
    signalCount: 3,
    decisionCount: 3,
    timeboxMinutes: 10,
  ),
];

const _previewSummary = IncomingTalentGovernanceReviewReadinessSummary(
  totalCount: 2,
  readyCount: 0,
  needsPrepCount: 1,
  blockedCount: 1,
  attentionCount: 2,
  decisionQuestionCount: 6,
  totalSignalCount: 8,
  totalTimeboxMinutes: 25,
  readinessRatio: 0,
  nextAction: 'Unblock 1 governance review prep task.',
);
