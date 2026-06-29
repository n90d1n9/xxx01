import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollAnalyticsPanel extends StatelessWidget {
  final PayrollAnalyticsSummary summary;

  const PayrollAnalyticsPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.insights_outlined,
      title: 'Payroll analytics',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final overview = _AnalyticsOverview(summary: summary);
              final action = _AnalyticsAction(summary: summary);
              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [overview, const SizedBox(height: 14), action],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: overview),
                  const SizedBox(width: 18),
                  Expanded(child: action),
                ],
              );
            },
          ),
        ),
        HrisSummaryGrid(metrics: summary.metrics.map(_metricCard).toList()),
        _StageTimeline(stages: summary.stages),
      ],
    );
  }
}

class _AnalyticsOverview extends StatelessWidget {
  final PayrollAnalyticsSummary summary;

  const _AnalyticsOverview({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${summary.completeStageCount}/${summary.stages.length} stages complete',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        HrisProgressBar(
          value: summary.closeProgress,
          color: _statusColor(_closeStatus(summary)),
          label:
              '${(summary.closeProgress * 100).round()}% payroll close progress',
        ),
        const SizedBox(height: 12),
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Readiness',
              value: '${summary.readinessScore}%',
            ),
            HrisMetricStripItem(
              label: 'Variance',
              value: '${summary.varianceRiskCount}',
            ),
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedStageCount}',
            ),
          ],
        ),
      ],
    );
  }
}

class _AnalyticsAction extends StatelessWidget {
  final PayrollAnalyticsSummary summary;

  const _AnalyticsAction({required this.summary});

  @override
  Widget build(BuildContext context) {
    final nextStage = summary.stages.firstWhere(
      (stage) => stage.status != PayrollAnalyticsStatus.complete,
      orElse:
          () => PayrollAnalyticsStage(
            id: 'closed',
            title: 'Closed',
            owner: 'Payroll Controller',
            detail: summary.nextAction,
            progress: 1,
            status: PayrollAnalyticsStatus.complete,
          ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _statusColor(nextStage.status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _stageIcon(nextStage.id),
            color: _statusColor(nextStage.status),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    nextStage.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  HrisStatusPill(
                    label: nextStage.status.label,
                    color: _statusColor(nextStage.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                summary.nextAction,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageTimeline extends StatelessWidget {
  final List<PayrollAnalyticsStage> stages;

  const _StageTimeline({required this.stages});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        children: [
          for (var index = 0; index < stages.length; index++) ...[
            _StageRow(stage: stages[index]),
            if (index < stages.length - 1)
              const Divider(height: 20, color: HrisColors.border),
          ],
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final PayrollAnalyticsStage stage;

  const _StageRow({required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(stage.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_stageIcon(stage.id), color: color, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    stage.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  HrisStatusPill(label: stage.status.label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                stage.owner,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 8),
              HrisProgressBar(
                value: stage.progress,
                color: color,
                label: stage.detail,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

HrisSummaryMetric _metricCard(PayrollAnalyticsMetric metric) {
  return HrisSummaryMetric(
    title: metric.title,
    value: metric.value,
    detail: metric.detail,
    icon: _metricIcon(metric.id),
    color: _statusColor(metric.status),
  );
}

PayrollAnalyticsStatus _closeStatus(PayrollAnalyticsSummary summary) {
  if (summary.completeStageCount == summary.stages.length) {
    return PayrollAnalyticsStatus.complete;
  }
  if (summary.blockedStageCount == 0) return PayrollAnalyticsStatus.ready;
  if (summary.readinessScore >= 70) return PayrollAnalyticsStatus.watch;
  return PayrollAnalyticsStatus.blocked;
}

Color _statusColor(PayrollAnalyticsStatus status) {
  return switch (status) {
    PayrollAnalyticsStatus.blocked => const Color(0xFFB91C1C),
    PayrollAnalyticsStatus.watch => const Color(0xFFB45309),
    PayrollAnalyticsStatus.ready => const Color(0xFF2563EB),
    PayrollAnalyticsStatus.complete => const Color(0xFF15803D),
  };
}

IconData _metricIcon(String id) {
  return switch (id) {
    'readiness' => Icons.speed_outlined,
    'close' => Icons.fact_check_outlined,
    'variance' => Icons.stacked_line_chart_outlined,
    'release' => Icons.hub_outlined,
    _ => Icons.insights_outlined,
  };
}

IconData _stageIcon(String id) {
  return switch (id) {
    'reconciliation' => Icons.balance_outlined,
    'payments' => Icons.payments_outlined,
    'payslips' => Icons.receipt_long_outlined,
    'liabilities' => Icons.account_balance_outlined,
    'journal' => Icons.library_books_outlined,
    'archive' => Icons.inventory_2_outlined,
    'controls' => Icons.verified_user_outlined,
    _ => Icons.task_alt_outlined,
  };
}
