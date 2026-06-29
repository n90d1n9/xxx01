import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'screens/setup_screen.dart';

// API Service

// Main App
void main() {
  runApp(const ProviderScope(child: KafkaManagerApp()));
}

class KafkaManagerApp extends ConsumerWidget {
  const KafkaManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Kafka Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SetupScreen(),
    );
  }
}


// Dashboard Screen

// Overview Screen




// Topics Screen

// Topic Details Screen


// Topic Config Dialog


// Create Topic Dialog


// Brokers Screen


// Monitoring Screen


