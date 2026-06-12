import 'package:flutter/material.dart';

import '../models/dashboard_workspace_risk_signal.dart';
import 'dashboard_risk_severity_summary.dart' show dashboardRiskSeverityColor;

class DashboardWorkspaceRiskBadge extends StatelessWidget {
  final DashboardWorkspaceRiskSignal signal;
  final bool compact;

  const DashboardWorkspaceRiskBadge({
    super.key,
    required this.signal,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = dashboardRiskSeverityColor(signal.severity);

    return Tooltip(
      message:
          '${signal.detailLabel}, ${signal.timeSensitiveRisks} time-sensitive. '
          '${signal.leadingSignal}.',
      child: Container(
        constraints: BoxConstraints(maxWidth: compact ? 118 : 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 15, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                compact ? signal.compactLabel : signal.detailLabel,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
