import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollArchivePackagePanel extends StatelessWidget {
  final PayrollArchivePackageSummary summary;
  final VoidCallback onArchivePackage;
  final VoidCallback onReopenArchive;

  const PayrollArchivePackagePanel({
    super.key,
    required this.summary,
    required this.onArchivePackage,
    required this.onReopenArchive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _summaryStatusColor(summary.status);

    return HrisSectionPanel(
      icon: Icons.inventory_2_outlined,
      title: 'Audit archive package',
      subtitle:
          '${summary.packageId} - retain until ${DateFormat('MMM d, yyyy').format(summary.retentionUntil)}',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          color: statusColor,
                        ),
                        _MetricChip(
                          icon: Icons.task_alt_outlined,
                          label:
                              '${summary.capturedCount}/${summary.evidenceItems.length} captured',
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
                  ),
                  const SizedBox(width: 8),
                  if (summary.status == PayrollArchivePackageStatus.archived)
                    OutlinedButton.icon(
                      onPressed: onReopenArchive,
                      icon: const Icon(Icons.undo_outlined),
                      label: const Text('Reopen'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: summary.canArchive ? onArchivePackage : null,
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Archive package'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _summaryIcon(summary.status),
                    color: statusColor,
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
        for (final item in summary.evidenceItems)
          _ArchiveEvidenceTile(item: item),
      ],
    );
  }
}

class _ArchiveEvidenceTile extends StatelessWidget {
  final PayrollArchiveEvidenceItem item;

  const _ArchiveEvidenceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _evidenceColor(item);

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
            child: Icon(_evidenceIcon(item), color: color, size: 20),
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
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            item.owner,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: item.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon: Icons.confirmation_number_outlined,
                      label: item.referenceCode,
                    ),
                    _MetricChip(
                      icon: Icons.description_outlined,
                      label: item.evidenceLabel,
                    ),
                  ],
                ),
                if (item.hasBlockers) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.blockers.first,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w800,
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

Color _summaryStatusColor(PayrollArchivePackageStatus status) {
  return switch (status) {
    PayrollArchivePackageStatus.blocked => const Color(0xFFB91C1C),
    PayrollArchivePackageStatus.ready => const Color(0xFF2563EB),
    PayrollArchivePackageStatus.archived => const Color(0xFF15803D),
  };
}

IconData _summaryIcon(PayrollArchivePackageStatus status) {
  return switch (status) {
    PayrollArchivePackageStatus.blocked => Icons.lock_outlined,
    PayrollArchivePackageStatus.ready => Icons.inventory_2_outlined,
    PayrollArchivePackageStatus.archived => Icons.verified_outlined,
  };
}

Color _evidenceColor(PayrollArchiveEvidenceItem item) {
  if (item.isCaptured) return const Color(0xFF15803D);
  if (item.hasBlockers) return const Color(0xFFB91C1C);
  return const Color(0xFF2563EB);
}

IconData _evidenceIcon(PayrollArchiveEvidenceItem item) {
  if (item.isCaptured) return Icons.verified_outlined;
  if (item.hasBlockers) return Icons.warning_amber_outlined;
  return Icons.description_outlined;
}
