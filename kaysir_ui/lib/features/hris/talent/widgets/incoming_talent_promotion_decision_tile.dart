import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_promotion_decision_models.dart';
import '../models/incoming_talent_promotion_readiness_models.dart';
import 'talent_meta_label.dart';

/// Promotion decision tile with implementation and compensation context.
class IncomingTalentPromotionDecisionTile extends StatelessWidget {
  final IncomingTalentPromotionDecision decision;

  const IncomingTalentPromotionDecisionTile({
    super.key,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentPromotionDecisionStatusColor(decision.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_reg_outlined, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decision.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${decision.currentRole} -> ${decision.frameworkLevelCode} ${decision.newRole}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: decision.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: decision.implementationProgress,
            color: color,
            label: decision.outcome.label,
          ),
          const SizedBox(height: 10),
          Text(
            decision.implementationNote,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            decision.compensationBandNote,
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
                icon: Icons.apartment_outlined,
                label: decision.department,
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: decision.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.verified_user_outlined,
                label: decision.approverName,
              ),
              TalentMetaLabel(
                icon: Icons.trending_up_outlined,
                label: decision.sourceRating.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(decision.effectiveDate),
              ),
              TalentMetaLabel(
                icon: Icons.event_repeat_outlined,
                label: DateFormat('MMM d').format(decision.followUpDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentPromotionDecisionStatusColor(
  IncomingTalentPromotionDecisionStatus status,
) {
  return switch (status) {
    IncomingTalentPromotionDecisionStatus.draft => const Color(0xFF2563EB),
    IncomingTalentPromotionDecisionStatus.approved => const Color(0xFF059669),
    IncomingTalentPromotionDecisionStatus.routed => const Color(0xFFD97706),
    IncomingTalentPromotionDecisionStatus.implemented => const Color(
      0xFF15803D,
    ),
    IncomingTalentPromotionDecisionStatus.deferred => const Color(0xFFDC2626),
    IncomingTalentPromotionDecisionStatus.closed => const Color(0xFF64748B),
  };
}

@Preview(name: 'Talent promotion decision tile')
Widget incomingTalentPromotionDecisionTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentPromotionDecisionTile(decision: _previewDecision),
      ),
    ),
  );
}

final _previewDecision = IncomingTalentPromotionDecision(
  id: 'promotion-decision-preview',
  readinessId: 'promotion-readiness-preview',
  careerPathId: 'career-path-preview',
  frameworkLevelId: 'framework-preview',
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Putri',
  department: 'Engineering',
  currentRole: 'Backend Engineer',
  newRole: 'Lead Backend Engineer',
  frameworkLevelCode: 'L5',
  ownerName: 'Engineering HRBP',
  approverName: 'Engineering people panel',
  outcome: IncomingTalentPromotionDecisionOutcome.promoteNow,
  status: IncomingTalentPromotionDecisionStatus.approved,
  compensationBandNote: 'Route L5 title and compensation band for approval.',
  implementationNote: 'Prepare promotion letter and HRIS title update.',
  riskControlNote: 'Confirm manager transition and backfill risk.',
  effectiveDate: DateTime(2026, 7, 9),
  followUpDate: DateTime(2026, 8, 8),
  sourceRating: IncomingTalentPromotionReadinessRating.readyNow,
  sourceReadinessStatus: IncomingTalentPromotionReadinessStatus.endorsed,
  createdAt: DateTime(2026, 6, 9),
);
