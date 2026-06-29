import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'sit.dart';

// Include the GoogleAuthClient definition (from above)
// (If placed in a separate file, import it accordingly)

/// Simple data model for an item.
class Item {
  final String id;
  final String name;
  final String price;

  Item({required this.id, required this.name, required this.price});
}

class SheetsDataPage extends StatefulWidget {
  const SheetsDataPage({super.key});

  @override
  State<SheetsDataPage> createState() => _SheetsDataPageState();
}

class _SheetsDataPageState extends State<SheetsDataPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for input fields.
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // List of items fetched from the sheet.
  List<Item> _items = [];

  // Replace with your actual spreadsheet ID and sheet name.
  final String spreadsheetId = 'YOUR_SPREADSHEET_ID';
  final String sheetName = 'Sheet1';

  late sheets.SheetsApi sheetsApi;
  late http.Client client;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSheetsApi();
  }

  Future<void> _initSheetsApi() async {
    // Configure Google Sign-In with the necessary scopes.
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        sheets.SheetsApi.spreadsheetsReadonlyScope,
        sheets.SheetsApi.spreadsheetsScope, // For writing
      ],
    );

    // Trigger the interactive sign-in.
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      // User canceled the sign-in.
      print("Sign-in canceled by user.");
      return;
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final String accessToken = auth.accessToken!;
    // Create an authenticated HTTP client.
    client = GoogleAuthClient(accessToken);
    sheetsApi = sheets.SheetsApi(client);

    // Fetch existing rows.
    await _fetchRows();
  }

  Future<void> _fetchRows() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Assumes the first row is headers (id, name, price), data starts at row 2.
      final String range = '$sheetName!A2:C';
      final response =
          await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
      List<Item> items = [];
      if (response.values != null) {
        for (var row in response.values!) {
          // Ensure row has at least three columns.
          String id = row.length > 0 ? row[0].toString() : '';
          String name = row.length > 1 ? row[1].toString() : '';
          String price = row.length > 2 ? row[2].toString() : '';
          items.add(Item(id: id, name: name, price: price));
        }
      }
      setState(() {
        _items = items;
      });
    } catch (e) {
      print("Error fetching rows: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _appendRow(String id, String name, String price) async {
    // Prepare the new row data.
    var valueRange = sheets.ValueRange.fromJson({
      "values": [
        [id, name, price]
      ]
    });

    try {
      // Append the new row to the sheet.
      await sheetsApi.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        '$sheetName!A:C',
        valueInputOption: 'USER_ENTERED',
      );
      // Refresh the list.
      await _fetchRows();
    } catch (e) {
      print("Error appending row: $e");
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Sheets Items"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Display the list of items.
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text("ID: ${item.id} - Price: ${item.price}"),
                      );
                    },
                  ),
                ),
                // Input form to add a new item.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text("Add New Item",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(labelText: "ID"),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Enter ID"
                              : null,
                        ),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: "Name"),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Enter Name"
                              : null,
                        ),
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(labelText: "Price"),
                          keyboardType: TextInputType.number,
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Enter Price"
                              : null,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _appendRow(
                                _idController.text,
                                _nameController.text,
                                _priceController.text,
                              );
                              // Clear the input fields after successful append.
                              _idController.clear();
                              _nameController.clear();
                              _priceController.clear();
                            }
                          },
                          child: Text("Add Item"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
