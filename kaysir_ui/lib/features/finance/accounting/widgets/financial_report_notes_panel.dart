import 'package:flutter/material.dart';

import '../models/financial_report_pack.dart';
import 'financial_report_panel_components.dart';
import 'financial_report_statement_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportNotesPanel extends StatelessWidget {
  const FinancialReportNotesPanel({
    required this.pack,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportPack pack;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDarkMode ? const Color(0xFF71C0F0) : Colors.blue;

    return FinancialReportPanelSurface(
      isDarkMode: isDarkMode,
      muted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinancialReportPanelHeader(
            title: 'Notes',
            subtitle: 'Disclosure narratives and standard references.',
            icon: Icons.sticky_note_2_rounded,
            accentColor: accentColor,
            isDarkMode: isDarkMode,
            trailing: FinancialReportPanelBadge(
              label: '${pack.notes.length} disclosures',
              color: accentColor,
              icon: Icons.article_outlined,
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(height: 12),
          if (pack.notes.isEmpty)
            FinancialReportPanelEmptyState(
              title: 'No disclosure notes are attached to this report pack.',
              icon: Icons.note_add_outlined,
              isDarkMode: isDarkMode,
            )
          else
            ...pack.notes.indexed.map(
              (entry) => FinancialReportDisclosureNoteTile(
                note: entry.$2,
                isDarkMode: isDarkMode,
                showDivider: entry.$1 != pack.notes.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class FinancialReportDisclosureNoteTile extends StatelessWidget {
  const FinancialReportDisclosureNoteTile({
    required this.note,
    required this.isDarkMode,
    this.showDivider = true,
    super.key,
  });

  final FinancialReportDisclosureNote note;
  final bool isDarkMode;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final accentColor = isDarkMode ? const Color(0xFF71C0F0) : Colors.blue;

    return Padding(
      padding: EdgeInsets.only(bottom: showDivider ? 12 : 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialReportTintedSurface(
                color: accentColor,
                width: 34,
                minHeight: 34,
                padding: EdgeInsets.zero,
                fillAlpha: isDarkMode ? 0.16 : 0.1,
                borderAlpha: 0.22,
                child: Center(
                  child: Text(
                    note.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          note.title,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        ...note.standardReferences.map(
                          (reference) => FinancialReportReferencePill(
                            reference: reference,
                            isDarkMode: isDarkMode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(note.body, style: TextStyle(color: mutedColor)),
                  ],
                ),
              ),
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
            ),
          ],
        ],
      ),
    );
  }
}
