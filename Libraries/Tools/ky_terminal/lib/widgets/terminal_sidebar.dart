import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import '../utils/virtual_filesystem.dart';
import '../models/terminal_models.dart';

class TerminalSidebar extends ConsumerStatefulWidget {
  const TerminalSidebar({super.key});

  @override
  ConsumerState<TerminalSidebar> createState() => _TerminalSidebarState();
}

class _TerminalSidebarState extends ConsumerState<TerminalSidebar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          // Sidebar tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TerminalTheme.border)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: TerminalTheme.blue,
              unselectedLabelColor: TerminalTheme.textMuted,
              indicatorColor: TerminalTheme.blue,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TerminalTheme.uiFont.copyWith(fontSize: 11),
              tabs: const [
                Tab(text: 'HISTORY'),
                Tab(text: 'FILES'),
                Tab(text: 'ENV'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _HistoryTab(),
                _FilesTab(),
                _EnvTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    if (activeTab == null) return const SizedBox();
    final history = activeTab.history.reversed.toList();

    if (history.isEmpty) {
      return Center(
        child: Text(
          'No history yet',
          style: TerminalTheme.uiFont.copyWith(
            color: TerminalTheme.textMuted,
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (_, i) {
        final cmd = history[i];
        return InkWell(
          onTap: () {
            // Would insert into input via a global input controller
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Row(
              children: [
                Icon(Icons.chevron_right, size: 12, color: TerminalTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cmd,
                    style: TerminalTheme.monoFont.copyWith(
                      fontSize: 11,
                      color: TerminalTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilesTab extends ConsumerWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(virtualFsProvider);
    final activeTab = ref.watch(activeTabProvider);
    final dir = activeTab?.workingDirectory ?? '/home/user';

    final entries = fs.listDirectory(dir, showHidden: false) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text(
            dir,
            style: TerminalTheme.monoFont.copyWith(
              fontSize: 10,
              color: TerminalTheme.textMuted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(color: TerminalTheme.border, height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) => _FileEntry(entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

class _FileEntry extends StatelessWidget {
  final FileSystemEntry entry;
  const _FileEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final icon = entry.isDirectory ? Icons.folder : _fileIcon(entry.name);
    final color = entry.isDirectory ? TerminalTheme.blue : TerminalTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              entry.name,
              style: TerminalTheme.uiFont.copyWith(
                fontSize: 12,
                color: entry.isDirectory ? TerminalTheme.blue : TerminalTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!entry.isDirectory)
            Text(
              _formatSize(entry.size),
              style: TerminalTheme.uiFont.copyWith(
                fontSize: 10,
                color: TerminalTheme.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'dart': return Icons.code;
      case 'yaml': case 'yml': return Icons.settings;
      case 'md': return Icons.article;
      case 'txt': return Icons.text_snippet;
      case 'json': return Icons.data_object;
      case 'sh': return Icons.terminal;
      case 'pdf': return Icons.picture_as_pdf;
      case 'png': case 'jpg': case 'gif': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()}K';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}M';
  }
}

class _EnvTab extends ConsumerWidget {
  const _EnvTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fs = ref.watch(virtualFsProvider);
    final env = fs.getAllEnv();
    final entries = env.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.key,
                style: TerminalTheme.monoFont.copyWith(
                  fontSize: 11,
                  color: TerminalTheme.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                e.value,
                style: TerminalTheme.monoFont.copyWith(
                  fontSize: 10,
                  color: TerminalTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
