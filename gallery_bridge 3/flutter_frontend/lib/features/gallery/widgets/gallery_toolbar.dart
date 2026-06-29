// lib/features/gallery/widgets/gallery_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';
import '../gallery_screen.dart' show ExtendedViewMode;

class GalleryToolbar extends ConsumerWidget {
  final ExtendedViewMode extMode;
  final ValueChanged<ExtendedViewMode> onViewChange;
  const GalleryToolbar({super.key, required this.extMode, required this.onViewChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns   = ref.watch(gridColumnsProvider);
    final items     = ref.watch(mediaItemsProvider).valueOrNull ?? [];
    final selection = ref.watch(selectionProvider);
    final showCols  = extMode == ExtendedViewMode.grid || extMode == ExtendedViewMode.list;

    return Container(
      height: AppTheme.toolbarHeight,
      color: AppTheme.bg1,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        _SearchBox(),
        const Spacer(),
        if (selection.length > 1)
          Padding(padding: const EdgeInsets.only(right: 10),
            child: Text('${selection.length} selected', style: const TextStyle(fontSize:11,color:AppTheme.accent,fontFamily:'Inter'))),
        Text('${items.length} items', style: const TextStyle(fontSize:11,color:AppTheme.textMuted,fontFamily:'JetBrains Mono')),
        const SizedBox(width: 10),
        _Vline(),
        if (showCols) ...[
          const Icon(Icons.grid_on, size: 12, color: AppTheme.textMuted),
          SizedBox(width: 80, child: Slider(value: columns.toDouble(), min: 2, max: 10, divisions: 8, activeColor: AppTheme.accent, inactiveColor: AppTheme.bg3, onChanged: (v) => ref.read(gridColumnsProvider.notifier).state = v.round())),
          _Vline(),
        ],
        _VMBtn(icon: Icons.grid_view,    active: extMode == ExtendedViewMode.grid,      onTap: () => onViewChange(ExtendedViewMode.grid),      tip: 'Grid (G)'),
        _VMBtn(icon: Icons.view_list,    active: extMode == ExtendedViewMode.list,      onTap: () => onViewChange(ExtendedViewMode.list),      tip: 'List (L)'),
        _VMBtn(icon: Icons.view_column,  active: extMode == ExtendedViewMode.filmstrip, onTap: () => onViewChange(ExtendedViewMode.filmstrip), tip: 'Filmstrip'),
        _VMBtn(icon: Icons.calendar_today, active: extMode == ExtendedViewMode.timeline, onTap: () => onViewChange(ExtendedViewMode.timeline), tip: 'Timeline (T)'),
        _VMBtn(icon: Icons.map_outlined, active: extMode == ExtendedViewMode.map,       onTap: () => onViewChange(ExtendedViewMode.map),       tip: 'Map (M)'),
      ]),
    );
  }
}

class _Vline extends StatelessWidget {
  @override Widget build(BuildContext context) => Container(width:1, height:20, margin: const EdgeInsets.symmetric(horizontal:6), color: AppTheme.border);
}

class _VMBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String tip;
  const _VMBtn({required this.icon, required this.active, required this.onTap, required this.tip});
  @override
  Widget build(BuildContext context) => Tooltip(message: tip, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(4),
    child: AnimatedContainer(duration: const Duration(milliseconds: 80), width:28, height:28,
      decoration: BoxDecoration(color: active ? AppTheme.bg3 : Colors.transparent, borderRadius: BorderRadius.circular(4)),
      child: Icon(icon, size: 15, color: active ? AppTheme.accent : AppTheme.textSecondary))));
}

class _SearchBox extends ConsumerStatefulWidget {
  @override ConsumerState<_SearchBox> createState() => _SearchBoxState();
}
class _SearchBoxState extends ConsumerState<_SearchBox> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(width: 200, height: 28,
    child: TextField(controller: _ctrl,
      style: const TextStyle(fontSize:12, color:AppTheme.textPrimary, fontFamily:'Inter'),
      decoration: InputDecoration(
        hintText: 'Search filenames…',
        hintStyle: const TextStyle(fontSize:12, color:AppTheme.textMuted),
        prefixIcon: const Icon(Icons.search, size:14, color:AppTheme.textMuted),
        suffixIcon: _ctrl.text.isNotEmpty ? InkWell(onTap:(){ _ctrl.clear(); ref.read(galleryFilterProvider.notifier).state = ref.read(galleryFilterProvider).copyWith(searchQuery: ''); setState((){}); }, child: const Icon(Icons.close, size:13, color:AppTheme.textMuted)) : null,
        filled: true, fillColor: AppTheme.bg2, contentPadding: EdgeInsets.zero,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color:AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color:AppTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color:AppTheme.accent)),
      ),
      onChanged: (v) { setState((){}); ref.read(galleryFilterProvider.notifier).state = ref.read(galleryFilterProvider).copyWith(searchQuery: v); },
    ));
}

