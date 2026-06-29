// lib/features/gallery/widgets/folder_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../core/bridge/gallery_bridge.dart';
import '../../../shared/theme/app_theme.dart';
import '../gallery_screen.dart' show ExtendedViewMode;
import 'collections_panel.dart';

class FolderSidebar extends ConsumerWidget {
  final ExtendedViewMode extMode;
  final ValueChanged<ExtendedViewMode> onViewChange;

  const FolderSidebar({
    super.key,
    required this.extMode,
    required this.onViewChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foldersAsync  = ref.watch(folderListProvider);
    final currentId     = ref.watch(currentFolderIdProvider);
    final indexingState = ref.watch(indexingProvider);

    return Container(
      color: AppTheme.bg1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────────────
          _SidebarHeader(onAddFolder: () => _pickAndAddFolder(context, ref)),
          const Divider(height: 1, color: AppTheme.border),

          // ── Views ──────────────────────────────────────────────────
          const _SectionLabel('VIEWS'),
          _NavRow(icon: Icons.grid_view_rounded,  label: 'All Photos',  active: extMode == ExtendedViewMode.grid,      onTap: () => onViewChange(ExtendedViewMode.grid)),
          _NavRow(icon: Icons.calendar_today,     label: 'Timeline',    active: extMode == ExtendedViewMode.timeline,  onTap: () => onViewChange(ExtendedViewMode.timeline)),
          _NavRow(icon: Icons.map_outlined,       label: 'Map',         active: extMode == ExtendedViewMode.map,       onTap: () => onViewChange(ExtendedViewMode.map)),
          _NavRow(icon: Icons.compare,            label: 'Compare',     active: extMode == ExtendedViewMode.compare,   onTap: () => onViewChange(ExtendedViewMode.compare)),
          _NavRow(icon: Icons.bar_chart_rounded,  label: 'Analytics',   active: extMode == ExtendedViewMode.analytics, onTap: () => onViewChange(ExtendedViewMode.analytics)),
          _NavRow(icon: Icons.tune,               label: 'Develop',     active: extMode == ExtendedViewMode.develop,   onTap: () => onViewChange(ExtendedViewMode.develop)),
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppTheme.border),

          // ── Smart collections ──────────────────────────────────────
          const _SectionLabel('SMART'),
          _SmartRow(dot: AppTheme.flagGreen,  label: 'Picked',   countId: 'picked',   onTap: () { ref.read(galleryFilterProvider.notifier).state = const GalleryFilter(flagFilter: 1); ref.read(currentFolderIdProvider.notifier).state = null; }),
          _SmartRow(dot: AppTheme.accent,     label: '4+ Stars',                       onTap: () { ref.read(galleryFilterProvider.notifier).state = const GalleryFilter(ratingMin: 4);  ref.read(currentFolderIdProvider.notifier).state = null; }),
          _SmartRow(dot: AppTheme.flagRed,    label: 'Rejected', countId: 'rejected',  onTap: () { ref.read(galleryFilterProvider.notifier).state = const GalleryFilter(flagFilter: 2); ref.read(currentFolderIdProvider.notifier).state = null; }),
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppTheme.border),

          // ── Folders ────────────────────────────────────────────────
          const _SectionLabel('FOLDERS'),
          Flexible(
            child: foldersAsync.when(
              loading: () => const Center(child: SizedBox(width:14, height:14, child: CircularProgressIndicator(strokeWidth:1.5, color:AppTheme.accent))),
              error: (e, _) => Padding(padding: const EdgeInsets.all(10), child: Text('$e', style: const TextStyle(fontSize:10, color:AppTheme.flagRed))),
              data: (folders) => ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (_, i) => _FolderTile(
                  folder: folders[i],
                  isSelected: folders[i].id == currentId,
                  isIndexing: indexingState.isIndexing && indexingState.currentFolder == folders[i].path,
                  onTap: () { ref.read(currentFolderIdProvider.notifier).state = folders[i].id; ref.read(galleryFilterProvider.notifier).state = const GalleryFilter(); onViewChange(ExtendedViewMode.grid); },
                  onRemove: () => ref.read(folderListProvider.notifier).removeFolder(folders[i].id),
                  onReindex: () => _startReindex(ref, folders[i]),
                ),
              ),
            ),
          ),

          // ── Collections ────────────────────────────────────────────
          const Divider(height: 1, color: AppTheme.border),
          const Expanded(child: SingleChildScrollView(child: CollectionsPanel())),

