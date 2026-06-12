// lib/screens/file_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_item.dart';
import '../providers/file_provider.dart';
import '../utils/file_utils.dart';
import '../widgets/app_drawer.dart';
import '../widgets/breadcrumb_nav.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/file_detail_row.dart';
import '../widgets/file_grid_card.dart';
import '../widgets/file_info_panel.dart';
import '../widgets/file_list_tile.dart';
import '../widgets/share_dialog.dart';
import '../widgets/type_filter_bar.dart';
import '../widgets/upload_overlay.dart';
import '../widgets/view_controls_bar.dart';
import '../widgets/grid_size_slider.dart';
import '../widgets/keyboard_shortcuts_overlay.dart';
import '../widgets/tag_manager_sheet.dart';

class FileExplorerScreen extends ConsumerStatefulWidget {
  const FileExplorerScreen({super.key});

  @override
  ConsumerState<FileExplorerScreen> createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends ConsumerState<FileExplorerScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(viewModeProvider);
    final drawerSection = ref.watch(drawerSectionProvider);
    final isSearchActive = ref.watch(isSearchActiveProvider);
    final navStack = ref.watch(navigationStackProvider);
    final canGoBack = navStack.length > 1;
    final isInfoPanelOpen = ref.watch(isInfoPanelOpenProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, isSearchActive, canGoBack, theme, colorScheme),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Breadcrumb
                    if (drawerSection == DrawerSection.myDrive && !isSearchActive)
                      const BreadcrumbNav(),

                    // Filter bar (always visible, not in search mode)
                    if (!isSearchActive) ...[
                      const SizedBox(height: 6),
                      const TypeFilterBar(),
                      const SizedBox(height: 4),
                    ] else
                      const SizedBox(height: 4),

                    // View controls
                    const ViewControlsBar(),

                    // Grid size slider (only in grid view)
                    if (viewMode == ViewMode.grid && !isSearchActive)
                      const GridSizeSlider(),

                    // File content
                    Expanded(
                      child: _buildContent(context, drawerSection, viewMode),
                    ),
                  ],
                ),
              ),

              // Info panel (desktop-style side panel)
              const FileInfoPanel(),
            ],
          ),

          // Upload progress overlay
          const UploadOverlay(),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isSearchActive,
      bool canGoBack, ThemeData theme, ColorScheme colorScheme) {
    if (isSearchActive) {
      return AppBar(
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(isSearchActiveProvider.notifier).state = false;
            ref.read(searchQueryProvider.notifier).state = '';
            _searchController.clear();
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search files and folders...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              ref.read(searchHistoryProvider.notifier).add(v.trim());
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
        bottom: _searchController.text.isEmpty
            ? _SearchHistoryBottom(onSelect: (q) {
                _searchController.text = q;
                ref.read(searchQueryProvider.notifier).state = q;
                setState(() {});
              })
            : null,
      );
    }

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 2,
      leading: canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                ref.read(navigationStackProvider.notifier).navigateBack();
                ref.read(selectedFilesProvider.notifier).clearAll();
              },
            )
          : Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
      title: _buildTitle(theme, colorScheme),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => ref.read(isSearchActiveProvider.notifier).state = true,
          tooltip: 'Search',
        ),
        const SizedBox(width: 2),
        CircleAvatar(
          radius: 16,
          backgroundColor: colorScheme.primaryContainer,
          child: Text('U',
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme, ColorScheme colorScheme) {
    final drawerSection = ref.watch(drawerSectionProvider);
    final navStack = ref.watch(navigationStackProvider);
    final canGoBack = navStack.length > 1;

    if (canGoBack) {
      final allFiles = ref.watch(filesNotifierProvider);
      final currentId = navStack.last;
      final folder = allFiles.firstWhere(
        (f) => f.id == currentId,
        orElse: () => FileItem(id: currentId!, name: 'Folder',
          type: FileType.folder, dateModified: DateTime.now(), dateCreated: DateTime.now()),
      );
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: (folder.folderColor ?? colorScheme.primary).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.folder_rounded, size: 16,
              color: folder.folderColor ?? colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(folder.name,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    const labels = {
      DrawerSection.myDrive: 'My Drive',
      DrawerSection.recent: 'Recent',
      DrawerSection.starred: 'Starred',
      DrawerSection.shared: 'Shared with me',
      DrawerSection.trash: 'Trash',
    };
    return Text(labels[drawerSection] ?? 'My Drive',
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700));
  }

  Widget _buildContent(BuildContext context, DrawerSection section, ViewMode viewMode) {
    final isSearchActive = ref.watch(isSearchActiveProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    List<FileItem> files;

    if (isSearchActive && searchQuery.isNotEmpty) {
      files = ref.watch(currentFolderFilesProvider);
    } else {
      switch (section) {
        case DrawerSection.recent:
          files = ref.watch(recentFilesProvider);
          break;
        case DrawerSection.starred:
          files = ref.watch(starredFilesProvider);
          break;
        case DrawerSection.shared:
          files = ref.watch(sharedFilesProvider);
          break;
        default:
          files = ref.watch(currentFolderFilesProvider);
      }
    }

    // Search with no query → show history
    if (isSearchActive && searchQuery.isEmpty) {
      return _SearchHistoryView(onSelect: (q) {
        _searchController.text = q;
        ref.read(searchQueryProvider.notifier).state = q;
        setState(() {});
      });
    }

    if (files.isEmpty) {
      return _EmptyState(section: section, isSearch: isSearchActive && searchQuery.isNotEmpty);
    }

    switch (viewMode) {
      case ViewMode.grid:
        return _GridView(files: files);
      case ViewMode.list:
        return _ListView(files: files);
      case ViewMode.detail:
        return _DetailView(files: files);
    }
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showNewItemSheet(context),
      icon: const Icon(Icons.add_rounded),
      label: const Text('New'),
      elevation: 2,
    );
  }

  void _showNewItemSheet(BuildContext context) {
    final currentFolderId = ref.read(currentFolderIdProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _NewItemSheet(currentFolderId: currentFolderId),
    );
  }
}

// ─── Search History Bottom ────────────────────────────────────────────────────

class _SearchHistoryBottom extends ConsumerWidget implements PreferredSizeWidget {
  final ValueChanged<String> onSelect;
  const _SearchHistoryBottom({required this.onSelect});

  @override
  Size get preferredSize => const Size.fromHeight(0);

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox.shrink();
}

// ─── Search History View ──────────────────────────────────────────────────────

class _SearchHistoryView extends ConsumerWidget {
  final ValueChanged<String> onSelect;
  const _SearchHistoryView({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('Search files and folders',
              style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent searches',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                  color: colorScheme.onSurfaceVariant)),
              TextButton(
                onPressed: () => ref.read(searchHistoryProvider.notifier).clear(),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('Clear all', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        ...history.map((q) => ListTile(
          leading: Icon(Icons.history_rounded, color: colorScheme.onSurfaceVariant, size: 20),
          title: Text(q, style: const TextStyle(fontSize: 14)),
          trailing: IconButton(
            onPressed: () => ref.read(searchHistoryProvider.notifier).remove(q),
            icon: Icon(Icons.close_rounded, size: 14, color: colorScheme.onSurfaceVariant),
            visualDensity: VisualDensity.compact,
          ),
          dense: true,
          onTap: () => onSelect(q),
        )),
      ],
    );
  }
}

// ─── Grid View ────────────────────────────────────────────────────────────────

class _GridView extends ConsumerWidget {
  final List<FileItem> files;
  const _GridView({required this.files});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = ref.watch(gridColumnCountProvider);
    // Convert column count to max cross-axis extent
    final screenWidth = MediaQuery.of(context).size.width;
    final maxExtent = (screenWidth / columns).clamp(100.0, 300.0);
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxExtent,
        childAspectRatio: 0.80,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: files.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 180 + (i % 8) * 30),
          curve: Curves.easeOut,
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child),
          ),
          child: FileGridCard(
            file: files[i],
            onTap: () => _handleTap(context, ref, files[i]),
          ),
        );
      },
    );
  }
}

