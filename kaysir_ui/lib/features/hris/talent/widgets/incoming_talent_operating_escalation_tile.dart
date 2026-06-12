import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile that presents one ranked talent operating escalation.
class IncomingTalentOperatingEscalationTile extends StatelessWidget {
  final IncomingTalentOperatingEscalationItem item;

  const IncomingTalentOperatingEscalationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingEscalationSeverityColor(item.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_sourceIcon(item.source), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.severity.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.normalizedPressureRatio,
            color: color,
            label:
                '${(item.normalizedPressureRatio * 100).round()}% escalation pressure',
          ),
          const SizedBox(height: 10),
          Text(
            item.nextAction,
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
                icon: _sourceIcon(item.source),
                label: item.source.label,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: _dueLabel(item),
              ),
              TalentMetaLabel(
                icon: Icons.stacked_line_chart_outlined,
                label:
                    '${item.signalCount} ${_plural(item.signalCount, 'signal')}',
              ),
              if (item.hasOwner)
                TalentMetaLabel(
                  icon: Icons.person_outline,
                  label: item.ownerName!,
                ),
              if (item.hasWorkstream)
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: item.workstreamLabel!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingEscalationSeverityColor(
  IncomingTalentOperatingEscalationSeverity severity,
) {
  return switch (severity) {
    IncomingTalentOperatingEscalationSeverity.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentOperatingEscalationSeverity.high => const Color(0xFFD97706),
    IncomingTalentOperatingEscalationSeverity.watch => const Color(0xFF2563EB),
  };
}

IconData _sourceIcon(IncomingTalentOperatingEscalationSource source) {
  return switch (source) {
    IncomingTalentOperatingEscalationSource.cadence =>
      Icons.calendar_month_outlined,
    IncomingTalentOperatingEscalationSource.ownerRebalance =>
      Icons.balance_outlined,
    IncomingTalentOperatingEscalationSource.workstreamPressure =>
      Icons.account_tree_outlined,
    IncomingTalentOperatingEscalationSource.inbox =>
      Icons.pending_actions_outlined,
  };
}

String _dueLabel(IncomingTalentOperatingEscalationItem item) {
  if (item.dueDate == null) return 'Immediate';
  if (item.overdue) {
    return 'Overdue ${DateFormat('MMM d').format(item.dueDate!)}';
  }
  if (item.dueToday) return 'Today';
  return DateFormat('MMM d').format(item.dueDate!);
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent escalation tile')
Widget incomingTalentOperatingEscalationTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingEscalationTile(item: _previewEscalation),
      ),
    ),
  );
}

final _previewEscalation = IncomingTalentOperatingEscalationItem(
  source: IncomingTalentOperatingEscalationSource.workstreamPressure,
  severity: IncomingTalentOperatingEscalationSeverity.critical,
  title: 'Risk council pressure',
  detail: '4 active items across 2 owners',
  nextAction: 'Recover 1 overdue risk council item.',
  signalCount: 5,
  dueDate: DateTime(2026, 6, 10),
  overdue: true,
  dueToday: false,
  ownerName: null,
  workstreamLabel: 'Risk council',
  pressureRatio: 0.81,
  referenceIds: const ['risk-overdue', 'risk-follow-up'],
);
