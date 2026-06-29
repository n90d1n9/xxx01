import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  const username = 'admin';
  const password = 'securepassword';
  final authHeader =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  //'Basic $username:$password'; //

  final uri = Uri.parse(
    'http://[::1]:8080/sse',
  ); // <- Use IP instead of localhost

  try {
    final request = await client.getUrl(uri);

    request.headers.set(HttpHeaders.authorizationHeader, authHeader);
    request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');

    final response = await request.close();

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Connected to SSE stream...');
      response.transform(utf8.decoder).transform(const LineSplitter()).listen((
        line,
      ) {
        if (line.trim().isNotEmpty) {
          print('> $line');
        }
      });
    } else {
      print('❌ Failed to connect: ${response.statusCode}');
    }
  } catch (e) {
    print('❗ Error: $e');
  }
}
