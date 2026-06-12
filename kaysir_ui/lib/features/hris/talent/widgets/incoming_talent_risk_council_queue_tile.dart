import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import 'talent_meta_label.dart';

/// List tile that explains one talent risk council queue item and action.
class IncomingTalentRiskCouncilQueueTile extends StatelessWidget {
  final IncomingTalentRiskCouncilQueueItem item;

  const IncomingTalentRiskCouncilQueueTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(item.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_categoryIcon(item.category), color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${item.role} - ${item.department}',
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
            value: item.urgencyRatio,
            color: color,
            label:
                '${item.signalCount} ${item.category.label.toLowerCase()} signals',
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            item.recommendedAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                icon: Icons.category_outlined,
                label: item.category.label,
              ),
              if (item.source != IncomingTalentRiskCouncilQueueSource.general)
                TalentMetaLabel(
                  icon: Icons.account_tree_outlined,
                  label: item.source.label,
                ),
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: item.department,
              ),
              TalentMetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(item.dueDate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _severityColor(IncomingTalentRiskCouncilQueueSeverity severity) {
  return switch (severity) {
    IncomingTalentRiskCouncilQueueSeverity.critical => const Color(0xFFDC2626),
    IncomingTalentRiskCouncilQueueSeverity.watch => const Color(0xFFD97706),
  };
}

IconData _categoryIcon(IncomingTalentRiskCouncilQueueCategory category) {
  return switch (category) {
    IncomingTalentRiskCouncilQueueCategory.intervention =>
      Icons.build_circle_outlined,
    IncomingTalentRiskCouncilQueueCategory.followUp => Icons.add_task_outlined,
    IncomingTalentRiskCouncilQueueCategory.resolutionReview =>
      Icons.fact_check_outlined,
    IncomingTalentRiskCouncilQueueCategory.careerSupport =>
      Icons.support_agent_outlined,
    IncomingTalentRiskCouncilQueueCategory.program =>
      Icons.workspace_premium_outlined,
  };
}

@Preview(name: 'Talent risk council queue tile')
Widget incomingTalentRiskCouncilQueueTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilQueueTile(item: _previewQueueItem),
      ),
    ),
  );
}

final _previewQueueItem = IncomingTalentRiskCouncilQueueItem(
  id: 'risk-council:candidate-preview:promotion-resolution-review',
  candidateId: 'candidate-preview',
  candidateName: 'Alya Maheswari',
  role: 'Senior People Partner',
  department: 'People Operations',
  category: IncomingTalentRiskCouncilQueueCategory.resolutionReview,
  severity: IncomingTalentRiskCouncilQueueSeverity.watch,
  title: 'Promotion resolution review risk',
  detail: '1 promotion resolution review still carries residual role risk.',
  recommendedAction:
      'Decide whether to reopen follow-up, escalate to people panel, or approve monitoring.',
  dueDate: DateTime(2026, 6, 10),
  signalCount: 1,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
);
