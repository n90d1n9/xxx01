import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollApprovalWorkflowPanel extends StatelessWidget {
  final PayrollApprovalWorkflowSummary summary;
  final ValueChanged<String> onApproveStage;
  final ValueChanged<String> onReopenStage;

  const PayrollApprovalWorkflowPanel({
    super.key,
    required this.summary,
    required this.onApproveStage,
    required this.onReopenStage,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.approval_outlined,
      title: 'Approval workflow',
      subtitle: '${summary.approvedCount}/${summary.stages.length} approved',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisMetricStrip(
                items: [
                  HrisMetricStripItem(
                    label: 'Approved',
                    value: '${summary.approvedCount}',
                  ),
                  HrisMetricStripItem(
                    label: 'Ready',
                    value: '${summary.readyCount}',
                  ),
                  HrisMetricStripItem(
                    label: 'Blocked',
                    value: '${summary.blockedCount}',
                  ),
                  HrisMetricStripItem(
                    label: 'Release',
                    value: summary.canReleasePayments ? 'Yes' : 'No',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    summary.isFullyApproved
                        ? Icons.verified_outlined
                        : Icons.flag_circle_outlined,
                    color:
                        summary.isFullyApproved
                            ? const Color(0xFF15803D)
                            : HrisColors.primary,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.nextAction,
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
        for (final stage in summary.stages)
          _ApprovalStageTile(
            stage: stage,
            onApproveStage: onApproveStage,
            onReopenStage: onReopenStage,
          ),
      ],
    );
  }
}

class _ApprovalStageTile extends StatelessWidget {
  final PayrollApprovalStage stage;
  final ValueChanged<String> onApproveStage;
  final ValueChanged<String> onReopenStage;

  const _ApprovalStageTile({
    required this.stage,
    required this.onApproveStage,
    required this.onReopenStage,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(stage.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(stage.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            stage.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: stage.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stage.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stage.nextAction,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                if (stage.canApprove || stage.canReopen) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child:
                        stage.canReopen
                            ? OutlinedButton.icon(
                              onPressed: () => onReopenStage(stage.id),
                              icon: const Icon(Icons.undo_outlined, size: 18),
                              label: const Text('Reopen'),
                            )
                            : FilledButton.tonalIcon(
                              onPressed: () => onApproveStage(stage.id),
                              icon: const Icon(Icons.verified_user_outlined),
                              label: const Text('Approve'),
                            ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(PayrollApprovalStageStatus status) {
  return switch (status) {
    PayrollApprovalStageStatus.blocked => const Color(0xFFB91C1C),
    PayrollApprovalStageStatus.ready => const Color(0xFF2563EB),
    PayrollApprovalStageStatus.approved => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollApprovalStageStatus status) {
  return switch (status) {
    PayrollApprovalStageStatus.blocked => Icons.lock_outlined,
    PayrollApprovalStageStatus.ready => Icons.pending_actions_outlined,
    PayrollApprovalStageStatus.approved => Icons.verified_outlined,
  };
}
