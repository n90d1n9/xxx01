import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'home.dart';
import 'features/sheets/sheet_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/sheets',
        builder: (context, state) => const SheetsScreen(),
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Google Sheets Integration',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
