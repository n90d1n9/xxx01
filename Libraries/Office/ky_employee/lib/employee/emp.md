import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:uuid/uuid.dart';

// MODELS
// lib/models/employee.dart

// REPOSITORIES
// lib/repositories/employee_repository.dart

// PROVIDERS
// lib/providers/employee_providers.dart
/* import 'package:flutter_riverpod/legacy.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';
import '../repositories/employee_repository_impl.dart'; */

// Repository provider


// SCREENS
// lib/screens/employee_list_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import 'employee_detail_screen.dart';
import 'add_edit_employee_screen.dart'; */





// lib/screens/employee_detail_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/employee_providers.dart';
import 'add_edit_employee_screen.dart'; */



// lib/screens/add_edit_employee_screen.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart'; */



// MAIN APP
// lib/main.dart
/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'screens/employee_list_screen.dart';
 */
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const EmployeeListScreen(),
    );
  }
}
