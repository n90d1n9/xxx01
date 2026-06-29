import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queue_ui/docs/screens/editor_with_ruler.dart';

import '../models/document_stats.dart';
import '../states/attachment_provider.dart';
import '../states/collaboration_provider.dart';
import '../states/command_provider.dart';
import '../states/docs_provider.dart';
import '../states/layout_provider.dart';
import '../states/word_count_provider.dart';
import '../widgets/attachment_panel.dart';
import '../widgets/command_palette.dart';
import '../widgets/command_palette_button.dart';
import '../widgets/comment_button.dart';
import '../widgets/comment_panel.dart';
import '../widgets/custom_toolbar.dart';
import 'editor_with_inline.dart';
import '../widgets/save_indicator.dart';
import '../widgets/sharing_panel.dart';
import '../widgets/slash_comment_editor.dart';
import '../widgets/status_bar.dart';
import '../widgets/template_gallery_dialog.dart';
import '../widgets/version_history_panel.dart';

class DocumentEditorScreen extends ConsumerStatefulWidget {
  const DocumentEditorScreen({super.key});

  @override
  ConsumerState<DocumentEditorScreen> createState() =>
      _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends ConsumerState<DocumentEditorScreen> {
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyboard = HardwareKeyboard.instance;

      // Command/Ctrl + K for command palette
      if (event.logicalKey == LogicalKeyboardKey.keyK &&
          (keyboard.isMetaPressed || keyboard.isControlPressed)) {
        ref.read(commandPaletteProvider.notifier).state = true;
        return;
      }

      // Command/Ctrl + S to save
      if (event.logicalKey == LogicalKeyboardKey.keyS &&
          (keyboard.isMetaPressed || keyboard.isControlPressed)) {
        ref.read(documentControllerProvider.notifier).saveDocument();
        return;
      }

      // Escape to exit focus mode
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        final focusMode = ref.read(focusModeProvider);
        if (focusMode) {
          ref.read(focusModeProvider.notifier).state = false;
        }
      }

      // Command/Ctrl + P for print
      if ((event.logicalKey == LogicalKeyboardKey.keyP) &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed)) {
        _handlePrint();
      }

      // Command/Ctrl + K for command palette
      if ((event.logicalKey == LogicalKeyboardKey.keyK) &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed)) {
        ref.read(commandPaletteProvider.notifier).state = true;
      }

      // Command/Ctrl + S to save
      if ((event.logicalKey == LogicalKeyboardKey.keyS) &&
          (HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isControlPressed)) {
        ref.read(documentControllerProvider.notifier).saveDocument();
      }
    }
  }

  void _handlePrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing document for printing...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    final showCommandPalette = ref.watch(commandPaletteProvider);
    final docState = ref.watch(documentControllerProvider);
    final toolbarVisible = ref.watch(toolbarVisibilityProvider);
    final layoutMode = ref.watch(layoutModeProvider);
    _titleController.value = TextEditingValue(
      text: docState.title,
      selection: _titleController.selection,
    );

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: layoutMode != LayoutMode.focus ? const _DocumentAppBar() : null,
        body: Stack(
          children: [
            Column(
              children: [
                if (toolbarVisible && !focusMode)
                  CustomToolbar(controller: docState.controller),
                Expanded(
                  child: _DocumentContent(
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                  ),
                ),
                const _StatusBarSection(),
              ],
            ),
            if (showCommandPalette)
              CommandPalette(
                onDismiss: () {
                  ref.read(commandPaletteProvider.notifier).state = false;
                },
              ),
          ],
        ),
        floatingActionButton: focusMode ? const _ExitFocusModeButton() : null,
      ),
    );
  }
}

