import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/terminal.dart';

class ApiService {
  // final String baseUrl;
  final http.Client client;
  final baseUrl = 'https://api.example.com';

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // Method to fetch terminals from the API
  Future<List<Terminal>> getTerminals() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/terminals'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Terminal.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load terminals: ${response.statusCode}');
      }
    } catch (e) {
      // You might want to implement proper error handling here
      throw Exception('Failed to load terminals: $e');
    }
  }

  // Add more API methods as needed, for example:
  Future<Terminal> getTerminalById(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/terminals/$id'));

    if (response.statusCode == 200) {
      return Terminal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load terminal: ${response.statusCode}');
    }
  }
}
