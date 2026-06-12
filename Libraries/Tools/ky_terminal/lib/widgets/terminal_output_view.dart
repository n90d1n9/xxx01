import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import 'output_line_widget.dart';

class TerminalOutputView extends ConsumerStatefulWidget {
  const TerminalOutputView({super.key});

  @override
  ConsumerState<TerminalOutputView> createState() => _TerminalOutputViewState();
}

class _TerminalOutputViewState extends ConsumerState<TerminalOutputView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);
    final settings = ref.watch(settingsProvider);
    final searchQuery = ref.watch(searchProvider);

    if (activeTab == null) return const SizedBox();

    final outputs = activeTab.outputs;

    // Scroll on new output
    ref.listen(activeTabProvider, (prev, next) {
      if (next != null && (prev?.outputs.length ?? 0) < next.outputs.length) {
        _scrollToBottom();
      }
    });

    // Filter by search
    final filteredOutputs = searchQuery != null && searchQuery.isNotEmpty
        ? outputs.where((o) => o.text.toLowerCase().contains(searchQuery.toLowerCase())).toList()
        : outputs;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SelectionArea(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: filteredOutputs.length,
          itemBuilder: (_, i) => OutputLineWidget(
            output: filteredOutputs[i],
            fontSize: settings.fontSize,
            showLineNumber: settings.showLineNumbers,
            lineNumber: i + 1,
            searchQuery: searchQuery,
          ),
        ),
      ),
    );
  }
}

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: TerminalTheme.surfaceElevated,
        border: Border(bottom: BorderSide(color: TerminalTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 16, color: TerminalTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (e) {
                if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.escape) {
                  ref.read(searchProvider.notifier).close();
                }
              },
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: TerminalTheme.monoFont.copyWith(fontSize: 13),
                cursorColor: TerminalTheme.cursor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Search output...',
                  hintStyle: TerminalTheme.monoFont.copyWith(
                    fontSize: 13,
                    color: TerminalTheme.textMuted,
                  ),
                ),
                onChanged: (v) => ref.read(searchProvider.notifier).set(v),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(searchProvider.notifier).close(),
            child: const Icon(Icons.close, size: 16, color: TerminalTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
