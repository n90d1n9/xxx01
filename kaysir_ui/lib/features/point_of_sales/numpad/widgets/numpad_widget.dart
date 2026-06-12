import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../provider/numpad_provider.dart';

class NumpadWidget extends ConsumerWidget {
  final VoidCallback? onEnter;

  const NumpadWidget({super.key, this.onEnter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(numpadProvider);

    return Column(
      children: [
        // Display the input value
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            input,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        // Numpad grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(16.0),
          children: [
            ...List.generate(9, (index) {
              return ElevatedButton(
                onPressed: () {
                  ref.read(numpadProvider.notifier).append('${index + 1}');
                },
                child: Text('${index + 1}'),
              );
            }),
            ElevatedButton(
              onPressed: () => ref.read(numpadProvider.notifier).clear(),
              child: const Text('C'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(numpadProvider.notifier).append('0');
              },
              child: const Text('0'),
            ),
            ElevatedButton(onPressed: onEnter, child: const Text('Enter')),
          ],
        ),
      ],
    );
  }
}
