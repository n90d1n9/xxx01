import 'package:flutter/material.dart';

import '../../../../widgets/ui/app_icon_badge.dart';
import '../../../../widgets/ui/app_text_cluster.dart';
import '../models/financial_report_pack.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_reference_pill.dart';

class FinancialReportStatementCardHeader extends StatelessWidget {
  const FinancialReportStatementCardHeader({
    required this.statement,
    required this.isDarkMode,
    required this.lineCount,
    required this.showComparative,
    required this.comparativeLabel,
    super.key,
  });

  final FinancialReportStatement statement;
  final bool isDarkMode;
  final int lineCount;
  final bool showComparative;
  final String comparativeLabel;

  @override
  Widget build(BuildContext context) {
    final accent = financialReportStatementAccentColor(
      statement.kind,
      isDarkMode,
    );
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIconBadge(
          icon: financialReportStatementIcon(statement.kind),
          size: 38,
          iconSize: 20,
          backgroundColor: accent.withValues(alpha: isDarkMode ? 0.16 : 0.1),
          foregroundColor: accent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextCluster(
                title: statement.title,
                subtitle: statement.subtitle,
                titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w900,
                ),
                subtitleStyle: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: mutedColor),
                titleGap: 4,
                subtitleMaxLines: 2,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FinancialReportPanelBadge(
                    label: '$lineCount line(s)',
                    color: accent,
                    icon: Icons.format_list_bulleted_rounded,
                    isDarkMode: isDarkMode,
                  ),
                  if (showComparative)
                    FinancialReportPanelBadge(
                      label: 'Compare $comparativeLabel',
                      color:
                          isDarkMode
                              ? Colors.grey.shade300
                              : Colors.blueGrey.shade700,
                      icon: Icons.compare_arrows_rounded,
                      isDarkMode: isDarkMode,
                    ),
                  ...statement.standardReferences.map(
                    (reference) => FinancialReportReferencePill(
                      reference: reference,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

bool financialReportStatementStartsExpanded(FinancialReportStatementKind kind) {
  switch (kind) {
    case FinancialReportStatementKind.financialPosition:
    case FinancialReportStatementKind.profitOrLossAndOci:
      return true;
    case FinancialReportStatementKind.changesInEquity:
    case FinancialReportStatementKind.cashFlows:
    case FinancialReportStatementKind.notes:
      return false;
  }
}

IconData financialReportStatementIcon(FinancialReportStatementKind kind) {
  switch (kind) {
    case FinancialReportStatementKind.financialPosition:
      return Icons.account_balance_rounded;
    case FinancialReportStatementKind.profitOrLossAndOci:
      return Icons.show_chart_rounded;
    case FinancialReportStatementKind.changesInEquity:
      return Icons.stacked_line_chart_rounded;
    case FinancialReportStatementKind.cashFlows:
      return Icons.waterfall_chart_rounded;
    case FinancialReportStatementKind.notes:
      return Icons.sticky_note_2_rounded;
  }
}

Color financialReportStatementAccentColor(
  FinancialReportStatementKind kind,
  bool isDarkMode,
) {
  switch (kind) {
    case FinancialReportStatementKind.financialPosition:
      return isDarkMode ? const Color(0xFF71C0F0) : Colors.blue.shade700;
    case FinancialReportStatementKind.profitOrLossAndOci:
      return isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700;
    case FinancialReportStatementKind.changesInEquity:
      return isDarkMode ? const Color(0xFFB39DDB) : Colors.deepPurple;
    case FinancialReportStatementKind.cashFlows:
      return isDarkMode ? const Color(0xFFFFD166) : Colors.amber.shade800;
    case FinancialReportStatementKind.notes:
      return isDarkMode ? const Color(0xFF9AD0F5) : Colors.blueGrey;
  }
}

Color financialReportStatementSurfaceColor(bool isDarkMode) {
  return isDarkMode ? const Color(0xFF2C2C44) : Colors.white;
}
