import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_checklist_models.dart';

class CandidateTalentHandoffChecklistSummaryTile extends StatelessWidget {
  final CandidateTalentHandoffChecklistSummary summary;

  const CandidateTalentHandoffChecklistSummaryTile({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.task_alt_outlined, color: HrisColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checklist action',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      summary.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChecklistStat(label: 'Tasks', value: '${summary.totalCount}'),
              _ChecklistStat(label: 'Open', value: '${summary.openCount}'),
              _ChecklistStat(
                label: 'Progress',
                value: '${summary.inProgressCount}',
              ),
              _ChecklistStat(
                label: 'Completed',
                value: '${summary.completedCount}',
              ),
              _ChecklistStat(
                label: 'Blocked',
                value: '${summary.blockedCount}',
              ),
              _ChecklistStat(
                label: 'Due soon',
                value: '${summary.dueSoonCount}',
              ),
              _ChecklistStat(
                label: 'Overdue',
                value: '${summary.overdueCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChecklistStat extends StatelessWidget {
  final String label;
  final String value;

  const _ChecklistStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}
