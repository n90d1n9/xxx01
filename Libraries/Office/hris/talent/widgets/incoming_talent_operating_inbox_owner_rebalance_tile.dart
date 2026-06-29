import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_operating_inbox_models.dart';
import 'talent_meta_label.dart';

/// Recommendation tile for rebalancing talent operating inbox ownership.
class IncomingTalentOperatingInboxOwnerRebalanceTile extends StatelessWidget {
  final IncomingTalentOperatingInboxOwnerRebalanceRecommendation recommendation;

  const IncomingTalentOperatingInboxOwnerRebalanceTile({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(recommendation.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_priorityIcon(recommendation.priority), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.sourceOwnerName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      recommendation.targetOwnerName == null
                          ? 'Needs relief capacity'
                          : 'Relief: ${recommendation.targetOwnerName}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: recommendation.priority.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: recommendation.pressureRatio,
            color: color,
            label: '${(recommendation.pressureRatio * 100).round()}% pressure',
          ),
          const SizedBox(height: 10),
          Text(
            recommendation.nextAction,
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
                icon: Icons.swap_horiz_outlined,
                label:
                    '${recommendation.suggestedItemCount} ${_plural(recommendation.suggestedItemCount, 'move')}',
              ),
              TalentMetaLabel(
                icon: Icons.pending_actions_outlined,
                label: '${recommendation.sourceItemCount} active',
              ),
              TalentMetaLabel(
                icon: Icons.priority_high_outlined,
                label: '${recommendation.sourceCriticalCount} critical',
              ),
              TalentMetaLabel(
                icon: Icons.timer_outlined,
                label: '${recommendation.sourceOverdueCount} overdue',
              ),
              TalentMetaLabel(
                icon: Icons.account_tree_outlined,
                label: recommendation.reason,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(
  IncomingTalentOperatingInboxOwnerRebalancePriority priority,
) {
  return switch (priority) {
    IncomingTalentOperatingInboxOwnerRebalancePriority.critical => const Color(
      0xFFDC2626,
    ),
    IncomingTalentOperatingInboxOwnerRebalancePriority.support => const Color(
      0xFFD97706,
    ),
  };
}

IconData _priorityIcon(
  IncomingTalentOperatingInboxOwnerRebalancePriority priority,
) {
  return switch (priority) {
    IncomingTalentOperatingInboxOwnerRebalancePriority.critical =>
      Icons.priority_high_outlined,
    IncomingTalentOperatingInboxOwnerRebalancePriority.support =>
      Icons.balance_outlined,
  };
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}

@Preview(name: 'Talent owner rebalance tile')
Widget incomingTalentOperatingInboxOwnerRebalanceTilePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: IncomingTalentOperatingInboxOwnerRebalanceTile(
          recommendation: _previewRecommendation,
        ),
      ),
    ),
  );
}

const _previewRecommendation =
    IncomingTalentOperatingInboxOwnerRebalanceRecommendation(
      sourceOwnerName: 'People Operations Talent Partner',
      targetOwnerName: 'Engineering HRBP',
      priority: IncomingTalentOperatingInboxOwnerRebalancePriority.critical,
      suggestedItemCount: 2,
      sourceItemCount: 4,
      sourceCriticalCount: 2,
      sourceOverdueCount: 1,
      sourceDueSoonCount: 1,
      sourceWorkstreamCount: 2,
      reliefCapacity: 1,
      reason: '1 overdue talent inbox item',
      nextAction:
          'Move 2 urgent talent items from People Operations Talent Partner to Engineering HRBP.',
    );
