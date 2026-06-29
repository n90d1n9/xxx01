import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../form_builder/clipboard/clipboard_provider.dart';
import '../history/history_manager_provider.dart';
import '../model/field_config.dart';
import '../model/form_theme.dart';
import '../service/theme_manager.dart';
import '../states/autosave_provider.dart';
import '../states/bulk_operation_manager.dart';
import '../states/filtered_provider.dart';
import '../states/form_field_provider.dart';
import '../states/selection_provider.dart';
import '../widget/bluk_operation_panel.dart';
import '../widget/components_palette.dart';
import '../widget/form_canvas.dart';
import '../widget/properties_panel.dart';
import '../widget/stats_bar.dart';
import '../widget/theme_customizer_panel.dart';

class FormBuilderDesigner extends ConsumerStatefulWidget {
  const FormBuilderDesigner({super.key});

  @override
  ConsumerState<FormBuilderDesigner> createState() =>
      _FormBuilderDesignerState();
}

class _FormBuilderDesignerState extends ConsumerState<FormBuilderDesigner> {
  bool _checkedAutoSave = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoSave();
    });
  }

  Future<void> _checkAutoSave() async {
    if (_checkedAutoSave) return;
    _checkedAutoSave = true;

    final autoSaveData = await StorageManager.loadAutoSave();
    if (autoSaveData != null && mounted) {
      _showRecoveryDialog(autoSaveData);
    }
  }

  void _showRecoveryDialog(Map<String, dynamic> autoSaveData) {
    final timestamp = DateTime.parse(autoSaveData['timestamp'] as String);
    final timeDiff = DateTime.now().difference(timestamp);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Row(
          children: [
            const Icon(Icons.restore, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'Recover Auto-Saved Form?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'An auto-saved version was found from ${_formatTimeDiff(timeDiff)} ago.',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              StorageManager.clearAutoSave();
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () => _recoverFromAutoSave(autoSaveData),
            child: const Text('Recover'),
          ),
        ],
      ),
    );
  }

  void _recoverFromAutoSave(Map<String, dynamic> data) {
    final fieldsJson = data['fields'] as List;
    final fields = fieldsJson
        .map((json) => FieldConfig.fromJson(json as Map<String, dynamic>))
        .toList();

    ref.read(formFieldsProvider.notifier).loadFields(fields);
    ref.read(autoSaveManagerProvider.notifier).markSaved();
    Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Form recovered'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatTimeDiff(Duration diff) {
    if (diff.inMinutes < 1) return 'less than a minute';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    }
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider);
    final showThemePanel = ref.watch(showThemePanelProvider);
    final selectionState = ref.watch(selectionManagerProvider);
    final autoSaveState = ref.watch(autoSaveManagerProvider);
    final historyState = ref.watch(historyManagerProvider);
    final clipboard = ref.watch(clipboardProvider);
    final showSearch = ref.watch(showSearchProvider);
    final showFilterPanel = ref.watch(showFilterPanelProvider);
    final filterManager = ref.watch(filterManagerProvider.notifier);

    final canUndo = historyState.canUndo;
    final canRedo = historyState.canRedo;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) => _handleKeyEvent(event, ref),
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          title: const Text(
            '🎨 Form Builder - Phase 2: Step 6 - Theme Builder',
          ),
          backgroundColor: theme.colors.surface,
          foregroundColor: theme.colors.text,
          actions: _buildAppBarActions(
            theme,
            selectionState,
            autoSaveState,
            canUndo,
            canRedo,
            clipboard,
            showSearch,
            showFilterPanel,
            filterManager,
          ),
        ),
        body: Column(
          children: [
            if (showThemePanel) ThemeCustomizerPanel(),
            if (selectionState.hasSelection) BulkOperationsPanel(theme: theme),
            StatsBar(theme: theme),
            Expanded(
              child: Row(
                children: [
                  ComponentPalette(theme: theme),
                  Expanded(child: FormCanvas(theme: theme)),
                  PropertiesPanel(theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(
    FormTheme theme,
    SelectionState selectionState,
    AutoSaveState autoSaveState,
    bool canUndo,
    bool canRedo,
    List<FieldConfig> clipboard,
    bool showSearch,
    bool showFilterPanel,
    FilterManager filterManager,
  ) {
    return [
      // Auto-save status
      _buildAutoSaveStatus(autoSaveState, theme),

      // Theme selector
      _buildThemeSelector(theme),

      // Theme customizer
      IconButton(
        icon: Icon(Icons.tune, color: theme.colors.text),
        tooltip: 'Customize Theme',
        onPressed: () {
          ref.read(showThemePanelProvider.notifier).state = !ref.read(
            showThemePanelProvider,
          );
        },
      ),

      const VerticalDivider(),

      // Manual save button
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'Save Now (Ctrl+S)',
        onPressed: () => _manualSave(),
      ),

      // Version history
      IconButton(
        icon: const Icon(Icons.history),
        tooltip: 'Version History',
        onPressed: _showVersionHistory,
      ),

      const VerticalDivider(),

      // Selection count
      if (selectionState.hasSelection)
        _buildSelectionCount(selectionState, theme),

      // Search & Filter
      ..._buildSearchFilterButtons(
        showSearch,
        showFilterPanel,
        filterManager,
        theme,
      ),

      const VerticalDivider(),

      // Undo/Redo
      ..._buildUndoRedoButtons(canUndo, canRedo),

      const VerticalDivider(),

      // Edit operations
      ..._buildEditOperations(selectionState, clipboard, ref),

      const VerticalDivider(),

      // Export & Clear
      IconButton(
        icon: const Icon(Icons.code),
        tooltip: 'Export',
        onPressed: () => _showExportDialog(context, ref),
      ),
      IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Clear All',
        onPressed: () => _showClearDialog(context, ref),
      ),
    ];
  }

  Widget _buildAutoSaveStatus(AutoSaveState autoSaveState, FormTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: autoSaveState.hasUnsavedChanges
            ? theme.colors.error.withOpacity(0.2)
            : theme.colors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (autoSaveState.isSaving)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            )
          else
            Icon(
              autoSaveState.hasUnsavedChanges
                  ? Icons.cloud_upload
                  : Icons.cloud_done,
              size: 16,
              color: autoSaveState.hasUnsavedChanges
                  ? theme.colors.error
                  : theme.colors.primary,
            ),
          const SizedBox(width: 6),
          Text(
            autoSaveState.saveStatus,
            style: TextStyle(
              color: autoSaveState.hasUnsavedChanges
                  ? theme.colors.error
                  : theme.colors.primary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(FormTheme theme) {
    return PopupMenuButton<FormTheme>(
      icon: Icon(Icons.palette, color: theme.colors.primary),
      tooltip: 'Change Theme',
      itemBuilder: (context) => PredefinedThemes.all.map((t) {
        return PopupMenuItem(
          value: t,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: t.colors.primary,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.colors.border),
                ),
              ),
              const SizedBox(width: 12),
              Text(t.name),
              if (theme.id == t.id) ...[
                const Spacer(),
                const Icon(Icons.check, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
      onSelected: (theme) {
        ref.read(themeManagerProvider.notifier).setTheme(theme);
      },
    );
  }

  Widget _buildSelectionCount(SelectionState selectionState, FormTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '${selectionState.count} selected',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSearchFilterButtons(
    bool showSearch,
    bool showFilterPanel,
    FilterManager filterManager,
    FormTheme theme,
  ) {
    return [
      IconButton(
        icon: Icon(showSearch ? Icons.search_off : Icons.search),
        tooltip: 'Search (Ctrl+F)',
        onPressed: () {
          ref.read(showSearchProvider.notifier).state = !showSearch;
        },
      ),
      IconButton(
        icon: Icon(
          showFilterPanel ? Icons.filter_alt : Icons.filter_alt_outlined,
          color: filterManager.hasActiveFilters ? Colors.blue : null,
        ),
        tooltip: 'Filters',
        onPressed: () {
          ref.read(showFilterPanelProvider.notifier).state = !showFilterPanel;
        },
      ),
      if (filterManager.hasActiveFilters)
        IconButton(
          icon: const Icon(Icons.clear_all),
          tooltip: 'Clear filters',
          onPressed: () =>
              ref.read(filterManagerProvider.notifier).clearAllFilters(),
        ),
    ];
  }

  List<Widget> _buildUndoRedoButtons(bool canUndo, bool canRedo) {
    return [
      IconButton(
        icon: const Icon(Icons.undo),
        tooltip: 'Undo (Ctrl+Z)',
        onPressed: canUndo
            ? () => ref.read(historyManagerProvider.notifier).undo()
            : null,
      ),
      IconButton(
        icon: const Icon(Icons.redo),
        tooltip: 'Redo (Ctrl+Y)',
        onPressed: canRedo
            ? () => ref.read(historyManagerProvider.notifier).redo()
            : null,
      ),
    ];
  }

  List<Widget> _buildEditOperations(
    SelectionState selectionState,
    List<FieldConfig> clipboard,
    WidgetRef ref,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.content_copy),
        tooltip: 'Copy (Ctrl+C)',
        onPressed: selectionState.hasSelection ? () => _handleCopy(ref) : null,
      ),
      IconButton(
        icon: const Icon(Icons.content_paste),
        tooltip: 'Paste (Ctrl+V)',
        onPressed: clipboard.isNotEmpty ? () => _handlePaste(ref) : null,
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete (Del)',
        onPressed: selectionState.hasSelection
            ? () => _handleDelete(ref)
            : null,
      ),
    ];
  }

  Future<void> _manualSave() async {
    ref.read(autoSaveManagerProvider.notifier).markSaving();
    await StorageManager.saveAutoSave(ref.read(formFieldsProvider));
    ref.read(autoSaveManagerProvider.notifier).markSaved();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💾 Saved successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showVersionHistory() async {
    final versions = await StorageManager.loadVersions();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Version History',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 500,
          height: 400,
          child: versions.isEmpty
              ? const Center(
                  child: Text(
                    'No saved versions',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: versions.length,
                  itemBuilder: (context, index) {
                    final version = versions[index];
                    final timestamp = DateTime.parse(
                      version['timestamp'] as String,
                    );
                    final fieldCount = (version['fields'] as List).length;

                    return ListTile(
                      leading: const Icon(Icons.restore, color: Colors.blue),
                      title: Text(
                        'Version ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDateTime(timestamp)} • $fieldCount fields',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: ElevatedButton(
                        child: const Text('Restore'),
                        onPressed: () {
                          _restoreVersion(version);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _restoreVersion(Map<String, dynamic> version) {
    final fieldsJson = version['fields'] as List;
    final fields = fieldsJson
        .map((json) => FieldConfig.fromJson(json as Map<String, dynamic>))
        .toList();

    ref.read(formFieldsProvider.notifier).loadFields(fields);
    ref.read(autoSaveManagerProvider.notifier).markDirty();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Version restored'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }

  KeyEventResult _handleKeyEvent(RawKeyEvent event, WidgetRef ref) {
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;

    final isCtrl = event.isControlPressed;
    final isShift = event.isShiftPressed;
    final key = event.logicalKey;

    // Ctrl+S - Manual save
    if (isCtrl && key == LogicalKeyboardKey.keyS) {
      _manualSave();
      return KeyEventResult.handled;
    }

    // Ctrl+Z - Undo
    if (isCtrl && key == LogicalKeyboardKey.keyZ && !isShift) {
      final canUndo = ref.read(historyManagerProvider).canUndo;
      if (canUndo) {
        ref.read(historyManagerProvider.notifier).undo();
        return KeyEventResult.handled;
      }
    }

    // Ctrl+Y or Ctrl+Shift+Z - Redo
    if ((isCtrl && key == LogicalKeyboardKey.keyY) ||
        (isCtrl && isShift && key == LogicalKeyboardKey.keyZ)) {
      final canRedo = ref.read(historyManagerProvider).canRedo;
      if (canRedo) {
        ref.read(historyManagerProvider.notifier).redo();
        return KeyEventResult.handled;
      }
    }

    // Ctrl+F - Search
    if (isCtrl && key == LogicalKeyboardKey.keyF) {
      ref.read(showSearchProvider.notifier).state = !ref.read(
        showSearchProvider,
      );
      return KeyEventResult.handled;
    }

    // Escape - Clear selection
    if (key == LogicalKeyboardKey.escape) {
      ref.read(selectionManagerProvider.notifier).clearSelection();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleCopy(WidgetRef ref) {
    final selectionState = ref.read(selectionManagerProvider);
    final fields = ref.read(formFieldsProvider);
    final fieldsToCopy = fields
        .where((f) => selectionState.selectedIds.contains(f.id))
        .toList();
    ref.read(clipboardProvider.notifier).copy(fieldsToCopy);
  }

  void _handlePaste(WidgetRef ref) {
    final clipboard = ref.read(clipboardProvider);
    for (final field in clipboard) {
      final newField = _duplicateField(field);
      ref.read(formFieldsProvider.notifier).addField(newField);
    }
  }

  void _handleDelete(WidgetRef ref) {
    final selectionState = ref.read(selectionManagerProvider);
    BulkOperationsManager.deleteSelected(ref, selectionState.selectedIds);
  }

  FieldConfig _duplicateField(FieldConfig field) {
    return field.copyWith(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      name: field.name != null ? '${field.name}_copy' : null,
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(formFieldsProvider.notifier).exportConfig();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          '📋 Form Configuration',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      config,
                      style: const TextStyle(
                        color: Color(0xFF4EC9B0),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: config));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Copied to clipboard!')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Clear All Fields?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove all fields. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(formFieldsProvider.notifier).clear();
              ref.read(selectedFieldProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
