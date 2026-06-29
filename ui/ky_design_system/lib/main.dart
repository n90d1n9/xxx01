import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storybook.dart';

void main() {
  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MikuStorybook());
  }
}

class MikuStorybook extends StatelessWidget {
  const MikuStorybook({super.key});

  @override
  Widget build(BuildContext context) => storybook;
}
