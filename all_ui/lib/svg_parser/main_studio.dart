import 'package:flutter/material.dart';

import 'designer/screen/svg_designer_home.dart';

void main() {
  runApp(const SvgAnimationStudioApp());
}

class SvgAnimationStudioApp extends StatelessWidget {
  const SvgAnimationStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Animation Designer',
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
      home: const SvgDesignerHome(),
    );
  }
}
