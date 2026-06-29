import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/pattern_library_provider.dart';
import '../widget/pattern/pattern_card.dart';

class TemplatesGalleryScreen extends ConsumerWidget {
  const TemplatesGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternState = ref.watch(patternLibraryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workflow Templates')),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 1.2,
        ),
        itemCount: patternState.patterns.length,
        itemBuilder: (context, index) {
          final pattern = patternState.patterns[index];
          return PatternCard(pattern: pattern);
        },
      ),
    );
  }
}
