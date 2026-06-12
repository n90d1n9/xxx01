import 'package:flutter/material.dart';

import '../models/financial_report_pack.dart';
import 'financial_report_statement_components.dart';

class FinancialReportPackSectionStack extends StatelessWidget {
  const FinancialReportPackSectionStack({
    required this.sections,
    this.spacing = 16,
    super.key,
  });

  final List<Widget> sections;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in sections.indexed) ...[
          if (entry.$1 > 0) SizedBox(height: spacing),
          entry.$2,
        ],
      ],
    );
  }
}

class FinancialReportStatementSection extends StatelessWidget {
  const FinancialReportStatementSection({
    required this.pack,
    required this.isDarkMode,
    this.spacing = 12,
    super.key,
  });

  final FinancialReportPack pack;
  final bool isDarkMode;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (pack.statements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in pack.statements.indexed)
          Padding(
            padding: EdgeInsets.only(
              bottom: entry.$1 == pack.statements.length - 1 ? 0 : spacing,
            ),
            child: FinancialReportStatementCard(
              pack: pack,
              statement: entry.$2,
              isDarkMode: isDarkMode,
            ),
          ),
      ],
    );
  }
}
