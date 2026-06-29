import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/talent_models.dart';
import 'talent_meta_label.dart';
import 'talent_status_styles.dart';

class MentorshipPanel extends StatelessWidget {
  final List<MentorshipPair> pairs;

  const MentorshipPanel({super.key, required this.pairs});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      title: 'Mentorship',
      icon: Icons.handshake_outlined,
      subtitle: '${pairs.length} active pairs',
      emptyMessage: 'No mentorship pairs match filters',
      children: pairs.map((pair) => _MentorshipTile(pair: pair)).toList(),
    );
  }
}

class _MentorshipTile extends StatelessWidget {
  final MentorshipPair pair;

  const _MentorshipTile({required this.pair});

  @override
  Widget build(BuildContext context) {
    final color = mentorshipHealthColor(pair.health);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${pair.mentorName} -> ${pair.menteeName}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: mentorshipHealthLabel(pair.health),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            pair.focusArea,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: pair.progress,
            color: color,
            label:
                '${pair.sessionsCompleted}/${pair.sessionsPlanned} sessions completed',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: pair.department,
              ),
              TalentMetaLabel(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('MMM d').format(pair.nextSession),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
