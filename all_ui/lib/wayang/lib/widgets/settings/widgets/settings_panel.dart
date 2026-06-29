import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/theme_provider.dart';
import 'workflow_setting.dart';

class SettingsPanel extends ConsumerWidget {
  final void Function() onPressedSave;
  final void Function() onPressedCancel;
  const SettingsPanel({
    super.key,
    required this.onPressedSave,
    required this.onPressedCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 80,
      right: 16,
      child: Card(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: WorkflowSettings(
            currentTheme: ref.watch(themeProvider),
            onThemeChanged: (theme) {
              ref.read(themeProvider.notifier).state = theme;
            },
            onPressedCancel: onPressedCancel,
            onPressedSave: onPressedSave,
          ),
        ),
      ),
    );
  }
}
