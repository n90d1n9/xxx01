import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../state/expression_provider.dart';
import 'cel_builder_screen.dart';

class VisualBuilder extends ConsumerWidget {
  const VisualBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootNode = ref.watch(expressionProvider).rootNode;

    if (rootNode == null) {
      return const Center(
        child: Text(
          'Click + to add a root node',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: NodeWidget(node: rootNode),
    );
  }
}
