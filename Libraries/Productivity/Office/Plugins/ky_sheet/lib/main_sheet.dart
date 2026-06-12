import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screen/sheet_office_workspace.dart';
import 'theme/ky_sheet_theme.dart';

void main() {
  runApp(const ProviderScope(child: SpreadsheetApp()));
}

class SpreadsheetApp extends StatelessWidget {
  const SpreadsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ky Sheet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: KySheetColors.accent,
          surface: KySheetColors.surface,
        ),
        scaffoldBackgroundColor: KySheetColors.canvas,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SheetOfficeWorkspace(),
    );
  }
}

// Models

// UI Components
