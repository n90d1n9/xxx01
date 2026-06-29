import 'package:flutter/material.dart';
import 'package:syirkah/modules/finance/accounting/pages/general_journal/blogic/general_journal_states.dart';

import '../models/general_joournal.dart';
import '../new_table.dart';

class GLTable extends StatelessWidget {
  const GLTable({super.key, required this.data});
  final List<GeneralJournal> data;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      /* headingRowColor:
          WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.blueAccent;
        }
        return null; // Use the default value.
      }), */
      columns: const [
        DataColumn(label: Text('Ref.')),
        DataColumn(label: Text('Tanggal')),
        DataColumn(label: Text('Keterangan')),
        DataColumn(label: Text('No. Dept.')),
        DataColumn(label: Text('Debet')),
        DataColumn(label: Text('Kredit')),
        DataColumn(label: Text('No. Proyek')),
        NewColumn(title: Text('sdsf'))
      ],
      rows: data.map((entry) {
        return DataRow(
          cells: [
            DataCell(Text(entry.ref)),
            DataCell(Text(entry.tanggal)),
            DataCell(Text(entry.keterangan)),
            DataCell(Text(entry.noDept)),
            DataCell(Text(entry.debet.toString())),
            DataCell(Text(entry.kredit.toString())),
            DataCell(Text(entry.noProyek)),
          ],
        );
      }).toList(),
    );;
  }
}