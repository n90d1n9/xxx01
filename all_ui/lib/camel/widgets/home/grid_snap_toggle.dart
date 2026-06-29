import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../states/provider.dart';

class GridSnapToggle extends ConsumerWidget {
  const GridSnapToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapToGrid = ref.watch(snapToGridProvider);

    return IconButton(
      icon: Icon(snapToGrid ? Icons.grid_on : Icons.grid_off),
      onPressed: () {
        ref.read(snapToGridProvider.notifier).state = !snapToGrid;
      },
      tooltip: 'Snap to Grid',
    );
  }
}
