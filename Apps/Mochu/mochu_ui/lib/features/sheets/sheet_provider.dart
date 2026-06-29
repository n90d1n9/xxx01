// lib/providers/sheets_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'sheet_service.dart';

final sheetsServiceProvider = Provider<SheetsService>((ref) => SheetsService());

/* final spreadsheetProvider = FutureProvider.family<sheets.Spreadsheet?, String>(
    (ref, accessToken) async {
  final sheetsService = ref.watch(sheetsServiceProvider);
  return sheetsService.createSpreadsheet(accessToken);
}); */

// You might also want to modify the spreadsheetProvider to handle the async token:
final spreadsheetProvider = FutureProvider.family<sheets.Spreadsheet?, String>(
    (ref, accessToken) async {
  if (accessToken.isEmpty) return null;
  final sheetsService = ref.watch(sheetsServiceProvider);
  return sheetsService.createSpreadsheet(accessToken);
});
