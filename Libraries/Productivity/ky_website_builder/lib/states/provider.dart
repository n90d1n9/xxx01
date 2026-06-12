import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/designer_state.dart';
import '../services/cloud_storage_service.dart';
import '../services/collaborator_service.dart';
import '../services/designer_service.dart';
import '../services/history_service.dart';

final cloudStorageServiceProvider = Provider((ref) => CloudStorageService());
final collaborationServiceProvider = Provider((ref) => CollaborationService());

final designerProvider = StateNotifierProvider<DesignerNotifier, DesignerState>(
  (ref) => DesignerNotifier(ref),
);

final historyServiceProvider = Provider((ref) => HistoryService());

/* final canUndoProvider = Provider<bool>((ref) {
  return ref.watch(designerProvider.notifier).canUndo();
});

final canRedoProvider = Provider<bool>((ref) {
  return ref.watch(designerProvider.notifier).canRedo();
});
 */
