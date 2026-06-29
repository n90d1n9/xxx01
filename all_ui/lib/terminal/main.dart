import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/terminal_theme.dart';
import 'widgets/terminal_screen.dart';

void main() {
  runApp(const ProviderScope(child: FlutterTerminalApp()));
}

class FlutterTerminalApp extends StatelessWidget {
  const FlutterTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Terminal',
      debugShowCheckedModeBanner: false,
      theme: TerminalTheme.dark,
      home: const TerminalScreen(),
    );
  }
}
