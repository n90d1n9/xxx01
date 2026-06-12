import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile for one normalized cross-HRIS talent operating SLA item.
class IncomingTalentOperatingSlaTile extends StatelessWidget {
  final IncomingTalentOperatingSlaItem item;

  const IncomingTalentOperatingSlaTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingSlaStatusColor(item.status);

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
                      '${item.source.label} - ${item.subjectName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.status.label, color: color),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: item.normalizedSlaPressureRatio,
            color: color,
            label:
                '${(item.normalizedSlaPressureRatio * 100).round()}% SLA pressure',
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
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: _dueLabel(item.daysUntilDue),
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: item.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: item.workstreamLabel,
              ),
              if (item.evidenceCount > 0)
                TalentMetaLabel(
                  icon: Icons.inventory_2_outlined,
                  label:
                      '${item.evidenceCount} ${_plural(item.evidenceCount, 'proof')}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingSlaStatusColor(
  IncomingTalentOperatingSlaStatus status,
) {
  return switch (status) {
    IncomingTalentOperatingSlaStatus.overdue => const Color(0xFFDC2626),
    IncomingTalentOperatingSlaStatus.dueToday => const Color(0xFFD97706),
    IncomingTalentOperatingSlaStatus.atRisk => const Color(0xFF2563EB),
    IncomingTalentOperatingSlaStatus.onTrack => const Color(0xFF059669),
  };
}

IconData _sourceIcon(IncomingTalentOperatingSlaSource source) {
  return switch (source) {
    IncomingTalentOperatingSlaSource.recruitment => Icons.how_to_reg_outlined,
    IncomingTalentOperatingSlaSource.training => Icons.school_outlined,
    IncomingTalentOperatingSlaSource.careerPath => Icons.route_outlined,
    IncomingTalentOperatingSlaSource.succession => Icons.groups_2_outlined,
    IncomingTalentOperatingSlaSource.promotion =>
      Icons.workspace_premium_outlined,
    IncomingTalentOperatingSlaSource.assurance => Icons.verified_user_outlined,
  };
}

String _dueLabel(int days) {
  if (days < 0) return '${days.abs()}d overdue';
  if (days == 0) return 'Due today';
  return 'Due in ${days}d';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent operating SLA tile')
Widget incomingTalentOperatingSlaTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingSlaTile(item: _previewItem),
      ),
    ),
  );
}

final _previewItem = IncomingTalentOperatingSlaItem(
  id: 'operating-sla-assurance-preview',
  referenceId: 'assurance-execution-preview',
  source: IncomingTalentOperatingSlaSource.assurance,
  status: IncomingTalentOperatingSlaStatus.overdue,
  title: 'People Operations Talent Partner execution - Risk council',
  subjectName: 'Risk council',
  department: 'Talent assurance',
  ownerName: 'People Operations Talent Partner',
  workstreamLabel: 'Assurance - Risk council',
  priorityLabel: 'Critical',
  nextAction:
      'Unblock linked risk council escalations with People Operations Talent Partner.',
  dueDate: DateTime(2026, 6, 10),
  daysUntilDue: -1,
  slaPressureRatio: 0.82,
  evidenceCount: 3,
  referenceIds: const ['evidence-risk-overdue', 'evidence-risk-linked'],
);
