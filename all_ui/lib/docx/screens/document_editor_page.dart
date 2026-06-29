import 'dart:async';
import 'dart:ui' as ui;

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart' as d;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/aiaction.dart';
import '../models/chart_data.dart';
import '../models/chart_type.dart';
import '../models/document_table.dart';
import '../models/document_theme.dart';
import '../models/drawing_board_controller.dart';
import '../models/drawing_board_painter.dart';
import '../models/drawing_data.dart';
import '../models/export_options.dart';
import '../models/page_layout.dart';
import '../models/page_size.dart';
import '../states/provider.dart';
import '../widgets/info_row.dart';
import '../widgets/lince_chart_painter.dart';
import '../widgets/more_options.dart';
import '../widgets/shortcut_item.dart';
import '../widgets/stat_item.dart';

class DocumentEditorPage extends ConsumerStatefulWidget {
  const DocumentEditorPage({super.key});

  @override
  ConsumerState<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends ConsumerState<DocumentEditorPage> {
  final _focusNode = FocusNode();
  bool _showStatistics = false;
  bool _showFindReplace = false;
  bool _showAIAssistant = false;
  bool _showInsertMenu = false;
  bool _showOutline = false;
  final _findController = TextEditingController();
  final _replaceController = TextEditingController();
  List<int> _searchResults = [];
  int _currentSearchIndex = -1;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    // Auto-save every 2 minutes
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _autoSave();
    });

    // Calculate pagination on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentProvider.notifier).state = ref
          .read(documentProvider)
          .copyWith(totalPages: 1);
      _updatePagination();
    });
  }

  void _autoSave() async {
    final docState = ref.read(documentProvider);
    if (docState.hasUnsavedChanges && !docState.isLoading) {
      await ref.read(documentProvider.notifier).saveDocument();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _updatePagination() {
    final text = ref.read(documentProvider).controller.document.toPlainText();
    final settings = ref.read(documentProvider).pageSettings;

    // Rough estimate: ~80 chars per line, ~40 lines per page
    final charsPerLine = 80;
    final linesPerPage = (settings.getContentHeight() / 20).floor();
    final totalChars = text.length;
    final totalLines = (totalChars / charsPerLine).ceil();
    final pages = (totalLines / linesPerPage).ceil().clamp(1, 9999);

    ref.read(documentProvider.notifier).state = ref
        .read(documentProvider)
        .copyWith(totalPages: pages);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _findController.dispose();
    _replaceController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _currentSearchIndex = -1;
      });
      return;
    }

    final text = ref.read(documentProvider).controller.document.toPlainText();
    final results = <int>[];

    var index = text.toLowerCase().indexOf(query.toLowerCase());
    while (index != -1) {
      results.add(index);
      index = text.toLowerCase().indexOf(query.toLowerCase(), index + 1);
    }

    setState(() {
      _searchResults = results;
      _currentSearchIndex = results.isEmpty ? -1 : 0;
    });

    if (results.isNotEmpty) {
      _highlightSearchResult(results[0], query.length);
    }
  }

  void _highlightSearchResult(int offset, int length) {
    final controller = ref.read(documentProvider).controller;
    controller.updateSelection(
      TextSelection(baseOffset: offset, extentOffset: offset + length),
      ChangeSource.local,
    );
  }

  void _nextSearchResult() {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
    });

    _highlightSearchResult(
      _searchResults[_currentSearchIndex],
      _findController.text.length,
    );
  }

  void _previousSearchResult() {
    if (_searchResults.isEmpty) return;

    setState(() {
      _currentSearchIndex =
          (_currentSearchIndex - 1 + _searchResults.length) %
          _searchResults.length;
    });

    _highlightSearchResult(
      _searchResults[_currentSearchIndex],
      _findController.text.length,
    );
  }

  void _replaceCurrentMatch() {
    if (_searchResults.isEmpty || _currentSearchIndex == -1) return;

    final controller = ref.read(documentProvider).controller;
    final offset = _searchResults[_currentSearchIndex];
    final findLength = _findController.text.length;
    final replaceText = _replaceController.text;

    controller.replaceText(
      offset,
      findLength,
      replaceText,
      TextSelection.collapsed(offset: offset + replaceText.length),
    );

    // Re-search after replacement
    _performSearch(_findController.text);
  }

  void _replaceAll() {
    if (_searchResults.isEmpty) return;

    final controller = ref.read(documentProvider).controller;
    final findText = _findController.text;
    final replaceText = _replaceController.text;

    // Replace from end to start to maintain correct offsets
    final sortedResults = List<int>.from(_searchResults)
      ..sort((a, b) => b.compareTo(a));

    for (final offset in sortedResults) {
      controller.replaceText(offset, findText.length, replaceText, null);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Replaced ${_searchResults.length} occurrence(s)'),
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _searchResults = [];
      _currentSearchIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);
    final stats = ref.watch(statisticsProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (docState.hasUnsavedChanges) {
            ref.read(documentProvider.notifier).saveDocument();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document saved (Ctrl+S)'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () {
          setState(() => _showFindReplace = !_showFindReplace);
        },
        const SingleActivator(LogicalKeyboardKey.keyH, control: true): () {
          setState(() => _showFindReplace = true);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) FocusScope.of(context).requestFocus(FocusNode());
          });
        },
        const SingleActivator(
          LogicalKeyboardKey.keyP,
          control: true,
        ): () async {
          try {
            final text = docState.controller.document.toPlainText();
            await Printing.layoutPdf(
              onLayout: (format) async {
                final pdf = pw.Document();
                final font = await PdfGoogleFonts.robotoRegular();
                pdf.addPage(
                  pw.Page(
                    build:
                        (context) =>
                            pw.Text(text, style: pw.TextStyle(font: font)),
                  ),
                );
                return pdf.save();
              },
            );
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Print error: $e')));
            }
          }
        },
        const SingleActivator(
          LogicalKeyboardKey.keyN,
          control: true,
        ): () async {
          await ref.read(documentProvider.notifier).createNewDocument();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () => _showTitleDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      docState.metadata.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 16),
                ],
              ),
            ),
            actions: [
              if (docState.hasUnsavedChanges)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Unsaved',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(
                  docState.metadata.isFavorite
                      ? Icons.star
                      : Icons.star_outline,
                ),
                tooltip: 'Toggle Favorite',
                color: docState.metadata.isFavorite ? Colors.amber : null,
                onPressed: () {
                  ref.read(documentProvider.notifier).toggleFavorite();
                },
              ),
              IconButton(
                icon: Icon(
                  _showStatistics ? Icons.analytics : Icons.analytics_outlined,
                ),
                tooltip: 'Statistics',
                onPressed:
                    () => setState(() => _showStatistics = !_showStatistics),
              ),
              IconButton(
                icon: Icon(_showFindReplace ? Icons.search_off : Icons.search),
                tooltip: 'Find & Replace',
                onPressed:
                    () => setState(() => _showFindReplace = !_showFindReplace),
              ),
              IconButton(
                icon: Icon(
                  _showAIAssistant
                      ? Icons.psychology
                      : Icons.psychology_outlined,
                ),
                tooltip: 'AI Assistant',
                onPressed:
                    () => setState(() => _showAIAssistant = !_showAIAssistant),
              ),
              IconButton(
                icon: Icon(
                  _showInsertMenu ? Icons.add_box : Icons.add_box_outlined,
                ),
                tooltip: 'Insert',
                onPressed:
                    () => setState(() => _showInsertMenu = !_showInsertMenu),
              ),
              // Collaboration indicator
              if (docState.isCollaborationEnabled &&
                  docState.collaborators.isNotEmpty)
                PopupMenuButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.people),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${docState.collaborators.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  tooltip: 'Collaborators',
                  itemBuilder: (context) {
                    return docState.collaborators.map((user) {
                      return PopupMenuItem(
                        enabled: false,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: user.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(user.name),
                            const Spacer(),
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.green[700],
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),

              if (_showInsertMenu)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insert Elements',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.table_chart, size: 18),
                            label: const Text('Table'),
                            onPressed: () => _showInsertTableDialog(context),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.bar_chart, size: 18),
                            label: const Text('Chart'),
                            onPressed: () => _showInsertChartDialog(context),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.draw, size: 18),
                            label: const Text('Drawing'),
                            onPressed: () => _showDrawingDialog(context),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.rectangle, size: 18),
                            label: const Text('Rectangle'),
                            onPressed: () {
                              ref
                                  .read(documentProvider.notifier)
                                  .insertShape('rectangle');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rectangle inserted'),
                                ),
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.circle, size: 18),
                            label: const Text('Circle'),
                            onPressed: () {
                              ref
                                  .read(documentProvider.notifier)
                                  .insertShape('circle');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Circle inserted'),
                                ),
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.change_history, size: 18),
                            label: const Text('Triangle'),
                            onPressed: () {
                              ref
                                  .read(documentProvider.notifier)
                                  .insertShape('triangle');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Triangle inserted'),
                                ),
                              );
                            },
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.star, size: 18),
                            label: const Text('Star'),
                            onPressed: () {
                              ref
                                  .read(documentProvider.notifier)
                                  .insertShape('star');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Star inserted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (_showAIAssistant)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'AI Writing Assistant',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (!ref.read(aiAssistantServiceProvider).hasApiKey)
                            TextButton.icon(
                              onPressed: () => _showAPIKeyDialog(context),
                              icon: const Icon(Icons.key, size: 16),
                              label: const Text(
                                'Setup',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (docState.isAIProcessing)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('AI is processing...'),
                              ],
                            ),
                          ),
                        )
                      else if (docState.aiResult != null)
                        _buildAIResultCard(context, docState.aiResult!)
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              AIAction.values.map((action) {
                                final aiService = ref.read(
                                  aiAssistantServiceProvider,
                                );
                                return ActionChip(
                                  avatar: Icon(
                                    aiService.getActionIcon(action),
                                    size: 18,
                                  ),
                                  label: Text(aiService.getActionLabel(action)),
                                  onPressed:
                                      ref
                                              .read(aiAssistantServiceProvider)
                                              .hasApiKey
                                          ? () => ref
                                              .read(documentProvider.notifier)
                                              .applyAIAction(action)
                                          : () => _showAPIKeyDialog(context),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),

              // Spell check toggle
              IconButton(
                icon: Icon(
                  docState.spellCheckEnabled
                      ? Icons.spellcheck
                      : Icons.spellcheck_outlined,
                  color: docState.spellCheckEnabled ? Colors.green : null,
                ),
                tooltip: 'Spell Check',
                onPressed: () {
                  ref.read(documentProvider.notifier).toggleSpellCheck();
                },
              ),
              if (docState.isSyncing)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (docState.lastSyncTime != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Tooltip(
                    message:
                        'Last synced: ${_formatTime(docState.lastSyncTime!)}',
                    child: const Icon(
                      Icons.cloud_done,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save',
                onPressed:
                    docState.hasUnsavedChanges
                        ? () async {
                          await ref
                              .read(documentProvider.notifier)
                              .saveDocument();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Document saved successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                        : null,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.file_upload),
                tooltip: 'Import',
                onSelected: (value) => _handleImport(context, value),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'docx',
                        child: Row(
                          children: [
                            Icon(Icons.description),
                            SizedBox(width: 8),
                            Text('Import DOCX'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf),
                            SizedBox(width: 8),
                            Text('Import PDF'),
                          ],
                        ),
                      ),
                    ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.file_download),
                tooltip: 'Export',
                onSelected: (value) => _handleExport(context, value),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'docx',
                        child: Row(
                          children: [
                            Icon(Icons.description),
                            SizedBox(width: 8),
                            Text('Export to DOCX'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf),
                            SizedBox(width: 8),
                            Text('Export to PDF'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pdf_advanced',
                        child: Row(
                          children: [
                            Icon(Icons.tune),
                            SizedBox(width: 8),
                            Text('Export PDF (Advanced)'),
                          ],
                        ),
                      ),
                    ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.view_sidebar),
                tooltip: 'View',
                onSelected: (value) {
                  if (value == 'print') {
                    ref
                        .read(documentProvider.notifier)
                        .setPageLayout(PageLayout.print);
                  } else if (value == 'web') {
                    ref
                        .read(documentProvider.notifier)
                        .setPageLayout(PageLayout.web);
                  } else if (value == 'outline') {
                    setState(() => _showOutline = !_showOutline);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(
                              docState.currentLayout == PageLayout.print
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Print Layout'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'web',
                        child: Row(
                          children: [
                            Icon(
                              docState.currentLayout == PageLayout.web
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Web Layout'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'outline',
                        child: Row(
                          children: [
                            Icon(
                              _showOutline
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Outline'),
                          ],
                        ),
                      ),
                    ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreOptions(context),
              ),
            ],
          ),
          body:
              docState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      if (docState.errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: Colors.red.withOpacity(0.1),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  docState.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  ref
                                      .read(documentProvider.notifier)
                                      .clearError();
                                },
                              ),
                            ],
                          ),
                        ),
                      if (_showStatistics)
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              StatItem(
                                icon: Icons.subject,
                                label: 'Words',
                                value: stats.wordCount.toString(),
                              ),
                              StatItem(
                                icon: Icons.text_fields,
                                label: 'Characters',
                                value: stats.characterCount.toString(),
                              ),
                              StatItem(
                                icon: Icons.format_list_numbered,
                                label: 'Paragraphs',
                                value: stats.paragraphCount.toString(),
                              ),
                              StatItem(
                                icon: Icons.timer_outlined,
                                label: 'Read Time',
                                value:
                                    '${stats.estimatedReadingTime.inMinutes} min',
                              ),
                            ],
                          ),
                        ),
                      if (_showFindReplace)
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _findController,
                                      decoration: InputDecoration(
                                        labelText: 'Find',
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                        suffixIcon:
                                            _searchResults.isNotEmpty
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 8.0,
                                                      ),
                                                  child: Text(
                                                    '${_currentSearchIndex + 1}/${_searchResults.length}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )
                                                : null,
                                      ),
                                      onChanged: _performSearch,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_upward),
                                    tooltip: 'Previous',
                                    onPressed:
                                        _searchResults.isEmpty
                                            ? null
                                            : _previousSearchResult,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_downward),
                                    tooltip: 'Next',
                                    onPressed:
                                        _searchResults.isEmpty
                                            ? null
                                            : _nextSearchResult,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _replaceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Replace',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed:
                                        _searchResults.isEmpty
                                            ? null
                                            : _replaceCurrentMatch,
                                    child: const Text('Replace'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        _searchResults.isEmpty
                                            ? null
                                            : _replaceAll,
                                    child: const Text('Replace All'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      quill.QuillSimpleToolbar(
                        controller: docState.controller,
                        config: quill.QuillSimpleToolbarConfig(
                          multiRowsDisplay: false,
                          showAlignmentButtons: true,
                          showBackgroundColorButton: true,
                          showCenterAlignment: true,
                          showCodeBlock: true,
                          showColorButton: true,
                          showDirection: true,
                          showFontSize: true,
                          showHeaderStyle: true,
                          showIndent: true,
                          showInlineCode: true,
                          showLink: true,
                          showListCheck: true,
                          showQuote: true,
                          showSearchButton: true,
                          showStrikeThrough: true,
                          showSubscript: true,
                          showSuperscript: true,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: quill.QuillEditor.basic(
                                  controller: docState.controller,
                                  config: quill.QuillEditorConfig(
                                    padding: const EdgeInsets.all(16),
                                    autoFocus: false,
                                    expands: true,
                                    placeholder:
                                        'Start typing your document here...',
                                    // readOnly: false,
                                  ),
                                  focusNode: _focusNode,
                                ),
                              ),
                            ),
                            // Display tables and charts below editor
                            if (docState.tables.isNotEmpty ||
                                docState.charts.isNotEmpty ||
                                docState.drawings.isNotEmpty)
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                                  border: Border(
                                    top: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (docState.tables.isNotEmpty) ...[
                                        Text(
                                          'Tables',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...docState.tables.map(
                                          (table) => _buildTablePreview(
                                            context,
                                            table,
                                          ),
                                        ),
                                      ],
                                      if (docState.charts.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          'Charts',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...docState.charts.map(
                                          (chart) => _buildChartPreview(
                                            context,
                                            chart,
                                          ),
                                        ),
                                      ],
                                      if (docState.drawings.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          'Drawings & Shapes',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children:
                                              docState.drawings.map((drawing) {
                                                return _buildDrawingPreview(
                                                  context,
                                                  drawing,
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Status bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                          border: Border(
                            top: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Page info
                            Text(
                              'Page ${docState.currentPage} of ${docState.totalPages}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 1,
                              height: 16,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.text_fields,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${stats.wordCount} words',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.article,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${stats.characterCount} characters',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            // Layout indicator
                            Icon(
                              docState.currentLayout == PageLayout.print
                                  ? Icons.description
                                  : Icons.web,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              docState.currentLayout == PageLayout.print
                                  ? 'Print Layout'
                                  : 'Web Layout',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (docState.hasUnsavedChanges)
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Unsaved',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Saved',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildAIResultCard(BuildContext context, String result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'AI Suggestion',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Text(result, style: const TextStyle(height: 1.5)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: result));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    ref.read(documentProvider.notifier).insertAIResult();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('AI text inserted')),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Insert'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(documentProvider.notifier).replaceWithAIResult();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text replaced with AI suggestion'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Replace'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref.read(documentProvider.notifier).clearAIResult();
                  },
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImport(BuildContext context, String type) async {
    final notifier = ref.read(documentProvider.notifier);
    try {
      if (type == 'docx') {
        await notifier.importFromDocx();
      } else if (type == 'pdf') {
        await notifier.importFromPdf();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document imported successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleExport(BuildContext context, String type) async {
    final notifier = ref.read(documentProvider.notifier);
    try {
      String path;
      if (type == 'docx') {
        path = await notifier.exportToDocx();
      } else if (type == 'pdf_advanced') {
        await _showAdvancedExportDialog(context);
        return;
      } else {
        path = await notifier.exportToPdf();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Exported successfully'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => Share.shareXFiles([XFile(path)]),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAdvancedExportDialog(BuildContext context) async {
    var options = const ExportOptions();
    var includePageNumbers = options.includePageNumbers;
    var includeMetadata = options.includeMetadata;
    var includeHeader = options.includeHeader;
    var includeFooter = options.includeFooter;
    var fontSize = options.fontSize;
    var lineSpacing = options.lineSpacing;
    final headerController = TextEditingController();
    final footerController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('PDF Export Options'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text('Include Page Numbers'),
                        value: includePageNumbers,
                        onChanged: (value) {
                          setState(() => includePageNumbers = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Include Metadata'),
                        subtitle: const Text(
                          'Author, title, dates in PDF properties',
                        ),
                        value: includeMetadata,
                        onChanged: (value) {
                          setState(() => includeMetadata = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Include Header'),
                        value: includeHeader,
                        onChanged: (value) {
                          setState(() => includeHeader = value);
                        },
                      ),
                      if (includeHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: headerController,
                            decoration: const InputDecoration(
                              labelText: 'Header Text',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Include Footer'),
                        value: includeFooter,
                        onChanged: (value) {
                          setState(() => includeFooter = value);
                        },
                      ),
                      if (includeFooter)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: footerController,
                            decoration: const InputDecoration(
                              labelText: 'Footer Text',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Font Size: ${fontSize.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: fontSize,
                        min: 8,
                        max: 24,
                        divisions: 16,
                        label: fontSize.toInt().toString(),
                        onChanged: (value) {
                          setState(() => fontSize = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Line Spacing: ${lineSpacing.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: lineSpacing,
                        min: 1.0,
                        max: 3.0,
                        divisions: 20,
                        label: lineSpacing.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() => lineSpacing = value);
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      final customOptions = ExportOptions(
                        includePageNumbers: includePageNumbers,
                        includeMetadata: includeMetadata,
                        includeHeader: includeHeader,
                        includeFooter: includeFooter,
                        headerText:
                            headerController.text.isNotEmpty
                                ? headerController.text
                                : null,
                        footerText:
                            footerController.text.isNotEmpty
                                ? footerController.text
                                : null,
                        fontSize: fontSize,
                        lineSpacing: lineSpacing,
                      );

                      try {
                        final path = await ref
                            .read(documentProvider.notifier)
                            .exportToPdf(options: customOptions);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'PDF exported with custom options',
                              ),
                              action: SnackBarAction(
                                label: 'Share',
                                onPressed:
                                    () => Share.shareXFiles([XFile(path)]),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Export failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Export'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showAPIKeyDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.key),
                SizedBox(width: 8),
                Text('Configure AI Assistant'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your Claude API key to enable AI features:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    hintText: 'sk-ant-...',
                    border: OutlineInputBorder(),
                    helperText: 'Get your key from console.anthropic.com',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your API key is stored locally and never shared.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    ref
                        .read(aiAssistantServiceProvider)
                        .setApiKey(controller.text.trim());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('API key configured successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showInsertTableDialog(BuildContext context) {
    int rows = 3;
    int columns = 3;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Insert Table'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Rows: '),
                        Expanded(
                          child: Slider(
                            value: rows.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: rows.toString(),
                            onChanged:
                                (value) => setState(() => rows = value.toInt()),
                          ),
                        ),
                        Text(rows.toString()),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Columns: '),
                        Expanded(
                          child: Slider(
                            value: columns.toDouble(),
                            min: 1,
                            max: 8,
                            divisions: 7,
                            label: columns.toString(),
                            onChanged:
                                (value) =>
                                    setState(() => columns = value.toInt()),
                          ),
                        ),
                        Text(columns.toString()),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(documentProvider.notifier)
                          .insertTable(rows, columns);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Table ($rows×$columns) inserted'),
                        ),
                      );
                    },
                    child: const Text('Insert'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showInsertChartDialog(BuildContext context) {
    ChartType selectedType = ChartType.bar;
    final titleController = TextEditingController(text: 'Chart Title');
    final labelsController = TextEditingController(text: 'A, B, C, D');
    final valuesController = TextEditingController(text: '10, 20, 15, 25');

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Insert Chart'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ChartType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Chart Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ChartType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.toString().split('.').last.toUpperCase(),
                                ),
                              );
                            }).toList(),
                        onChanged:
                            (value) => setState(() => selectedType = value!),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: labelsController,
                        decoration: const InputDecoration(
                          labelText: 'Labels (comma-separated)',
                          border: OutlineInputBorder(),
                          hintText: 'A, B, C',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: valuesController,
                        decoration: const InputDecoration(
                          labelText: 'Values (comma-separated)',
                          border: OutlineInputBorder(),
                          hintText: '10, 20, 30',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      try {
                        final labels =
                            labelsController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList();
                        final values =
                            valuesController.text
                                .split(',')
                                .map((e) => double.tryParse(e.trim()) ?? 0)
                                .toList();

                        if (labels.length != values.length) {
                          throw Exception('Labels and values count must match');
                        }

                        ref
                            .read(documentProvider.notifier)
                            .insertChart(
                              selectedType,
                              titleController.text,
                              labels,
                              values,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chart inserted')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text('Insert'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showDrawingDialog(BuildContext context) {
    final controller = DrawingBoardController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  // Toolbar
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Drawing Board',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.undo),
                              onPressed: () => controller.undo(),
                              tooltip: 'Undo',
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => controller.clear(),
                              tooltip: 'Clear All',
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Color palette
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: controller,
                                builder: (context, _) {
                                  return IconButton(
                                    icon: Icon(
                                      controller.state.isErasing
                                          ? Icons.auto_fix_high
                                          : Icons.auto_fix_off,
                                      color:
                                          controller.state.isErasing
                                              ? Colors.red
                                              : null,
                                    ),
                                    onPressed: () => controller.toggleEraser(),
                                    tooltip: 'Eraser',
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              ...[
                                Colors.black,
                                Colors.red,
                                Colors.blue,
                                Colors.green,
                                Colors.yellow,
                                Colors.orange,
                                Colors.purple,
                                Colors.pink,
                                Colors.brown,
                                Colors.grey,
                              ].map((color) {
                                return AnimatedBuilder(
                                  animation: controller,
                                  builder: (context, _) {
                                    return GestureDetector(
                                      onTap: () => controller.setColor(color),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                controller.state.currentColor ==
                                                        color
                                                    ? Colors.white
                                                    : Colors.grey,
                                            width:
                                                controller.state.currentColor ==
                                                        color
                                                    ? 3
                                                    : 1,
                                          ),
                                          boxShadow:
                                              controller.state.currentColor ==
                                                      color
                                                  ? [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Stroke width slider
                        AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            return Row(
                              children: [
                                const Icon(Icons.line_weight, size: 16),
                                Expanded(
                                  child: Slider(
                                    value: controller.state.strokeWidth,
                                    min: 1,
                                    max: 20,
                                    divisions: 19,
                                    label:
                                        controller.state.strokeWidth
                                            .toInt()
                                            .toString(),
                                    onChanged:
                                        (value) =>
                                            controller.setStrokeWidth(value),
                                  ),
                                ),
                                Text(
                                  '${controller.state.strokeWidth.toInt()}px',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Drawing canvas
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          return GestureDetector(
                            onPanStart: (details) {
                              controller.addPoint(details.localPosition);
                            },
                            onPanUpdate: (details) {
                              controller.addPoint(details.localPosition);
                            },
                            onPanEnd: (details) {
                              controller.addNull();
                            },
                            child: CustomPaint(
                              painter: DrawingBoardPainter(
                                controller.state.points,
                              ),
                              size: Size.infinite,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Bottom actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Convert drawing to image
                            final recorder = ui.PictureRecorder();
                            final canvas = Canvas(recorder);
                            final painter = DrawingBoardPainter(
                              controller.state.points,
                            );
                            painter.paint(canvas, const Size(400, 400));

                            final picture = recorder.endRecording();
                            final image = await picture.toImage(400, 400);
                            final byteData = await image.toByteData(
                              format: ui.ImageByteFormat.png,
                            );

                            if (byteData != null && context.mounted) {
                              ref
                                  .read(documentProvider.notifier)
                                  .insertDrawing(
                                    byteData.buffer.asUint8List(),
                                    400,
                                    400,
                                  );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Drawing inserted'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Insert'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTablePreview(BuildContext context, DocumentTable table) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Table ${table.rows}×${table.columns}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                      items: [
                        const PopupMenuItem(
                          value: 'row',
                          child: Row(
                            children: [
                              Icon(Icons.table_rows, size: 18),
                              SizedBox(width: 8),
                              Text('Add Row'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'column',
                          child: Row(
                            children: [
                              Icon(Icons.view_column, size: 18),
                              SizedBox(width: 8),
                              Text('Add Column'),
                            ],
                          ),
                        ),
                      ],
                    ).then((value) {
                      if (value == 'row') {
                        ref
                            .read(documentProvider.notifier)
                            .addTableRow(table.id);
                      } else if (value == 'column') {
                        ref
                            .read(documentProvider.notifier)
                            .addTableColumn(table.id);
                      }
                    });
                  },
                  tooltip: 'Add Row/Column',
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, size: 18),
                  onPressed: () => _showTableEditorDialog(context, table),
                  tooltip: 'Full Editor',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () {
                    ref.read(documentProvider.notifier).deleteTable(table.id);
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children:
                    table.data.asMap().entries.map((rowEntry) {
                      final rowIndex = rowEntry.key;
                      final row = rowEntry.value;
                      return TableRow(
                        decoration:
                            rowIndex == 0 && table.hasHeader
                                ? BoxDecoration(color: Colors.blue.shade50)
                                : null,
                        children:
                            row.asMap().entries.map((cellEntry) {
                              final colIndex = cellEntry.key;
                              final cell = cellEntry.value;
                              return TableCell(
                                child: InkWell(
                                  onTap:
                                      () => _editTableCell(
                                        context,
                                        table,
                                        rowIndex,
                                        colIndex,
                                        cell,
                                      ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 60,
                                      minHeight: 30,
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      cell.isEmpty ? '(tap to edit)' : cell,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            rowIndex == 0 && table.hasHeader
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            cell.isEmpty ? Colors.grey : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTableCell(
    BuildContext context,
    DocumentTable table,
    int row,
    int col,
    String currentValue,
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Cell (${row + 1}, ${col + 1})'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text',
              ),
              maxLines: 3,
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(documentProvider.notifier)
                      .updateTableCell(table.id, row, col, controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showTableEditorDialog(BuildContext context, DocumentTable table) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Table Editor - ${table.rows}×${table.columns}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(documentProvider.notifier)
                              .addTableRow(table.id);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Row'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(documentProvider.notifier)
                              .addTableColumn(table.id);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Column'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final docState = ref.watch(documentProvider);
                            final currentTable = docState.tables.firstWhere(
                              (t) => t.id == table.id,
                              orElse: () => table,
                            );

                            return Table(
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
                              ),
                              defaultColumnWidth: const FixedColumnWidth(120),
                              children: [
                                // Header row with delete buttons
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                  ),
                                  children: [
                                    const TableCell(
                                      child: SizedBox(width: 30, height: 30),
                                    ),
                                    ...List.generate(currentTable.columns, (
                                      colIndex,
                                    ) {
                                      return TableCell(
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    documentProvider.notifier,
                                                  )
                                                  .deleteTableColumn(
                                                    table.id,
                                                    colIndex,
                                                  );
                                            },
                                            tooltip: 'Delete Column',
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                // Data rows
                                ...currentTable.data.asMap().entries.map((
                                  rowEntry,
                                ) {
                                  final rowIndex = rowEntry.key;
                                  final row = rowEntry.value;
                                  return TableRow(
                                    decoration:
                                        rowIndex == 0 && currentTable.hasHeader
                                            ? BoxDecoration(
                                              color: Colors.blue.shade50,
                                            )
                                            : null,
                                    children: [
                                      // Row delete button
                                      TableCell(
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    documentProvider.notifier,
                                                  )
                                                  .deleteTableRow(
                                                    table.id,
                                                    rowIndex,
                                                  );
                                            },
                                            tooltip: 'Delete Row',
                                          ),
                                        ),
                                      ),
                                      // Cell data
                                      ...row.asMap().entries.map((cellEntry) {
                                        final colIndex = cellEntry.key;
                                        final cell = cellEntry.value;
                                        return TableCell(
                                          child: InkWell(
                                            onTap:
                                                () => _editTableCell(
                                                  context,
                                                  currentTable,
                                                  rowIndex,
                                                  colIndex,
                                                  cell,
                                                ),
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                cell.isEmpty
                                                    ? '(tap to edit)'
                                                    : cell,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      rowIndex == 0 &&
                                                              currentTable
                                                                  .hasHeader
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                  color:
                                                      cell.isEmpty
                                                          ? Colors.grey
                                                          : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildChartPreview(BuildContext context, ChartData chart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getChartIcon(chart.type), size: 18, color: chart.color),
                const SizedBox(width: 8),
                Text(
                  chart.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () {
                    ref.read(documentProvider.notifier).deleteChart(chart.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(height: 150, child: _buildSimpleChart(chart)),
          ],
        ),
      ),
    );
  }

  IconData _getChartIcon(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return Icons.bar_chart;
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.pie:
        return Icons.pie_chart;
      case ChartType.doughnut:
        return Icons.donut_small;
    }
  }

  Widget _buildSimpleChart(ChartData chart) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: _buildAdvancedChart(chart),
    );
  }

  Widget _buildAdvancedChart(ChartData chart) {
    switch (chart.type) {
      case ChartType.bar:
        return _buildBarChart(chart);
      case ChartType.line:
        return _buildLineChart(chart);
      case ChartType.pie:
        return _buildPieChart(chart);
      case ChartType.doughnut:
        return _buildDoughnutChart(chart);
    }
  }

  Widget _buildBarChart(ChartData chart) {
    final maxValue = chart.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                chart.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;
                  final height = (value / maxValue) * 100;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  chart.color,
                                  chart.color.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: chart.color.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chart.labels[index],
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(ChartData chart) {
    final maxValue = chart.values.reduce((a, b) => a > b ? a : b);
    final minValue = chart.values.reduce((a, b) => a < b ? a : b);

    return CustomPaint(
      painter: LineChartPainter(
        points: chart.values,
        labels: chart.labels,
        color: chart.color,
        maxValue: maxValue,
        minValue: minValue,
      ),
      child: Container(),
    );
  }

  Widget _buildPieChart(ChartData chart) {
    final total = chart.values.reduce((a, b) => a + b);
    final colors = _generateColors(chart.values.length, chart.color);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: PieChartPainter(
              values: chart.values,
              colors: colors,
              total: total,
            ),
            child: Container(),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                chart.labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final value = chart.values[index];
                  final percentage = (value / total * 100).toStringAsFixed(1);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$label: $percentage%',
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDoughnutChart(ChartData chart) {
    final total = chart.values.reduce((a, b) => a + b);
    final colors = _generateColors(chart.values.length, chart.color);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: DoughnutChartPainter(
              values: chart.values,
              colors: colors,
              total: total,
            ),
            child: Container(),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                chart.labels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final value = chart.values[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$label: ${value.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  List<Color> _generateColors(int count, Color baseColor) {
    return List.generate(count, (index) {
      final hue = (baseColor.blue8bit + (index * 360 / count)) % 360;
      return HSLColor.fromAHSL(1, hue, 0.7, 0.6).toColor();
    });
  }

  Widget _buildDrawingPreview(BuildContext context, DrawingData drawing) {
    return Card(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(8),
            child: Image.memory(drawing.imageBytes, fit: BoxFit.contain),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 16,
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  ref.read(documentProvider.notifier).deleteDrawing(drawing.id);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineView(BuildContext context) {
    final notifier = ref.read(documentProvider.notifier);
    final outline = notifier.generateOutline();

    if (outline.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No headings found.\nUse # for headings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: outline.length,
      itemBuilder: (context, index) {
        final item = outline[index];
        return ListTile(
          contentPadding: EdgeInsets.only(left: item.level * 16.0 + 8),
          dense: true,
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 14 - (item.level * 0.5),
              fontWeight: item.level == 1 ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            // Jump to heading position
            ref
                .read(documentProvider)
                .controller
                .updateSelection(
                  TextSelection.collapsed(offset: item.offset),
                  ChangeSource.local,
                );
            _focusNode.requestFocus();
          },
        );
      },
    );
  }

  void _showTitleDialog(BuildContext context) {
    final controller = TextEditingController(
      text: ref.read(documentProvider).metadata.title,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Document Title'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  ref.read(documentProvider.notifier).updateTitle(value.trim());
                  Navigator.pop(context);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    ref
                        .read(documentProvider.notifier)
                        .updateTitle(controller.text.trim());
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => MoreOptions());
  }
}
