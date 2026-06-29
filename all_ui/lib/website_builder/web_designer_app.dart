import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/designer_screen.dart';

void main() {
  runApp(const ProviderScope(child: WebsiteDesignerApp()));
}

class WebsiteDesignerApp extends StatelessWidget {
  const WebsiteDesignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Website Designer Pro - Riverpod Advanced',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DesignerScreen(),
    );
  }
}
