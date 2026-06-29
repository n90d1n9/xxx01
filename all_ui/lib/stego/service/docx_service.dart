import 'dart:io';

import 'package:docx_template/docx_template.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:pdfx/pdfx.dart';

class DocumentService {
  static Future<String> extractFromDocx(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final docx = DocxTemplate.fromBytes(bytes);
      return docx.toString();
    } catch (e) {
      return 'Error reading DOCX: $e';
    }
  }

  static Future<String> extractFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final PdfDocument document = await PdfDocument.openData(bytes);
      StringBuffer buffer = StringBuffer();

      for (int i = 0; i < document.pagesCount; i++) {
        try {
          final page = await document.getPage(i + 1);
          buffer.write('--- Page ${i + 1} ---\n');

          // Get PDF page info
          buffer.write(
            'Page Size: ${page.width.toInt()} x ${page.height.toInt()}\n',
          );
          buffer.write('[PDF content extracted - metadata included]\n\n');

          // Since direct text extraction isn't available in pdfx,
          // we'll provide page metadata
          buffer.write(
            'Note: For full text extraction, convert PDF to text format first.\n',
          );
        } catch (e) {
          buffer.write('(Page ${i + 1} - Error: $e)\n');
        }
      }

      document.close();

      if (buffer.toString().isEmpty) {
        return 'PDF loaded successfully. Contains ${document.pagesCount} page(s).\n'
            'Note: PDF text extraction requires manual conversion or OCR.\n'
            'Consider converting PDF to text format first.';
      }

      return buffer.toString();
    } catch (e) {
      return 'Error reading PDF: $e\n'
          'Tip: Try converting PDF to text format first using an online converter.';
    }
  }

  static Future<String> extractFromExcel(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      StringBuffer buffer = StringBuffer();

      for (var table in excel.tables.keys) {
        buffer.write('Sheet: $table\n');
        buffer.write('---\n');

        final rows = excel.tables[table]?.rows ?? [];
        for (var row in rows) {
          final cells = row
              .map((cell) => cell?.value?.toString() ?? '')
              .where((cell) => cell.isNotEmpty)
              .join(' | ');
          if (cells.isNotEmpty) {
            buffer.write('$cells\n');
          }
        }
        buffer.write('\n');
      }

      return buffer.toString();
    } catch (e) {
      return 'Error reading Excel: $e';
    }
  }
}
