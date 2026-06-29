// lib/features/gallery/widgets/collections_panel.dart
//
// Collections sidebar panel.
// Shows all user-created albums. Supports:
//   - Creating new collections
//   - Drag-to-collect (drag selected items from grid onto a collection)
//   - Selecting a collection as the active view
//   - Inline rename on double-click
//   - Delete with confirmation
//   - Item count badge
//   - Cover image (first item's thumbnail)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Collection model (local – mirrors Rust collections::Collection)
// ─────────────────────────────────────────────────────────────────────────────

class GCollection {
  final int id;
  final String name;
  final int itemCount;
  final String kind; // "album" | "smart"
  const GCollection({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.kind,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

class CollectionsNotifier extends Notifier<List<GCollection>> {
  @override
  List<GCollection> build() => [
        const GCollection(id: 1, name: 'Best of 2024',    itemCount: 24, kind: 'album'),
        const GCollection(id: 2, name: 'Portfolio',       itemCount: 12, kind: 'album'),
        const GCollection(id: 3, name: 'Client Delivery', itemCount: 38, kind: 'album'),
        const GCollection(id: 4, name: '5-Star Picks',    itemCount: 9,  kind: 'smart'),
      ];

  void add(String name) {
    final id = state.isEmpty ? 1 : state.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    state = [...state, GCollection(id: id, name: name, itemCount: 0, kind: 'album')];
  }

  void rename(int id, String newName) {
    state = [
      for (final c in state)
        if (c.id == id)
          GCollection(id: c.id, name: newName, itemCount: c.itemCount, kind: c.kind)
        else
          c
    ];
  }

  void remove(int id) {
    state = state.where((c) => c.id != id).toList();
  }

  void addItems(int collectionId, int count) {
    state = [
      for (final c in state)
        if (c.id == collectionId)
          GCollection(id: c.id, name: c.name, itemCount: c.itemCount + count, kind: c.kind)
        else
          c
    ];
  }
}

final collectionsProvider =
    NotifierProvider<CollectionsNotifier, List<GCollection>>(CollectionsNotifier.new);

final activeCollectionIdProvider = StateProvider<int?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────
// Panel widget
// ─────────────────────────────────────────────────────────────────────────────

class CollectionsPanel extends ConsumerStatefulWidget {
  const CollectionsPanel({super.key});

  @override
  ConsumerState<CollectionsPanel> createState() => _CollectionsPanelState();
}

class _CollectionsPanelState extends ConsumerState<CollectionsPanel> {
  int? _renamingId;
  final _renameCtrl = TextEditingController();
  int? _draggingOverId;

  @override
  void dispose() {
    _renameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections   = ref.watch(collectionsProvider);
    final activeId      = ref.watch(activeCollectionIdProvider);
    final selectedItems = ref.watch(selectionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: Row(
            children: [
              const Text('COLLECTIONS',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.3,
                      fontFamily: 'Inter')),
              const Spacer(),
              InkWell(
                onTap: () => _createCollection(context),
                child: const Icon(Icons.add, size: 14, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),

        // List
        for (final col in collections)
          DragTarget<Set<int>>(
            onWillAcceptWithDetails: (details) {
              setState(() => _draggingOverId = col.id);
              return details.data.isNotEmpty;
            },
            onLeave: (_) => setState(() => _draggingOverId = null),
            onAcceptWithDetails: (details) {
              setState(() => _draggingOverId = null);
              ref.read(collectionsProvider.notifier).addItems(col.id, details.data.length);
              _showDropFeedback(context, col.name, details.data.length);
            },
            builder: (ctx, candidateData, rejectedData) {
              final isDragOver = _draggingOverId == col.id;
              return _CollectionRow(
                collection: col,
                isActive: activeId == col.id,
                isDragOver: isDragOver,
                isRenaming: _renamingId == col.id,
                renameCtrl: _renameCtrl,
                onTap: () {
                  ref.read(activeCollectionIdProvider.notifier).state =
                      activeId == col.id ? null : col.id;
                },
                onDoubleTap: () {
                  setState(() {
                    _renamingId = col.id;
                    _renameCtrl.text = col.name;
                  });
                },
                onRenameSubmit: () {
                  final name = _renameCtrl.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(collectionsProvider.notifier).rename(col.id, name);
                  }
                  setState(() => _renamingId = null);
                },
                onRenameCancel: () => setState(() => _renamingId = null),
                onDelete: () => _confirmDelete(context, col),
              );
            },
          ),

        // Drop hint when items selected
        if (selectedItems.length >= 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('Drag ${selectedItems.length} items onto a collection',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted, fontFamily: 'Inter')),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _createCollection(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bg2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppTheme.border)),
        title: const Text('New Collection',
            style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textPrimary, fontFamily: 'Inter'),
          decoration: const InputDecoration(
            hintText: 'Collection name',
            hintStyle: TextStyle(color: AppTheme.textMuted),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(ctrl.text),
              child: const Text('Create',
                  style: TextStyle(color: AppTheme.accent))),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      ref.read(collectionsProvider.notifier).add(name.trim());
    }
  }

  Future<void> _confirmDelete(BuildContext context, GCollection col) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bg2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppTheme.border)),
        title: const Text('Delete collection?',
            style: TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
        content: Text('Remove "${col.name}"? Images are not deleted.',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: AppTheme.flagRed))),
        ],
      ),
    );
    if (ok == true) {
      ref.read(collectionsProvider.notifier).remove(col.id);
      if (ref.read(activeCollectionIdProvider) == col.id) {
        ref.read(activeCollectionIdProvider.notifier).state = null;
      }
    }
  }

  void _showDropFeedback(BuildContext context, String name, int count) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Added $count item${count == 1 ? '' : 's'} to "$name"'),
      backgroundColor: AppTheme.bg3,
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collection row tile
// ─────────────────────────────────────────────────────────────────────────────

