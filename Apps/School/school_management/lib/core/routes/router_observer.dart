import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class RouterObserver extends NavigatorObserver {
  final log = Logger('RouterObserver');
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    log.info('New route pushed: ${route.currentResult}');
  }
}
