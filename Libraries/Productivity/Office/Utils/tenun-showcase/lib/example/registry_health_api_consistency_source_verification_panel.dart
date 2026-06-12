import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_consistency_source_release_gates.dart';
import 'registry_health_api_consistency_source_verification.dart';

class RegistryHealthApiConsistencySourceVerificationPanel
    extends StatelessWidget {
  const RegistryHealthApiConsistencySourceVerificationPanel({
    super.key,
    required this.report,
    this.verificationLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConsistencySourceVerificationReport report;
  final int verificationLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API source verification.');
    }

    final visibleItems = report.visibleItems(limit: verificationLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Source Verification',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (showCopyActions)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () => _copyVerificationJson(context),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _copyMatrix(context),
                    icon: const Icon(Icons.fact_check_outlined, size: 16),
                    label: const Text('Copy Matrix'),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SourceVerificationMetricChip(
              label: 'Verifications',
              value: report.verificationCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceVerificationMetricChip(
              label: 'Shared',
              value: report.sharedVerificationCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceVerificationMetricChip(
              label: 'Gate Links',
              value: report.gateCoverageCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _SourceVerificationMetricChip(
              label: 'Review',
              value: report.reviewVerificationCount.toString(),
              color: report.reviewVerificationCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _SourceVerificationMetricChip(
              label: 'Impact',
              value: '+${report.scoreImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems) _SourceVerificationRow(item: item),
        if (report.verificationCount > visibleItems.length)
          Text(
            '+${report.verificationCount - visibleItems.length} more verifications',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }

  void _copyVerificationJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(
      report.toJson(verificationLimit: verificationLimit),
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source verification JSON copied')),
    );
  }

  void _copyMatrix(BuildContext context) {
    final text = registryHealthApiConsistencySourceVerificationText(
      report,
      verificationLimit: verificationLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API source verification matrix copied')),
    );
  }
}

class _SourceVerificationMetricChip extends StatelessWidget {
  const _SourceVerificationMetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(Icons.fact_check_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SourceVerificationRow extends StatelessWidget {
  const _SourceVerificationRow({required this.item});

  final RegistryHealthApiConsistencySourceVerificationItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _sourceVerificationStatusColor(item.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, size: 18, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.kindLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.coverageLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.checkLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  item.gateCoverageLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  item.milestoneCoverageLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _sourceVerificationStatusColor(
  RegistryHealthApiConsistencySourceReleaseGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConsistencySourceReleaseGateStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencySourceReleaseGateStatus.review:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencySourceReleaseGateStatus.blocked:
      return Colors.red.shade700;
  }
}
