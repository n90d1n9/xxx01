import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fin_statment_large.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial Statements',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      //home: const FinancialStatementsScreen(),
      home: const FinancialStatementsScreen(),
    );
  }
}
