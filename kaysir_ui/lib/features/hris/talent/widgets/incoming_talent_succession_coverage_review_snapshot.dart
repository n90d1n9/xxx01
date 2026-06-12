import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentSuccessionCoverageReviewSnapshot extends StatelessWidget {
  final IncomingTalentSuccessionCoverageReviewDraft draft;

  const IncomingTalentSuccessionCoverageReviewSnapshot({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final health = draft.coverageHealth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                draft.scopeLabel.isEmpty
                    ? 'Coverage snapshot'
                    : draft.scopeLabel,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (health != null)
              HrisStatusPill(label: health.label, color: _healthColor(health)),
          ],
        ),
        const SizedBox(height: 10),
        HrisProgressBar(
          value: draft.coverageScore / 100,
          color: health == null ? HrisColors.primary : _healthColor(health),
          label: '${draft.coverageScore}% dashboard coverage score',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            TalentMetaLabel(
              icon: Icons.groups_2_outlined,
              label:
                  '${draft.readyCoverageCount}/${draft.totalCandidates} ready',
            ),
            TalentMetaLabel(
              icon: Icons.warning_amber_outlined,
              label: '${draft.attentionSignalCount} attention signals',
            ),
            TalentMetaLabel(
              icon: Icons.task_alt_outlined,
              label: '${draft.openBenchActionCount} open bench actions',
            ),
          ],
        ),
      ],
    );
  }

  Color _healthColor(IncomingTalentSuccessionCoverageHealth health) {
    return switch (health) {
      IncomingTalentSuccessionCoverageHealth.strong => Colors.green,
      IncomingTalentSuccessionCoverageHealth.watch => Colors.amber,
      IncomingTalentSuccessionCoverageHealth.critical => Colors.red,
    };
  }
}