class _DocumentAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _DocumentAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentControllerProvider);
    final collabState = ref.watch(collaborationProvider);
    final focusMode = ref.watch(focusModeProvider);
    final themeMode = ref.watch(themeProvider);

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: DocumentTitleEditor(
        title: docState.title,
        onTitleChanged: (value) {
          ref.read(documentControllerProvider.notifier).updateTitle(value);
        },
      ),
      actions: [
        const SaveIndicator(),
        const CommentsButton(),
        const CommandPaletteButton(),
        // Collaboration status
        if (collabState.isConnected && collabState.activeUsers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ...collabState.activeUsers
                    .take(3)
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Tooltip(
                          message: user.name,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: user.color,
                            child: Text(
                              user.name[0],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                if (collabState.activeUsers.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey,
                      child: Text(
                        '+${collabState.activeUsers.length - 3}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Share button
        IconButton(
          icon: const Icon(Icons.people_outline, size: 20),
          tooltip: 'Share',
          onPressed: () => _showSharingPanel(context),
        ),
        // Version history
        IconButton(
          icon: const Icon(Icons.history, size: 20),
          tooltip: 'Version History',
          onPressed: () => _showVersionHistory(context),
        ),
        // Comments
        IconButton(
          icon: Badge(
            label: Text('${docState.comments.length}'),
            isLabelVisible: docState.comments.isNotEmpty,
            child: const Icon(Icons.comment_outlined, size: 20),
          ),
          tooltip: 'Comments',
          onPressed: () => _showCommentsPanel(context),
        ),
        // Attachments
        Consumer(
          builder: (context, ref, child) {
            final attachments = ref.watch(attachmentsProvider);
            return IconButton(
              icon: Badge(
                label: Text('${attachments.length}'),
                isLabelVisible: attachments.isNotEmpty,
                child: const Icon(Icons.attach_file, size: 20),
              ),
              tooltip: 'Attachments',
              onPressed: () => _showAttachmentsPanel(context),
            );
          },
        ),
        // More menu
        PopupMenuButton<void>(
          icon: const Icon(Icons.more_vert, size: 20),
          itemBuilder:
              (context) => [
                PopupMenuItem<void>(
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 12),
                      Text('New from Template'),
                    ],
                  ),
                  onTap: () => _showTemplateGallery(context),
                ),
                PopupMenuItem<void>(
                  child: const Row(
                    children: [
                      Icon(Icons.upload_file, size: 18),
                      SizedBox(width: 12),
                      Text('Upload File'),
                    ],
                  ),
                  onTap: () => _pickFile(ref, context),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<void>(
                  child: const Row(
                    children: [
                      Icon(Icons.download, size: 18),
                      SizedBox(width: 12),
                      Text('Export as JSON'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      final json =
                          ref
                              .read(documentControllerProvider.notifier)
                              .exportToJson();
                      Clipboard.setData(ClipboardData(text: json));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exported to clipboard')),
                      );
                    });
                  },
                ),
                PopupMenuItem<void>(
                  child: Row(
                    children: [
                      Icon(
                        focusMode ? Icons.fullscreen_exit : Icons.fullscreen,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(focusMode ? 'Exit Focus Mode' : 'Focus Mode'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      ref.read(focusModeProvider.notifier).state = !focusMode;
                    });
                  },
                ),
                PopupMenuItem<void>(
                  child: Row(
                    children: [
                      Icon(
                        themeMode ? Icons.light_mode : Icons.dark_mode,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(themeMode ? 'Light Mode' : 'Dark Mode'),
                    ],
                  ),
                  onTap: () => _toggleTheme(ref),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<void>(
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18),
                      SizedBox(width: 12),
                      Text('Document Info'),
                    ],
                  ),
                  onTap: () => _showDocumentInfo(context, ref),
                ),
              ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showSharingPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SharingPanel(),
    );
  }

  void _showVersionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const VersionHistoryPanel(),
    );
  }

  void _showCommentsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CommentsPanel(),
    );
  }

  void _showAttachmentsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AttachmentsPanel(),
    );
  }

  void _showTemplateGallery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TemplateGalleryDialog(),
    );
  }

  void _pickFile(WidgetRef ref, BuildContext context) {
    // Simulate file picker
    ref
        .read(attachmentsProvider.notifier)
        .addAttachment(
          'example_document.pdf',
          'application/pdf',
          1024576, // 1MB
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('File uploaded successfully')));
  }

  void _exportToJson(BuildContext context, WidgetRef ref) {
    final json = ref.read(documentControllerProvider.notifier).exportToJson();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exported to clipboard')));
  }

  void _toggleFocusMode(WidgetRef ref) {
    ref.read(focusModeProvider.notifier).state = !ref.read(focusModeProvider);
  }

  void _toggleTheme(WidgetRef ref) {
    ref.read(themeProvider.notifier).state = !ref.read(themeProvider);
  }

  void _showDocumentInfo(BuildContext context, WidgetRef ref) {
    final stats = ref.read(wordCountProvider);
    showDialog(
      context: context,
      builder: (context) => _DocumentInfoDialog(stats: stats),
    );
  }
}

