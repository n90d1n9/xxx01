import 'package:flutter/material.dart';
import 'package:ky_scrumboard/ky_scrumboard.dart';

void main() {
  runApp(const ScrumBoardDemoApp());
}

class ScrumBoardDemoApp extends StatelessWidget {
  const ScrumBoardDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ScrumBoardScreen(),
    );
  }
}
