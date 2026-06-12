import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logging/logging.dart';

import '../../themes/theme.dart';
import '../../core/themes/util.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

MaterialTheme materialTheme(BuildContext context) {
  final textTheme = createTextTheme(context, "Roboto Condensed", "Roboto Flex");

  return MaterialTheme(textTheme);
}

const supportedLocales = [Locale('en'), Locale('id')];

final lightTheme = ThemeData.light();
final darkTheme = ThemeData.dark();

bool validateEmail(String value) {
  // Regex for email validation
  String pattern =
      "[a-zA-Z0-9+._%-+]{1,256}\\@"
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}"
      "(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

Future<String> jsonFromFile(String path) async {
  final String response = await rootBundle.loadString(path);
  return response;
}

Future<Map<String, dynamic>> jwt() async {
  return JwtDecoder.decode('');
}

Future<List<String>> roles() async {
  return (await jwt())["auth"].split(",");
}

Future<bool> isRole(String role) async {
  final List<String> b = await roles();
  return b.contains(role);
}

DateTime instantToDate(DateTime date) {
  return DateTime.parse(
    date.toString().substring(0, date.toString().length - 1),
  );
}

void setupWindow() {
  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {}
  // Get the operating system as a string.
  // Or, use a predicate getter.
  if (Platform.isMacOS) {
  } else {}
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

String getOS() {
  String os = Platform.operatingSystem;
  return os;
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
Widget getIcon(
  String icon, {
  String? title,
  Color color = Colors.black,
  double size = 24.0,
}) => Icon(getIconData(icon), color: color, size: size, semanticLabel: title);

IconData getIconData(String name) => icons()[name] ?? Icons.circle_outlined;

Map<String, IconData> icons() => {
  'home': Icons.home,
  'label': Icons.label,
  'list': Icons.list,
  'logout': Icons.logout,
  'person': Icons.person_outline,
  'access_alarm': Icons.access_alarm,
  'account_tree': Icons.account_tree_rounded,
  'yt_search': Icons.youtube_searched_for,
  'abc': Icons.abc,
  'add_photo': Icons.add_a_photo,
  'add': Icons.add,
  'command': Icons.rule_rounded,
  'project': Icons.view_timeline_outlined,
  'scrumboard': Icons.view_column_rounded,
  'gantt': Icons.timeline_outlined,
  'account_balance': Icons.account_balance_rounded,
  'account_balance_wallet': Icons.account_balance_wallet_rounded,
  'balance': Icons.balance_rounded,
  'edit_note': Icons.edit_note_rounded,
  'event_repeat': Icons.event_repeat_rounded,
  'fact_check': Icons.fact_check_rounded,
  'group': Icons.group_rounded,
  'billing': Icons.receipt_long_rounded,
  'billing-workspaces': Icons.people_alt_rounded,
  'billing-invoices': Icons.article_rounded,
  'billing-create-invoice': Icons.note_add_rounded,
  'billing-insights': Icons.insights_rounded,
  'billing-outbox': Icons.outbox_rounded,
  'billing-products': Icons.storefront_rounded,
  'billing-checkout': Icons.shopping_cart_rounded,
  'billing-diagnostics': Icons.health_and_safety_rounded,
  'commerce': Icons.hub_rounded,
  'commerce-profiles': Icons.tune_rounded,
  'ecommerce-pos': Icons.point_of_sale_rounded,
  'ecommerce-orders': Icons.receipt_long_rounded,
  'layout-builder': Icons.dashboard_customize_rounded,
  'website-builder': Icons.web_asset_rounded,
  'presentation-editor': Icons.slideshow_rounded,
  'marketplace-orders': Icons.storefront_rounded,
  'delivery-orders': Icons.local_shipping_rounded,
  'wholesale-orders': Icons.warehouse_rounded,
  'restaurant': Icons.restaurant_rounded,
  'restaurant-floor': Icons.table_restaurant_rounded,
  'restaurant-menu': Icons.restaurant_menu_rounded,
  'restaurant-kitchen': Icons.soup_kitchen_rounded,
  'history': Icons.history_rounded,
  'health_and_safety': Icons.health_and_safety_rounded,
  'inventory': Icons.inventory_2_rounded,
  'inventory_2': Icons.inventory_2_rounded,
  'lock_clock': Icons.lock_clock_rounded,
  'menu_book': Icons.menu_book_rounded,
  'outbox': Icons.outbox_rounded,
  'payments': Icons.payments_rounded,
  'playlist_add_check': Icons.playlist_add_check_rounded,
  'policy': Icons.policy_rounded,
  'request_quote': Icons.request_quote_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'rule_folder': Icons.rule_folder_rounded,
  'settings': Icons.settings_rounded,
  'store': Icons.store_rounded,
  'sticky_note': Icons.sticky_note_2_rounded,
  'summarize': Icons.summarize_rounded,
  'speed': Icons.speed_rounded,
  'sync_alt': Icons.sync_alt_rounded,
  'trending_up': Icons.trending_up_rounded,
  'verified_user': Icons.verified_user_rounded,
  'waterfall_chart': Icons.waterfall_chart_rounded,
};

String transformStringParam(List<String> text) {
  String payload = '';
  const del = '&';
  var i = 0;
  for (var e in text) {
    payload += e + (i < text.length - 1 ? del : '');
    i++;
  }
  return payload;
}
