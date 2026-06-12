import 'package:flutter/material.dart';

import 'financial_report_panel_components.dart';

typedef FinancialReportAuditTrailItemBuilder<T> =
    Widget Function(BuildContext context, T event);

class FinancialReportAuditTrailPanel<T> extends StatelessWidget {
  const FinancialReportAuditTrailPanel({
    required this.title,
    required this.events,
    required this.itemBuilder,
    required this.isDarkMode,
    this.icon = Icons.manage_history_rounded,
    this.maxVisibleEvents = 5,
    this.itemSpacing = 8,
    this.padding = const EdgeInsets.all(12),
    this.accentColor,
    this.backgroundColor,
    this.borderColor,
    this.emptyMessage,
    this.emptyActionLabel,
    this.emptyActionIcon,
    this.onEmptyAction,
    super.key,
  });

  final String title;
  final List<T> events;
  final FinancialReportAuditTrailItemBuilder<T> itemBuilder;
  final bool isDarkMode;
  final IconData icon;
  final int maxVisibleEvents;
  final double itemSpacing;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? emptyMessage;
  final String? emptyActionLabel;
  final IconData? emptyActionIcon;
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? _defaultAccentColor(isDarkMode);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final visibleLimit = maxVisibleEvents < 0 ? 0 : maxVisibleEvents;
    final visibleEvents = events.take(visibleLimit).toList();
    final olderCount = events.length - visibleEvents.length;

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      muted: true,
      padding: padding,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (visibleEvents.isEmpty) ...[
            Text(
              emptyMessage ?? 'No audit events captured yet.',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
            if (emptyActionLabel != null && onEmptyAction != null) ...[
              SizedBox(height: itemSpacing),
              OutlinedButton.icon(
                onPressed: onEmptyAction,
                icon: Icon(emptyActionIcon ?? Icons.add_task_rounded),
                label: Text(emptyActionLabel!),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ] else
            ...visibleEvents.indexed.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom:
                      entry.$1 == visibleEvents.length - 1 ? 0 : itemSpacing,
                ),
                child: itemBuilder(context, entry.$2),
              ),
            ),
          if (olderCount > 0) ...[
            if (visibleEvents.isNotEmpty) SizedBox(height: itemSpacing),
            Text(
              '+$olderCount older event(s)',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

Color _defaultAccentColor(bool isDarkMode) {
  return isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey;
}
