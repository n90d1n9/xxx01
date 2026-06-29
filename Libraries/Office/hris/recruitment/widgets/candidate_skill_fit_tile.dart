import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_skill_fit_models.dart';
import '../models/recruitment_models.dart';
import 'recruitment_meta_label.dart';

class CandidateSkillFitTile extends StatelessWidget {
  final CandidateSkillFitProfile profile;

  const CandidateSkillFitTile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = _fitStatusColor(profile.status);
    final displayedSignals = profile.signals.take(3).toList();

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
                    child: Icon(_fitStatusIcon(profile.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          profile.role,
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
                label: profile.status.label,
                color: color,
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
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.fitScore / 100,
            color: color,
            label: 'Fit ${profile.fitScore}% - ${profile.topSkillGap}',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.flag_outlined,
                label: _stageLabel(profile.stage),
              ),
              RecruitmentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: 'Coach: ${profile.suggestedMentor}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.school_outlined,
                label: profile.suggestedLearningPlan,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < displayedSignals.length; index++) ...[
            _SkillSignalRow(signal: displayedSignals[index]),
            if (index < displayedSignals.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 10),
          Text(
            profile.nextAction,
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

class _SkillSignalRow extends StatelessWidget {
  final CandidateSkillFitSignal signal;

  const _SkillSignalRow({required this.signal});

  @override
  Widget build(BuildContext context) {
    final color = _signalStatusColor(signal.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                signal.skill,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: signal.status.label, color: color),
          ],
        ),
        const SizedBox(height: 6),
        HrisProgressBar(
          value: signal.progress,
          color: color,
          label:
              'Level ${signal.currentLevel}/${signal.targetLevel}, gap ${signal.levelGap}',
        ),
      ],
    );
  }
}

Color _fitStatusColor(CandidateSkillFitStatus status) {
  return switch (status) {
    CandidateSkillFitStatus.strongFit => const Color(0xFF15803D),
    CandidateSkillFitStatus.coaching => const Color(0xFF2563EB),
    CandidateSkillFitStatus.gapRisk => const Color(0xFFB45309),
  };
}

IconData _fitStatusIcon(CandidateSkillFitStatus status) {
  return switch (status) {
    CandidateSkillFitStatus.strongFit => Icons.verified_outlined,
    CandidateSkillFitStatus.coaching => Icons.psychology_alt_outlined,
    CandidateSkillFitStatus.gapRisk => Icons.report_problem_outlined,
  };
}

Color _signalStatusColor(CandidateSkillSignalStatus status) {
  return switch (status) {
    CandidateSkillSignalStatus.strength => const Color(0xFF15803D),
    CandidateSkillSignalStatus.coaching => const Color(0xFF2563EB),
    CandidateSkillSignalStatus.gap => const Color(0xFFB45309),
  };
}

String _stageLabel(CandidateStage stage) {
  return switch (stage) {
    CandidateStage.applied => 'Applied',
    CandidateStage.screening => 'Screening',
    CandidateStage.interview => 'Interview',
    CandidateStage.offer => 'Offer',
    CandidateStage.hired => 'Hired',
    CandidateStage.rejected => 'Rejected',
  };
}
