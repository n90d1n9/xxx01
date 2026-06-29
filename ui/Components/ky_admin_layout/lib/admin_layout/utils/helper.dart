import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';
import 'package:miku_core/core/themes/theme.dart';
import 'package:miku_core/core/themes/util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import 'package:html/parser.dart' as html_parser;

//import 'package:html/dom.dart' as dom;

String getBaseUrl(String url) {
  final idx = url.indexOf('?');
  return idx == -1 ? url : url.substring(0, idx);
}

/// Extracts the first image URL from WordPress JSON content
String? extractImageUrl(Map<String, dynamic> json) {
  try {
    // Get the HTML content from JSON
    final content = json['content']['rendered'] as String?;
    if (content == null) return null;

    // Parse HTML and find the first <img> tag
    final document = html_parser.parse(content);
    final imgElements = document.getElementsByTagName('img');
    if (imgElements.isEmpty) return null;

    // Get the 'src' attribute and remove query parameters
    final imgSrc = imgElements[0].attributes['src'];
    return imgSrc?.split('?')[0]; // Returns clean URL
  } catch (e) {
    debugPrint('Error extracting image URL: $e');
    return null;
  }
}

setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ),
  );
}

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

Future<String?> getCityFromCoordinates(
  double latitude,
  double longitude,
) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality; // This is the city name
    }
  } catch (e) {
    debugPrint('Error occurred: $e');
  }
  return null;
}

Color getRandomPastelColor() {
  final Random random = Random();

  // Pastel colors are typically high in brightness and low in saturation.
  // We'll use HSLColor for better control, then convert to Color.
  final double hue = random.nextDouble() * 360;
  final double saturation = 0.4 + random.nextDouble() * 0.2; // 40% to 60%
  final double lightness = 0.7 + random.nextDouble() * 0.1; // 70% to 80%

  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

String encodeQueryToPlusFormat(String query) {
  return query.trim().split(RegExp(r'\s+')).join('+');
}

openInApplication(String url) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

String formatNumber(int number) {
  if (number >= 1000000000) {
    return '${(number / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
  } else if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';
  } else {
    return number.toString();
  }
}

materialTheme(context) {
  TextTheme textTheme =
      createTextTheme(context, "Roboto Condensed", "Roboto Flex");

  KyMaterialTheme theme = KyMaterialTheme(textTheme);
  return theme;
}

const supportedLocales = [
  Locale('en'),
  Locale('id'),
];

final lightTheme = ThemeData.light();
final darkTheme = ThemeData.dark();

bool validateEmail(String value) {
  // Regex for email validation
  String pattern = "[a-zA-Z0-9+._%-+]{1,256}\\@"
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}"
      "(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

Future<String> jsonFromFile(String path) async {
  final String response = await rootBundle.loadString(path);
  return response;
}

Future<Map<String, dynamic>> jwt(String token) async {
  return JwtDecoder.decode(token);
}

Future<List<String>> roles() async {
  return (await jwt(''))["auth"].split(",");
}

Future<bool> isRole(String role) async {
  final List<String> b = await roles();
  return b.contains(role);
}

instantToDate(DateTime date) {
  return DateTime.parse(
      date.toString().substring(0, date.toString().length - 1));
}

void setupWindow() {
  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {}
  // Get the operating system as a string.
  // Or, use a predicate getter.
  try {
    if (Platform.isMacOS) {
    } else {}
  } catch (e) {
    // Web platform - skip platform-specific setup
  }
}

Future<bool> isConnectInternet() async {
  bool isConnected = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      isConnected = true;
    }
  } on SocketException catch (_) {
    isConnected = false;
  }
  return isConnected;
}

String extractFirstImageFromHtml(String html) {
  final RegExp exp = RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false);
  final match = exp.firstMatch(html);
  return match != null ? match.group(1)! : '';
}

String getOS() {
  try {
    String os = Platform.operatingSystem;
    return os;
  } catch (e) {
    // Web platform doesn't support Platform.operatingSystem
    return 'web';
  }
}

String getScript() {
  // Get the URI of the script being run.
  var uri = Platform.script;
  return uri.toFilePath();
}

String getEnvironment(String envVarName) {
  // Get the value of an environment variable
  Map<String, String> envVars = Platform.environment;

  return envVars[envVarName].toString();
}

/* 
showModal(context, text, [onPressed]) =>
    ScaffoldMessenger.of(context).showsnakeBar(snakeBar(
      action: snakeBarAction(label: 'Action', onPressed: onPressed),
      content: Text(text),
      duration: const Duration(milliseconds: 1500),
      width: 280.0, // Width of the snakeBar.
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0, // Inner padding for snakeBar content.
      ),
      behavior: snakeBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
 */
Widget getIcon(String icon,
        {String? title, Color color = Colors.black, double size = 24.0}) =>
    Icon(
      getIconData(icon),
      color: color,
      size: size,
      semanticLabel: title,
    );

IconData getIconData(String name) => icons()[name] ?? Icons.home;

Map<String, IconData> icons() => {
      'home': Icons.home,
      'label': Icons.label,
      'list': Icons.list,
      'access_alarm': Icons.access_alarm,
      'yt_search': Icons.youtube_searched_for,
      'abc': Icons.abc,
      'add_photo': Icons.add_a_photo,
      'add': Icons.add
    };

transformStringParam(List<String> text) {
  String payload = '';
  var del = '&';
  var i = 0;
  for (var e in text) {
    payload += e + (i < text.length - 1 ? del : '');
    i++;
  }
  return payload;
}

String formatTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inDays > 0) {
    if (difference.inDays > 6) {
      return DateFormat('MMM d').format(time);
    } else {
      return DateFormat('E').format(time); // Day of week
    }
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'Now';
  }
}

/// Safe navigation helper to prevent go_router crashes
void safeNavigate(BuildContext context, String path) {
  try {
    context.push(path);
  } catch (e) {
    debugPrint('Navigation error for path $path: $e');
    // Fallback to a safe route
    try {
      context.push('/');
    } catch (fallbackError) {
      debugPrint('Fallback navigation also failed: $fallbackError');
    }
  }
}

/// Safe navigation helper with replacement (no back button)
void safeNavigateReplacement(BuildContext context, String path) {
  try {
    context.go(path);
  } catch (e) {
    debugPrint('Navigation replacement error for path $path: $e');
    // Fallback to a safe route
    try {
      context.go('/');
    } catch (fallbackError) {
      debugPrint('Fallback navigation replacement also failed: $fallbackError');
    }
  }
}
