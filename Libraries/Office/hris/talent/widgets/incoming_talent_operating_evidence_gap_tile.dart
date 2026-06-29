import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile that shows one evidence gap needed for talent operating closure.
class IncomingTalentOperatingEvidenceGapTile extends StatelessWidget {
  final IncomingTalentOperatingEvidenceGap gap;

  const IncomingTalentOperatingEvidenceGapTile({super.key, required this.gap});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingEvidenceGapRiskColor(gap.risk);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon(gap.type), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gap.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${gap.workstreamLabel} - ${gap.statusLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: gap.risk.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: gap.normalizedPressureRatio,
            color: color,
            label:
                '${(gap.normalizedPressureRatio * 100).round()}% evidence pressure',
          ),
          const SizedBox(height: 10),
          Text(
            gap.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            gap.evidenceRequest,
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
                icon: Icons.event_available_outlined,
                label: _dueLabel(gap),
              ),
              TalentMetaLabel(icon: Icons.person_outline, label: gap.ownerName),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: gap.workstreamLabel,
              ),
              TalentMetaLabel(
                icon: Icons.link_outlined,
                label:
                    '${gap.linkedEscalationCount} linked ${_plural(gap.linkedEscalationCount, 'escalation')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingEvidenceGapRiskColor(
  IncomingTalentOperatingEvidenceGapRisk risk,
) {
  return switch (risk) {
    IncomingTalentOperatingEvidenceGapRisk.critical => const Color(0xFFDC2626),
    IncomingTalentOperatingEvidenceGapRisk.high => const Color(0xFFD97706),
    IncomingTalentOperatingEvidenceGapRisk.watch => const Color(0xFF2563EB),
  };
}

IconData _typeIcon(IncomingTalentOperatingEvidenceGapType type) {
  return switch (type) {
    IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence =>
      Icons.fact_check_outlined,
    IncomingTalentOperatingEvidenceGapType.learningEvidence =>
      Icons.school_outlined,
    IncomingTalentOperatingEvidenceGapType.careerPathEvidence =>
      Icons.route_outlined,
    IncomingTalentOperatingEvidenceGapType.successionEvidence =>
      Icons.groups_2_outlined,
    IncomingTalentOperatingEvidenceGapType.promotionEvidence =>
      Icons.workspace_premium_outlined,
  };
}

String _dueLabel(IncomingTalentOperatingEvidenceGap gap) {
  if (gap.overdue) {
    return 'Overdue ${DateFormat('MMM d').format(gap.dueDate)}';
  }
  if (gap.dueToday) return 'Today';
  return DateFormat('MMM d').format(gap.dueDate);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent evidence gap tile')
Widget incomingTalentOperatingEvidenceGapTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingEvidenceGapTile(gap: _previewGap),
      ),
    ),
  );
}

final _previewGap = IncomingTalentOperatingEvidenceGap(
  id: 'evidence-risk-overdue',
  type: IncomingTalentOperatingEvidenceGapType.riskCouncilEvidence,
  risk: IncomingTalentOperatingEvidenceGapRisk.critical,
  title: 'Risk council evidence: Ari Talent',
  subjectName: 'Ari Talent',
  ownerName: 'People Operations Talent Partner',
  workstreamLabel: 'Risk council',
  statusLabel: 'Blocked',
  evidenceRequest:
      'Attach decision notes, owner commitment, and follow-up acceptance.',
  nextAction: 'Recover overdue risk council evidence for Ari Talent.',
  dueDate: DateTime(2026, 6, 10),
  daysUntilDue: -1,
  overdue: true,
  dueToday: false,
  linkedEscalationCount: 2,
  pressureRatio: 0.91,
  referenceIds: const ['risk-overdue'],
);
