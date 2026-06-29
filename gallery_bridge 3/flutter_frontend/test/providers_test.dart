// flutter_frontend/test/providers_test.dart
//
// Unit tests for all Riverpod providers.
// Tests run without the Rust engine by verifying stub/default behaviour.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gallery_bridge/core/providers/gallery_providers.dart';
import 'package:gallery_bridge/core/undo/undo_redo.dart';
import 'package:gallery_bridge/core/models/gallery_models.dart';

void main() {
  group('GalleryFilter', () {
    test('default filter is not active', () {
      const f = GalleryFilter();
      expect(f.isActive, isFalse);
    });

    test('flagFilter makes filter active', () {
      const f = GalleryFilter(flagFilter: 1);
      expect(f.isActive, isTrue);
    });

    test('ratingMin makes filter active', () {
      const f = GalleryFilter(ratingMin: 4);
      expect(f.isActive, isTrue);
    });

    test('colorLabel makes filter active', () {
      const f = GalleryFilter(colorLabel: 'red');
      expect(f.isActive, isTrue);
    });

    test('searchQuery makes filter active', () {
      const f = GalleryFilter(searchQuery: 'vacation');
      expect(f.isActive, isTrue);
    });

    test('copyWith preserves unchanged fields', () {
      const f = GalleryFilter(ratingMin: 3, colorLabel: 'blue');
      final f2 = f.copyWith(flagFilter: 1);
      expect(f2.ratingMin, equals(3));
      expect(f2.colorLabel, equals('blue'));
      expect(f2.flagFilter, equals(1));
    });

    test('copyWith can clear fields with null', () {
      const f = GalleryFilter(ratingMin: 3);
      final f2 = f.copyWith(ratingMin: null);
      expect(f2.ratingMin, isNull);
    });
  });

  group('UndoRedoState', () {
    test('initial state has empty stacks', () {
      const state = UndoRedoState(undoStack: [], redoStack: []);
      expect(state.canUndo, isFalse);
      expect(state.canRedo, isFalse);
    });

    test('canUndo after push', () {
      const initial = UndoRedoState(undoStack: [], redoStack: []);
      final cmd = _MockCommand('test action');
      final next = initial.push(cmd);
      expect(next.canUndo, isTrue);
      expect(next.undoDescription, equals('test action'));
    });

    test('canRedo after undo', () {
      const initial = UndoRedoState(undoStack: [], redoStack: []);
      final cmd = _MockCommand('test action');
      final pushed = initial.push(cmd);
      final undone = pushed.popUndo();
      expect(undone.canRedo, isTrue);
      expect(undone.canUndo, isFalse);
    });

    test('redo re-adds to undoStack', () {
      const initial = UndoRedoState(undoStack: [], redoStack: []);
      final cmd = _MockCommand('test');
      final withCmd = initial.push(cmd);
      final undone = withCmd.popUndo();
      final redone = undone.popRedo();
      expect(redone.canUndo, isTrue);
      expect(redone.canRedo, isFalse);
    });

    test('push clears redo stack', () {
      const initial = UndoRedoState(undoStack: [], redoStack: []);
      final cmd1 = _MockCommand('first');
      final cmd2 = _MockCommand('second');
      final withCmd1 = initial.push(cmd1);
      final undone = withCmd1.popUndo();
      expect(undone.canRedo, isTrue);
      // Pushing new command should clear redo
      final withCmd2 = undone.push(cmd2);
      expect(withCmd2.canRedo, isFalse);
    });

    test('history capped at 200', () {
      var state = const UndoRedoState(undoStack: [], redoStack: []);
      for (int i = 0; i < 250; i++) {
        state = state.push(_MockCommand('cmd $i'));
      }
      expect(state.undoStack.length, lessThanOrEqualTo(200));
    });
  });

  group('GMediaItem helpers', () {
    const item = GMediaItem(
      id: 1, folderId: 1, filePath: '/photos/DSC_001.jpg',
      fileName: 'DSC_001.jpg', fileSize: 5_000_000,
      width: 6000, height: 4000, mimeType: 'image/jpeg',
      rating: 3, flag: 1, isRaw: false, indexedAt: 0, modifiedAt: 0,
    );

    test('aspectRatio formats correctly', () {
      expect(item.aspectRatio, equals('6000×4000'));
    });

    test('fileSizeFormatted shows MB', () {
      expect(item.fileSizeFormatted, contains('MB'));
    });

    test('colorLabel defaults to empty string', () {
      expect(item.colorLabel, equals(''));
    });
  });

  group('GGalleryStats helpers', () {
    const stats = GGalleryStats(
      totalItems: 1000,
      totalFolders: 5,
      totalSizeBytes: 2_500_000_000,
      rawCount: 200,
      flaggedCount: 50,
      rejectedCount: 30,
    );

    test('totalSizeFormatted shows GB for large sizes', () {
      expect(stats.totalSizeFormatted, contains('GB'));
    });

    test('small size shows MB', () {
      const small = GGalleryStats(
        totalItems: 10, totalFolders: 1, totalSizeBytes: 50_000_000,
        rawCount: 0, flaggedCount: 0, rejectedCount: 0,
      );
      expect(small.totalSizeFormatted, contains('MB'));
    });
  });

  group('GSlideshowConfig helpers', () {
    const config = GSlideshowConfig(
      title: 'My Slideshow',
      slideCount: 30,
      totalDurationMs: 125_000,
      json: '{}',
    );

    test('durationFormatted shows minutes:seconds', () {
      expect(config.durationFormatted, equals('2:05'));
    });

    test('zero duration formats correctly', () {
      const zero = GSlideshowConfig(title:'', slideCount:0, totalDurationMs:0, json:'{}');
      expect(zero.durationFormatted, equals('0:00'));
    });
  });

  group('SelectionNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial selection is empty', () {
      final sel = container.read(selectionProvider);
      expect(sel, isEmpty);
    });

    test('toggle adds item', () {
      container.read(selectionProvider.notifier).toggle(1);
      expect(container.read(selectionProvider), contains(1));
    });

    test('toggle same item removes it', () {
      container.read(selectionProvider.notifier).toggle(1);
      container.read(selectionProvider.notifier).toggle(1);
      expect(container.read(selectionProvider), isEmpty);
    });

    test('selectOnly replaces selection', () {
      container.read(selectionProvider.notifier).toggle(1);
      container.read(selectionProvider.notifier).toggle(2);
      container.read(selectionProvider.notifier).selectOnly(3);
      final sel = container.read(selectionProvider);
      expect(sel, equals({3}));
    });

    test('clear empties selection', () {
      container.read(selectionProvider.notifier).toggle(1);
      container.read(selectionProvider.notifier).toggle(2);
      container.read(selectionProvider.notifier).clear();
      expect(container.read(selectionProvider), isEmpty);
    });

    test('selectAll sets all ids', () {
      container.read(selectionProvider.notifier).selectAll([1, 2, 3, 4, 5]);
      expect(container.read(selectionProvider).length, equals(5));
    });

    test('addRange extends current selection', () {
      container.read(selectionProvider.notifier).toggle(1);
      container.read(selectionProvider.notifier).addRange([2, 3, 4]);
      expect(container.read(selectionProvider).length, equals(4));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock command for undo/redo tests
// ─────────────────────────────────────────────────────────────────────────────
class _MockCommand extends GalleryCommand {
  final String _desc;
  int executeCount = 0;
  int undoCount = 0;

  _MockCommand(this._desc);

  @override
  String get description => _desc;

  @override
  Future<void> execute(WidgetRef ref) async => executeCount++;

  @override
  Future<void> undo(WidgetRef ref) async => undoCount++;
}
