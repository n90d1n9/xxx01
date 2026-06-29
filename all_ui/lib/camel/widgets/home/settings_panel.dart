import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/provider.dart';

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: ref.read(darkModeProvider),
              onChanged: (value) {
                ref.read(darkModeProvider.notifier).state = value;
              },
            ),
            SwitchListTile(
              title: const Text('Snap to Grid'),
              value: ref.read(snapToGridProvider),
              onChanged: (value) {
                ref.read(snapToGridProvider.notifier).state = value;
              },
            ),
            SwitchListTile(
              title: const Text('Show Mini Map'),
              value: ref.read(showMiniMapProvider),
              onChanged: (value) {
                ref.read(showMiniMapProvider.notifier).state = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
