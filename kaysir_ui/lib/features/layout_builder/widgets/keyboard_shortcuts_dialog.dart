import 'package:flutter/material.dart';

Future<void> showKeyboardShortcutsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _KeyboardShortcutsDialog(),
  );
}

class _KeyboardShortcutsDialog extends StatefulWidget {
  const _KeyboardShortcutsDialog();

  @override
  State<_KeyboardShortcutsDialog> createState() =>
      _KeyboardShortcutsDialogState();
}

class _KeyboardShortcutsDialogState extends State<_KeyboardShortcutsDialog> {
  late final TextEditingController _searchController;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _filteredGroups(_query);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard_alt_outlined),
          SizedBox(width: 10),
          Text('Keyboard Shortcuts'),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      content: SizedBox(
        width: 580,
        height: 520,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search shortcuts',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  groups.isEmpty
                      ? Center(
                        child: Text(
                          'No shortcuts found',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                      : ListView.separated(
                        itemCount: groups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return _ShortcutGroupSection(group: group);
                        },
                      ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ShortcutGroupSection extends StatelessWidget {
  final _ShortcutGroup group;

  const _ShortcutGroupSection({required this.group});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            group.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (var index = 0; index < group.shortcuts.length; index++) ...[
                if (index > 0) const Divider(height: 1),
                _ShortcutRow(entry: group.shortcuts[index]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final _ShortcutEntry entry;

  const _ShortcutRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.action,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              entry.shortcut,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<_ShortcutGroup> _filteredGroups(String query) {
  final terms =
      query
          .trim()
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((term) => term.isNotEmpty)
          .toList();
  if (terms.isEmpty) return _shortcutGroups;

  return [
    for (final group in _shortcutGroups)
      _ShortcutGroup(
        title: group.title,
        shortcuts: group.shortcuts
            .where((entry) => entry.matches(group.title, terms))
            .toList(growable: false),
      ),
  ].where((group) => group.shortcuts.isNotEmpty).toList(growable: false);
}

class _ShortcutGroup {
  final String title;
  final List<_ShortcutEntry> shortcuts;

  const _ShortcutGroup({required this.title, required this.shortcuts});
}

class _ShortcutEntry {
  final String action;
  final String shortcut;
  final String keywords;

  const _ShortcutEntry({
    required this.action,
    required this.shortcut,
    this.keywords = '',
  });

  bool matches(String group, List<String> terms) {
    final haystack = '$group $action $shortcut $keywords'.toLowerCase();
    return terms.every(haystack.contains);
  }
}

const _shortcutGroups = [
  _ShortcutGroup(
    title: 'Command',
    shortcuts: [
      _ShortcutEntry(action: 'Open command palette', shortcut: 'Ctrl/Cmd+K'),
      _ShortcutEntry(action: 'Open shortcut help', shortcut: 'Ctrl/Cmd+/'),
      _ShortcutEntry(action: 'Save layout', shortcut: 'Ctrl/Cmd+S'),
      _ShortcutEntry(action: 'Undo', shortcut: 'Ctrl/Cmd+Z'),
      _ShortcutEntry(
        action: 'Redo',
        shortcut: 'Ctrl/Cmd+Y or Shift+Ctrl/Cmd+Z',
      ),
    ],
  ),
  _ShortcutGroup(
    title: 'Selection',
    shortcuts: [
      _ShortcutEntry(action: 'Select all components', shortcut: 'Ctrl/Cmd+A'),
      _ShortcutEntry(action: 'Clear selection', shortcut: 'Esc'),
      _ShortcutEntry(action: 'Copy selection', shortcut: 'Ctrl/Cmd+C'),
      _ShortcutEntry(action: 'Paste at pointer', shortcut: 'Ctrl/Cmd+V'),
      _ShortcutEntry(action: 'Duplicate selection', shortcut: 'Ctrl/Cmd+D'),
      _ShortcutEntry(
        action: 'Copy selection bounds',
        shortcut: 'Shift+Ctrl/Cmd+B',
        keywords: 'geometry x y width height',
      ),
      _ShortcutEntry(action: 'Delete selection', shortcut: 'Delete/Backspace'),
      _ShortcutEntry(action: 'Group selection', shortcut: 'Ctrl/Cmd+G'),
      _ShortcutEntry(action: 'Ungroup selection', shortcut: 'Shift+Ctrl/Cmd+G'),
      _ShortcutEntry(action: 'Invert selection', shortcut: 'Shift+Ctrl/Cmd+I'),
    ],
  ),
  _ShortcutGroup(
    title: 'Move And Resize',
    shortcuts: [
      _ShortcutEntry(action: 'Nudge selection', shortcut: 'Arrow keys'),
      _ShortcutEntry(action: 'Nudge selection 5x', shortcut: 'Shift+Arrow'),
      _ShortcutEntry(
        action: 'Resize selection',
        shortcut: 'Ctrl/Cmd+Arrow',
        keywords: 'width height size',
      ),
      _ShortcutEntry(
        action: 'Resize selection 5x',
        shortcut: 'Shift+Ctrl/Cmd+Arrow',
        keywords: 'width height size',
      ),
      _ShortcutEntry(
        action: 'Nudge one layout-rule column',
        shortcut: 'Ctrl/Cmd+Alt+Left/Right',
        keywords: 'tabular auto grid columns move layout rules',
      ),
      _ShortcutEntry(
        action: 'Nudge one layout-rule row',
        shortcut: 'Ctrl/Cmd+Alt+Up/Down',
        keywords: 'tabular auto grid rows move layout rules',
      ),
      _ShortcutEntry(action: 'Keep selection inside canvas', shortcut: 'Alt+I'),
      _ShortcutEntry(
        action: 'Move selection to clear spot',
        shortcut: 'Alt+M',
        keywords: 'conflict collision overlap resolve layout rules',
      ),
      _ShortcutEntry(
        action: 'Move selection to free Auto Grid cells',
        shortcut: 'Alt+F',
        keywords: 'auto grid free cells overlap collision',
      ),
      _ShortcutEntry(
        action: 'Resolve visible Auto Grid conflicts',
        shortcut: 'Alt+Shift+F',
        keywords: 'auto grid conflicts overlaps collisions cleanup',
      ),
      _ShortcutEntry(
        action: 'Compact visible Auto Grid',
        shortcut: 'Alt+Shift+C',
        keywords: 'auto grid compact pack visible holes gaps cleanup',
      ),
      _ShortcutEntry(action: 'Center selection on canvas', shortcut: 'Alt+C'),
      _ShortcutEntry(
        action: 'Center selection horizontally',
        shortcut: 'Alt+Shift+H',
      ),
      _ShortcutEntry(
        action: 'Center selection vertically',
        shortcut: 'Alt+Shift+V',
      ),
    ],
  ),
  _ShortcutGroup(
    title: 'Canvas And View',
    shortcuts: [
      _ShortcutEntry(action: 'Toggle grid', shortcut: 'Alt+G'),
      _ShortcutEntry(action: 'Toggle snap', shortcut: 'Alt+S'),
      _ShortcutEntry(action: 'Toggle precision guides', shortcut: 'Alt+P'),
      _ShortcutEntry(
        action: 'Toggle Auto Grid occupancy',
        shortcut: 'Alt+O',
        keywords: 'overlay occupied cells conflicts',
      ),
      _ShortcutEntry(action: 'Zoom in', shortcut: 'Ctrl/Cmd+='),
      _ShortcutEntry(action: 'Zoom out', shortcut: 'Ctrl/Cmd+-'),
      _ShortcutEntry(action: 'Reset zoom', shortcut: 'Ctrl/Cmd+0'),
      _ShortcutEntry(action: 'Fit canvas', shortcut: 'Ctrl/Cmd+1'),
      _ShortcutEntry(action: 'Fit selection', shortcut: 'Ctrl/Cmd+2'),
    ],
  ),
  _ShortcutGroup(
    title: 'Layer Order',
    shortcuts: [
      _ShortcutEntry(action: 'Select layer above', shortcut: 'Alt+Up'),
      _ShortcutEntry(action: 'Select layer below', shortcut: 'Alt+Down'),
      _ShortcutEntry(action: 'Bring forward', shortcut: 'Ctrl/Cmd+]'),
      _ShortcutEntry(action: 'Bring to front', shortcut: 'Shift+Ctrl/Cmd+]'),
      _ShortcutEntry(action: 'Send backward', shortcut: 'Ctrl/Cmd+['),
      _ShortcutEntry(action: 'Send to back', shortcut: 'Shift+Ctrl/Cmd+['),
      _ShortcutEntry(action: 'Toggle selection lock', shortcut: 'Alt+L'),
      _ShortcutEntry(action: 'Toggle visibility', shortcut: 'Alt+V'),
    ],
  ),
  _ShortcutGroup(
    title: 'Preview',
    shortcuts: [
      _ShortcutEntry(action: 'Toggle preview mode', shortcut: 'Alt+R'),
      _ShortcutEntry(action: 'Toggle breakpoints', shortcut: 'Alt+B'),
      _ShortcutEntry(action: 'Desktop preview', shortcut: 'Alt+1'),
      _ShortcutEntry(action: 'Tablet preview', shortcut: 'Alt+2'),
      _ShortcutEntry(action: 'Mobile preview', shortcut: 'Alt+3'),
      _ShortcutEntry(
        action: 'Cycle preview device',
        shortcut: 'Alt+Left/Right',
      ),
    ],
  ),
  _ShortcutGroup(
    title: 'Inspector Fields',
    shortcuts: [
      _ShortcutEntry(
        action: 'Increase numeric value',
        shortcut: 'ArrowUp',
        keywords: 'number field stepper',
      ),
      _ShortcutEntry(
        action: 'Decrease numeric value',
        shortcut: 'ArrowDown',
        keywords: 'number field stepper',
      ),
    ],
  ),
];
