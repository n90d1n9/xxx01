import 'package:flutter/material.dart';

import 'billing_domain_module_readiness_frame.dart';

class BillingDiagnosticsDomainSignalCard extends StatelessWidget {
  final String title;
  final String summary;
  final IconData icon;
  final Color accentColor;
  final List<String> signals;

  const BillingDiagnosticsDomainSignalCard({
    super.key,
    required this.title,
    required this.summary,
    required this.icon,
    required this.accentColor,
    this.signals = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BillingReadinessFrame(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (signals.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final signal in signals)
                        _BillingDiagnosticsSignalPill(
                          label: signal,
                          color: accentColor,
                        ),
                    ],
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

class _BillingDiagnosticsSignalPill extends StatelessWidget {
  final String label;
  final Color color;

  const _BillingDiagnosticsSignalPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
