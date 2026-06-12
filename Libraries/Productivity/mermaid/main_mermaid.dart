import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math' as math;

import 'screens/mermaid_editor_screen.dart';

void main() {
  runApp(const ProviderScope(child: MermaidApp()));
}

class MermaidApp extends StatelessWidget {
  const MermaidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mermaid Diagram Editor',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MermaidEditorScreen(),
    );
  }
}
