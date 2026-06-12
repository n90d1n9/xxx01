import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/talent_models.dart';
import 'talent_meta_label.dart';
import 'talent_status_styles.dart';

class SkillMatrixPanel extends StatelessWidget {
  final List<SkillGap> skillGaps;

  const SkillMatrixPanel({super.key, required this.skillGaps});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Skill Matrix',
      icon: Icons.psychology_alt_outlined,
      subtitle: '${skillGaps.length} capability signals',
      emptyMessage: 'No skill records match filters',
      children:
          skillGaps
              .map((skillGap) => _SkillGapTile(skillGap: skillGap))
              .toList(),
    );
  }
}

class _SkillGapTile extends StatelessWidget {
  final SkillGap skillGap;

  const _SkillGapTile({required this.skillGap});

  @override
  Widget build(BuildContext context) {
    final color = skillStatusColor(skillGap.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skillGap.employeeName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: skillStatusLabel(skillGap.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${skillGap.role} - ${skillGap.skill}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: skillGap.progress,
            color: color,
            label:
                'Level ${skillGap.currentLevel}/${skillGap.targetLevel}, gap ${skillGap.levelGap}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: skillGap.department,
              ),
              TalentMetaLabel(
                icon: Icons.person_outline,
                label: 'Mentor: ${skillGap.mentorName}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
