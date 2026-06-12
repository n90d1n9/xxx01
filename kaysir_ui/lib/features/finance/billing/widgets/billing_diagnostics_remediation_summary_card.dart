import 'package:flutter/material.dart';

class BillingDiagnosticsRemediationSummaryCard extends StatelessWidget {
  final String summaryLabel;
  final int actionCount;
  final int blockerActionCount;
  final int warningActionCount;

  const BillingDiagnosticsRemediationSummaryCard({
    super.key,
    required this.summaryLabel,
    required this.actionCount,
    required this.blockerActionCount,
    required this.warningActionCount,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _RemediationSummaryVisuals.fromCounts(
      blockerActionCount: blockerActionCount,
      warningActionCount: warningActionCount,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(visuals.icon, color: visuals.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryLabel,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RemediationSummaryChip(
                      label: 'Actions',
                      value: '$actionCount',
                      color: const Color(0xFF2563EB),
                    ),
                    _RemediationSummaryChip(
                      label: 'Blockers',
                      value: '$blockerActionCount',
                      color: const Color(0xFFDC2626),
                    ),
                    _RemediationSummaryChip(
                      label: 'Hardening',
                      value: '$warningActionCount',
                      color: const Color(0xFFD97706),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemediationSummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RemediationSummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemediationSummaryVisuals {
  final IconData icon;
  final Color color;

  const _RemediationSummaryVisuals({required this.icon, required this.color});

  factory _RemediationSummaryVisuals.fromCounts({
    required int blockerActionCount,
    required int warningActionCount,
  }) {
    if (blockerActionCount > 0) {
      return const _RemediationSummaryVisuals(
        icon: Icons.report_outlined,
        color: Color(0xFFDC2626),
      );
    }

    if (warningActionCount > 0) {
      return const _RemediationSummaryVisuals(
        icon: Icons.rule_folder_outlined,
        color: Color(0xFFD97706),
      );
    }

    return const _RemediationSummaryVisuals(
      icon: Icons.verified_outlined,
      color: Color(0xFF047857),
    );
  }
}
