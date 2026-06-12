import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_extension_readiness_service.dart';

class ProjectDomainExtensionReadinessPanel extends StatelessWidget {
  const ProjectDomainExtensionReadinessPanel({
    required this.summary,
    super.key,
  });

  final ProjectDomainExtensionReadinessSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              '${summary.completedReadinessFieldCount}/${summary.readinessFieldCount} domain fields complete',
          subtitle: summary.guidance,
          icon: _statusIcon(),
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: statusColor.withValues(alpha: 0.12),
          iconForegroundColor: statusColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.statusLabel,
            icon: _statusIcon(),
            color: statusColor,
            maxWidth: 132,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: summary.completionRatio,
            minHeight: 8,
            color: statusColor,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(
              label:
                  '${summary.completedRequiredFieldCount}/${summary.requiredFieldCount} required',
              icon: Icons.priority_high_rounded,
              color: colorScheme.error,
              maxWidth: 138,
            ),
            AppStatusPill(
              label:
                  '${summary.completedRecommendedFieldCount}/${summary.recommendedFieldCount} recommended',
              icon: Icons.fact_check_outlined,
              color: colorScheme.primary,
              maxWidth: 178,
            ),
            AppStatusPill(
              label: '${summary.filledCustomFieldCount} custom filled',
              icon: Icons.add_task_outlined,
              color: colorScheme.primary,
              maxWidth: 156,
            ),
            AppStatusPill(
              label: '${summary.riskRuleCount} risk signals',
              icon: Icons.sensors_outlined,
              color: colorScheme.tertiary,
              maxWidth: 146,
            ),
            AppStatusPill(
              label: '${summary.watchedFieldCount} watched fields',
              icon: Icons.visibility_outlined,
              color: colorScheme.secondary,
              maxWidth: 160,
            ),
          ],
        ),
        if (summary.missingRequiredFields.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppInfoRow(
            title: _fieldLabels(summary.missingRequiredFields),
            subtitle:
                '${summary.missingRequiredFields.length} required field${summary.missingRequiredFields.length == 1 ? '' : 's'} missing before this domain is ready',
            icon: Icons.assignment_late_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.errorContainer.withValues(
              alpha: 0.55,
            ),
            iconForegroundColor: colorScheme.onErrorContainer,
            titleMaxLines: 2,
            subtitleMaxLines: 2,
          ),
        ],
        if (summary.missingRequiredFields.isEmpty &&
            summary.missingRecommendedFields.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppInfoRow(
            title: _fieldLabels(summary.missingRecommendedFields),
            subtitle:
                summary.missingWatchedFields.isEmpty
                    ? 'Recommended domain context still improves handoff quality'
                    : '${summary.missingWatchedFields.length} missing recommended field${summary.missingWatchedFields.length == 1 ? '' : 's'} can trigger risk prompts',
            icon: Icons.playlist_add_check_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.primaryContainer.withValues(
              alpha: 0.42,
            ),
            iconForegroundColor: colorScheme.onPrimaryContainer,
            titleMaxLines: 2,
            subtitleMaxLines: 2,
          ),
        ],
      ],
    );
  }

  String _fieldLabels(List<ProjectDomainExtensionFieldSignal> fields) {
    return fields.map((field) => field.label).join(', ');
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (summary.status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return Colors.orange.shade700;
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return colorScheme.primary;
      case ProjectDomainExtensionReadinessStatus.ready:
        return Colors.green.shade700;
    }
  }

  IconData _statusIcon() {
    switch (summary.status) {
      case ProjectDomainExtensionReadinessStatus.needsContext:
        return Icons.edit_note_outlined;
      case ProjectDomainExtensionReadinessStatus.inProgress:
        return Icons.pending_actions_outlined;
      case ProjectDomainExtensionReadinessStatus.ready:
        return Icons.verified_outlined;
    }
  }
}
