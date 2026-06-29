import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/docs_provider.dart';
import 'slash_menu_content.dart';

class SlashCommandEditor extends ConsumerStatefulWidget {
  final quill.QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;

  const SlashCommandEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
  });

  @override
  ConsumerState<SlashCommandEditor> createState() => _SlashCommandEditorState();
}

class _SlashCommandEditorState extends ConsumerState<SlashCommandEditor> {
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.document.toPlainText();
    final selection = widget.controller.selection;

    if (selection.baseOffset > 0) {
      final beforeCursor = text.substring(0, selection.baseOffset);
      final lastLine = beforeCursor.split('\n').last;

      if (lastLine.startsWith('/')) {
        _searchQuery = lastLine.substring(1);
        _showSlashMenu();
      } else {
        _removeOverlay();
      }
    }
  }

  void _showSlashMenu() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: MediaQuery.of(context).size.width / 2 - 200,
            top: 200,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: SlashMenuContent(
                  query: _searchQuery,
                  onSelect: _handleBlockSelection,
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleBlockSelection(String blockType) {
    final selection = widget.controller.selection;
    final text = widget.controller.document.toPlainText();
    final beforeCursor = text.substring(0, selection.baseOffset);
    final lastLineStart = beforeCursor.lastIndexOf('\n') + 1;

    widget.controller.replaceText(
      lastLineStart,
      selection.baseOffset - lastLineStart,
      '',
      TextSelection.collapsed(offset: lastLineStart),
    );

    ref.read(documentControllerProvider.notifier).insertBlock(blockType);
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return quill.QuillEditor.basic(
      controller: widget.controller,
      focusNode: widget.focusNode,
      scrollController: widget.scrollController,
      config: quill.QuillEditorConfig(
        padding: const EdgeInsets.all(48),
        placeholder: 'Type "/" for commands, or start writing...',
        customStyles: quill.DefaultStyles(
          placeHolder: quill.DefaultTextBlockStyle(
            TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const quill.HorizontalSpacing(0, 0),
            const quill.VerticalSpacing(0, 0),
            const quill.VerticalSpacing(0, 0),
            BoxDecoration(),
          ),
        ),
      ),
    );
  }
}
