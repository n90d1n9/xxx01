import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_action_button.dart';
import '../../../../widgets/ui/app_content_panel.dart';
import '../../../../widgets/ui/app_metric_grid.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/financial_report_management_measure.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportManagementMeasureSummary extends StatelessWidget {
  const FinancialReportManagementMeasureSummary({
    required this.reconciliations,
    super.key,
  });

  final List<FinancialReportManagementMeasureReconciliation> reconciliations;

  @override
  Widget build(BuildContext context) {
    final approvedCount =
        reconciliations
            .where((reconciliation) => reconciliation.isApproved)
            .length;
    final openVarianceCount =
        reconciliations
            .where((reconciliation) => !reconciliation.isBalanced)
            .length;

    return AppMetricGrid(
      maxColumns: 3,
      metrics: [
        AppMetricGridItem(
          title: 'Management Measures',
          value: reconciliations.length.toString(),
          helper: 'UKTM register',
          icon: Icons.rule_rounded,
          accentColor: Colors.indigo,
        ),
        AppMetricGridItem(
          title: 'Approved',
          value: '$approvedCount/${reconciliations.length}',
          helper: 'Release approval',
          icon: Icons.verified_user_outlined,
          accentColor: Colors.teal,
        ),
        AppMetricGridItem(
          title: 'Open Variances',
          value: openVarianceCount.toString(),
          helper: 'Reconciliation variance',
          icon: Icons.balance_rounded,
          accentColor: openVarianceCount == 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}

class FinancialReportManagementMeasureCard extends StatelessWidget {
  const FinancialReportManagementMeasureCard({
    required this.reconciliation,
    required this.onEdit,
    required this.onRemove,
    required this.onApprove,
    required this.onMarkInReview,
    required this.onReturn,
    super.key,
  });

  final FinancialReportManagementMeasureReconciliation reconciliation;
  final VoidCallback onEdit;
  final VoidCallback? onRemove;
  final VoidCallback onApprove;
  final VoidCallback onMarkInReview;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final measure = reconciliation.measure;
    final colorScheme = Theme.of(context).colorScheme;

    return AppContentPanel(
      title: measure.label,
      subtitle: 'Owner ${measure.owner}',
      leadingIcon: Icons.speed_rounded,
      trailing: AppStatusPill(
        label: measure.approvalStatus.label,
        color: _statusColor(colorScheme, measure.approvalStatus),
        icon: _statusIcon(measure.approvalStatus),
        maxWidth: 140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MeasureFact(
                label: 'Measure',
                value: _amount(reconciliation.measureAmount),
              ),
              _MeasureFact(
                label: 'Closest SAK subtotal',
                value: _amount(reconciliation.subtotalAmount),
              ),
              _MeasureFact(
                label: 'Adjustments',
                value: _amount(reconciliation.adjustmentTotal),
              ),
              _MeasureFact(
                label: 'Variance',
                value: _amount(reconciliation.variance),
                alert: !reconciliation.isBalanced,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 14),
          if (measure.adjustments.isEmpty)
            Text(
              'No separate management adjustments captured.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            _AdjustmentList(adjustments: measure.adjustments),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppActionButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                variant: AppActionButtonVariant.secondary,
                onPressed: onEdit,
                compact: true,
              ),
              AppActionButton(
                label: 'Approve',
                icon: Icons.verified_user_outlined,
                onPressed: measure.approvalStatus.isApproved ? null : onApprove,
                compact: true,
              ),
              AppActionButton(
                label: 'Review',
                icon: Icons.rate_review_outlined,
                variant: AppActionButtonVariant.secondary,
                onPressed:
                    measure.approvalStatus ==
                            FinancialReportManagementMeasureApprovalStatus
                                .inReview
                        ? null
                        : onMarkInReview,
                compact: true,
              ),
              AppActionButton(
                label: 'Return',
                icon: Icons.undo_rounded,
                variant: AppActionButtonVariant.text,
                onPressed:
                    measure.approvalStatus ==
                            FinancialReportManagementMeasureApprovalStatus
                                .returned
                        ? null
                        : onReturn,
                compact: true,
              ),
              AppActionButton(
                label: 'Remove',
                icon: Icons.delete_outline_rounded,
                variant: AppActionButtonVariant.destructive,
                onPressed: onRemove,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdjustmentList extends StatelessWidget {
  const _AdjustmentList({required this.adjustments});

  final List<FinancialReportManagementMeasureAdjustment> adjustments;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final adjustment in adjustments)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adjustment.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        adjustment.sourceReference,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _amount(adjustment.amount),
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MeasureFact extends StatelessWidget {
  const _MeasureFact({
    required this.label,
    required this.value,
    this.alert = false,
  });

  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FinancialReportTintedSurface(
      color: alert ? colorScheme.error : colorScheme.onSurfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor:
          alert
              ? colorScheme.errorContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest,
      borderAlpha: alert ? 0.2 : 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color:
                  alert
                      ? colorScheme.onErrorContainer
                      : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  ColorScheme colorScheme,
  FinancialReportManagementMeasureApprovalStatus status,
) {
  switch (status) {
    case FinancialReportManagementMeasureApprovalStatus.approved:
      return Colors.green;
    case FinancialReportManagementMeasureApprovalStatus.inReview:
      return colorScheme.primary;
    case FinancialReportManagementMeasureApprovalStatus.returned:
      return colorScheme.error;
    case FinancialReportManagementMeasureApprovalStatus.draft:
      return Colors.blueGrey;
  }
}

IconData _statusIcon(FinancialReportManagementMeasureApprovalStatus status) {
  switch (status) {
    case FinancialReportManagementMeasureApprovalStatus.approved:
      return Icons.verified_user_outlined;
    case FinancialReportManagementMeasureApprovalStatus.inReview:
      return Icons.rate_review_outlined;
    case FinancialReportManagementMeasureApprovalStatus.returned:
      return Icons.undo_rounded;
    case FinancialReportManagementMeasureApprovalStatus.draft:
      return Icons.edit_note_outlined;
  }
}

String _amount(double value) {
  final rounded = value.round();
  if ((value - rounded).abs() < 0.01) {
    return rounded.toString();
  }
  return value.toStringAsFixed(2);
}
