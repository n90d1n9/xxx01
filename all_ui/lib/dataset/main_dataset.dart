import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/main_navigation_page.dart';

void main() {
  runApp(const ProviderScope(child: LLMStudioApp()));
}

class LLMStudioApp extends StatelessWidget {
  const LLMStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LLM Fine-tuning Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      /*  darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ), */
      home: const MainNavigationPage(),
    );
  }
}
