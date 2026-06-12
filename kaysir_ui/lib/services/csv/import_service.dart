import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../../features/product/models/product.dart';

class ImportService {
  Future<List<Product>> importProductsFromCsv() async {
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
            (row) => Product(
              id: row[0],
              name: row[1].toString(),
              systemStock: int.parse(row[2].toString()),
              actualStock: int.parse(row[2].toString()),
              category: row[3].toString(),
              /* minimumStock: int.parse(row[4].toString()),
        maximumStock: int.parse(row[5].toString()),
        unitPrice: double.parse(row[6].toString()), */
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
