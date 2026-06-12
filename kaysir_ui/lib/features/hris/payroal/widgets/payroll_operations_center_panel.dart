import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollOperationsCenterPanel extends StatelessWidget {
  final PayrollOperationsCenterSummary summary;

  const PayrollOperationsCenterPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currentStage = summary.currentStage;
    final statusColor =
        currentStage == null
            ? _statusColor(PayrollOperationsStageStatus.complete)
            : _statusColor(currentStage.status);

    return HrisSectionPanel(
      icon: Icons.route_outlined,
      title: 'Payroll operations center',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final overview = _OperationsOverview(
                summary: summary,
                statusColor: statusColor,
              );
              final action = _OperationsAction(
                stage: currentStage,
                nextAction: summary.nextAction,
                statusColor: statusColor,
              );

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
        _OperationsStageGrid(stages: summary.stages),
      ],
    );
  }
}

class _OperationsOverview extends StatelessWidget {
  final PayrollOperationsCenterSummary summary;
  final Color statusColor;

  const _OperationsOverview({required this.summary, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${summary.completeCount}/${summary.stages.length} stages complete',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        HrisProgressBar(
          value: summary.progress,
          color: statusColor,
          label: '${(summary.progress * 100).round()}% operational progress',
        ),
        const SizedBox(height: 12),
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Blocked',
              value: '${summary.blockedCount}',
            ),
            HrisMetricStripItem(label: 'Ready', value: '${summary.readyCount}'),
            HrisMetricStripItem(
              label: 'At risk',
              value: payrollCurrencyFormat.format(summary.amountAtRisk),
            ),
          ],
        ),
      ],
    );
  }
}

class _OperationsAction extends StatelessWidget {
  final PayrollOperationsStage? stage;
  final String nextAction;
  final Color statusColor;

  const _OperationsAction({
    required this.stage,
    required this.nextAction,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final stage = this.stage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            stage == null ? Icons.verified_outlined : _stageIcon(stage.id),
            color: statusColor,
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
                    stage?.title ?? 'Complete',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  HrisStatusPill(
                    label:
                        stage?.status.label ??
                        PayrollOperationsStageStatus.complete.label,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                nextAction,
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

class _OperationsStageGrid extends StatelessWidget {
  final List<PayrollOperationsStage> stages;

  const _OperationsStageGrid({required this.stages});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 720 ? 1 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 142,
          ),
          itemCount: stages.length,
          itemBuilder: (context, index) {
            return _OperationsStageCard(stage: stages[index]);
          },
        );
      },
    );
  }
}

class _OperationsStageCard extends StatelessWidget {
  final PayrollOperationsStage stage;

  const _OperationsStageCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(stage.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_stageIcon(stage.id), color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      stage.owner,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: stage.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: stage.progress,
            color: color,
            label: '${(stage.progress * 100).round()}% complete',
          ),
          const SizedBox(height: 8),
          Text(
            stage.detail,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(PayrollOperationsStageStatus status) {
  return switch (status) {
    PayrollOperationsStageStatus.blocked => const Color(0xFFB91C1C),
    PayrollOperationsStageStatus.ready => const Color(0xFF2563EB),
    PayrollOperationsStageStatus.active => const Color(0xFF7C3AED),
    PayrollOperationsStageStatus.complete => const Color(0xFF15803D),
  };
}

IconData _stageIcon(String id) {
  return switch (id) {
    'run-plan' => Icons.assignment_turned_in_outlined,
    'readiness' => Icons.manage_search_outlined,
    'approvals' => Icons.verified_user_outlined,
    'funding' => Icons.account_balance_outlined,
    'payments' => Icons.payments_outlined,
    'statements' => Icons.description_outlined,
    'statutory' => Icons.policy_outlined,
    'finance-posting' => Icons.receipt_long_outlined,
    'close' => Icons.fact_check_outlined,
    _ => Icons.route_outlined,
  };
}
