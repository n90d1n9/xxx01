import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollRunClosePanel extends StatelessWidget {
  final PayrollRunClosePlan plan;
  final ValueChanged<String> onCompleteStep;
  final ValueChanged<String> onReopenStep;

  const PayrollRunClosePanel({
    super.key,
    required this.plan,
    required this.onCompleteStep,
    required this.onReopenStep,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.fact_check_outlined,
      title: 'Run close workflow',
      subtitle: '${plan.completedCount}/${plan.steps.length} steps complete',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: plan.progressRatio,
                color:
                    plan.isClosed
                        ? const Color(0xFF15803D)
                        : HrisColors.primary,
                label: '${(plan.progressRatio * 100).round()}% close progress',
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.flag_circle_outlined,
                    color: HrisColors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        for (final step in plan.steps)
          _CloseStepTile(
            step: step,
            onComplete: onCompleteStep,
            onReopen: onReopenStep,
          ),
      ],
    );
  }
}

class _CloseStepTile extends StatelessWidget {
  final PayrollRunCloseStep step;
  final ValueChanged<String> onComplete;
  final ValueChanged<String> onReopen;

  const _CloseStepTile({
    required this.step,
    required this.onComplete,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(step.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_statusIcon(step.status), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      step.owner,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: step.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.action,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (step.canComplete || (step.isComplete && step.canReopen)) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (step.canComplete)
                  FilledButton.tonalIcon(
                    onPressed: () => onComplete(step.id),
                    icon: const Icon(Icons.task_alt_outlined),
                    label: Text(_completeLabel(step.id)),
                  ),
                if (step.isComplete && step.canReopen)
                  OutlinedButton.icon(
                    onPressed: () => onReopen(step.id),
                    icon: const Icon(Icons.undo_outlined),
                    label: const Text('Reopen'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _completeLabel(String stepId) {
  return switch (stepId) {
    'review-reconciliation' => 'Mark reviewed',
    'lock-payroll' => 'Lock run',
    'disburse-payments' => 'Mark paid',
    'publish-payslips' => 'Publish',
    'remit-liabilities' => 'Remit',
    'post-journal' => 'Post',
    'archive-run' => 'Archive',
    'review-controls' => 'Sign off',
    'close-period' => 'Close period',
    _ => 'Complete',
  };
}

Color _statusColor(PayrollRunCloseStepStatus status) {
  return switch (status) {
    PayrollRunCloseStepStatus.blocked => const Color(0xFFB91C1C),
    PayrollRunCloseStepStatus.ready => const Color(0xFF2563EB),
    PayrollRunCloseStepStatus.complete => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollRunCloseStepStatus status) {
  return switch (status) {
    PayrollRunCloseStepStatus.blocked => Icons.block_outlined,
    PayrollRunCloseStepStatus.ready => Icons.playlist_add_check_outlined,
    PayrollRunCloseStepStatus.complete => Icons.verified_outlined,
  };
}
