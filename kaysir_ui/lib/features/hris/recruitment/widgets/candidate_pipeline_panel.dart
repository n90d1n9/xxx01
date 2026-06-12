import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/recruitment_models.dart';
import 'recruitment_meta_label.dart';
import 'recruitment_status_styles.dart';

class CandidatePipelinePanel extends StatelessWidget {
  final List<CandidateProfile> candidates;

  const CandidatePipelinePanel({super.key, required this.candidates});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Candidate Pipeline',
      icon: Icons.people_alt_outlined,
      subtitle: '${candidates.length} candidates',
      emptyMessage: 'No candidates match filters',
      children:
          candidates
              .map((candidate) => _CandidateTile(candidate: candidate))
              .toList(),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final CandidateProfile candidate;

  const _CandidateTile({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final color = candidateStageColor(candidate.stage);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              _initials(candidate.name),
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidate.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    HrisStatusPill(
                      label: candidateStageLabel(candidate.stage),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${candidate.role} - ${candidate.source}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    RecruitmentMetaLabel(
                      icon: Icons.person_outline,
                      label: candidate.owner,
                    ),
                    RecruitmentMetaLabel(
                      icon: Icons.speed_outlined,
                      label: 'Score ${candidate.score}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
