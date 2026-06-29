import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import '../states/incoming_talent_governance_execution_evidence_provider.dart';
import 'incoming_talent_governance_execution_evidence_tile.dart';
import 'talent_meta_label.dart';

/// Audit register for governance execution evidence and residual risk.
class IncomingTalentGovernanceExecutionEvidencePanel extends ConsumerWidget {
  const IncomingTalentGovernanceExecutionEvidencePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(
      incomingTalentGovernanceExecutionEvidenceItemsProvider,
    );
    final summary = ref.watch(
      incomingTalentGovernanceExecutionEvidenceSummaryProvider,
    );
    final color = incomingTalentGovernanceExecutionEvidenceSummaryColor(
      summary,
    );

    return HrisSectionPanel(
      icon: Icons.plagiarism_outlined,
      title: 'Talent governance evidence register',
      subtitle: summary.nextAction,
      emptyMessage: 'No talent governance evidence records',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Records',
              value: '${summary.totalCount}',
            ),
            HrisMetricStripItem(
              label: 'Missing',
              value: '${summary.missingCount}',
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value:
                  '${summary.monitorCount + summary.reopenedCount + summary.escalatedCount}',
            ),
            HrisMetricStripItem(
              label: 'Risk',
              value: '${summary.residualRiskCount}',
            ),
          ],
        ),
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.averageReadinessRatio,
                color: color,
                label:
                    '${(summary.averageReadinessRatio * 100).round()}% evidence readiness',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  TalentMetaLabel(
                    icon: Icons.check_circle_outline,
                    label:
                        '${summary.acceptedCount} accepted ${_plural(summary.acceptedCount, 'record')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.warning_amber_outlined,
                    label:
                        '${summary.signalCount} active ${_plural(summary.signalCount, 'signal')}',
                  ),
                  TalentMetaLabel(
                    icon: Icons.gavel_outlined,
                    label:
                        '${summary.decisionCount} governance ${_plural(summary.decisionCount, 'decision')}',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          const HrisListSurface(
            child: Text('No governance execution evidence records yet.'),
          )
        else
          for (final item in items.take(6))
            IncomingTalentGovernanceExecutionEvidenceTile(item: item),
      ],
    );
  }
}

Color incomingTalentGovernanceExecutionEvidenceSummaryColor(
  IncomingTalentGovernanceExecutionEvidenceSummary summary,
) {
  if (summary.escalatedCount > 0 ||
      summary.reopenedCount > 0 ||
      summary.missingCount > 0) {
    return const Color(0xFFDC2626);
  }
  if (summary.monitorCount > 0 || summary.residualRiskCount > 0) {
    return const Color(0xFFD97706);
  }
  return const Color(0xFF059669);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent governance execution evidence panel')
Widget incomingTalentGovernanceExecutionEvidencePanelPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentGovernanceExecutionEvidenceItemsProvider.overrideWithValue(
        _previewItems,
      ),
      incomingTalentGovernanceExecutionEvidenceSummaryProvider
          .overrideWithValue(
            IncomingTalentGovernanceExecutionEvidenceSummary.fromItems(
              _previewItems,
            ),
          ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentGovernanceExecutionEvidencePanel(),
        ),
      ),
    ),
  );
}

final _previewItems = [
  IncomingTalentGovernanceExecutionEvidenceItem(
    id: 'talent-governance-execution-evidence:assurance',
    actionId: 'talent-governance-execution-action:assurance',
    trackId: 'talent-governance-execution:assurance',
    status: IncomingTalentGovernanceExecutionEvidenceStatus.monitor,
    title: 'People Risk and Assurance - recover overdue',
    evidenceRequirement:
        'Attach assurance approval evidence, owner confirmation, and recovery note.',
    evidenceSummary:
        'Closure evidence confirms assurance approval follow-through is attached.',
    ownerConfirmationNote:
        'Owner confirms recovery evidence and governance cadence.',
    ownerName: 'People Risk and Assurance',
    reviewerName: 'People Risk and Assurance',
    dueDate: DateTime(2026, 6, 11),
    closureDate: DateTime(2026, 6, 12),
    nextReviewDate: DateTime(2026, 6, 26),
    residualRiskCount: 1,
    signalCount: 5,
    decisionCount: 3,
    readinessRatio: 0.7,
  ),
  IncomingTalentGovernanceExecutionEvidenceItem(
    id: 'talent-governance-execution-evidence:action-sla',
    actionId: 'talent-governance-execution-action:action-sla',
    trackId: 'talent-governance-execution:action-sla',
    status: IncomingTalentGovernanceExecutionEvidenceStatus.missing,
    title: 'Talent Operations - attach evidence',
    evidenceRequirement: 'Attach action SLA recovery notes.',
    evidenceSummary: '',
    ownerConfirmationNote: '',
    ownerName: 'Talent Operations',
    reviewerName: '',
    dueDate: DateTime(2026, 6, 15),
    closureDate: null,
    nextReviewDate: null,
    residualRiskCount: 0,
    signalCount: 3,
    decisionCount: 3,
    readinessRatio: 0.2,
  ),
];
