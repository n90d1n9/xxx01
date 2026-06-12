import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/candidate_talent_handoff_checklist_models.dart';
import 'recruitment_meta_label.dart';

class CandidateTalentHandoffChecklistTile extends StatelessWidget {
  final CandidateTalentHandoffChecklistItem item;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBlock;

  const CandidateTalentHandoffChecklistTile({
    super.key,
    required this.item,
    required this.asOfDate,
    required this.onStart,
    required this.onComplete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_statusIcon(item.status), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          item.candidateName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final status = HrisStatusPill(
                label: item.status.label,
                color: color,
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), status],
                );
              }

              return Row(
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 12),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              RecruitmentMetaLabel(
                icon: Icons.category_outlined,
                label: item.category.label,
              ),
              RecruitmentMetaLabel(
                icon: Icons.badge_outlined,
                label: 'Owner: ${item.ownerName}',
              ),
              RecruitmentMetaLabel(
                icon: Icons.event_available_outlined,
                label:
                    '${item.daysUntilDue(asOfDate)} days - ${DateFormat('MMM d').format(item.dueDate)}',
              ),
              if (item.requiredBeforeStart)
                const RecruitmentMetaLabel(
                  icon: Icons.lock_clock_outlined,
                  label: 'Before start',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.status !=
              CandidateTalentHandoffChecklistStatus.completed) ...[
            const SizedBox(height: 12),
            _ChecklistActions(
              status: item.status,
              onStart: onStart,
              onComplete: onComplete,
              onBlock: onBlock,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistActions extends StatelessWidget {
  final CandidateTalentHandoffChecklistStatus status;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBlock;

  const _ChecklistActions({
    required this.status,
    required this.onStart,
    required this.onComplete,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final primary =
        status == CandidateTalentHandoffChecklistStatus.inProgress
            ? FilledButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Complete'),
            )
            : FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_outlined),
              label: Text(
                status == CandidateTalentHandoffChecklistStatus.blocked
                    ? 'Resume'
                    : 'Start',
              ),
            );

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (status != CandidateTalentHandoffChecklistStatus.blocked)
            OutlinedButton.icon(
              onPressed: onBlock,
              icon: const Icon(Icons.block_outlined),
              label: const Text('Block'),
            ),
          primary,
        ],
      ),
    );
  }
}

Color _statusColor(CandidateTalentHandoffChecklistStatus status) {
  return switch (status) {
    CandidateTalentHandoffChecklistStatus.open => const Color(0xFF2563EB),
    CandidateTalentHandoffChecklistStatus.inProgress => const Color(0xFFB45309),
    CandidateTalentHandoffChecklistStatus.completed => const Color(0xFF15803D),
    CandidateTalentHandoffChecklistStatus.blocked => const Color(0xFFDC2626),
  };
}

IconData _statusIcon(CandidateTalentHandoffChecklistStatus status) {
  return switch (status) {
    CandidateTalentHandoffChecklistStatus.open => Icons.task_outlined,
    CandidateTalentHandoffChecklistStatus.inProgress =>
      Icons.pending_actions_outlined,
    CandidateTalentHandoffChecklistStatus.completed => Icons.verified_outlined,
    CandidateTalentHandoffChecklistStatus.blocked =>
      Icons.report_problem_outlined,
  };
}
