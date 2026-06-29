import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollEvidenceCenterPanel extends StatelessWidget {
  final PayrollEvidenceCenterSummary summary;

  const PayrollEvidenceCenterPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.snippet_folder_outlined,
      title: 'Evidence center',
      subtitle: summary.periodLabel,
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisProgressBar(
                value: summary.captureRate,
                color: color,
                label:
                    '${(summary.captureRate * 100).round()}% evidence captured',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.status.label, color: color),
                  _MetricChip(
                    icon: Icons.verified_outlined,
                    label: '${summary.capturedCount} captured',
                  ),
                  _MetricChip(
                    icon: Icons.playlist_add_check_outlined,
                    label: '${summary.readyCount} ready',
                  ),
                  _MetricChip(
                    icon: Icons.warning_amber_outlined,
                    label: '${summary.blockedCount} blocked',
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
              for (var index = 0; index < summary.items.length; index++) ...[
                _EvidenceRow(item: summary.items[index]),
                if (index < summary.items.length - 1)
                  const Divider(height: 20, color: HrisColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final PayrollEvidenceItem item;

  const _EvidenceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_categoryIcon(item.category), color: color, size: 19),
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
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: item.status.label, color: color),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.owner,
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
                    icon: Icons.category_outlined,
                    label: item.category.label,
                  ),
                  _MetricChip(
                    icon: Icons.confirmation_number_outlined,
                    label: item.reference,
                  ),
                  if (item.blockers.isNotEmpty)
                    _MetricChip(
                      icon: Icons.report_problem_outlined,
                      label: item.blockers.first,
                    ),
                ],
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

Color _statusColor(PayrollEvidenceStatus status) {
  return switch (status) {
    PayrollEvidenceStatus.blocked => const Color(0xFFB91C1C),
    PayrollEvidenceStatus.ready => const Color(0xFF2563EB),
    PayrollEvidenceStatus.captured => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollEvidenceStatus status) {
  return switch (status) {
    PayrollEvidenceStatus.blocked => Icons.lock_outlined,
    PayrollEvidenceStatus.ready => Icons.snippet_folder_outlined,
    PayrollEvidenceStatus.captured => Icons.verified_outlined,
  };
}

IconData _categoryIcon(PayrollEvidenceCategory category) {
  return switch (category) {
    PayrollEvidenceCategory.setup => Icons.settings_suggest_outlined,
    PayrollEvidenceCategory.approval => Icons.approval_outlined,
    PayrollEvidenceCategory.finance => Icons.account_balance_outlined,
    PayrollEvidenceCategory.payment => Icons.payments_outlined,
    PayrollEvidenceCategory.archive => Icons.inventory_2_outlined,
  };
}
