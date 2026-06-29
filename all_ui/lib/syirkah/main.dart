// FOLDER STRUCTURE
// lib/
// ├── main.dart
// ├── models/
// │   ├── user.dart
// │   ├── proposal.dart
// │   └── partnership.dart
// ├── providers/
// │   ├── auth_provider.dart
// │   ├── proposal_provider.dart
// │   └── partnership_provider.dart
// ├── screens/
// │   ├── auth/
// │   │   ├── login_screen.dart
// │   │   └── register_screen.dart
// │   ├── home_screen.dart
// │   ├── proposal/
// │   │   ├── proposal_list_screen.dart
// │   │   ├── proposal_detail_screen.dart
// │   │   └── create_proposal_screen.dart
// │   └── partnership/
// │       ├── my_investments_screen.dart
// │       └── my_partnerships_screen.dart
// └── widgets/
//     ├── proposal_card.dart
//     └── proposal_template.dart

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Syirkah Partnership',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const HomeScreen(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (_, __) => const HomeScreen(),
      ),
    );
  }
}
