import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import 'talent_meta_label.dart';

/// Visual summary tile for a ranked incoming talent succession candidate.
class IncomingTalentSuccessionCandidateTile extends StatelessWidget {
  final IncomingTalentSuccessionCandidate candidate;

  const IncomingTalentSuccessionCandidateTile({
    super.key,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    final color = _readinessColor(candidate.readiness);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      candidate.targetRole,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: candidate.readiness.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: candidate.readinessRatio,
            color: color,
            label:
                '${candidate.readinessScore}% readiness, ${candidate.confidenceScore}/5 confidence',
          ),
          const SizedBox(height: 10),
          Text(
            candidate.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            candidate.evidenceSummary,
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
                label: candidate.department,
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: candidate.promotionTrack,
              ),
              TalentMetaLabel(
                icon: Icons.warning_amber_outlined,
                label: candidate.risk.label,
              ),
              TalentMetaLabel(
                icon: Icons.task_alt_outlined,
                label: '${candidate.openInterventionCount} open actions',
              ),
              if (candidate.latestEvidenceDate != null)
                TalentMetaLabel(
                  icon: Icons.event_available_outlined,
                  label: DateFormat(
                    'MMM d',
                  ).format(candidate.latestEvidenceDate!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _readinessColor(IncomingTalentSuccessionReadiness readiness) {
  return switch (readiness) {
    IncomingTalentSuccessionReadiness.readyNow => const Color(0xFF059669),
    IncomingTalentSuccessionReadiness.readySoon => const Color(0xFF2563EB),
    IncomingTalentSuccessionReadiness.developing => const Color(0xFFD97706),
    IncomingTalentSuccessionReadiness.blocked => const Color(0xFFDC2626),
  };
}

@Preview(name: 'Talent succession candidate tile')
Widget incomingTalentSuccessionCandidateTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentSuccessionCandidateTile(
          candidate: _previewCandidate,
        ),
      ),
    ),
  );
}

final _previewCandidate = IncomingTalentSuccessionCandidate(
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  targetRole: 'Future Senior People Partner scope',
  promotionTrack: 'Senior People Partner development bench',
  readiness: IncomingTalentSuccessionReadiness.developing,
  risk: IncomingTalentSuccessionRisk.medium,
  readinessScore: 88,
  confidenceScore: 4,
  openInterventionCount: 0,
  latestCalibrationDecisionLabel: 'Accelerate growth',
  evidenceSummary:
      'Accelerate growth; 88% readiness; 4/5 confidence; 0 open actions; Promotion resolution evidence.',
  nextAction: 'Resolve 1 promotion resolution review.',
  latestEvidenceDate: DateTime(2026, 6, 10),
);
