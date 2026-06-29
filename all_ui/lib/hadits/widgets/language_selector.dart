import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/hadith_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        ref.read(localeProvider.notifier).state = value;
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'id',
              child: Row(
                children: [
                  if (locale == 'id') const Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  const Text('Bahasa Indonesia'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  if (locale == 'en') const Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  const Text('English'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'ar',
              child: Row(
                children: [
                  if (locale == 'ar') const Icon(Icons.check, size: 20),
                  const SizedBox(width: 8),
                  const Text('العربية'),
                ],
              ),
            ),
          ],
    );
  }
}
