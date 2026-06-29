// Auto-save provider - saves every 30 seconds if there are changes
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'component_provider.dart';
import 'provider.dart';

final autoSaveProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

// Watch for auto-save trigger
final autoSaveWatcherProvider = Provider<void>((ref) {
  ref.listen(autoSaveProvider, (previous, next) {
    next.whenData((timestamp) {
      final hasChanges = ref.read(hasUnsavedChangesProvider);
      final projectId = ref.read(designerProvider).currentProjectId;

      if (hasChanges && projectId != null) {
        ref
            .read(designerProvider.notifier)
            .saveToCloud('Auto-save at ${timestamp.toString()}');
      }
    });
  });
});
