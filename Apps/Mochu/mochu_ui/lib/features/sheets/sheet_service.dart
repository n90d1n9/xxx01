// lib/services/sheets_service.dart
import 'package:dio/dio.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart';

class SheetsService {
  final Dio _dio = Dio();

  Future<sheets.Spreadsheet?> createSpreadsheet(String accessToken) async {
    try {
      final client = await _getAuthenticatedClient(accessToken);
      final sheetsApi = sheets.SheetsApi(client);

      final spreadsheet = sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(
          title: 'My New Spreadsheet',
        ),
      );

      return await sheetsApi.spreadsheets.create(spreadsheet);
    } catch (e) {
      print('Error creating spreadsheet: $e');
      return null;
    }
  }

  Future<void> updateValues(String accessToken, String spreadsheetId,
      String range, List<List<dynamic>> values) async {
    try {
      final client = await _getAuthenticatedClient(accessToken);
      final sheetsApi = sheets.SheetsApi(client);

      final valueRange = sheets.ValueRange(values: values);

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
    } catch (e) {
      print('Error updating values: $e');
    }
  }

  Future<AuthClient> _getAuthenticatedClient(String accessToken) async {
    final client =
        await clientViaApiKey('AIzaSyDsi5CwpHGvjxkH1I9EmSDNQL0OMIVtPgQ');
    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        accessToken,
        DateTime.now().add(const Duration(hours: 1)),
      ),
      null,
      ['https://www.googleapis.com/auth/spreadsheets'],
    );

    return authenticatedClient(client, credentials);
  }
}
