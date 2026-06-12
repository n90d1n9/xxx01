// Search Sheet (simplified)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class SearchSheet extends ConsumerWidget {
  const SearchSheet({Key? key}) : super(key: key);

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
      child: const Text('Search Sheet - Implementation same as before'),
    );
  }
}
