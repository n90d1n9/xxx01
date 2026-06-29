import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/diagram_provider.dart';
//import 'package:flutter_mermaid/flutter_mermaid.dart';

class ViewerScreen extends ConsumerWidget {
  final String id;

  const ViewerScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagrams = ref.watch(diagramProvider);
    final content = diagrams[id];

    if (content == null) {
      return const Scaffold(
        body: Center(
          child: Text('Diagram not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mermaid Viewer'),
      ),
      body: Center(
        child: FlutterMermaid(
          chart: content,
        ),
      ),
    );
  }
}
