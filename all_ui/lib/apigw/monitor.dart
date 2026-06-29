// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:queue_ui/apigw/monitor/screens/apisx_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: ApiGatewayMonitorApp()));
}

class ApiGatewayMonitorApp extends StatelessWidget {
  const ApiGatewayMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ApisixDashboard(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Iket  Monitor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

// lib/models/api_metrics.dart


// lib/services/api_service.dart

// lib/providers/api_providers.dart

// lib/screens/dashboard_screen.dart

// lib/widgets/metric_card.dart

// lib/widgets/connections_chart.dart


// lib/widgets/requests_chart.dart


// lib/widgets/memory_usage_chart.dart


// lib/config/theme.dart


// pubspec.yaml
/*
name: api_gateway_monitor
description: A modern Iket  performance monitoring dashboard.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  flutter_riverpod: ^2.3.6
  go_router: ^12.1.0
  http: ^1.2.0
  intl: ^0.19.0
  fl_chart: ^0.66.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
*/
