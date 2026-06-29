// Export/Import Service
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../model/agenda_item.dart';
import '../model/priority.dart';

class ExportImportService {
  // Export to JSON
  static Future<void> exportToJson(List<AgendaItem> items) async {
    try {
      final jsonData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'itemCount': items.length,
        'items': items.map((item) => item.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/agenda_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
      );
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Agenda Planner Backup',
        text:
            'Backup created on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
      );
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  // Export to CSV
  static Future<void> exportToCsv(List<AgendaItem> items) async {
    try {
      final rows = [
        [
          'Title',
          'Description',
          'Category',
          'Start Time',
          'End Time',
          'Location',
          'Priority',
          'Completed',
          'Tags',
          'Recurrence',
        ],
        ...items.map(
          (item) => [
            item.title,
            item.description,
            item.category,
            item.startTime.toIso8601String(),
            item.endTime.toIso8601String(),
            item.location ?? '',
            item.priority.toString().split('.').last,
            item.isCompleted.toString(),
            item.tags.join(';'),
            item.recurrence?.type.toString().split('.').last ?? 'none',
          ],
        ),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/agenda_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
      );
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Agenda Export',
        text: 'CSV export with ${items.length} events',
      );
    } catch (e) {
      throw Exception('CSV export failed: $e');
    }
  }

  // Export to PDF
  static Future<void> exportToPdf(List<AgendaItem> items) async {
    try {
      final pdf = pw.Document();

      // Group items by date
      final Map<String, List<AgendaItem>> groupedItems = {};
      for (final item in items) {
        final dateKey = DateFormat('yyyy-MM-dd').format(item.startTime);
        if (!groupedItems.containsKey(dateKey)) {
          groupedItems[dateKey] = [];
        }
        groupedItems[dateKey]!.add(item);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Agenda Planner Export',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Text(
              'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            ...groupedItems.entries.map((entry) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Header(
                    level: 1,
                    child: pw.Text(
                      DateFormat(
                        'EEEE, MMMM d, yyyy',
                      ).format(DateTime.parse(entry.key)),
                    ),
                  ),
                  ...entry.value.map((item) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(5),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item.title,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          if (item.description.isNotEmpty) ...[
                            pw.SizedBox(height: 5),
                            pw.Text(item.description),
                          ],
                          if (item.location != null) ...[
                            pw.SizedBox(height: 5),
                            pw.Text('Location: ${item.location}'),
                          ],
                        ],
                      ),
                    );
                  }),
                  pw.SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/agenda_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Agenda PDF',
        text: 'PDF export with ${items.length} events',
      );
    } catch (e) {
      throw Exception('PDF export failed: $e');
    }
  }

  // Import from JSON
  static Future<List<AgendaItem>> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);

      if (jsonData['items'] == null) {
        throw Exception('Invalid backup file format');
      }

      final items = (jsonData['items'] as List)
          .map((json) => AgendaItem.fromJson(json))
          .toList();

      return items;
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  // Import from CSV
  static Future<List<AgendaItem>> importFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        throw Exception('CSV file is empty or invalid');
      }

      final items = <AgendaItem>[];
      // Skip header row
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 8) continue;

        items.add(
          AgendaItem(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            title: row[0].toString(),
            description: row[1].toString(),
            category: row[2].toString(),
            startTime: DateTime.parse(row[3].toString()),
            endTime: DateTime.parse(row[4].toString()),
            location: row[5].toString().isEmpty ? null : row[5].toString(),
            priority: Priority.values.firstWhere(
              (e) => e.toString().split('.').last == row[6].toString(),
              orElse: () => Priority.medium,
            ),
            isCompleted: row[7].toString().toLowerCase() == 'true',
            tags: row[8]
                .toString()
                .split(';')
                .where((t) => t.isNotEmpty)
                .toList(),
            color: Colors.blue,
          ),
        );
      }

      return items;
    } catch (e) {
      throw Exception('CSV import failed: $e');
    }
  }
}
