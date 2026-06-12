import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

/// Shows delivery readiness for exported payroll report packages.
class PayrollReportDistributionPanel extends StatelessWidget {
  final PayrollReportDistributionSummary summary;
  final VoidCallback onDeliverReady;
  final ValueChanged<String> onReopenReport;

  const PayrollReportDistributionPanel({
    super.key,
    required this.summary,
    required this.onDeliverReady,
    required this.onReopenReport,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.ios_share_outlined,
      title: 'Report distribution',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.deliveryRate,
                color: color,
                label:
                    '${(summary.deliveryRate * 100).round()}% reports delivered',
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        HrisStatusPill(
                          label: summary.status.label,
                          color: color,
                        ),
                        _MetricChip(
                          icon: Icons.lock_outlined,
                          label: '${summary.blockedCount} blocked',
                        ),
                        _MetricChip(
                          icon: Icons.outbox_outlined,
                          label: '${summary.readyCount} ready',
                        ),
                        _MetricChip(
                          icon: Icons.verified_outlined,
                          label: '${summary.deliveredCount} delivered',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: summary.readyCount > 0 ? onDeliverReady : null,
                    icon: const Icon(Icons.ios_share_outlined),
                    label: const Text('Deliver ready'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_statusIcon(summary.status), color: color, size: 19),
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
        HrisListSurface(
          child: Column(
            children: [
              for (var index = 0; index < summary.lines.length; index++) ...[
                _DistributionRow(
                  line: summary.lines[index],
                  onReopenReport: onReopenReport,
                ),
                if (index < summary.lines.length - 1)
                  const Divider(height: 22, color: HrisColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final PayrollReportDistributionLine line;
  final ValueChanged<String> onReopenReport;

  const _DistributionRow({required this.line, required this.onReopenReport});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(line.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_channelIcon(line.channel), color: color, size: 20),
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
                    child: Text(
                      line.report.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: line.status.label, color: color),
                  if (line.canReopen) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Reopen delivery',
                      icon: const Icon(Icons.undo_outlined),
                      onPressed: () => onReopenReport(line.report.id),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                line.report.id,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.send_outlined,
                    label: line.channel.label,
                  ),
                  _MetricChip(
                    icon: Icons.group_outlined,
                    label: line.recipientLabel,
                  ),
                  _MetricChip(
                    icon: Icons.person_pin_circle_outlined,
                    label: line.report.owner,
                  ),
                  if (line.receipt != null) ...[
                    _MetricChip(
                      icon: Icons.badge_outlined,
                      label: line.receipt!.deliveredBy,
                    ),
                    _MetricChip(
                      icon: Icons.event_available_outlined,
                      label: _dateLabel(line.receipt!.deliveredAt),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                line.nextAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      line.status == PayrollReportDistributionStatus.blocked
                          ? color
                          : HrisColors.ink,
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

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollReportDistributionStatus status) {
  return switch (status) {
    PayrollReportDistributionStatus.blocked => const Color(0xFFB91C1C),
    PayrollReportDistributionStatus.ready => const Color(0xFF2563EB),
    PayrollReportDistributionStatus.delivered => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollReportDistributionStatus status) {
  return switch (status) {
    PayrollReportDistributionStatus.blocked => Icons.lock_outlined,
    PayrollReportDistributionStatus.ready => Icons.outbox_outlined,
    PayrollReportDistributionStatus.delivered => Icons.verified_outlined,
  };
}

IconData _channelIcon(PayrollReportDistributionChannel channel) {
  return switch (channel) {
    PayrollReportDistributionChannel.financeWorkspace =>
      Icons.account_balance_outlined,
    PayrollReportDistributionChannel.secureBankPortal =>
      Icons.security_outlined,
    PayrollReportDistributionChannel.taxPortal => Icons.policy_outlined,
    PayrollReportDistributionChannel.auditVault => Icons.inventory_2_outlined,
  };
}

String _dateLabel(DateTime value) {
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
