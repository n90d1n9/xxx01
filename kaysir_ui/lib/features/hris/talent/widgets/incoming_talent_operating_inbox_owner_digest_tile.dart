import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Tile summarizing one owner's active talent operating inbox workload.
class IncomingTalentOperatingInboxOwnerDigestTile extends StatelessWidget {
  final IncomingTalentOperatingInboxOwnerDigest digest;

  const IncomingTalentOperatingInboxOwnerDigestTile({
    super.key,
    required this.digest,
  });

  @override
  Widget build(BuildContext context) {
    final color = incomingTalentOperatingInboxOwnerLoadColor(digest.load);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_loadIcon(digest.load), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      digest.ownerName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${digest.totalCount} active talent ${_plural(digest.totalCount, 'item')}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: digest.load.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            digest.nextAction,
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
                label: DateFormat('MMM d').format(digest.earliestDueDate),
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${digest.criticalCount} critical',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${digest.overdueCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.upcoming_outlined,
                label: '${digest.dueSoonCount} due soon',
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label:
                    '${digest.sourceCount} ${_plural(digest.sourceCount, 'workstream')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color incomingTalentOperatingInboxOwnerLoadColor(
  IncomingTalentOperatingInboxOwnerLoad load,
) {
  return switch (load) {
    IncomingTalentOperatingInboxOwnerLoad.critical => const Color(0xFFDC2626),
    IncomingTalentOperatingInboxOwnerLoad.stretched => const Color(0xFFD97706),
    IncomingTalentOperatingInboxOwnerLoad.balanced => const Color(0xFF2563EB),
    IncomingTalentOperatingInboxOwnerLoad.clear => const Color(0xFF15803D),
  };
}

IconData _loadIcon(IncomingTalentOperatingInboxOwnerLoad load) {
  return switch (load) {
    IncomingTalentOperatingInboxOwnerLoad.critical =>
      Icons.priority_high_outlined,
    IncomingTalentOperatingInboxOwnerLoad.stretched => Icons.speed_outlined,
    IncomingTalentOperatingInboxOwnerLoad.balanced =>
      Icons.assignment_ind_outlined,
    IncomingTalentOperatingInboxOwnerLoad.clear => Icons.check_circle_outline,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent inbox owner digest tile')
Widget incomingTalentOperatingInboxOwnerDigestTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentOperatingInboxOwnerDigestTile(
          digest: _previewDigest,
        ),
      ),
    ),
  );
}

final _previewDigest = IncomingTalentOperatingInboxOwnerDigest(
  ownerName: 'People Operations Talent Partner',
  load: IncomingTalentOperatingInboxOwnerLoad.critical,
  totalCount: 3,
  criticalCount: 2,
  watchCount: 1,
  routineCount: 0,
  overdueCount: 1,
  dueSoonCount: 1,
  riskCouncilCount: 2,
  developmentCount: 0,
  successionCount: 0,
  promotionCount: 1,
  earliestDueDate: DateTime(2026, 6, 10),
  nextAction:
      'Recover 1 overdue talent inbox item with People Operations Talent Partner.',
  itemIds: const ['risk-follow-up:preview', 'promotion-action:preview'],
);
