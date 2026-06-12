import 'package:flutter/material.dart';

import 'financial_report_tinted_surface_components.dart';

class FinancialReportActionCardTitleRow extends StatelessWidget {
  const FinancialReportActionCardTitleRow({
    required this.icon,
    required this.color,
    required this.title,
    this.clearTooltip,
    this.onClear,
    this.showClearAction = false,
    this.maxTitleLines = 2,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? clearTooltip;
  final VoidCallback? onClear;
  final bool showClearAction;
  final int maxTitleLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: maxTitleLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showClearAction)
          IconButton(
            tooltip: clearTooltip ?? 'Clear',
            visualDensity: VisualDensity.compact,
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
      ],
    );
  }
}

class FinancialReportActionCardResolutionLine extends StatelessWidget {
  const FinancialReportActionCardResolutionLine({
    required this.statusLabel,
    required this.actorName,
    required this.note,
    this.actorContext = '',
    this.maxLines = 2,
    super.key,
  });

  final String statusLabel;
  final String actorName;
  final String actorContext;
  final String note;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FinancialReportTintedSurface(
      color: colorScheme.onSurfaceVariant,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      ),
      borderAlpha: 0.14,
      child: Text(
        '$statusLabel by $actorName$actorContext | $note',
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
