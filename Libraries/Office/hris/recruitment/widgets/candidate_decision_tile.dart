import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_decision_models.dart';
import 'recruitment_meta_label.dart';

class CandidateDecisionTile extends StatelessWidget {
  final CandidateDecisionPacket packet;
  final DateTime asOfDate;
  final VoidCallback? onReview;

  const CandidateDecisionTile({
    super.key,
    required this.packet,
    required this.asOfDate,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final color = _recommendationColor(packet.recommendation);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _recommendationIcon(packet.recommendation),
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packet.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          packet.role,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final status = HrisStatusPill(
                label: packet.recommendation.label,
                color: color,
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  status,
                  if (onReview != null)
                    OutlinedButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Review'),
                    ),
                ],
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), actions],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: packet.fitScore / 100,
            color: color,
            label:
                'Fit ${packet.fitScore}% - due ${DateFormat('MMM d').format(packet.decisionDueDate)}',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${packet.daysUntilDue(asOfDate)} days',
              ),
              RecruitmentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: 'Mentor: ${packet.suggestedMentor}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.school_outlined,
                label: packet.suggestedLearningPlan,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            packet.nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _DecisionLines(
            title: packet.blockers.isEmpty ? 'Handoff items' : 'Blockers',
            lines:
                packet.blockers.isEmpty ? packet.handoffItems : packet.blockers,
          ),
        ],
      ),
    );
  }
}

class _DecisionLines extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _DecisionLines({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HrisColors.muted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        for (final line in lines.take(3))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: HrisColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(line)),
              ],
            ),
          ),
      ],
    );
  }
}

Color _recommendationColor(CandidateDecisionRecommendation recommendation) {
  return switch (recommendation) {
    CandidateDecisionRecommendation.approve => const Color(0xFF15803D),
    CandidateDecisionRecommendation.conditional => const Color(0xFF2563EB),
    CandidateDecisionRecommendation.hold => const Color(0xFFB45309),
  };
}

IconData _recommendationIcon(CandidateDecisionRecommendation recommendation) {
  return switch (recommendation) {
    CandidateDecisionRecommendation.approve => Icons.verified_outlined,
    CandidateDecisionRecommendation.conditional => Icons.assignment_outlined,
    CandidateDecisionRecommendation.hold => Icons.pause_circle_outline,
  };
}
