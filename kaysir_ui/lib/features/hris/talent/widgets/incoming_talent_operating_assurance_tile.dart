import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile that summarizes audit assurance for one talent workstream.
class IncomingTalentOperatingAssuranceTile extends StatelessWidget {
  final IncomingTalentOperatingAssuranceWorkstream workstream;

  const IncomingTalentOperatingAssuranceTile({
    super.key,
    required this.workstream,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingAssuranceLevelColor(workstream.level);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_workstreamIcon(workstream.workstreamLabel), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workstream.workstreamLabel,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${workstream.gapCount} evidence ${_plural(workstream.gapCount, 'gap')} across ${workstream.ownerCount} ${_plural(workstream.ownerCount, 'owner')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: workstream.level.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: workstream.exposureRatio,
            color: color,
            label:
                '${(workstream.exposureRatio * 100).round()}% audit exposure',
          ),
          const SizedBox(height: 10),
          Text(
            workstream.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: _dueLabel(workstream),
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${workstream.criticalGapCount} critical',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${workstream.overdueGapCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.link_outlined,
                label:
                    '${workstream.linkedEscalationCount} linked ${_plural(workstream.linkedEscalationCount, 'escalation')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingAssuranceLevelColor(
  IncomingTalentOperatingAssuranceLevel level,
) {
  return switch (level) {
    IncomingTalentOperatingAssuranceLevel.exposed => const Color(0xFFDC2626),
    IncomingTalentOperatingAssuranceLevel.guarded => const Color(0xFFD97706),
    IncomingTalentOperatingAssuranceLevel.ready => const Color(0xFF15803D),
  };
}

IconData _workstreamIcon(String workstreamLabel) {
  return switch (workstreamLabel) {
    'Risk council' => Icons.gavel_outlined,
    'Development' => Icons.school_outlined,
    'Succession' => Icons.groups_2_outlined,
    'Promotion' => Icons.workspace_premium_outlined,
    _ => Icons.verified_user_outlined,
  };
}

String _dueLabel(IncomingTalentOperatingAssuranceWorkstream workstream) {
  final nextDueDate = workstream.nextDueDate;
  if (nextDueDate == null) return 'Ready';
  return DateFormat('MMM d').format(nextDueDate);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent assurance tile')
Widget incomingTalentOperatingAssuranceTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingAssuranceTile(
          workstream: _previewWorkstream,
        ),
      ),
    ),
  );
}

final _previewWorkstream = IncomingTalentOperatingAssuranceWorkstream(
  workstreamLabel: 'Risk council',
  level: IncomingTalentOperatingAssuranceLevel.exposed,
  gapCount: 2,
  criticalGapCount: 1,
  highGapCount: 1,
  watchGapCount: 0,
  overdueGapCount: 1,
  dueTodayGapCount: 0,
  linkedEscalationCount: 3,
  ownerCount: 2,
  nextDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 1 overdue risk council evidence gap.',
  gapIds: const ['evidence-risk-overdue', 'evidence-risk-today'],
);
