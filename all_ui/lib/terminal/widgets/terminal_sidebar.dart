import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import '../models/terminal_models.dart';

class TerminalSidebar extends ConsumerStatefulWidget {
  const TerminalSidebar({super.key});

  @override
  ConsumerState<TerminalSidebar> createState() => _TerminalSidebarState();
}

class _TerminalSidebarState extends ConsumerState<TerminalSidebar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: TerminalTheme.surface,
        border: Border(right: BorderSide(color: TerminalTheme.border)),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            height: 34,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TerminalTheme.border)),
            ),
            child: TabBar(
              controller: _tabs,
              labelColor: TerminalTheme.blue,
              unselectedLabelColor: TerminalTheme.textMuted,
              indicatorColor: TerminalTheme.blue,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              tabs: const [
                Tab(text: 'HISTORY'),
                Tab(text: 'FILES'),
                Tab(text: 'ENV'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [_HistoryTab(), _FilesTab(), _EnvTab()],
            ),
          ),
          // Bottom settings strip
          _SettingsStrip(),
        ],
      ),
    );
  }
}

// ── History ────────────────────────────────────────────────────────────────────
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeTabProvider);
    if (tab == null) return const SizedBox.expand();

    final history = tab.history.reversed.toList();

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 28, color: TerminalTheme.textMuted),
            const SizedBox(height: 8),
            Text(
              'No history yet',
              style: TerminalTheme.uiFont.copyWith(
                color: TerminalTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: history.length,
      itemBuilder: (_, i) => _HistoryItem(
        command: history[i],
        index: tab.history.length - 1 - i, // reverse index for history nav
      ),
    );
  }
}

