import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../states/component_provider.dart';

class AnimationPanel extends ConsumerWidget {
  const AnimationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponent = ref.watch(selectedComponentProvider);

    return Container(
      width: 300,
      color: Colors.white,
      child: selectedComponent == null
          ? const Center(child: Text('Select a component'))
          : const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Animation Panel'),
            ),
    );
  }
}