class _DocumentInfoDialog extends StatelessWidget {
  final DocumentStats stats;

  const _DocumentInfoDialog({required this.stats});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Document Statistics'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Words', stats.words.toString()),
          _buildInfoRow('Characters', stats.characters.toString()),
          _buildInfoRow(
            'Characters (no spaces)',
            stats.charactersNoSpaces.toString(),
          ),
          _buildInfoRow('Paragraphs', stats.paragraphs.toString()),
          _buildInfoRow('Reading time', '${stats.readingTime} min'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}

class DocumentTitleEditor extends StatefulWidget {
  final String title;
  final ValueChanged<String> onTitleChanged;

  const DocumentTitleEditor({
    super.key,
    required this.title,
    required this.onTitleChanged,
  });

  @override
  State<DocumentTitleEditor> createState() => _DocumentTitleEditorState();
}

class _DocumentTitleEditorState extends State<DocumentTitleEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
  }

  @override
  void didUpdateWidget(covariant DocumentTitleEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title && _controller.text != widget.title) {
      _controller.text = widget.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.description_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Untitled Document',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              isDense: true,
            ),
            onChanged: widget.onTitleChanged,
          ),
        ),
      ],
    );
  }
}

class _DocumentContent extends ConsumerWidget {
  final FocusNode focusNode;
  final ScrollController scrollController;

  const _DocumentContent({
    required this.focusNode,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusMode = ref.watch(focusModeProvider);
    final docState = ref.watch(documentControllerProvider);

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: focusMode ? 900 : 800),
          margin: EdgeInsets.all(focusMode ? 48 : 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(focusMode ? 0 : 8),
            boxShadow:
                focusMode
                    ? null
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(focusMode ? 0 : 8),
            /*  child: EditorWithInlineButtons(
              controller: docState.controller,
              focusNode: focusNode,
              scrollController: scrollController,
            ), */
            child: EnhancedEditorWithRuler(
              controller: docState.controller,
              focusNode: focusNode,
              scrollController: scrollController,
            ),
            /*  child: SlashCommandEditor(
              controller: docState.controller,
              focusNode: focusNode,
              scrollController: scrollController,
            ), */
          ),
        ),
      ),
    );
  }
}

class _StatusBarSection extends ConsumerWidget {
  const _StatusBarSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusMode = ref.watch(focusModeProvider);
    final stats = ref.watch(wordCountProvider);
    final docState = ref.watch(documentControllerProvider);

    if (focusMode) return const SizedBox.shrink();

    return StatusBar(stats: stats, lastModified: docState.lastModified);
  }
}

class _ExitFocusModeButton extends ConsumerWidget {
  const _ExitFocusModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.small(
      onPressed: () {
        ref.read(focusModeProvider.notifier).state = false;
      },
      tooltip: 'Exit Focus Mode',
      child: const Icon(Icons.fullscreen_exit, size: 20),
    );
  }
}
