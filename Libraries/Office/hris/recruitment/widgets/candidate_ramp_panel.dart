import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_ramp_models.dart';
import 'recruitment_meta_label.dart';
import 'recruitment_status_styles.dart';

class CandidateRampPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<CandidateRampPlan> plans;
  final CandidateRampSummary summary;
  final DateTime asOfDate;

  const CandidateRampPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.plans,
    required this.summary,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.school_outlined,
      title: title,
      subtitle: subtitle,
      emptyMessage: 'No candidate ramp plans match filters',
      children: [
        _RampSummaryTile(summary: summary),
        for (final plan in plans)
          _CandidateRampTile(plan: plan, asOfDate: asOfDate),
      ],
    );
  }
}

class _RampSummaryTile extends StatelessWidget {
  final CandidateRampSummary summary;

  const _RampSummaryTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag_circle_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ramp action',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RampStat(label: 'Plans', value: '${summary.totalPlans}'),
              _RampStat(label: 'At risk', value: '${summary.atRiskCount}'),
              _RampStat(label: 'Coaching', value: '${summary.coachingCount}'),
              _RampStat(label: 'Offer', value: '${summary.offerStageCount}'),
              _RampStat(
                label: 'Score',
                value: summary.averageCandidateScore.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RampStat extends StatelessWidget {
  final String label;
  final String value;

  const _RampStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 86),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CandidateRampTile extends StatelessWidget {
  final CandidateRampPlan plan;
  final DateTime asOfDate;

  const _CandidateRampTile({required this.plan, required this.asOfDate});

  @override
  Widget build(BuildContext context) {
    final readinessColor = _readinessColor(plan.readiness);

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
                      color: readinessColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _readinessIcon(plan.readiness),
                      color: readinessColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          plan.role,
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
                label: plan.readiness.label,
                color: readinessColor,
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), status],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.apartment_outlined,
                label: plan.department,
              ),
              RecruitmentMetaLabel(
                icon: Icons.timeline_outlined,
                label: candidateStageLabel(plan.stage),
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label: _readinessDateLabel(plan, asOfDate),
              ),
              RecruitmentMetaLabel(
                icon: Icons.person_outline,
                label: 'Mentor: ${plan.mentorName}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.candidateScore / 100,
            color: readinessColor,
            label:
                'Candidate score ${plan.candidateScore}, skill gap ${plan.skillGapLevel}',
          ),
          const SizedBox(height: 10),
          Text(
            plan.skillFocus,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.learningPlanTitle,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            plan.action,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _readinessDateLabel(CandidateRampPlan plan, DateTime asOfDate) {
  final days = plan.daysUntilReady(asOfDate);
  final date = DateFormat('MMM d').format(plan.readinessDate);
  if (days == 0) return '$date - today';
  if (days < 0) return '$date - overdue';
  return '$date - ${days}d';
}

Color _readinessColor(CandidateRampReadiness readiness) {
  return switch (readiness) {
    CandidateRampReadiness.ready => const Color(0xFF15803D),
    CandidateRampReadiness.coaching => const Color(0xFFB45309),
    CandidateRampReadiness.atRisk => const Color(0xFFB91C1C),
  };
}

IconData _readinessIcon(CandidateRampReadiness readiness) {
  return switch (readiness) {
    CandidateRampReadiness.ready => Icons.verified_outlined,
    CandidateRampReadiness.coaching => Icons.school_outlined,
    CandidateRampReadiness.atRisk => Icons.warning_amber_outlined,
  };
}