// ── FilterStrip ───────────────────────────────────────────────────────────────
class FilterStrip extends ConsumerWidget {
  const FilterStrip({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(galleryFilterProvider);
    if (!filter.isActive) return const SizedBox.shrink();
    return Container(height: 30, color: AppTheme.bg2,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        const Icon(Icons.filter_list, size:12, color:AppTheme.accent),
        const SizedBox(width: 5),
        const Text('Filtered:', style: TextStyle(fontSize:11, color:AppTheme.accent)),
        const SizedBox(width: 8),
        if (filter.flagFilter != null)
          _Chip(label: filter.flagFilter==1?'Picked':'Rejected', onRemove: () => ref.read(galleryFilterProvider.notifier).state = filter.copyWith(flagFilter: null)),
        if (filter.ratingMin != null)
          _Chip(label: '${filter.ratingMin}+ ★', onRemove: () => ref.read(galleryFilterProvider.notifier).state = filter.copyWith(ratingMin: null)),
        if (filter.colorLabel != null)
          _Chip(label: filter.colorLabel!, onRemove: () => ref.read(galleryFilterProvider.notifier).state = filter.copyWith(colorLabel: null)),
        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty)
          _Chip(label: '"${filter.searchQuery}"', onRemove: () => ref.read(galleryFilterProvider.notifier).state = filter.copyWith(searchQuery: '')),
        const Spacer(),
        InkWell(onTap: () => ref.read(galleryFilterProvider.notifier).state = const GalleryFilter(),
          child: const Text('Clear all', style: TextStyle(fontSize:11, color:AppTheme.textMuted))),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _Chip({required this.label, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(right:6),
    padding: const EdgeInsets.symmetric(horizontal:8, vertical:2),
    decoration: BoxDecoration(color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.accent, width:.5)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize:10, color:AppTheme.accent)),
      const SizedBox(width: 3),
      GestureDetector(onTap: onRemove, child: const Icon(Icons.close, size:10, color:AppTheme.accent)),
    ]));
}

// ── IndexingProgressBar ───────────────────────────────────────────────────────
class IndexingProgressBar extends ConsumerWidget {
  const IndexingProgressBar({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(indexingProvider);
    if (!state.isIndexing) return const SizedBox.shrink();
    return Container(color: AppTheme.bg1, padding: const EdgeInsets.symmetric(horizontal:12, vertical:5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const SizedBox(width:12, height:12, child: CircularProgressIndicator(strokeWidth:1.5, color:AppTheme.accent)),
          const SizedBox(width: 8),
          Expanded(child: Text('Indexing: ${state.currentFile?.split('/').last ?? '…'}', style: const TextStyle(fontSize:11, color:AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
          Text('${state.indexed} / ${state.total}', style: const TextStyle(fontSize:10, color:AppTheme.textMuted, fontFamily:'JetBrains Mono')),
        ]),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: state.progress > 0 ? state.progress : null, backgroundColor: AppTheme.bg3, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent), minHeight: 2)),
      ]));
  }
}

// ── FilmstripView ─────────────────────────────────────────────────────────────
class FilmstripView extends ConsumerWidget {
  const FilmstripView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(mediaItemsProvider);
    final activeId   = ref.watch(activeItemIdProvider);
    return Column(children: [
      Expanded(child: itemsAsync.maybeWhen(
        data: (items) {
          final active = activeId != null ? items.where((i) => i.id == activeId).firstOrNull : items.firstOrNull;
          if (active == null) return const SizedBox.shrink();
          return Container(color: AppTheme.bg0, child: active.thumbnailPath != null
            ? Image.file(scale:1, fit: BoxFit.contain, errorBuilder:(_,__,___)=>const Icon(Icons.broken_image, color:AppTheme.textMuted))
            : const Center(child: Icon(Icons.image_not_supported_outlined, size:48, color:AppTheme.textMuted)));
        },
        orElse: () => const SizedBox.shrink(),
      )),
      Container(height: AppTheme.filmstripHeight, color: AppTheme.bg1,
        child: itemsAsync.maybeWhen(
          data: (items) => ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal:4, vertical:4),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              final isActive = item.id == activeId;
              return GestureDetector(
                onTap: () { ref.read(activeItemIdProvider.notifier).state = item.id; ref.read(selectionProvider.notifier).selectOnly(item.id); },
                child: AnimatedContainer(duration: const Duration(milliseconds:80),
                  width: AppTheme.filmstripHeight - 8,
                  margin: const EdgeInsets.symmetric(horizontal:2),
                  decoration: BoxDecoration(border: Border.all(color: isActive ? AppTheme.accent : Colors.transparent, width:2), borderRadius: BorderRadius.circular(2)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(1),
                    child: item.thumbnailPath != null
                      ? Image.file(scale:1, fit:BoxFit.cover, errorBuilder:(_,__,___)=>Container(color:AppTheme.bg2))
                      : Container(color: AppTheme.bg2))),
              );
            },
          ),
          orElse: () => const SizedBox.shrink(),
        )),
    ]);
  }
}