          // ── Stats footer ───────────────────────────────────────────
          const Divider(height: 1, color: AppTheme.border),
          const _StatsFooter(),
        ],
      ),
    );
  }

  Future<void> _pickAndAddFolder(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Select a folder to index');
    if (result == null) return;
    await ref.read(folderListProvider.notifier).addFolder(result);
    _startReindex(ref, GFolder(id: 0, path: result, displayName: result, itemCount: 0));
  }

  void _startReindex(WidgetRef ref, GFolder folder) {
    ref.read(indexingProvider.notifier).startIndexing(folder.path, GalleryBridge.thumbCacheDir);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final VoidCallback onAddFolder;
  const _SidebarHeader({required this.onAddFolder});
  @override
  Widget build(BuildContext context) => Container(
    height: AppTheme.toolbarHeight,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      const Icon(Icons.photo_library, size: 14, color: AppTheme.accent),
      const SizedBox(width: 8),
      const Text('GalleryBridge', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontFamily: 'Inter')),
      const Spacer(),
      Tooltip(message: 'Add Folder', child: InkWell(onTap: onAddFolder, borderRadius: BorderRadius.circular(4), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 16, color: AppTheme.textSecondary)))),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 3),
    child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 1.3, fontFamily: 'Inter')),
  );
}

class _NavRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavRow({required this.icon, required this.label, required this.active, required this.onTap});
  @override State<_NavRow> createState() => _NavRowState();
}
class _NavRowState extends State<_NavRow> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(()=>_hovered=true),
    onExit:  (_) => setState(()=>_hovered=false),
    child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      color: widget.active ? AppTheme.bg3 : _hovered ? AppTheme.bg2 : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(children: [
        Icon(widget.icon, size: 13, color: widget.active ? AppTheme.accent : AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(widget.label, style: TextStyle(fontSize: 12, color: widget.active ? AppTheme.textPrimary : AppTheme.textSecondary, fontFamily: 'Inter', fontWeight: widget.active ? FontWeight.w500 : FontWeight.w400)),
      ]),
    )),
  );
}

class _SmartRow extends StatelessWidget {
  final Color dot;
  final String label;
  final String? countId;
  final VoidCallback onTap;
  const _SmartRow({required this.dot, required this.label, this.countId, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: dot)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontFamily: 'Inter')),
      ]),
    ),
  );
}

class _FolderTile extends StatefulWidget {
  final GFolder folder;
  final bool isSelected, isIndexing;
  final VoidCallback onTap, onRemove, onReindex;
  const _FolderTile({required this.folder, required this.isSelected, required this.isIndexing, required this.onTap, required this.onRemove, required this.onReindex});
  @override State<_FolderTile> createState() => _FolderTileState();
}
class _FolderTileState extends State<_FolderTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(()=>_hovered=true),
    onExit:  (_) => setState(()=>_hovered=false),
    child: GestureDetector(
      onTap: widget.onTap,
      onSecondaryTapUp: (d) => _menu(context, d.globalPosition),
      child: AnimatedContainer(duration: const Duration(milliseconds: 80),
        color: widget.isSelected ? AppTheme.bg3 : _hovered ? AppTheme.bg2 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(children: [
          widget.isIndexing
            ? const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:1.5,color:AppTheme.accent))
            : Icon(Icons.folder, size: 14, color: widget.isSelected ? AppTheme.accent : AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.folder.displayName, style: TextStyle(fontSize: 12, color: widget.isSelected ? AppTheme.textPrimary : AppTheme.textSecondary, fontFamily: 'Inter', fontWeight: widget.isSelected ? FontWeight.w500 : FontWeight.w400), overflow: TextOverflow.ellipsis),
            Text('${widget.folder.itemCount} items', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontFamily: 'Inter')),
          ])),
        ]),
      ),
    ),
  );

  void _menu(BuildContext ctx, Offset pos) async {
    final r = await showMenu<String>(context: ctx, position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx, pos.dy), color: AppTheme.bg2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: AppTheme.border)), items: [
      const PopupMenuItem(value:'reindex', height:32, child: Text('Re-index', style: TextStyle(fontSize:12, color:AppTheme.textPrimary))),
      const PopupMenuItem(value:'remove',  height:32, child: Text('Remove',   style: TextStyle(fontSize:12, color:AppTheme.flagRed))),
    ]);
    if (r == 'reindex') widget.onReindex();
    if (r == 'remove')  widget.onRemove();
  }
}

class _StatsFooter extends ConsumerWidget {
  const _StatsFooter();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(galleryStatsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Text(stats.maybeWhen(data:(s)=>'${s.totalItems} items', orElse:()=>'—'), style: const TextStyle(fontSize:10,color:AppTheme.textMuted,fontFamily:'JetBrains Mono')),
        const Spacer(),
        Text(stats.maybeWhen(data:(s)=>s.totalSizeFormatted, orElse:()=>'—'), style: const TextStyle(fontSize:10,color:AppTheme.textMuted,fontFamily:'JetBrains Mono')),
      ]),
    );
  }
}
