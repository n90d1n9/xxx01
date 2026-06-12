import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../provider/layout_state_provider.dart';
import '../widgets/component_renderer.dart';
import 'editor_screen.dart';

class LayoutCustomizerScreen extends StatelessWidget {
  const LayoutCustomizerScreen({super.key});

  static const routePath = EditorScreen.routePath;

  @override
  Widget build(BuildContext context) {
    return const EditorScreen();
  }
}

class CashierScreen extends ConsumerWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(layoutStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit layout',
            onPressed: () => context.go(LayoutCustomizerScreen.routePath),
          ),
        ],
      ),
      body: Stack(
        children: [
          for (final component in layout.components)
            Positioned(
              left: component.position.dx,
              top: component.position.dy,
              width: component.size.width,
              height: component.size.height,
              child: ComponentRenderer(component: component, isPreview: true),
            ),
        ],
      ),
    );
  }
}
