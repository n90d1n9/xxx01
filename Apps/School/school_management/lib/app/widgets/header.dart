import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/search/screens/search_form.dart';
import '../states/settings/settings_notifier.dart';

class Header extends ConsumerWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        /* Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search here...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            onChanged: (value) {
              // ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ), */
        Expanded(
          child: const SizedBox(height: 50, width: 500, child: SearchForm()),
        ),
        const SizedBox(width: 60),
        IconButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).toggleTheme();
          },
          icon: Icon(
            ref.watch(settingsProvider).themeMode == ThemeMode.light
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.settings),
        const SizedBox(width: 8),
        const Icon(Icons.notifications),
        const SizedBox(width: 8),
        const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }
}
