import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Models


 

// Providers




// Main app to demonstrate the dashboard
class HRAnalyticsApp extends StatelessWidget {
  const HRAnalyticsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'HR Analytics Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const HRDashboardScreen(),
      ),
    );
  }
}

void main() {
  runApp(const HRAnalyticsApp());
}
