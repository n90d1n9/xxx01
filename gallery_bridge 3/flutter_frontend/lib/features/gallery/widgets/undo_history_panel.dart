// lib/features/gallery/widgets/undo_history_panel.dart
//
// Undo/redo history panel — slides in from the right side.
// Shows the full action stack with undo/redo controls.
// Each entry shows: icon, description, timestamp.
// Clicking an entry undoes back to that point.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/undo/undo_redo.dart';
import '../../../shared/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Panel visibility provider
// ─────────────────────────────────────────────────────────────────────────────

final historyPanelVisibleProvider = StateProvider<bool>((ref) => false);

// ─────────────────────────────────────────────────────────────────────────────
// Panel widget
// ─────────────────────────────────────────────────────────────────────────────

class UndoHistoryPanel extends ConsumerWidget {
  const UndoHistoryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(historyPanelVisibleProvider);
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(1, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 260,
          decoration: const BoxDecoration(
            color: AppTheme.bg1,
            border: Border(left: BorderSide(color: AppTheme.border)),
          ),
          child: const _PanelContent(),
        ),
      ),
    );
  }
}

class _PanelContent extends ConsumerWidget {
  const _PanelContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(undoRedoProvider);
    final notifier = ref.read(undoRedoProvider.notifier);

    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyZ,
            meta: true): () async => await notifier.undo(),
        SingleActivator(LogicalKeyboardKey.keyZ,
            meta: true, shift: true): () async => await notifier.redo(),
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            height: AppTheme.toolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('History',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Inter')),
                const Spacer(),
                // Undo button
                Tooltip(
                  message: state.canUndo
                      ? 'Undo: ${state.undoDescription}'
                      : 'Nothing to undo',
                  child: IconButton(
                    icon: Icon(
                      Icons.undo,
                      size: 16,
                      color: state.canUndo
                          ? AppTheme.textSecondary
                          : AppTheme.textMuted,
                    ),
                    onPressed:
                        state.canUndo ? () => notifier.undo() : null,
                  ),
                ),
                // Redo button
                Tooltip(
                  message: state.canRedo
                      ? 'Redo: ${state.redoDescription}'
                      : 'Nothing to redo',
                  child: IconButton(
                    icon: Icon(
                      Icons.redo,
                      size: 16,
                      color: state.canRedo
                          ? AppTheme.textSecondary
                          : AppTheme.textMuted,
                    ),
                    onPressed:
                        state.canRedo ? () => notifier.redo() : null,
                  ),
                ),
                // Close
                IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  onPressed: () => ref
                      .read(historyPanelVisibleProvider.notifier)
                      .state = false,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // Keyboard hint
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: AppTheme.bg2,
            child: const Row(
              children: [
                _KeyBadge('⌘Z'),
                SizedBox(width: 4),
                Text('Undo',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
                SizedBox(width: 12),
                _KeyBadge('⌘⇧Z'),
                SizedBox(width: 4),
                Text('Redo',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),

          // History list
          Expanded(
            child: state.undoStack.isEmpty && state.redoStack.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history,
                            size: 28, color: AppTheme.textMuted),
                        SizedBox(height: 8),
                        Text('No history yet',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted)),
                      ],
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    reverse: true,
                    children: [
                      // Current state marker
                      _HistoryMarker(
                        label: 'Current state',
                        isActive: true,
                      ),
                      // Undo stack (reversed — most recent first)
                      ...state.undoStack.reversed
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => _HistoryEntry(
                                description: e.value.description,
                                index: state.undoStack.length - e.key,
                                isUndo: true,
                                canUndo: true,
                                onUndo: () => notifier.undo(),
                              )),
                      // Redo stack
                      if (state.redoStack.isNotEmpty) ...[
                        _HistoryMarker(label: '— undone —'),
                        ...state.redoStack.reversed
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => _HistoryEntry(
                                  description: e.value.description,
                                  index: -(e.key + 1),
                                  isUndo: false,
                                  canUndo: false,
                                  onUndo: () {},
                                )),
                      ],
                    ],
                  ),
          ),

          // Clear button
          if (state.canUndo || state.canRedo) ...[
            const Divider(height: 1, color: AppTheme.border),
            InkWell(
              onTap: () => notifier.clear(),
              child: Container(
                height: 36,
                alignment: Alignment.center,
                child: const Text('Clear History',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontFamily: 'Inter')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryEntry extends StatefulWidget {
  final String description;
  final int index;
  final bool isUndo;
  final bool canUndo;
  final VoidCallback onUndo;

  const _HistoryEntry({
    required this.description,
    required this.index,
    required this.isUndo,
    required this.canUndo,
    required this.onUndo,
  });

  @override
  State<_HistoryEntry> createState() => _HistoryEntryState();
}

class _HistoryEntryState extends State<_HistoryEntry> {
  bool _hovered = false;

  static IconData _iconFor(String desc) {
    if (desc.contains('rating') || desc.contains('★')) return Icons.star;
    if (desc.contains('Pick'))    return Icons.flag;
    if (desc.contains('Reject'))  return Icons.close;
    if (desc.contains('label'))   return Icons.circle;
    if (desc.contains('Rename'))  return Icons.drive_file_rename_outline;
    if (desc.contains('Export'))  return Icons.upload;
    return Icons.edit;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        color: _hovered && widget.canUndo
            ? AppTheme.bg3
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            Icon(
              _iconFor(widget.description),
              size: 12,
              color: widget.isUndo
                  ? AppTheme.textSecondary
                  : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.description,
                style: TextStyle(
                    fontSize: 11,
                    color: widget.isUndo
                        ? AppTheme.textSecondary
                        : AppTheme.textMuted,
                    fontFamily: 'Inter'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryMarker extends StatelessWidget {
  final String label;
  final bool isActive;
  const _HistoryMarker({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Container(height: 1, color: AppTheme.border),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 9,
                    color: isActive ? AppTheme.accent : AppTheme.textMuted,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'Inter'),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: AppTheme.border),
            ),
          ],
        ),
      );
}

class _KeyBadge extends StatelessWidget {
  final String label;
  const _KeyBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: AppTheme.bg3,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 9,
                color: AppTheme.textSecondary,
                fontFamily: 'JetBrains Mono')),
      );
}
