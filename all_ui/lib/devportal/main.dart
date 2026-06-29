import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queue_ui/devportal/screens/developer_console_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: MaterialApp(home: DeveloperConsoleScreen())),
  );
}
