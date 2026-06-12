import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_content_panel.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/financial_report_management_measure_release_readiness.dart';
import 'financial_report_focus_highlight.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportManagementMeasureReleaseChecklistStrip
    extends StatelessWidget {
  const FinancialReportManagementMeasureReleaseChecklistStrip({
    required this.summary,
    this.focusedKind,
    super.key,
  });

  final FinancialReportManagementMeasureReleaseReadinessSummary summary;
  final FinancialReportManagementMeasureReleaseCheckKind? focusedKind;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent =
        summary.readyForExport ? Colors.teal.shade700 : colorScheme.tertiary;

    return AppContentPanel(
      title: 'UKTM Release Evidence',
      subtitle: summary.nextAction,
      leadingIcon: Icons.fact_check_rounded,
      elevated: false,
      trailing: AppStatusPill(
        label:
            summary.readyForExport
                ? 'Export ready'
                : '${summary.actionRequiredCount} action(s)',
        color: accent,
        icon:
            summary.readyForExport
                ? Icons.verified_rounded
                : Icons.pending_actions_rounded,
        maxWidth: 160,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.completionRatio.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 12),
          FinancialReportResponsiveWrapGrid<
            FinancialReportManagementMeasureReleaseCheckItem
          >(
            items: summary.items,
            breakpoints: const [
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 760,
                columns: 2,
              ),
              FinancialReportResponsiveGridBreakpoint(
                minWidth: 1080,
                columns: 4,
              ),
            ],
            itemBuilder:
                (context, item) => _ManagementMeasureReleaseCheckTile(
                  item: item,
                  focused: item.kind == focusedKind,
                ),
          ),
        ],
      ),
    );
  }
}

class _ManagementMeasureReleaseCheckTile extends StatelessWidget {
  const _ManagementMeasureReleaseCheckTile({
    required this.item,
    required this.focused,
  });

  final FinancialReportManagementMeasureReleaseCheckItem item;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(item.status, colorScheme);

    return FinancialReportFocusHighlight(
      active: focused,
      color: color,
      child: FinancialReportTintedSurface(
        color: color,
        minHeight: 142,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_kindIcon(item.kind), color: color, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
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
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                AppStatusPill(
                  label: item.status.label,
                  color: color,
                  icon: item.isReady ? Icons.check_circle_rounded : Icons.error,
                  maxWidth: 130,
                ),
                AppStatusPill(
                  label: item.metric,
                  color: colorScheme.primary,
                  maxWidth: 150,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.detail,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(
  FinancialReportManagementMeasureReleaseCheckStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportManagementMeasureReleaseCheckStatus.ready:
      return Colors.teal.shade700;
    case FinancialReportManagementMeasureReleaseCheckStatus.actionRequired:
      return colorScheme.error;
  }
}

IconData _kindIcon(FinancialReportManagementMeasureReleaseCheckKind kind) {
  switch (kind) {
    case FinancialReportManagementMeasureReleaseCheckKind.auditTrail:
      return Icons.manage_history_rounded;
    case FinancialReportManagementMeasureReleaseCheckKind.approval:
      return Icons.verified_user_outlined;
    case FinancialReportManagementMeasureReleaseCheckKind.reconciliation:
      return Icons.balance_rounded;
    case FinancialReportManagementMeasureReleaseCheckKind.exportEvidence:
      return Icons.ios_share_rounded;
  }
}