class _HistoryItem extends ConsumerWidget {
  final String command;
  final int index;
  const _HistoryItem({required this.command, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // ← Fixed: writes the command into the global input controller.
        final ctrl = globalInputController;
        ctrl.value = TextEditingValue(
          text: command,
          selection: TextSelection.collapsed(offset: command.length),
        );
        // Also update the history index so ↑/↓ continues from here.
        final tab = ref.read(activeTabProvider);
        if (tab != null) {
          ref.read(tabsProvider.notifier).setHistoryIndex(tab.id, index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          children: [
            const Icon(
              Icons.subdirectory_arrow_right,
              size: 11,
              color: TerminalTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                command,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: TerminalTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            // Re-run button
            InkWell(
              onTap: () {
                final tab = ref.read(activeTabProvider);
                if (tab != null && !tab.isBusy) {
                  ref
                      .read(commandExecutionProvider.notifier)
                      .execute(command, tab.id);
                }
              },
              borderRadius: BorderRadius.circular(3),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.play_arrow,
                  size: 11,
                  color: TerminalTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Files ──────────────────────────────────────────────────────────────────────
class _FilesTab extends ConsumerWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeTabProvider);
    if (tab == null) return const SizedBox.expand();

    final fs = ref.read(tabsProvider.notifier).fsFor(tab.id);
    final dir = tab.workingDirectory;
    final entries = fs.listDirectory(dir, showHidden: false) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: TerminalTheme.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.folder_open,
                size: 12,
                color: TerminalTheme.blue,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  dir.replaceFirst('/home/user', '~'),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: TerminalTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              '(empty)',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: TerminalTheme.textMuted,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: entries.length,
              itemBuilder: (_, i) => _FileRow(entry: entries[i]),
            ),
          ),
      ],
    );
  }
}

class _FileRow extends ConsumerWidget {
  final FileSystemEntry entry;
  const _FileRow({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDir = entry.isDirectory;
    final icon = isDir ? Icons.folder : _icon(entry.name);
    final color = isDir ? TerminalTheme.blue : TerminalTheme.textSecondary;

    return InkWell(
      onTap: isDir
          ? () {
              // cd into the directory on tap.
              final tab = ref.read(activeTabProvider);
              if (tab != null) {
                ref
                    .read(commandExecutionProvider.notifier)
                    .execute('cd ${entry.name}', tab.id);
              }
            }
          : () {
              // Populate input with cat command.
              globalInputController.value = TextEditingValue(
                text: 'cat ${entry.name}',
                selection: TextSelection.collapsed(
                  offset: 'cat ${entry.name}'.length,
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                entry.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: isDir ? TerminalTheme.blue : TerminalTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            if (!isDir)
              Text(
                _fmtSize(entry.size),
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 9,
                  color: TerminalTheme.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'dart':
        return Icons.code;
      case 'yaml':
      case 'yml':
        return Icons.settings_outlined;
      case 'md':
        return Icons.article_outlined;
      case 'json':
        return Icons.data_object;
      case 'sh':
        return Icons.terminal;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'png':
      case 'jpg':
      case 'gif':
      case 'webp':
        return Icons.image_outlined;
      case 'gz':
      case 'zip':
      case 'xz':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _fmtSize(int b) {
    if (b < 1024) return '${b}B';
    if (b < 1048576) return '${(b / 1024).round()}K';
    return '${(b / 1048576).toStringAsFixed(1)}M';
  }
}

// ── Environment ────────────────────────────────────────────────────────────────
class _EnvTab extends ConsumerStatefulWidget {
  const _EnvTab();

  @override
  ConsumerState<_EnvTab> createState() => _EnvTabState();
}

class _EnvTabState extends ConsumerState<_EnvTab> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(activeTabProvider);
    if (tab == null) return const SizedBox.expand();

    final fs = ref.read(tabsProvider.notifier).fsFor(tab.id);
    final allEnv = fs.getAllEnv();
    final entries =
        allEnv.entries
            .where(
              (e) =>
                  _filter.isEmpty ||
                  e.key.toLowerCase().contains(_filter.toLowerCase()) ||
                  e.value.toLowerCase().contains(_filter.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: TextField(
            onChanged: (v) => setState(() => _filter = v),
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 11,
              color: TerminalTheme.textPrimary,
            ),
            cursorColor: TerminalTheme.cursor,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              hintText: 'Filter vars…',
              hintStyle: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                color: TerminalTheme.textMuted,
              ),
              filled: true,
              fillColor: TerminalTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: TerminalTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: TerminalTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: TerminalTheme.blue),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final e = entries[i];
              return InkWell(
                onTap: () {
                  globalInputController.value = TextEditingValue(
                    text: 'echo \$${e.key}',
                    selection: TextSelection.collapsed(
                      offset: 'echo \$${e.key}'.length,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: TerminalTheme.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        e.value,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: TerminalTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Settings strip ────────────────────────────────────────────────────────────
class _SettingsStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: TerminalTheme.border)),
        color: TerminalTheme.background,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _SToggle(
            icon: Icons.format_list_numbered,
            tooltip: 'Toggle line numbers',
            active: s.showLineNumbers,
            onTap: () =>
                ref.read(settingsProvider.notifier).toggleLineNumbers(),
          ),
          _SToggle(
            icon: Icons.outlined_flag,
            tooltip: 'Toggle blinking cursor',
            active: s.blinkCursor,
            onTap: () =>
                ref.read(settingsProvider.notifier).toggleBlinkCursor(),
          ),
          _SToggle(
            icon: Icons.compress,
            tooltip: 'Compact mode',
            active: s.compactMode,
            onTap: () => ref.read(settingsProvider.notifier).toggleCompact(),
          ),
          const Spacer(),
          Text(
            '${s.fontSize.toInt()}px',
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: TerminalTheme.textMuted,
            ),
          ),
          const SizedBox(width: 4),
          _SIconBtn(
            icon: Icons.remove,
            onTap: () => ref.read(settingsProvider.notifier).decreaseFontSize(),
          ),
          _SIconBtn(
            icon: Icons.add,
            onTap: () => ref.read(settingsProvider.notifier).increaseFontSize(),
          ),
        ],
      ),
    );
  }
}

class _SToggle extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;
  const _SToggle({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 13,
          color: active ? TerminalTheme.blue : TerminalTheme.textMuted,
        ),
      ),
    ),
  );
}

class _SIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(icon, size: 13, color: TerminalTheme.textMuted),
    ),
  );
}
