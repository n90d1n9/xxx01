import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';

class BrowseByRawiScreen extends ConsumerWidget {
  const BrowseByRawiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawis = ref.watch(rawiListProvider);
    final hadiths = ref.watch(hadithListProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr(ref, 'browse_by_rawi'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            rawis.map((rawi) {
              final rawiHadiths =
                  hadiths.where((h) => h.sanad.contains(rawi.id)).toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    rawi.name.get(locale),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rawi.name.ar),
                      Text('${rawiHadiths.length} ${tr(ref, 'hadiths')}'),
                    ],
                  ),
                  children:
                      rawiHadiths.map((h) {
                        return ListTile(
                          title: Text(
                            h.translation.get(locale),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${h.grade} - ${tr(ref, 'hadith_number')}${h.number}',
                          ),
                          onTap: () {
                            ref.read(selectedHadithProvider.notifier).state = h;
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                ),
              );
            }).toList(),
      ),
    );
  }
}
