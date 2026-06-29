import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/stego_home.dart';

void main() {
  runApp(const ProviderScope(child: SteganographyApp()));
}

class SteganographyApp extends StatelessWidget {
  const SteganographyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Steganography Suite',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const SteganographyHome(),
    );
  }
}
