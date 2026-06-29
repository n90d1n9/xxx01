import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<void> exportToCsv(List<dynamic> products) async {
    final csvData = [
      [
        'ID',
        'Name',
        'System Stock',
        'Actual Stock',
        'Difference',
        'Notes',
        'Last Checked',
      ],
      ...products.map(
        (p) => [
          p.id,
          p.name,
          p.systemStock,
          p.actualStock,
          p.actualStock! - p.systemStock,
          p.notes ?? '',
          p.lastChecked?.toIso8601String() ?? '',
        ],
      ),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/stock_opname_report.csv');
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(file.path)], subject: 'Stock Opname Report');
  }

  Future<List<dynamic>> importProductsFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return [];

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);

      // Skip header row
      return rows
          .skip(1)
          .map(
            (row) => {
              'id': row[0],
              'name': row[1],
              'systemStock': row[2],
              'actualStock': row[3],
              'notes': row[4],
              'lastChecked': DateTime.tryParse(row[5]),
            },
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
