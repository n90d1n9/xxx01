import 'package:flutter/material.dart';

import '../models/financial_report_release_control.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseControlSummaryPanel extends StatelessWidget {
  const FinancialReportReleaseControlSummaryPanel({
    required this.summary,
    super.key,
  });

  final FinancialReportReleaseControlSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent =
        summary.releaseComplete ? Colors.teal.shade700 : colorScheme.tertiary;

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon:
                        summary.releaseComplete
                            ? Icons.verified_rounded
                            : Icons.route_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Release Control Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.nextAction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final badge = FinancialReportReleaseSignOffBadge(
                label: summary.headline,
                color: accent,
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), badge],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.completionRatio.clamp(0, 1),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 14),
          FinancialReportResponsiveWrapGrid<FinancialReportReleaseControlStage>(
            items: summary.stages,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 820,
                columns: 3,
              ),
            ],
            itemBuilder:
                (_, stage) =>
                    FinancialReportReleaseControlStageTile(stage: stage),
          ),
        ],
      ),
    );
  }
}

class FinancialReportReleaseControlStageTile extends StatelessWidget {
  const FinancialReportReleaseControlStageTile({
    required this.stage,
    super.key,
  });

  final FinancialReportReleaseControlStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _stageColor(stage.status, colorScheme);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_stageIcon(stage), color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FinancialReportReleaseSignOffBadge(
            label: stage.status.label,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            stage.detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

Color _stageColor(
  FinancialReportReleaseControlStageStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportReleaseControlStageStatus.complete:
      return Colors.teal.shade700;
    case FinancialReportReleaseControlStageStatus.actionNeeded:
      return colorScheme.tertiary;
    case FinancialReportReleaseControlStageStatus.blocked:
      return colorScheme.error;
  }
}

IconData _stageIcon(FinancialReportReleaseControlStage stage) {
  switch (stage.kind) {
    case FinancialReportReleaseControlStageKind.packageIntegrity:
      return Icons.fingerprint_rounded;
    case FinancialReportReleaseControlStageKind.managementMeasures:
      return Icons.speed_rounded;
    case FinancialReportReleaseControlStageKind.signOff:
      return Icons.draw_rounded;
    case FinancialReportReleaseControlStageKind.distribution:
      return Icons.send_rounded;
  }
}
