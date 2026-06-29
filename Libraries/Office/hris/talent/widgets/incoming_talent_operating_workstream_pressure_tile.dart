import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile for one ranked talent operating workstream pressure signal.
class IncomingTalentOperatingWorkstreamPressureTile extends StatelessWidget {
  final IncomingTalentOperatingWorkstreamPressure pressure;

  const IncomingTalentOperatingWorkstreamPressureTile({
    super.key,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingWorkstreamPressureColor(
      pressure.level,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_workstreamIcon(pressure.workstream), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pressure.workstream.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${pressure.totalCount} active ${_plural(pressure.totalCount, 'item')} across ${pressure.ownerCount} ${_plural(pressure.ownerCount, 'owner')}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: pressure.level.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: pressure.pressureRatio,
            color: color,
            label: '${(pressure.pressureRatio * 100).round()}% pressure',
          ),
          const SizedBox(height: 10),
          Text(
            pressure.nextAction,
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
                label: DateFormat('MMM d').format(pressure.earliestDueDate),
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${pressure.criticalCount} critical',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${pressure.overdueCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.upcoming_outlined,
                label: '${pressure.dueSoonCount} due soon',
              ),
              TalentMetaLabel(
                icon: Icons.supervisor_account_outlined,
                label: '${pressure.overloadedOwnerCount} overloaded owners',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingWorkstreamPressureColor(
  IncomingTalentOperatingWorkstreamPressureLevel level,
) {
  return switch (level) {
    IncomingTalentOperatingWorkstreamPressureLevel.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentOperatingWorkstreamPressureLevel.elevated => const Color(
      0xFFD97706,
    ),
    IncomingTalentOperatingWorkstreamPressureLevel.steady => const Color(
      0xFF15803D,
    ),
  };
}

IconData _workstreamIcon(IncomingTalentOperatingWorkstream workstream) {
  return switch (workstream) {
    IncomingTalentOperatingWorkstream.riskCouncil => Icons.gavel_outlined,
    IncomingTalentOperatingWorkstream.development => Icons.school_outlined,
    IncomingTalentOperatingWorkstream.succession => Icons.groups_2_outlined,
    IncomingTalentOperatingWorkstream.promotion =>
      Icons.workspace_premium_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent workstream pressure tile')
Widget incomingTalentOperatingWorkstreamPressureTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingWorkstreamPressureTile(
          pressure: _previewPressure,
        ),
      ),
    ),
  );
}

final _previewPressure = IncomingTalentOperatingWorkstreamPressure(
  workstream: IncomingTalentOperatingWorkstream.riskCouncil,
  level: IncomingTalentOperatingWorkstreamPressureLevel.critical,
  totalCount: 4,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 1,
  overdueCount: 1,
  dueSoonCount: 1,
  ownerCount: 2,
  overloadedOwnerCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction: 'Recover 1 overdue risk council item.',
  itemIds: const ['risk-overdue', 'risk-follow-up'],
);
