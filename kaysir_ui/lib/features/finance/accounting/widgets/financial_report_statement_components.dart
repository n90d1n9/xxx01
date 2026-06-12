import 'package:flutter/material.dart';

import '../models/financial_report_pack.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_statement_card_components.dart';
import 'financial_report_statement_line_components.dart';

export 'financial_report_reference_pill.dart';
export 'financial_report_statement_card_components.dart';
export 'financial_report_statement_line_components.dart';

class FinancialReportStatementCard extends StatelessWidget {
  const FinancialReportStatementCard({
    required this.pack,
    required this.statement,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPack pack;
  final FinancialReportStatement statement;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showComparative =
            pack.hasComparativePeriod && statement.hasComparativeAmounts;
        final useComparativeColumns =
            showComparative && constraints.maxWidth >= 720;
        final comparativeLabel = _comparisonLabelForStatement(statement.kind);

        return FinancialReportPanelSurface(
          isDarkMode: isDarkMode,
          padding: EdgeInsets.zero,
          backgroundColor: financialReportStatementSurfaceColor(isDarkMode),
          child: ExpansionTile(
            initiallyExpanded: financialReportStatementStartsExpanded(
              statement.kind,
            ),
            shape: const RoundedRectangleBorder(),
            collapsedShape: const RoundedRectangleBorder(),
            tilePadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            iconColor: mutedColor,
            collapsedIconColor: mutedColor,
            title: FinancialReportStatementCardHeader(
              statement: statement,
              isDarkMode: isDarkMode,
              lineCount: statement.lines.length,
              showComparative: showComparative,
              comparativeLabel: comparativeLabel,
            ),
            children: [
              Divider(height: 1, color: financialReportPanelBorder(isDarkMode)),
              const SizedBox(height: 8),
              if (useComparativeColumns)
                FinancialReportStatementColumnHeader(
                  isDarkMode: isDarkMode,
                  comparativeLabel: comparativeLabel,
                ),
              ...statement.lines.map(
                (line) => FinancialReportStatementLineRow(
                  line: line,
                  isDarkMode: isDarkMode,
                  showComparative: showComparative,
                  useComparativeColumns: useComparativeColumns,
                  comparativeLabel: comparativeLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _comparisonLabelForStatement(FinancialReportStatementKind kind) {
    if (kind == FinancialReportStatementKind.financialPosition) {
      return pack.comparativeAsOfLabel ?? 'Comparative';
    }
    return pack.comparativePeriodLabel ?? 'Comparative';
  }
}
