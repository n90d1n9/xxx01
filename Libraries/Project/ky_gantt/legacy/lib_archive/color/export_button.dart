
import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import '../task/task.dart';

class ExportButton extends StatelessWidget {
  final List<Task> tasks;
  final DateTime startDate;
  final DateTime endDate;

  const ExportButton({
    super.key,
    required this.tasks,
    required this.startDate,
    required this.endDate,
  });

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Excel Spreadsheet'),
              subtitle: const Text('Export as .xlsx file'),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF Document'),
              subtitle: const Text('Export as .pdf file'),
              onTap: () {
                Navigator.pop(context);
                _exportToPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON Data'),
              subtitle: const Text('Export as .json file'),
              onTap: () {
                Navigator.pop(context);
                _exportToJson();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Tasks'];

    // Add headers
    sheet.appendRow([
      TextCellValue('Task Name'),
      TextCellValue('Start Date'),
      TextCellValue('End Date'),
      TextCellValue('Duration'),
      TextCellValue('Priority'),
      TextCellValue('Status'),
      TextCellValue('Assigned To'),
      TextCellValue('Progress'),
    ]);

    // Add task data
    for (var task in tasks) {
      sheet.appendRow([
     
        TextCellValue(task.name!),
        TextCellValue(DateFormat('yyyy-MM-dd').format(task.startDate!)),
        TextCellValue(DateFormat('yyyy-MM-dd').format(task.endDate!)),
        TextCellValue('${task.duration} days'),
        TextCellValue(task.priority!.label),
        TextCellValue(task.status!.label),
       // TextCellValue(task.assignedTo!.join(', ') ?? ''),
        TextCellValue('${(task.progress * 100).toStringAsFixed(0)}%'),
      ]);
    }

    // Save file
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final fileName = 'project_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      // Implement file saving logic based on platform
    }
  }

  Future<void> _exportToPdf() async {
    /* final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Project Timeline'),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                ['Task', 'Start', 'End', 'Status', 'Progress'],
                ...tasks.map((task) => [
                  task.name!,
                  DateFormat('MM/dd/yyyy').format(task.startDate!),
                  DateFormat('MM/dd/yyyy').format(task.endDate!),
                  task.status.label,
                  '${(task.progress * 100).toStringAsFixed(0)}%',
                ]),
              ],
            ),
          ],
        ),
      ), 
    );

    final fileBytes = await pdf.save();
    final fileName = 'project_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    // Implement file saving logic based on platform

    */
  }

  Future<void> _exportToJson() async {
    final jsonData = {
      'projectStart': startDate.toIso8601String(),
      'projectEnd': endDate.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };

    final jsonString = jsonEncode(jsonData);
    final fileName = 'project_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
    // Implement file saving logic based on platform
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Export Project',
      child: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () => _showExportDialog(context),
      ),
    );
  }
}


