// Filter Sheet (simplified)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: const Text('Filter Sheet - Implementation same as before'),
    );
  }
}
