import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/menu_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButton<MenuMode>(
            value: ref.watch(menuStateProvider).mode,
            onChanged: (MenuMode? newMode) {
              if (newMode != null) {
                ref.read(menuStateProvider.notifier).setMode(newMode);
              }
            },
            items: MenuMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
