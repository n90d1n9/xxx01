// lib/core/undo/undo_redo.dart
//
// Command-pattern undo/redo system.
// Every curation action (rating, flag, color label, rename, batch ops)
// is wrapped in a GalleryCommand and pushed onto the history stack.
// Undo replays the inverse operation; redo replays forward.
//
// Architecture:
//   GalleryCommand          — abstract base, stores before/after state
//   UndoRedoNotifier        — Riverpod notifier owning the history stack
//   undoRedoProvider        — provider reference
//   CommandExecutor         — helper that executes AND records
//
// Max history depth: 200 actions (configurable).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bridge/gallery_bridge.dart';
import '../models/gallery_models.dart';
import '../providers/gallery_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Abstract command
// ─────────────────────────────────────────────────────────────────────────────

abstract class GalleryCommand {
  /// Human-readable description shown in the history panel.
  String get description;

  /// Execute the forward action (also called on initial execution).
  Future<void> execute(WidgetRef ref);

  /// Execute the inverse action.
  Future<void> undo(WidgetRef ref);
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete commands
// ─────────────────────────────────────────────────────────────────────────────

class SetRatingCommand extends GalleryCommand {
  final int itemId;
  final int oldRating;
  final int newRating;

  SetRatingCommand({
    required this.itemId,
    required this.oldRating,
    required this.newRating,
  });

  @override
  String get description => 'Set rating to $newRating ★';

  @override
  Future<void> execute(WidgetRef ref) async {
    await GalleryBridge.setRating(itemId, newRating);
    await _refreshItem(ref, itemId);
  }

  @override
  Future<void> undo(WidgetRef ref) async {
    await GalleryBridge.setRating(itemId, oldRating);
    await _refreshItem(ref, itemId);
  }
}

class SetFlagCommand extends GalleryCommand {
  final int itemId;
  final int oldFlag;
  final int newFlag;

  SetFlagCommand({
    required this.itemId,
    required this.oldFlag,
    required this.newFlag,
  });

  static const _labels = {0: 'Unflag', 1: 'Pick', 2: 'Reject'};

  @override
  String get description => '${_labels[newFlag] ?? 'Flag'} image';

  @override
  Future<void> execute(WidgetRef ref) async {
    await GalleryBridge.setFlag(itemId, newFlag);
    await _refreshItem(ref, itemId);
  }

  @override
  Future<void> undo(WidgetRef ref) async {
    await GalleryBridge.setFlag(itemId, oldFlag);
    await _refreshItem(ref, itemId);
  }
}

class SetColorLabelCommand extends GalleryCommand {
  final int itemId;
  final String oldLabel;
  final String newLabel;

  SetColorLabelCommand({
    required this.itemId,
    required this.oldLabel,
    required this.newLabel,
  });

  @override
  String get description =>
      newLabel.isEmpty ? 'Clear color label' : 'Set $newLabel label';

  @override
  Future<void> execute(WidgetRef ref) async {
    await GalleryBridge.setColorLabel(itemId, newLabel);
    await _refreshItem(ref, itemId);
  }

  @override
  Future<void> undo(WidgetRef ref) async {
    await GalleryBridge.setColorLabel(itemId, oldLabel);
    await _refreshItem(ref, itemId);
  }
}

// Batch versions
class BatchSetRatingCommand extends GalleryCommand {
  final List<(int, int)> itemsWithOldRatings; // (itemId, oldRating)
  final int newRating;

  BatchSetRatingCommand({
    required this.itemsWithOldRatings,
    required this.newRating,
  });

  @override
  String get description =>
      'Set rating to $newRating ★ for ${itemsWithOldRatings.length} items';

