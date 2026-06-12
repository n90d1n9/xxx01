import 'package:flutter/material.dart';

class BillingDiagnosticsReleaseSummaryCard extends StatelessWidget {
  final String summaryLabel;
  final bool hasBlockers;

  const BillingDiagnosticsReleaseSummaryCard({
    super.key,
    required this.summaryLabel,
    required this.hasBlockers,
  });

  @override
  Widget build(BuildContext context) {
    final icon =
        hasBlockers ? Icons.pending_actions_outlined : Icons.task_alt_outlined;
    final color =
        hasBlockers ? const Color(0xFFD97706) : const Color(0xFF047857);

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
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              summaryLabel,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
