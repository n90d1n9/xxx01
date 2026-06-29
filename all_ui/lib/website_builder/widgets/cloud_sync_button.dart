import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../states/provider.dart';

class CloudSyncButton extends ConsumerWidget {
  const CloudSyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designerProvider);
    final notifier = ref.read(designerProvider.notifier);

    return FloatingActionButton.extended(
      onPressed:
          state.projectStatus == ProjectStatus.saving
              ? null
              : () => notifier.saveToCloud('Project ${DateTime.now()}'),
      icon:
          state.projectStatus == ProjectStatus.saving
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.cloud_upload),
      label: Text(
        state.projectStatus == ProjectStatus.saving
            ? 'Saving...'
            : 'Save to Cloud',
      ),
    );
  }
}
