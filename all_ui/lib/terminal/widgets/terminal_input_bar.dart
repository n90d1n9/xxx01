import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import '../utils/command_processor.dart';

class TerminalInputBar extends ConsumerStatefulWidget {
  const TerminalInputBar({super.key});

  @override
  ConsumerState<TerminalInputBar> createState() => _TerminalInputBarState();
}

class _TerminalInputBarState extends ConsumerState<TerminalInputBar> {
  // Re-use the global controller so history-click in sidebar populates the field.
  TextEditingController get _ctrl => globalInputController;
  final _focus = FocusNode();

  List<String> _suggestions   = [];
  bool         _showSugg      = false;
  int          _suggIdx       = -1;
  int          _tabCycleIdx   = 0;   // cycles through matches on repeated Tab
  String       _tabPrefix     = '';  // the text that triggered the cycle

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChanged);
    _focus.dispose();
    // Do NOT dispose globalInputController here — it's global.
    super.dispose();
  }

  // ── Text change → autocomplete ─────────────────────────────────────────────
  void _onTextChanged() {
    _updateSuggestions(_ctrl.text);
  }

  void _updateSuggestions(String text) {
    if (text.isEmpty) {
      _clearSugg(); return;
    }

    final parts       = text.split(' ');
    final isFirstWord = parts.length == 1;
    final partial     = parts.last;

    if (isFirstWord) {
      // Command autocomplete — derived from the single source of truth.
      final matches = kBuiltinCommands.where((c) => c.startsWith(partial) && c != partial).toList()..sort();
      if (matches.isEmpty) { _clearSugg(); return; }
      setState(() {
        _suggestions = matches;
        _showSugg    = true;
        _suggIdx     = -1;
      });
    } else if (partial.isNotEmpty) {
      // Path autocomplete after the first word.
      final tab = ref.read(activeTabProvider);
      if (tab == null) { _clearSugg(); return; }
      final fs      = ref.read(tabsProvider.notifier).fsFor(tab.id);
      final dirsOnly= const {'cd', 'ls', 'mkdir', 'rmdir', 'tree', 'du'}.contains(parts.first);
      final matches = fs.autocomplete(partial, dirsOnly: dirsOnly);
      if (matches.isEmpty) { _clearSugg(); return; }
      setState(() {
        _suggestions = matches;
        _showSugg    = true;
        _suggIdx     = -1;
      });
    } else {
      _clearSugg();
    }
  }

  void _clearSugg() {
    if (_showSugg || _suggestions.isNotEmpty) {
      setState(() { _showSugg = false; _suggestions = []; _suggIdx = -1; });
    }
  }

  // ── Tab: cycle through completions ─────────────────────────────────────────
  void _handleTab() {
    if (_suggestions.isEmpty) return;

    final text  = _ctrl.text;
    final parts = text.split(' ');

    // On first Tab: record the prefix so repeated tabs cycle without filtering.
    if (_tabPrefix != text.split(' ').last) {
      _tabPrefix    = text.split(' ').last;
      _tabCycleIdx  = 0;
    } else {
      _tabCycleIdx  = (_tabCycleIdx + 1) % _suggestions.length;
    }

    final completion = _suggestions[_tabCycleIdx];
    parts[parts.length - 1] = completion;
    final newText = parts.join(' ');
    _ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    // Show the selection visually.
    setState(() { _suggIdx = _tabCycleIdx; });
  }

  // ── Enter ──────────────────────────────────────────────────────────────────
  void _handleEnter() {
    final cmd = _ctrl.text.trim();
    if (cmd.isEmpty) return;
    final tab = ref.read(activeTabProvider);
    if (tab == null || tab.isBusy) return;

    ref.read(commandExecutionProvider.notifier).execute(cmd, tab.id);
    _ctrl.clear();
    _clearSugg();
    _tabPrefix = '';
  }

  // ── History navigation (↑ / ↓) ─────────────────────────────────────────────
  // historyIndex == history.length  →  live prompt (empty or user-typed text)
  void _handleUp() {
    final tab = ref.read(activeTabProvider);
    if (tab == null || tab.history.isEmpty) return;

    // historyIndex starts at history.length (no preview). First ↑ goes to last entry.
    final newIdx = (tab.historyIndex - 1).clamp(0, tab.history.length - 1);
    if (newIdx == tab.historyIndex) return; // already at oldest
    ref.read(tabsProvider.notifier).setHistoryIndex(tab.id, newIdx);
    _ctrl.value = TextEditingValue(
      text: tab.history[newIdx],
      selection: TextSelection.collapsed(offset: tab.history[newIdx].length),
    );
    _clearSugg();
  }

  void _handleDown() {
    final tab = ref.read(activeTabProvider);
    if (tab == null) return;

    if (tab.historyIndex >= tab.history.length) return; // already at live prompt

    final newIdx = tab.historyIndex + 1;
    ref.read(tabsProvider.notifier).setHistoryIndex(tab.id, newIdx);

    if (newIdx >= tab.history.length) {
      // Back at live prompt — restore empty field.
      _ctrl.clear();
    } else {
      _ctrl.value = TextEditingValue(
        text: tab.history[newIdx],
        selection: TextSelection.collapsed(offset: tab.history[newIdx].length),
      );
    }
    _clearSugg();
  }

  // ── Global keyboard shortcuts ──────────────────────────────────────────────
  KeyEventResult _handleKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;

    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final key  = event.logicalKey;

    if (ctrl && key == LogicalKeyboardKey.keyL) {
      final tab = ref.read(activeTabProvider);
      if (tab != null) ref.read(tabsProvider.notifier).clearOutput(tab.id);
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyT) {
      ref.read(tabsProvider.notifier).addTab();
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyF) {
      ref.read(searchProvider.notifier).open();
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyW) {
      // Close active tab.
      final tab = ref.read(activeTabProvider);
      if (tab != null) ref.read(tabsProvider.notifier).closeTab(tab.id);
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyC) {
      // Cancel current input (like bash Ctrl+C).
      _ctrl.clear();
      _clearSugg();
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyU) {
      // Kill to beginning of line.
      _ctrl.clear();
      _clearSugg();
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyA) {
      // Jump to start of line.
      _ctrl.selection = const TextSelection.collapsed(offset: 0);
      return KeyEventResult.handled;
    }
    if (ctrl && key == LogicalKeyboardKey.keyE) {
      // Jump to end of line.
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.tab) {
      _handleTab();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      if (_showSugg) {
        setState(() => _suggIdx = (_suggIdx - 1).clamp(0, _suggestions.length - 1));
      } else {
        _handleUp();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      if (_showSugg) {
        setState(() => _suggIdx = (_suggIdx + 1).clamp(0, _suggestions.length - 1));
      } else {
        _handleDown();
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _clearSugg();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);
    final settings  = ref.watch(settingsProvider);
    final isBusy    = activeTab?.isBusy ?? false;
    final dir       = activeTab?.workingDirectory ?? '/home/user';
    final shortDir  = dir.replaceFirst('/home/user', '~');
    final fs        = fontSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Autocomplete popup ───────────────────────────────────────────────
        if (_showSugg && _suggestions.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TerminalTheme.surfaceElevated,
              border: Border.all(color: TerminalTheme.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _suggestions.asMap().entries.map((e) {
                final sel = e.key == _suggIdx;
                return GestureDetector(
                  onTap: () {
                    setState(() { _suggIdx = e.key; _tabCycleIdx = e.key; });
                    _handleTab();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sel ? TerminalTheme.blue.withOpacity(0.15) : Colors.transparent,
                      border: Border.all(
                        color: sel ? TerminalTheme.blue : TerminalTheme.border,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: settings.fontSize - 1,
                        color: sel ? TerminalTheme.blue : TerminalTheme.green,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // ── Prompt + input ──────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: settings.compactMode ? 6 : 10,
          ),
          decoration: const BoxDecoration(
            color: TerminalTheme.surface,
            border: Border(top: BorderSide(color: TerminalTheme.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Git-style prompt segments.
              _PromptSegment(shortDir: shortDir, fontSize: settings.fontSize),
              const SizedBox(width: 2),

              // Text field.
              Expanded(
                child: Focus(
                  onKeyEvent: _handleKey,
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    enabled: !isBusy,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: settings.fontSize,
                      color: TerminalTheme.textPrimary,
                      height: 1.4,
                    ),
                    cursorColor: TerminalTheme.cursor,
                    cursorWidth: 7,
                    cursorHeight: settings.fontSize * 1.2,
                    cursorRadius: const Radius.circular(1),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) {
                      _handleEnter();
                      _focus.requestFocus();
                    },
                  ),
                ),
              ),

              // Busy spinner (per-tab, not global).
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: TerminalTheme.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  double get fontSize => 13; // fallback; real value from settings in build
}

// ── Prompt display ─────────────────────────────────────────────────────────────
class _PromptSegment extends StatelessWidget {
  final String shortDir;
  final double fontSize;
  const _PromptSegment({required this.shortDir, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        // user@host
        TextSpan(
          text: 'user',
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize, height: 1.4,
            color: TerminalTheme.green, fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '@flutter-terminal',
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize, height: 1.4,
            color: TerminalTheme.green,
          ),
        ),
        TextSpan(
          text: ':',
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize, height: 1.4,
            color: TerminalTheme.textMuted,
          ),
        ),
        // cwd
        TextSpan(
          text: shortDir,
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize, height: 1.4,
            color: TerminalTheme.blue, fontWeight: FontWeight.bold,
          ),
        ),
        // arrow
        TextSpan(
          text: ' ❯ ',
          style: TextStyle(
            fontFamily: 'JetBrains Mono', fontSize: fontSize, height: 1.4,
            color: TerminalTheme.purple, fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
  }
}
