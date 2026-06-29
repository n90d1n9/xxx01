import 'package:googleapis/sheets/v4.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;

/// A custom HTTP client that automatically adds the OAuth access token to each request.
class GoogleAuthClient extends http.BaseClient {
  final String accessToken;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this.accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add the OAuth access token in the Authorization header.
    request.headers['Authorization'] = 'Bearer $accessToken';
    return _inner.send(request);
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [SheetsApi.spreadsheetsReadonlyScope],
);

Future<void> openSpreadsheet() async {
  // Initiate interactive sign-in.
  final GoogleSignInAccount? account = await _googleSignIn.signIn();
  if (account == null) {
    // The user canceled the sign-in
    print("User canceled sign in");
    return;
  }

  // Obtain the authentication details (including access token).
  final GoogleSignInAuthentication auth = await account.authentication;
  final String accessToken = auth.accessToken!;

  // Create an authenticated HTTP client.
  final http.Client client = GoogleAuthClient(accessToken);

  // Instantiate the Sheets API.
  final SheetsApi sheetsApi = SheetsApi(client);

  // Replace with your actual spreadsheet ID
  final String spreadsheetId = 'YOUR_SPREADSHEET_ID';

  try {
    // Retrieve the spreadsheet metadata.
    final spreadsheet = await sheetsApi.spreadsheets.get(spreadsheetId);
    print("Spreadsheet Title: ${spreadsheet.properties?.title}");

    // Optionally, fetch values from a specific range:
    // final response = await sheetsApi.spreadsheets.values.get(
    //   spreadsheetId, 'Sheet1!A1:D10');
    // print(response.values);
  } catch (e) {
    print("Error retrieving spreadsheet: $e");
  } finally {
    client.close();
  }
}

void main() async {
  await openSpreadsheet();
}