// ─── List View ────────────────────────────────────────────────────────────────

class _ListView extends ConsumerWidget {
  final List<FileItem> files;
  const _ListView({required this.files});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: files.length,
      itemBuilder: (_, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 150 + (i % 10) * 25),
          curve: Curves.easeOut,
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(offset: Offset(16 * (1 - v), 0), child: child),
          ),
          child: FileListTile(
            file: files[i],
            onTap: () => _handleTap(context, ref, files[i]),
          ),
        );
      },
    );
  }
}

// ─── Detail View ─────────────────────────────────────────────────────────────

class _DetailView extends ConsumerWidget {
  final List<FileItem> files;
  const _DetailView({required this.files});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const FileDetailHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (_, i) => FileDetailRow(
              file: files[i],
              onTap: () => _handleTap(context, ref, files[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Tap handler ─────────────────────────────────────────────────────────────

void _handleTap(BuildContext context, WidgetRef ref, FileItem file) {
  if (file.isFolder) {
    ref.read(navigationStackProvider.notifier).navigateTo(file.id);
    ref.read(selectedFilesProvider.notifier).clearAll();
  } else {
    ref.read(filesNotifierProvider.notifier).updateLastOpened(file.id);
    ref.read(infoPanelFileProvider.notifier).state = file;
    _showFilePreview(context, ref, file);
  }
}

void _showFilePreview(BuildContext context, WidgetRef ref, FileItem file) {
  final colorScheme = Theme.of(context).colorScheme;
  final fileColor = FileUtils.getFileColor(file.type);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: fileColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Icon(FileUtils.getFileIcon(file.type), size: 56, color: fileColor)),
          ),
          const SizedBox(height: 20),
          Text(file.name,
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('${FileUtils.getFileTypeName(file.type)} · ${file.displaySize}',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center),
          const SizedBox(height: 24),

          // Quick action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PreviewAction(Icons.open_in_new_rounded, 'Open', () {}),
              _PreviewAction(Icons.share_rounded, 'Share', () {
                Navigator.pop(ctx);
                showDialog(context: context,
                  builder: (_) => ShareDialog(file: file));
              }),
              _PreviewAction(Icons.download_rounded, 'Download', () {}),
              _PreviewAction(
                file.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                file.isStarred ? 'Starred' : 'Star',
                () => ref.read(filesNotifierProvider.notifier).toggleStar(file.id),
                color: file.isStarred ? Colors.amber : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
          const SizedBox(height: 12),

          _InfoRow2('Owner', file.owner == 'me' ? 'Me' : (file.owner ?? '--')),
          _InfoRow2('Modified', FileUtils.formatFullDate(file.dateModified)),
          _InfoRow2('Created', FileUtils.formatFullDate(file.dateCreated)),
          if (file.lastOpenedAt != null)
            _InfoRow2('Last opened', FileUtils.formatDate(file.lastOpenedAt!)),
          if (file.isShared)
            _InfoRow2('Shared with', file.sharedWith.join(', ')),
          if (file.description?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _InfoRow2('Description', file.description!),
          ],
          if (file.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: file.tags.map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )).toList(),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(filesNotifierProvider.notifier).trashFile(file.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('"${file.name}" moved to trash'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                action: SnackBarAction(label: 'Undo',
                  onPressed: () => ref.read(filesNotifierProvider.notifier).restoreFile(file.id)),
              ));
            },
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
            label: Text('Move to trash', style: TextStyle(color: Colors.red.shade600)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red.shade300),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PreviewAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _PreviewAction(this.icon, this.label, this.onTap, {this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = color ?? colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _InfoRow2 extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow2(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13))),
          Expanded(
            child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final DrawerSection section;
  final bool isSearch;
  const _EmptyState({required this.section, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final (icon, title, subtitle) = isSearch
        ? (Icons.search_off_rounded, 'No results', 'Try a different search term.')
        : switch (section) {
            DrawerSection.starred => (Icons.star_outline_rounded, 'No starred files',
              'Star files and folders to find them quickly here.'),
            DrawerSection.recent => (Icons.access_time_rounded, 'No recent files',
              'Files you open or edit will appear here.'),
            DrawerSection.shared => (Icons.people_outline_rounded, 'Nothing shared yet',
              'Files shared with you will appear here.'),
            DrawerSection.trash => (Icons.delete_outline_rounded, 'Trash is empty',
              'Deleted files will be here for 30 days.'),
            _ => (Icons.folder_open_rounded, 'This folder is empty',
              'Upload files or create folders to get started.'),
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text(title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── New Item Sheet ───────────────────────────────────────────────────────────

class _NewItemSheet extends ConsumerWidget {
  final String? currentFolderId;
  const _NewItemSheet({this.currentFolderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final fakeUploads = [
      ('Report_Q2.pdf', FileType.pdf),
      ('Screenshot.png', FileType.image),
      ('DataExport.csv', FileType.spreadsheet),
    ];

    final items = [
      (Icons.create_new_folder_rounded, 'New folder', Colors.orange, () {
        Navigator.pop(context);
        showDialog(context: context, builder: (_) => const CreateFolderDialog());
      }),
      (Icons.upload_file_rounded, 'Upload file', colorScheme.primary, () {
        Navigator.pop(context);
        final pick = fakeUploads[DateTime.now().millisecond % fakeUploads.length];
        ref.read(uploadTasksProvider.notifier)
            .startFakeUpload(pick.$1, pick.$2, currentFolderId);
      }),
      (Icons.photo_rounded, 'Upload photo or video', Colors.purple, () {
        Navigator.pop(context);
        ref.read(uploadTasksProvider.notifier)
            .startFakeUpload('Photo_${DateTime.now().millisecond}.jpg', FileType.image, currentFolderId);
      }),
      (Icons.description_rounded, 'New document', const Color(0xFF4285F4), () {
        Navigator.pop(context);
        _createFile(context, ref, 'Untitled document', FileType.document);
      }),
      (Icons.table_chart_rounded, 'New spreadsheet', const Color(0xFF34A853), () {
        Navigator.pop(context);
        _createFile(context, ref, 'Untitled spreadsheet', FileType.spreadsheet);
      }),
      (Icons.slideshow_rounded, 'New presentation', const Color(0xFFFBBC04), () {
        Navigator.pop(context);
        _createFile(context, ref, 'Untitled presentation', FileType.presentation);
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2)),
          ),
          Text('Create or upload',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: item.$3.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(item.$1, color: item.$3, size: 20),
            ),
            title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w500)),
            onTap: item.$4,
          )),
        ],
      ),
    );
  }

  void _createFile(BuildContext context, WidgetRef ref, String name, FileType type) {
    final file = FileItem(
      id: 'file-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      sizeBytes: 0,
      dateModified: DateTime.now(),
      dateCreated: DateTime.now(),
      parentId: currentFolderId,
      owner: 'me',
      lastOpenedAt: DateTime.now(),
    );
    ref.read(filesNotifierProvider.notifier).addFile(file);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('"$name" created'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
