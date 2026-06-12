import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_info_row.dart';
import '../../../../widgets/ui/app_select_field.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../../../../widgets/ui/app_surface.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../models/financial_report_evidence_close_task.dart';

class FinancialReportEvidenceTaskResolutionHeader extends StatelessWidget {
  const FinancialReportEvidenceTaskResolutionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: Icons.assignment_turned_in_rounded,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextCluster(
            title: 'Resolve Evidence Task',
            subtitle: 'Attach review evidence for close readiness.',
            titleStyle: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            subtitleMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class FinancialReportEvidenceTaskSummaryCard extends StatelessWidget {
  const FinancialReportEvidenceTaskSummaryCard({required this.task, super.key});

  final FinancialReportEvidenceCloseTask task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(14),
      backgroundColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextCluster(
                  title: task.title,
                  subtitle: task.actionLabel,
                  titleStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  subtitleMaxLines: 3,
                ),
              ),
              const SizedBox(width: 10),
              AppStatusPill(
                label: task.priority.label,
                color: task.priority._color(colorScheme),
                icon: task.priority._icon,
                maxWidth: 120,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _EvidenceTaskFact(
                title: 'Schedule',
                value: task.scheduleTitle,
                icon: Icons.fact_check_outlined,
              ),
              _EvidenceTaskFact(
                title: 'Owner',
                value: task.owner,
                icon: Icons.person_rounded,
              ),
              _EvidenceTaskFact(
                title: 'Reviewer',
                value: task.reviewer,
                icon: Icons.verified_user_rounded,
              ),
              _EvidenceTaskFact(
                title: 'Signals',
                value: task.signalLabel,
                icon: Icons.sensors_rounded,
              ),
              _EvidenceTaskFact(
                title: 'Reference',
                value: task.reference,
                icon: Icons.rule_folder_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialReportEvidenceTaskStatusField extends StatelessWidget {
  const FinancialReportEvidenceTaskStatusField({
    required this.status,
    required this.onChanged,
    super.key,
  });

  final FinancialReportEvidenceCloseTaskResolutionStatus status;
  final ValueChanged<FinancialReportEvidenceCloseTaskResolutionStatus>
  onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<FinancialReportEvidenceCloseTaskResolutionStatus>(
      label: 'Resolution status',
      icon: Icons.rule_rounded,
      value: status,
      options: [
        for (final value
            in FinancialReportEvidenceCloseTaskResolutionStatus.values)
          AppSelectOption(value: value, label: value.label),
      ],
      onChanged: onChanged,
    );
  }
}

class _EvidenceTaskFact extends StatelessWidget {
  const _EvidenceTaskFact({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: AppInfoRow(
        title: value,
        subtitle: title,
        icon: icon,
        contained: true,
        iconStyle: AppInfoRowIconStyle.badge,
        titleMaxLines: 2,
        subtitleMaxLines: 1,
      ),
    );
  }
}

extension _FinancialReportEvidenceCloseTaskPriorityVisuals
    on FinancialReportEvidenceCloseTaskPriority {
  IconData get _icon {
    switch (this) {
      case FinancialReportEvidenceCloseTaskPriority.action:
        return Icons.priority_high_rounded;
      case FinancialReportEvidenceCloseTaskPriority.monitor:
        return Icons.visibility_rounded;
    }
  }

  Color _color(ColorScheme colorScheme) {
    switch (this) {
      case FinancialReportEvidenceCloseTaskPriority.action:
        return colorScheme.error;
      case FinancialReportEvidenceCloseTaskPriority.monitor:
        return colorScheme.tertiary;
    }
  }
}
