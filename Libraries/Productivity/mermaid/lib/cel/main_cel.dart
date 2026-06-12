// Main App
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'screen/cel_builder_screen.dart';

void main() {
  runApp(const ProviderScope(child: CELBuilderApp()));
}

class CELBuilderApp extends StatelessWidget {
  const CELBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEL Expression Builder',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CELBuilderHome(),
    );
  }
}
