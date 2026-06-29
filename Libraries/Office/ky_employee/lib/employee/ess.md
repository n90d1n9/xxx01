import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
/* class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String imageUrl;
  final DateTime joinDate;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.imageUrl,
    required this.joinDate,
  });
} */

// UI Components

// Edit Profile Screen

// Pay Stubs Screen

// Request Time Off Screen

// Time Off Requests Screen

// Main App
class EmployeeSelfServiceApp extends StatelessWidget {
  const EmployeeSelfServiceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Employee Self-Service',
        theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
        home: const EmployeeSelfServiceScreen(),
      ),
    );
  }
}

void main() {
  runApp(const EmployeeSelfServiceApp());
}
