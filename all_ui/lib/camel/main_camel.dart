import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'screens/designer_home.dart';
import 'screens/wayang_builder.dart';
import 'states/provider.dart';

void main() {
  runApp(const ProviderScope(child: CamelDesignerApp()));
}

class CamelDesignerApp extends ConsumerWidget {
  const CamelDesignerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Wayang Integration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const WayangBuilder(),
    );
  }
}
