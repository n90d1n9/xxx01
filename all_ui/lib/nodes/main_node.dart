import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'node_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Agent Builder Test',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const NodeCardTestPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
