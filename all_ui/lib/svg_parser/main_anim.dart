import 'package:flutter/material.dart';

import 'anim/screen/advanced_studio_home.dart';

void main() {
  runApp(const AdvancedSvgStudioApp());
}

class AdvancedSvgStudioApp extends StatelessWidget {
  const AdvancedSvgStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced SVG Animation Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const AdvancedStudioHome(),
    );
  }
}
