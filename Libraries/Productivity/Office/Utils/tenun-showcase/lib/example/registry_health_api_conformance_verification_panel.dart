import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_conformance_verification.dart';

class RegistryHealthApiConformanceVerificationPanel extends StatelessWidget {
  const RegistryHealthApiConformanceVerificationPanel({
    super.key,
    required this.report,
    this.verificationLimit = 6,
    this.showCopyActions = true,
  });

  final RegistryHealthApiConformanceVerificationReport report;
  final int verificationLimit;
  final bool showCopyActions;

  @override
  Widget build(BuildContext context) {
    if (report.isClear) {
      return const Text('No API conformance verification.');
    }

    final visibleItems = report.visibleItems(limit: verificationLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Conformance Verification',
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
            _ConformanceVerificationMetricChip(
              label: 'Verifications',
              value: report.verificationCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceVerificationMetricChip(
              label: 'Shared',
              value: report.sharedVerificationCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceVerificationMetricChip(
              label: 'Gate Links',
              value: report.gateCoverageCount.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            _ConformanceVerificationMetricChip(
              label: 'Review',
              value: report.reviewVerificationCount.toString(),
              color: report.reviewVerificationCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
            _ConformanceVerificationMetricChip(
              label: 'Blocked',
              value: report.blockedVerificationCount.toString(),
              color: report.blockedVerificationCount == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in visibleItems)
          _ConformanceVerificationRow(item: item),
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
      const SnackBar(content: Text('API conformance verification JSON copied')),
    );
  }

  void _copyMatrix(BuildContext context) {
    final text = registryHealthApiConformanceVerificationText(
      report,
      verificationLimit: verificationLimit,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API conformance verification copied')),
    );
  }
}

class _ConformanceVerificationMetricChip extends StatelessWidget {
  const _ConformanceVerificationMetricChip({
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

class _ConformanceVerificationRow extends StatelessWidget {
  const _ConformanceVerificationRow({required this.item});

  final RegistryHealthApiConformanceVerificationItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = _conformanceVerificationStatusColor(item.status);

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _conformanceVerificationStatusColor(
  RegistryHealthApiConformanceGateStatus status,
) {
  switch (status) {
    case RegistryHealthApiConformanceGateStatus.ready:
      return Colors.green.shade700;
    case RegistryHealthApiConformanceGateStatus.review:
      return Colors.orange.shade800;
    case RegistryHealthApiConformanceGateStatus.blocked:
      return Colors.red.shade700;
  }
}
