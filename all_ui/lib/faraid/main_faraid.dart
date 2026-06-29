import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/family_tree_screen.dart';
import 'states/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: FaraidApp()));
}

// main.dart
class FaraidApp extends ConsumerWidget {
  const FaraidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Kalkulator Faraid',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const FamilyTreeScreen(),
    );
  }
}
