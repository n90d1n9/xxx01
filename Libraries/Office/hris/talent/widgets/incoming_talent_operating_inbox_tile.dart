import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile for one cross-HRIS talent operating inbox action.
class IncomingTalentOperatingInboxTile extends StatelessWidget {
  final IncomingTalentOperatingInboxItem item;
  final DateTime asOfDate;

  const IncomingTalentOperatingInboxTile({
    super.key,
    required this.item,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingInboxPriorityColor(item.priority);

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
                      '${item.subjectName} - ${item.department}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: item.priority.label, color: color),
            ],
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
                icon: Icons.account_tree_outlined,
                label: item.source.label,
              ),
              TalentMetaLabel(
                icon: Icons.badge_outlined,
                label: item.ownerName,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: _dueLabel(item.daysUntilDue(asOfDate)),
              ),
              TalentMetaLabel(
                icon: Icons.info_outline,
                label: item.statusLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingInboxPriorityColor(
  IncomingTalentOperatingInboxPriority priority,
) {
  return switch (priority) {
    IncomingTalentOperatingInboxPriority.critical => const Color(0xFFDC2626),
    IncomingTalentOperatingInboxPriority.watch => const Color(0xFFD97706),
    IncomingTalentOperatingInboxPriority.routine => const Color(0xFF2563EB),
  };
}

IconData _sourceIcon(IncomingTalentOperatingInboxSource source) {
  return switch (source) {
    IncomingTalentOperatingInboxSource.riskCouncilDecision =>
      Icons.fact_check_outlined,
    IncomingTalentOperatingInboxSource.riskCouncilFollowUp =>
      Icons.next_plan_outlined,
    IncomingTalentOperatingInboxSource.trainingSession => Icons.school_outlined,
    IncomingTalentOperatingInboxSource.careerPathReview =>
      Icons.account_tree_outlined,
    IncomingTalentOperatingInboxSource.successionCoverageFollowUp =>
      Icons.groups_2_outlined,
    IncomingTalentOperatingInboxSource.promotionStabilization =>
      Icons.workspace_premium_outlined,
  };
}

String _dueLabel(int days) {
  if (days < 0) return '${days.abs()}d overdue';
  if (days == 0) return 'Due today';
  return 'Due in ${days}d';
}

@Preview(name: 'Talent operating inbox tile')
Widget incomingTalentOperatingInboxTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingInboxTile(
          item: _previewItem,
          asOfDate: DateTime(2026, 6, 11),
        ),
      ),
    ),
  );
}

final _previewItem = IncomingTalentOperatingInboxItem(
  id: 'risk-follow-up:preview',
  source: IncomingTalentOperatingInboxSource.riskCouncilFollowUp,
  priority: IncomingTalentOperatingInboxPriority.critical,
  title: 'Create risk council follow-up',
  subjectName: 'Alya Maheswari',
  department: 'People Operations',
  ownerName: 'People Operations Talent Partner',
  statusLabel: 'Escalated',
  nextAction:
      'Create the owner follow-up and capture council commitment evidence.',
  dueDate: DateTime(2026, 6, 10),
);
