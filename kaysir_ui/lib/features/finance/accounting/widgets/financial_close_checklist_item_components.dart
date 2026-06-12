import 'package:flutter/material.dart';

import '../models/financial_close_checklist.dart';
import 'financial_close_status_pill.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialCloseChecklistItemGrid extends StatelessWidget {
  const FinancialCloseChecklistItemGrid({
    required this.items,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialCloseChecklistItem> items;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return FinancialCloseChecklistEmptyState(isDarkMode: isDarkMode);
    }

    return FinancialReportResponsiveWrapGrid<FinancialCloseChecklistItem>(
      items: items,
      breakpoints: const [
        FinancialReportResponsiveGridBreakpoint(minWidth: 620, columns: 2),
        FinancialReportResponsiveGridBreakpoint(minWidth: 860, columns: 3),
      ],
      itemBuilder:
          (context, item) => FinancialCloseChecklistItemCard(
            item: item,
            isDarkMode: isDarkMode,
          ),
    );
  }
}

class FinancialCloseChecklistItemCard extends StatelessWidget {
  const FinancialCloseChecklistItemCard({
    required this.item,
    required this.isDarkMode,
    super.key,
  });

  final FinancialCloseChecklistItem item;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final color = financialCloseItemStatusColor(item.status, isDarkMode);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 132,
      padding: const EdgeInsets.all(14),
      fillAlpha: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                financialCloseItemStatusIcon(item.status),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FinancialCloseStatusPill(
                label: item.status.label,
                color: color,
                isDarkMode: isDarkMode,
              ),
              FinancialCloseStatusPill(
                label: item.reference,
                color: isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey,
                isDarkMode: isDarkMode,
              ),
              if (item.amountLabel != null)
                FinancialCloseStatusPill(
                  label: item.amountLabel!,
                  color: mutedColor,
                  isDarkMode: isDarkMode,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialCloseChecklistEmptyState extends StatelessWidget {
  const FinancialCloseChecklistEmptyState({
    required this.isDarkMode,
    super.key,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportPanelEmptyState(
      title: 'No close checklist items are available for this period.',
      icon: Icons.rule_folder_rounded,
      isDarkMode: isDarkMode,
    );
  }
}

Color financialCloseItemStatusColor(
  FinancialCloseItemStatus status,
  bool isDarkMode,
) {
  switch (status) {
    case FinancialCloseItemStatus.ready:
      return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
    case FinancialCloseItemStatus.review:
      return isDarkMode ? const Color(0xFF71C0F0) : Colors.blueGrey.shade700;
    case FinancialCloseItemStatus.blocked:
      return Colors.orange.shade700;
  }
}

IconData financialCloseItemStatusIcon(FinancialCloseItemStatus status) {
  switch (status) {
    case FinancialCloseItemStatus.ready:
      return Icons.check_circle_rounded;
    case FinancialCloseItemStatus.review:
      return Icons.rate_review_rounded;
    case FinancialCloseItemStatus.blocked:
      return Icons.warning_rounded;
  }
}
