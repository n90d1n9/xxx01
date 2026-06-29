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
  final _scrollCtrl = ScrollController();
  bool _userScrolledUp = false; // suppress auto-scroll when user reads history

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);

    // Register the scroll listener once — never inside build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(activeTabProvider, (prev, next) {
        if (!mounted) return;
        final prevLen = prev?.outputs.length ?? 0;
        final nextLen = next?.outputs.length ?? 0;
        if (nextLen > prevLen && !_userScrolledUp) {
          _scrollToBottom();
        }
      });
    });
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final atBottom = _scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 40;
    if (atBottom != !_userScrolledUp) {
      setState(() => _userScrolledUp = !atBottom);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab   = ref.watch(activeTabProvider);
    final settings    = ref.watch(settingsProvider);
    final searchQuery = ref.watch(searchProvider);

    if (activeTab == null) return const SizedBox.expand();

    final outputs = searchQuery != null && searchQuery.isNotEmpty
        ? activeTab.outputs
            .where((o) => o.text.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList()
        : activeTab.outputs;

    return Stack(
      children: [
        SelectionArea(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: EdgeInsets.symmetric(
              vertical: settings.compactMode ? 6 : 12,
            ),
            itemCount: outputs.length,
            itemBuilder: (_, i) => OutputLineWidget(
              output: outputs[i],
              fontSize: settings.fontSize,
              showLineNumber: settings.showLineNumbers,
              lineNumber: i + 1,
              searchQuery: searchQuery,
            ),
          ),
        ),

        // ── Scroll-to-bottom FAB ───────────────────────────────────────────
        if (_userScrolledUp)
          Positioned(
            right: 16,
            bottom: 8,
            child: Material(
              color: TerminalTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() => _userScrolledUp = false);
                  _scrollToBottom();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: TerminalTheme.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, size: 12, color: TerminalTheme.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'Jump to bottom',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          color: TerminalTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
// Fixed: leaked FocusNode replaced with a properly stored & disposed node.
// Escape is handled via the stored FocusNode's onKeyEvent, not an inline new FocusNode.
class TerminalSearchBar extends ConsumerStatefulWidget {
  const TerminalSearchBar({super.key});

  @override
  ConsumerState<TerminalSearchBar> createState() => _TerminalSearchBarState();
}

class _TerminalSearchBarState extends ConsumerState<TerminalSearchBar> {
  final _ctrl      = TextEditingController();
  final _focusNode = FocusNode();           // stored → disposed
  final _keyNode   = FocusNode();           // for KeyboardListener → disposed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _keyNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(activeTabProvider)?.outputs.length ?? 0;
    final query = ref.watch(searchProvider) ?? '';
    final matches = query.isEmpty
        ? 0
        : ref.watch(activeTabProvider)?.outputs
              .where((o) => o.text.toLowerCase().contains(query.toLowerCase()))
              .length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: TerminalTheme.surfaceElevated,
        border: Border(bottom: BorderSide(color: TerminalTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 15, color: TerminalTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: KeyboardListener(
              focusNode: _keyNode,
              onKeyEvent: (e) {
                if (e is KeyDownEvent &&
                    e.logicalKey == LogicalKeyboardKey.escape) {
                  ref.read(searchProvider.notifier).close();
                }
              },
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                style: TerminalTheme.monoFont.copyWith(fontSize: 13),
                cursorColor: TerminalTheme.cursor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Search output…',
                  hintStyle: TerminalTheme.monoFont.copyWith(
                    fontSize: 13, color: TerminalTheme.textMuted,
                  ),
                ),
                onChanged: (v) => ref.read(searchProvider.notifier).update(v),
              ),
            ),
          ),
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '$matches match${matches == 1 ? "" : "es"}',
                style: TerminalTheme.monoFont.copyWith(
                  fontSize: 11,
                  color: matches > 0 ? TerminalTheme.green : TerminalTheme.red,
                ),
              ),
            ),
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => ref.read(searchProvider.notifier).close(),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: TerminalTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
