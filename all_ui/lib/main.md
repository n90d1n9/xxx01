import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queue_ui/ppt/ppt.dart';
import 'package:queue_ui/queue.dart';

/* void main() {
  runApp(ProviderScope(child: const MainApp()));
} */

void main() {
  runApp(const MyPPT());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CustomerViewScreen());
  }
}
