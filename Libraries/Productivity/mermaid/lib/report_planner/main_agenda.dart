// Main App
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'screen/agenda_planner_home.dart';
//import 'service/notification_service.dart';
import 'state/agenda_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  // await NotificationService.initialize();
  runApp(const ProviderScope(child: AgendaPlannerApp()));
}

class AgendaPlannerApp extends ConsumerWidget {
  const AgendaPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Agenda Planner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
      ),
      themeMode: themeMode,
      home: const AgendaPlannerHome(),
    );
  }
}
