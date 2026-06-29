import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_follow_up_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import 'talent_meta_label.dart';

/// Council decision picker that preserves source context before follow-up entry.
class IncomingTalentRiskCouncilFollowUpDecisionPicker extends StatelessWidget {
  final IncomingTalentRiskCouncilFollowUpDraft draft;
  final List<IncomingTalentRiskCouncilDecision> decisions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentRiskCouncilFollowUpDecisionPicker({
    super.key,
    required this.draft,
    required this.decisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDecision = _selectedDecision;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('risk-council-follow-up-${draft.decisionId}'),
          isExpanded: true,
          initialValue: selectedDecision?.id,
          decoration: const InputDecoration(
            labelText: 'Risk council decision',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fact_check_outlined),
          ),
          items:
              decisions
                  .map(
                    (decision) => DropdownMenuItem(
                      value: decision.id,
                      child: Text(
                        _decisionLabel(decision),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: decisions.isEmpty ? null : onChanged,
          validator:
              (value) => validateRiskCouncilFollowUpRequired(
                value,
                'a council decision',
              ),
        ),
        if (selectedDecision != null) ...[
          const SizedBox(height: 8),
          _FollowUpDecisionContext(decision: selectedDecision),
        ],
      ],
    );
  }

  IncomingTalentRiskCouncilDecision? get _selectedDecision {
    for (final decision in decisions) {
      if (decision.id == draft.decisionId) return decision;
    }
    return null;
  }
}

/// Compact selected-decision summary for council follow-up creation.
class _FollowUpDecisionContext extends StatelessWidget {
  final IncomingTalentRiskCouncilDecision decision;

  const _FollowUpDecisionContext({required this.decision});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            decision.commitmentSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.rule_folder_outlined,
                label: decision.outcome.label,
              ),
              if (decision.source !=
                  IncomingTalentRiskCouncilQueueSource.general)
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: decision.source.label,
                ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label: decision.sourceSeverity.label,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: decision.ownerName,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _decisionLabel(IncomingTalentRiskCouncilDecision decision) {
  final parts = [
    decision.candidateName,
    decision.outcome.label,
    if (decision.source != IncomingTalentRiskCouncilQueueSource.general)
      decision.source.label,
  ];
  return parts.join(' - ');
}

@Preview(name: 'Talent risk council follow-up decision picker')
Widget incomingTalentRiskCouncilFollowUpDecisionPickerPreview() {
  final decision = _previewDecision;

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilFollowUpDecisionPicker(
          draft: IncomingTalentRiskCouncilFollowUpDraft.fromDecision(
            decision: decision,
            asOfDate: DateTime(2026, 6, 11),
          ),
          decisions: [decision],
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

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