  @override
  Future<void> execute(WidgetRef ref) async {
    for (final (id, _) in itemsWithOldRatings) {
      await GalleryBridge.setRating(id, newRating);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }

  @override
  Future<void> undo(WidgetRef ref) async {
    for (final (id, oldRating) in itemsWithOldRatings) {
      await GalleryBridge.setRating(id, oldRating);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }
}

class BatchSetFlagCommand extends GalleryCommand {
  final List<(int, int)> itemsWithOldFlags;
  final int newFlag;

  BatchSetFlagCommand({
    required this.itemsWithOldFlags,
    required this.newFlag,
  });

  static const _labels = {0: 'Unflag', 1: 'Pick', 2: 'Reject'};

  @override
  String get description =>
      '${_labels[newFlag] ?? 'Flag'} ${itemsWithOldFlags.length} items';

  @override
  Future<void> execute(WidgetRef ref) async {
    for (final (id, _) in itemsWithOldFlags) {
      await GalleryBridge.setFlag(id, newFlag);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }

  @override
  Future<void> undo(WidgetRef ref) async {
    for (final (id, oldFlag) in itemsWithOldFlags) {
      await GalleryBridge.setFlag(id, oldFlag);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }
}

class BatchSetColorLabelCommand extends GalleryCommand {
  final List<(int, String)> itemsWithOldLabels;
  final String newLabel;

  BatchSetColorLabelCommand({
    required this.itemsWithOldLabels,
    required this.newLabel,
  });

  @override
  String get description => newLabel.isEmpty
      ? 'Clear label on ${itemsWithOldLabels.length} items'
      : 'Set $newLabel label on ${itemsWithOldLabels.length} items';

  @override
  Future<void> execute(WidgetRef ref) async {
    for (final (id, _) in itemsWithOldLabels) {
      await GalleryBridge.setColorLabel(id, newLabel);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }

  @override
  Future<void> undo(WidgetRef ref) async {
    for (final (id, oldLabel) in itemsWithOldLabels) {
      await GalleryBridge.setColorLabel(id, oldLabel);
    }
    ref.read(mediaItemsProvider.notifier).refresh();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Undo/redo state
// ─────────────────────────────────────────────────────────────────────────────

const int _maxHistory = 200;

class UndoRedoState {
  final List<GalleryCommand> undoStack;
  final List<GalleryCommand> redoStack;

  const UndoRedoState({
    required this.undoStack,
    required this.redoStack,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  String? get undoDescription =>
      undoStack.isEmpty ? null : undoStack.last.description;
  String? get redoDescription =>
      redoStack.isEmpty ? null : redoStack.last.description;

  UndoRedoState push(GalleryCommand cmd) {
    final newUndo = [...undoStack, cmd];
    if (newUndo.length > _maxHistory) newUndo.removeAt(0);
    return UndoRedoState(undoStack: newUndo, redoStack: []);
  }

  UndoRedoState popUndo() {
    if (undoStack.isEmpty) return this;
    final cmd = undoStack.last;
    return UndoRedoState(
      undoStack: undoStack.sublist(0, undoStack.length - 1),
      redoStack: [...redoStack, cmd],
    );
  }

  UndoRedoState popRedo() {
    if (redoStack.isEmpty) return this;
    final cmd = redoStack.last;
    return UndoRedoState(
      undoStack: [...undoStack, cmd],
      redoStack: redoStack.sublist(0, redoStack.length - 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class UndoRedoNotifier extends Notifier<UndoRedoState> {
  @override
  UndoRedoState build() =>
      const UndoRedoState(undoStack: [], redoStack: []);

  /// Execute a command and push it onto the undo stack.
  Future<void> execute(GalleryCommand cmd) async {
    await cmd.execute(ref);
    state = state.push(cmd);
  }

  /// Undo the last command.
  Future<void> undo() async {
    if (!state.canUndo) return;
    final cmd = state.undoStack.last;
    state = state.popUndo();
    await cmd.undo(ref);
  }

  /// Redo the last undone command.
  Future<void> redo() async {
    if (!state.canRedo) return;
    final cmd = state.redoStack.last;
    state = state.popRedo();
    await cmd.execute(ref);
  }

  void clear() {
    state = const UndoRedoState(undoStack: [], redoStack: []);
  }
}

final undoRedoProvider =
    NotifierProvider<UndoRedoNotifier, UndoRedoState>(UndoRedoNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _refreshItem(WidgetRef ref, int id) async {
  final updated = await GalleryBridge.getMediaItem(id);
  if (updated != null) {
    ref.read(mediaItemsProvider.notifier).updateItem(updated);
  }
}