class _CollectionRow extends StatefulWidget {
  final GCollection collection;
  final bool isActive;
  final bool isDragOver;
  final bool isRenaming;
  final TextEditingController renameCtrl;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onRenameSubmit;
  final VoidCallback onRenameCancel;
  final VoidCallback onDelete;

  const _CollectionRow({
    required this.collection,
    required this.isActive,
    required this.isDragOver,
    required this.isRenaming,
    required this.renameCtrl,
    required this.onTap,
    required this.onDoubleTap,
    required this.onRenameSubmit,
    required this.onRenameCancel,
    required this.onDelete,
  });

  @override
  State<_CollectionRow> createState() => _CollectionRowState();
}

class _CollectionRowState extends State<_CollectionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSmart = widget.collection.kind == 'smart';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: widget.isDragOver
              ? AppTheme.accentGlow
              : widget.isActive
                  ? AppTheme.bg3
                  : _hovered
                      ? AppTheme.bg2
                      : Colors.transparent,
          child: Row(
            children: [
              Icon(
                isSmart ? Icons.auto_awesome : Icons.photo_album_outlined,
                size: 13,
                color: widget.isActive ? AppTheme.accent : AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: widget.isRenaming
                    ? _RenameField(
                        ctrl: widget.renameCtrl,
                        onSubmit: widget.onRenameSubmit,
                        onCancel: widget.onRenameCancel,
                      )
                    : Text(
                        widget.collection.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isActive
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontFamily: 'Inter',
                          fontWeight: widget.isActive
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              // Item count badge
              if (!widget.isRenaming)
                Text(
                  '${widget.collection.itemCount}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontFamily: 'Inter'),
                ),
              // Drag-over indicator
              if (widget.isDragOver) ...[
                const SizedBox(width: 4),
                const Icon(Icons.add_circle,
                    size: 12, color: AppTheme.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final result = await showMenu<String>(
      context: context,
      position:
          RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      color: AppTheme.bg2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppTheme.border)),
      items: [
        const PopupMenuItem(
            value: 'rename',
            height: 32,
            child: Text('Rename',
                style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
        const PopupMenuItem(
            value: 'delete',
            height: 32,
            child: Text('Delete collection',
                style: TextStyle(fontSize: 12, color: AppTheme.flagRed))),
      ],
    );
    if (result == 'rename') widget.onDoubleTap();
    if (result == 'delete') widget.onDelete();
  }
}

class _RenameField extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  const _RenameField(
      {required this.ctrl, required this.onSubmit, required this.onCancel});

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        autofocus: true,
        style: const TextStyle(
            fontSize: 12, color: AppTheme.textPrimary, fontFamily: 'Inter'),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.accent)),
        ),
        onSubmitted: (_) => onSubmit(),
        onEditingComplete: onSubmit,
        onTapOutside: (_) => onCancel(),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
      );
}
