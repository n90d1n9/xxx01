import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_models.dart';

class CandidateTalentHandoffReadinessPreview extends StatelessWidget {
  final CandidateTalentHandoffDraft draft;

  const CandidateTalentHandoffReadinessPreview({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (draft.status) {
      CandidateTalentHandoffStatus.ready => const Color(0xFF15803D),
      CandidateTalentHandoffStatus.watch => const Color(0xFF2563EB),
      CandidateTalentHandoffStatus.blocked => const Color(0xFFB45309),
      null => HrisColors.primary,
    };

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  draft.candidateName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (draft.status != null)
                HrisStatusPill(label: draft.status!.label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${draft.role} - ${draft.department}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.readinessScore / 100,
            color: color,
            label: '${draft.readinessScore}% readiness score',
          ),
        ],
      ),
    );
  }
}
