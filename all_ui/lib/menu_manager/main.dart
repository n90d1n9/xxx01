import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'screens/menu_manager.dart';
import 'services/app_router.dart';
import 'widgets/custom.dart';
import 'widgets/nav.dart';

// MenuItem Model with more robust properties

// Local Storage Service

// Menu Provider with Local Storage

// Rest of the previous implementation remains the same (NavigationSidebar, CustomAppBar)
// ... (Keep the previous implementations of these classes)

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ),
    ),
  );
}
