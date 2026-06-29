// lib/features/gallery/gallery_screen.dart — fully wired main screen v3.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/gallery_providers.dart';
import '../../core/undo/undo_redo.dart';
import '../../shared/theme/app_theme.dart';
import 'widgets/folder_sidebar.dart';
import 'widgets/gallery_toolbar.dart';
import 'widgets/media_grid.dart';
import 'widgets/metadata_panel.dart';
import 'widgets/indexing_progress_bar.dart';
import 'widgets/filmstrip.dart';
import 'widgets/filter_strip.dart';
import 'widgets/batch_operations_panel.dart';
import 'widgets/timeline_view.dart';
import 'widgets/map_view.dart';
import 'widgets/undo_history_panel.dart';
import '../analytics/analytics_screen.dart';
import '../compare/compare_view.dart';
import '../develop/develop_panel.dart';

enum ExtendedViewMode { grid, list, filmstrip, timeline, map, compare, analytics, develop }
final extendedViewModeProvider = StateProvider<ExtendedViewMode>((ref) => ExtendedViewMode.grid);

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode     = ref.watch(extendedViewModeProvider);
    final historyOn = ref.watch(historyPanelVisibleProvider);
    return CallbackShortcuts(
      bindings: _shortcuts(ref),
      child: Focus(autofocus: true, child: Scaffold(backgroundColor: AppTheme.bg0,
        body: Column(children: [
          const IndexingProgressBar(),
          Expanded(child: Row(children: [
            SizedBox(width: AppTheme.sidebarWidth,
              child: FolderSidebar(extMode: mode, onViewChange: (m) => ref.read(extendedViewModeProvider.notifier).state = m)),
            const VerticalDivider(width:1,color:AppTheme.border),
            Expanded(child: Column(children: [
              GalleryToolbar(extMode: mode, onViewChange: (m) => ref.read(extendedViewModeProvider.notifier).state = m),
              const FilterStrip(),
              Expanded(child: _content(mode)),
              const BatchOperationsPanel(),
            ])),
            const VerticalDivider(width:1,color:AppTheme.border),
            if (mode == ExtendedViewMode.develop)
              SizedBox(width: AppTheme.metaPanelWidth + 40, child: const DevelopPanel())
            else
              SizedBox(width: AppTheme.metaPanelWidth, child: const MetadataPanel()),
            if (historyOn) ...[const VerticalDivider(width:1,color:AppTheme.border), const UndoHistoryPanel()],
          ])),
        ]),
      )),
    );
  }

  Widget _content(ExtendedViewMode m) => switch (m) {
    ExtendedViewMode.grid      => const MediaGrid(),
    ExtendedViewMode.list      => const MediaGrid(),
    ExtendedViewMode.filmstrip => const FilmstripView(),
    ExtendedViewMode.timeline  => const TimelineView(),
    ExtendedViewMode.map       => const MapView(),
    ExtendedViewMode.compare   => const CompareView(),
    ExtendedViewMode.analytics => const AnalyticsScreen(),
    ExtendedViewMode.develop   => const MediaGrid(),
  };

  Map<ShortcutActivator, VoidCallback> _shortcuts(WidgetRef ref) => {
    const SingleActivator(LogicalKeyboardKey.keyP): () => _flag(ref, 1),
    const SingleActivator(LogicalKeyboardKey.keyX): () => _flag(ref, 2),
    const SingleActivator(LogicalKeyboardKey.keyU): () => _flag(ref, 0),
    const SingleActivator(LogicalKeyboardKey.digit1): () => _rate(ref, 1),
    const SingleActivator(LogicalKeyboardKey.digit2): () => _rate(ref, 2),
    const SingleActivator(LogicalKeyboardKey.digit3): () => _rate(ref, 3),
    const SingleActivator(LogicalKeyboardKey.digit4): () => _rate(ref, 4),
    const SingleActivator(LogicalKeyboardKey.digit5): () => _rate(ref, 5),
    const SingleActivator(LogicalKeyboardKey.digit0): () => _rate(ref, 0),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () async => ref.read(undoRedoProvider.notifier).undo(),
    SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true): () async => ref.read(undoRedoProvider.notifier).redo(),
    const SingleActivator(LogicalKeyboardKey.keyG): () => ref.read(extendedViewModeProvider.notifier).state = ExtendedViewMode.grid,
    const SingleActivator(LogicalKeyboardKey.keyL): () => ref.read(extendedViewModeProvider.notifier).state = ExtendedViewMode.list,
    const SingleActivator(LogicalKeyboardKey.keyT): () => ref.read(extendedViewModeProvider.notifier).state = ExtendedViewMode.timeline,
    const SingleActivator(LogicalKeyboardKey.keyM): () => ref.read(extendedViewModeProvider.notifier).state = ExtendedViewMode.map,
    const SingleActivator(LogicalKeyboardKey.escape): () { ref.read(selectionProvider.notifier).clear(); ref.read(extendedViewModeProvider.notifier).state = ExtendedViewMode.grid; },
    SingleActivator(LogicalKeyboardKey.keyA, meta: true): () { final items = ref.read(mediaItemsProvider).valueOrNull ?? []; ref.read(selectionProvider.notifier).selectAll(items.map((i) => i.id).toList()); },
    SingleActivator(LogicalKeyboardKey.keyH, meta: true): () => ref.read(historyPanelVisibleProvider.notifier).state = !ref.read(historyPanelVisibleProvider),
  };

  void _flag(WidgetRef ref, int flag) {
    final sel = ref.read(selectionProvider);
    final items = ref.read(mediaItemsProvider).valueOrNull ?? [];
    final changed = items.where((i) => sel.contains(i.id)).map((i) => (i.id, i.flag)).toList();
    if (changed.isEmpty) return;
    ref.read(undoRedoProvider.notifier).execute(BatchSetFlagCommand(itemsWithOldFlags: changed, newFlag: flag));
  }

  void _rate(WidgetRef ref, int rating) {
    final sel = ref.read(selectionProvider);
    final items = ref.read(mediaItemsProvider).valueOrNull ?? [];
    final changed = items.where((i) => sel.contains(i.id)).map((i) => (i.id, i.rating)).toList();
    if (changed.isEmpty) return;
    ref.read(undoRedoProvider.notifier).execute(BatchSetRatingCommand(itemsWithOldRatings: changed, newRating: rating));
  }
}
