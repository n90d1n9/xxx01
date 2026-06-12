// lib/widgets/keyboard_shortcuts_overlay.dart
import 'package:flutter/material.dart';

class KeyboardShortcutsOverlay extends StatelessWidget {
  const KeyboardShortcutsOverlay({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const KeyboardShortcutsOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const shortcuts = [
      _ShortcutGroup('Navigation', [
        ('⌘ + ↑', 'Go to parent folder'),
        ('⌘ + ↓ / Enter', 'Open selected item'),
        ('Alt + ←', 'Go back'),
        ('Alt + →', 'Go forward'),
      ]),
      _ShortcutGroup('File Operations', [
        ('⌘ + C', 'Copy selected files'),
        ('⌘ + X', 'Cut selected files'),
        ('⌘ + V', 'Paste files'),
        ('⌘ + D', 'Duplicate selected'),
        ('Delete / ⌘ + ⌫', 'Move to trash'),
        ('⌘ + Z', 'Undo last action'),
      ]),
      _ShortcutGroup('Selection', [
        ('⌘ + A', 'Select all'),
        ('Escape', 'Clear selection'),
        ('Space', 'Preview selected file'),
        ('⇧ + Click', 'Range select'),
      ]),
      _ShortcutGroup('View', [
        ('⌘ + 1', 'Grid view'),
        ('⌘ + 2', 'List view'),
        ('⌘ + 3', 'Detail view'),
        ('⌘ + +', 'Increase grid size'),
        ('⌘ + −', 'Decrease grid size'),
        ('⌘ + F', 'Search'),
      ]),
      _ShortcutGroup('File Actions', [
        ('⌘ + N', 'New folder'),
        ('F2', 'Rename'),
        ('⌘ + I', 'Show file info'),
        ('⌘ + S', 'Add to starred'),
        ('⌘ + Enter', 'Share'),
      ]),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.keyboard_rounded,
                      color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Keyboard Shortcuts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: shortcuts.map((group) => _ShortcutGroupWidget(group: group))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutGroup {
  final String title;
  final List<(String, String)> items;
  const _ShortcutGroup(this.title, this.items);
}

class _ShortcutGroupWidget extends StatelessWidget {
  final _ShortcutGroup group;
  const _ShortcutGroupWidget({required this.group});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          group.title.toUpperCase(),
          style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w800,
            color: colorScheme.primary, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        ...group.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _KeyBadge(keys: item.$1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.$2,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _KeyBadge extends StatelessWidget {
  final String keys;
  const _KeyBadge({required this.keys});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parts = keys.split(' + ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < parts.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text('+',
                style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(parts[i],
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                fontFamily: 'monospace',
              )),
          ),
        ],
      ],
    );
  }
}
