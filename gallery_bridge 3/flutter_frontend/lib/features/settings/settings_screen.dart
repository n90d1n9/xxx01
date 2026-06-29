// lib/features/settings/settings_screen.dart
//
// Settings screen with tabs:
//   1. General — default sort, thumbnail quality, UI density
//   2. Cache   — thumbnail cache size, location, prune controls
//   3. Export  — manage export presets, output folder
//   4. Shortcuts — keyboard shortcut reference card

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/bridge/gallery_bridge.dart';
import '../../shared/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String initialTab;
  const SettingsScreen({super.key, this.initialTab = 'general'});
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this, initialIndex: ['general','cache','export','shortcuts'].indexOf(widget.initialTab).clamp(0,3));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg0,
      body: Column(
        children: [
          // Header
          Container(
            height: AppTheme.toolbarHeight,
            color: AppTheme.bg1,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      size: 16, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                const Text('Settings',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          // Tabs
          Container(
            color: AppTheme.bg1,
            child: TabBar(
              controller: _tabs,
              indicatorColor: AppTheme.accent,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                  fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Cache'),
                Tab(text: 'Export'),
                Tab(text: 'Shortcuts'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _GeneralTab(),
                _CacheTab(),
                _ExportTab(),
                _ShortcutsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GeneralTab extends StatefulWidget {
  const _GeneralTab();

  @override
  State<_GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<_GeneralTab> {
  String _defaultSort = 'date';
  bool _showHiddenFiles = false;
  bool _autoWatchFolders = true;
  int _gridDensity = 5;

  @override
  Widget build(BuildContext context) {
    return _SettingsBody(children: [
      _SettingsSection(
        title: 'Library',
        children: [
          _SettingsRow(
            label: 'Default sort',
            description: 'How items are sorted when opening a folder',
            child: DropdownButton<String>(
              value: _defaultSort,
              dropdownColor: AppTheme.bg2,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textPrimary, fontFamily: 'Inter'),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Date captured')),
                DropdownMenuItem(value: 'name', child: Text('Filename')),
                DropdownMenuItem(value: 'size', child: Text('File size')),
                DropdownMenuItem(value: 'rating', child: Text('Rating')),
              ],
              onChanged: (v) => setState(() => _defaultSort = v!),
            ),
          ),
          _SettingsRow(
            label: 'Default grid columns',
            description: 'Number of columns in grid view',
            child: Row(
              children: [
                Text('$_gridDensity',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontFamily: 'JetBrains Mono')),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: _gridDensity.toDouble(),
                    min: 2,
                    max: 10,
                    divisions: 8,
                    activeColor: AppTheme.accent,
                    inactiveColor: AppTheme.bg3,
                    onChanged: (v) =>
                        setState(() => _gridDensity = v.round()),
                  ),
                ),
              ],
            ),
          ),
          _SettingsRow(
            label: 'Watch folders automatically',
            description: 'Re-index when files change',
            child: Switch(
              value: _autoWatchFolders,
              activeColor: AppTheme.accent,
              onChanged: (v) => setState(() => _autoWatchFolders = v),
            ),
          ),
          _SettingsRow(
            label: 'Show hidden files',
            description: 'Include files starting with .',
            child: Switch(
              value: _showHiddenFiles,
              activeColor: AppTheme.accent,
              onChanged: (v) => setState(() => _showHiddenFiles = v),
            ),
          ),
        ],
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CacheTab extends StatefulWidget {
  const _CacheTab();

  @override
  State<_CacheTab> createState() => _CacheTabState();
}

class _CacheTabState extends State<_CacheTab> {
  int _maxCacheGb = 2;
  String _cacheStats = 'Calculating…';
  bool _pruning = false;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    // final bytes = await GalleryBridge.thumbnailCacheSize(GalleryBridge.thumbCacheDir);
    // setState(() => _cacheStats = '${(bytes / 1e9).toStringAsFixed(2)} GB used');
    setState(() => _cacheStats = '0.00 GB used');
  }

  Future<void> _pruneCache() async {
    setState(() => _pruning = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _pruning = false;
      _cacheStats = '0.00 GB used';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsBody(children: [
      _SettingsSection(
        title: 'Thumbnail Cache',
        children: [
          _InfoCard(
            label: 'Cache location',
            value: '~/Library/Application Support/GalleryBridge/thumbnails',
          ),
          _InfoCard(label: 'Current usage', value: _cacheStats),
          _SettingsRow(
            label: 'Maximum cache size',
            description: 'Thumbnails pruned when limit is exceeded',
            child: Row(
              children: [
                Text('$_maxCacheGb GB',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accent,
                        fontFamily: 'JetBrains Mono')),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Slider(
                    value: _maxCacheGb.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: AppTheme.accent,
                    inactiveColor: AppTheme.bg3,
                    onChanged: (v) =>
                        setState(() => _maxCacheGb = v.round()),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _ActionBtn(
                  label: 'Prune Now',
                  loading: _pruning,
                  onTap: _pruneCache,
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  label: 'Clear All',
                  danger: true,
                  onTap: () async {
                    setState(() => _cacheStats = 'Clearing…');
                    await Future.delayed(const Duration(milliseconds: 400));
                    await _loadCacheStats();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ExportTab extends StatelessWidget {
  const _ExportTab();

  @override
  Widget build(BuildContext context) {
    final presets = [
      ('Web Optimised', '1920px max · JPEG 82 · No EXIF'),
      ('Social Media', '1080×1080 · JPEG 90 · No EXIF'),
      ('Print Ready', 'Original size · PNG · Preserve EXIF'),
      ('Contact Sheet', '400px max · JPEG 75 · No EXIF'),
    ];

    return _SettingsBody(children: [
      _SettingsSection(
        title: 'Export Presets',
        children: [
          for (final (name, desc) in presets)
            _PresetRow(name: name, description: desc),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ActionBtn(
              label: '+ New Preset',
              onTap: () {},
            ),
          ),
        ],
      ),
      _SettingsSection(
        title: 'Default Output Folder',
        children: [
          _InfoCard(label: 'Output path', value: '~/Desktop/GalleryBridge Exports'),
          _ActionBtn(label: 'Change Folder', onTap: () {}),
        ],
      ),
    ]);
  }
}

class _PresetRow extends StatelessWidget {
  final String name;
  final String description;
  const _PresetRow({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                Text(description,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 13, color: AppTheme.textMuted),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ShortcutsTab extends StatelessWidget {
  const _ShortcutsTab();

  @override
  Widget build(BuildContext context) {
    const shortcuts = [
      ('Navigation', [
        ('←  /  →', 'Previous / Next image'),
        ('Escape', 'Close lightbox / Clear selection'),
        ('⌘A', 'Select all visible'),
        ('G', 'Switch to grid view'),
        ('L', 'Switch to list view'),
      ]),
      ('Curation', [
        ('P', 'Pick (flag as accepted)'),
        ('X', 'Reject'),
        ('U', 'Clear flag'),
        ('1 – 5', 'Set star rating'),
        ('0', 'Clear rating'),
      ]),
      ('Lightbox', [
        ('H', 'Toggle histogram'),
        ('+  /  -', 'Zoom in / out'),
        ('Space', 'Reset zoom'),
      ]),
    ];

    return _SettingsBody(
      children: [
        for (final (category, keys) in shortcuts)
          _SettingsSection(
            title: category,
            children: [
              for (final (key, label) in keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.bg3,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(key,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textPrimary,
                                fontFamily: 'JetBrains Mono')),
                      ),
                      const SizedBox(width: 12),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsBody extends StatelessWidget {
  final List<Widget> children;
  const _SettingsBody({required this.children});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection(
      {required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1.2,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;
  const _SettingsRow(
      {required this.label,
      required this.description,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontFamily: 'JetBrains Mono'),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool danger;
  final bool loading;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    this.danger = false,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.bg2,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: danger ? AppTheme.flagRed : AppTheme.border,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: AppTheme.accent))
            : Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    color: danger ? AppTheme.flagRed : AppTheme.textPrimary,
                    fontFamily: 'Inter'),
              ),
      ),
    );
  }
}
