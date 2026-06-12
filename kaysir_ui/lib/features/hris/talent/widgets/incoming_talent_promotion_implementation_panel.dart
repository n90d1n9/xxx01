import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_implementation_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import '../states/incoming_talent_promotion_implementation_provider.dart';
import 'incoming_talent_promotion_implementation_form.dart';
import 'incoming_talent_promotion_implementation_tile.dart';

/// Panel for routing and tracking promotion implementation work.
class IncomingTalentPromotionImplementationPanel extends ConsumerWidget {
  const IncomingTalentPromotionImplementationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final implementations = ref.watch(
      filteredIncomingTalentPromotionImplementationsProvider,
    );
    final summary = ref.watch(
      incomingTalentPromotionImplementationSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.task_alt_outlined,
      title: 'Promotion implementation',
      subtitle: summary.nextAction,
      emptyMessage: 'No promotion implementation data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Planned',
              value: '${summary.plannedCount}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.inProgressCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(label: 'Due', value: '${summary.dueSoonCount}'),
          ],
        ),
        HrisProgressBar(
          value: summary.averageProgress,
          color: HrisColors.primary,
          label:
              '${(summary.averageProgress * 100).round()}% implementation progress',
        ),
        const IncomingTalentPromotionImplementationForm(),
        if (implementations.isEmpty)
          const HrisListSurface(
            child: Text('No promotion implementations created yet.'),
          )
        else
          for (final implementation in implementations)
            IncomingTalentPromotionImplementationTile(
              implementation: implementation,
            ),
      ],
    );
  }
}

@Preview(name: 'Talent promotion implementation panel')
Widget incomingTalentPromotionImplementationPanelPreview() {
  final implementations = [_previewPanelImplementation];

  return ProviderScope(
    overrides: [
      filteredIncomingTalentPromotionImplementationsProvider.overrideWithValue(
        implementations,
      ),
      incomingTalentPromotionImplementationSummaryProvider.overrideWithValue(
        IncomingTalentPromotionImplementationSummary.fromImplementations(
          implementations: implementations,
          asOfDate: DateTime(2026, 6, 9),
        ),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentPromotionImplementationPanel(),
        ),
      ),
    ),
  );
}

final _previewPanelImplementation = IncomingTalentPromotionImplementation(
  id: 'promotion-implementation-preview',
  decisionId: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  approverName: 'Engineering people panel',
  action: IncomingTalentPromotionImplementationAction.titleUpdate,
  status: IncomingTalentPromotionImplementationStatus.inProgress,
  systemOfRecord: 'HRIS employee profile',
  implementationStep: 'Prepare promotion letter and HRIS title update.',
  evidenceNote: 'Capture signed letter and HRIS update confirmation.',
  blockerNote: 'Confirm manager transition and backfill risk.',
  dueDate: DateTime(2026, 7, 9),
  completedDate: null,
  sourceOutcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  sourceDecisionStatus: IncomingTalentPromotionDecisionStatus.approved,
  sourceReadinessRating: IncomingTalentPromotionReadinessRating.readyNow,
  createdAt: DateTime(2026, 6, 9),
);
