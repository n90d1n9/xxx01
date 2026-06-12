import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/product/models/product.dart';

class ExportService {
  Future<void> exportToCsv(List<Product> products) async {
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
}
