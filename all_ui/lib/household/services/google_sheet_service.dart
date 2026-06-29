// Google Sheets Service
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class GoogleSheetsService {
  static const String spreadsheetIdKey = 'google_sheets_spreadsheet_id';

  Future<void> saveSpreadsheetId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(spreadsheetIdKey, id);
  }

  Future<String?> getSpreadsheetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(spreadsheetIdKey);
  }

  Future<void> exportToGoogleSheets(
    List<Expense> expenses,
    String spreadsheetId,
  ) async {
    // Note: This is a simplified version. In production, you need:
    // 1. OAuth2 authentication with Google
    // 2. Enable Google Sheets API in Google Cloud Console
    // 3. Add credentials.json file

    // For now, we'll create a CSV that can be manually imported
    throw UnimplementedError(
      'Google Sheets integration requires OAuth2 setup. Use CSV export instead.',
    );
  }

  Future<String> createSpreadsheet(String title) async {
    throw UnimplementedError(
      'Google Sheets integration requires OAuth2 setup.',
    );
  }
}
