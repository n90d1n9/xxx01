import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CanvasBackground extends ConsumerWidget {
  const CanvasBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).canvasColor,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
