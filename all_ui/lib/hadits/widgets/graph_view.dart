import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../screens/related_hadith_screen.dart';
import '../states/hadith_provider.dart';
import 'hadith_detail_card.dart';
import 'sanad_graph.dart';

class GraphView extends ConsumerWidget {
  const GraphView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHadith = ref.watch(selectedHadithProvider);
    final hadiths = ref.watch(filteredHadithsProvider);

    if (hadiths.isEmpty) {
      return Center(child: Text(tr(ref, 'no_hadiths')));
    }

    final displayHadith = selectedHadith ?? hadiths.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SanadGraph(hadith: displayHadith),
          const SizedBox(height: 16),
          HadithDetailCard(hadith: displayHadith),
          if (displayHadith.relatedHadiths.isNotEmpty) ...[
            const SizedBox(height: 16),
            RelatedHadithsSection(hadithIds: displayHadith.relatedHadiths),
          ],
        ],
      ),
    );
  }
}
