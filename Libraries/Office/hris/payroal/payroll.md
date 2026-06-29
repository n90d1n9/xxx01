import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
/* class Employee {
  final String id;
  final String name;
  final String position;
  final double salary;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.salary,
    required this.imageUrl,
  });
} */

// Providers
/*  */

//;

// Main application
class PayrollApp extends ConsumerWidget {
  const PayrollApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Payroll System',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      home: const PayrollScreen(),
    );
  }
}

// Payroll History Screen

// Tax Calculator Screen

void main() {
  runApp(const ProviderScope(child: PayrollApp()));
}
