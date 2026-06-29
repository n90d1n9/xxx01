import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_decision_models.dart';
import '../models/incoming_talent_risk_council_queue_models.dart';
import 'talent_meta_label.dart';

/// Queue item picker that keeps council decision source context visible.
class IncomingTalentRiskCouncilDecisionQueuePicker extends StatelessWidget {
  final IncomingTalentRiskCouncilDecisionDraft draft;
  final List<IncomingTalentRiskCouncilQueueItem> items;
  final ValueChanged<String?> onChanged;

  const IncomingTalentRiskCouncilDecisionQueuePicker({
    super.key,
    required this.draft,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = _selectedItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('risk-council-decision-${draft.queueItemId}'),
          isExpanded: true,
          initialValue: selectedItem?.id,
          decoration: const InputDecoration(
            labelText: 'Council queue item',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.groups_2_outlined),
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        _queueItemLabel(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: items.isEmpty ? null : onChanged,
          validator:
              (value) => validateRiskCouncilDecisionRequired(
                value,
                'a council queue item',
              ),
        ),
        if (selectedItem != null) ...[
          const SizedBox(height: 8),
          _DecisionQueueItemContext(item: selectedItem),
        ],
      ],
    );
  }

  IncomingTalentRiskCouncilQueueItem? get _selectedItem {
    for (final item in items) {
      if (item.id == draft.queueItemId) return item;
    }
    return null;
  }
}

/// Compact selected-queue summary for risk council decision entry.
class _DecisionQueueItemContext extends StatelessWidget {
  final IncomingTalentRiskCouncilQueueItem item;

  const _DecisionQueueItemContext({required this.item});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                icon: Icons.warning_amber_outlined,
                label: item.severity.label,
              ),
              TalentMetaLabel(
                icon: Icons.insights_outlined,
                label: '${item.signalCount} signals',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _queueItemLabel(IncomingTalentRiskCouncilQueueItem item) {
  final parts = [
    item.candidateName,
    item.category.label,
    if (item.source != IncomingTalentRiskCouncilQueueSource.general)
      item.source.label,
  ];
  return parts.join(' - ');
}

@Preview(name: 'Talent risk council decision queue picker')
Widget incomingTalentRiskCouncilDecisionQueuePickerPreview() {
  final item = _previewQueueItem;

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentRiskCouncilDecisionQueuePicker(
          draft: IncomingTalentRiskCouncilDecisionDraft.fromQueueItem(
            item: item,
            asOfDate: DateTime(2026, 6, 11),
          ),
          items: [item],
          onChanged: (_) {},
        ),
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
  dueDate: DateTime(2026, 6, 17),
  signalCount: 1,
  source: IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
);
