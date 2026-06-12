import 'package:flutter/material.dart';
import 'package:ky_website_builder/ky_website_builder.dart';

void main() {
  runApp(const WebsiteDesignerApp());
}

class WebsiteDesignerApp extends StatelessWidget {
  const WebsiteDesignerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaysir Website Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
        brightness: Brightness.dark,
      ),
      home: const WebsiteBuilderScreen(),
    );
  }
}
