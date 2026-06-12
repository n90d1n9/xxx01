import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollApprovalQueuePanel extends StatelessWidget {
  final List<PayrollAdjustmentRequest> adjustments;
  final List<PayrollExceptionItem> exceptions;
  final ValueChanged<String> onApproveAdjustment;
  final ValueChanged<String> onRejectAdjustment;
  final ValueChanged<String> onResolveException;
  final ValueChanged<String> onReopenException;

  const PayrollApprovalQueuePanel({
    super.key,
    required this.adjustments,
    required this.exceptions,
    required this.onApproveAdjustment,
    required this.onRejectAdjustment,
    required this.onResolveException,
    required this.onReopenException,
  });

  @override
  Widget build(BuildContext context) {
    final pendingAdjustments =
        adjustments.where((adjustment) => adjustment.isPending).length;
    final openExceptions =
        exceptions.where((exception) => exception.isOpen).length;

    return HrisSectionPanel(
      icon: Icons.rule_folder_outlined,
      title: 'Approvals and exceptions',
      subtitle: '$pendingAdjustments adjustments, $openExceptions exceptions',
      children: [
        for (final adjustment in adjustments)
          _AdjustmentTile(
            adjustment: adjustment,
            onApprove: onApproveAdjustment,
            onReject: onRejectAdjustment,
          ),
        for (final exception in exceptions)
          _ExceptionTile(
            exception: exception,
            onResolve: onResolveException,
            onReopen: onReopenException,
          ),
      ],
    );
  }
}

class _AdjustmentTile extends StatelessWidget {
  final PayrollAdjustmentRequest adjustment;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;

  const _AdjustmentTile({
    required this.adjustment,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final color = _adjustmentStatusColor(adjustment.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adjustment.employeeName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${adjustment.id} - ${adjustment.type.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: adjustment.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MetaLabel(
                icon: Icons.payments_outlined,
                label: payrollCurrencyFormat.format(adjustment.amount),
              ),
              _MetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(adjustment.effectiveDate),
              ),
              _MetaLabel(
                icon: Icons.business_center_outlined,
                label: adjustment.costCenter,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            adjustment.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (adjustment.isPending) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => onApprove(adjustment.id),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onReject(adjustment.id),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Reject'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExceptionTile extends StatelessWidget {
  final PayrollExceptionItem exception;
  final ValueChanged<String> onResolve;
  final ValueChanged<String> onReopen;

  const _ExceptionTile({
    required this.exception,
    required this.onResolve,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final color = _exceptionColor(exception);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exception.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${exception.employeeName} - ${exception.owner}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label:
                    exception.isOpen
                        ? exception.severity.label
                        : exception.status.label,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _MetaLabel(
                icon: Icons.event_available_outlined,
                label: DateFormat('MMM d').format(exception.dueDate),
              ),
              _MetaLabel(
                icon: Icons.assignment_outlined,
                label: exception.status.label,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exception.action,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child:
                exception.isOpen
                    ? FilledButton.tonalIcon(
                      onPressed: () => onResolve(exception.id),
                      icon: const Icon(Icons.task_alt_outlined),
                      label: const Text('Resolve'),
                    )
                    : OutlinedButton.icon(
                      onPressed: () => onReopen(exception.id),
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    ),
          ),
        ],
      ),
    );
  }
}

class _MetaLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _adjustmentStatusColor(PayrollAdjustmentStatus status) {
  return switch (status) {
    PayrollAdjustmentStatus.submitted => const Color(0xFF2563EB),
    PayrollAdjustmentStatus.approved => const Color(0xFF15803D),
    PayrollAdjustmentStatus.rejected => const Color(0xFFB91C1C),
  };
}

Color _exceptionColor(PayrollExceptionItem exception) {
  if (exception.status == PayrollExceptionStatus.resolved) {
    return const Color(0xFF15803D);
  }

  return switch (exception.severity) {
    PayrollExceptionSeverity.critical => const Color(0xFFB91C1C),
    PayrollExceptionSeverity.warning => const Color(0xFFB45309),
    PayrollExceptionSeverity.info => const Color(0xFF2563EB),
  };
}
