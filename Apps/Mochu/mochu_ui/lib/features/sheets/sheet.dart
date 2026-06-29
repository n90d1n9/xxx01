import 'dart:convert';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Define the required scope (read-only in this case).
const _scopes = [SheetsApi.spreadsheetsReadonlyScope];

Future<void> openSpreadsheet() async {
  // Replace the following JSON string with your service account credentials.
  // You can download these from your Google Cloud Console.
  final accountCredentials = ServiceAccountCredentials.fromJson(r'''
{
  "private_key_id": "YOUR_PRIVATE_KEY_ID",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "your-service-account-email@your-project.iam.gserviceaccount.com",
  "client_id": "YOUR_CLIENT_ID",
  "type": "service_account"
}
  ''');

  // Create an authenticated HTTP client.
  var client = await clientViaServiceAccount(accountCredentials, _scopes);

  // Instantiate the Sheets API.
  var sheetsApi = SheetsApi(client);

  // The spreadsheetId is the long ID found in your sheet's URL:
  // e.g., in https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/edit#gid=0
  var spreadsheetId = 'YOUR_SPREADSHEET_ID';

  try {
    // Fetch the spreadsheet's metadata.
    var spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
    print('Spreadsheet Title: ${spreadsheet.properties?.title}');

    // You can also fetch values from a specific range:
    // var response = await sheetsApi.spreadsheets.values.get(spreadsheetId, 'Sheet1!A1:D10');
    // print(response.values);
  } catch (e) {
    print('Error retrieving spreadsheet: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await openSpreadsheet();
}
