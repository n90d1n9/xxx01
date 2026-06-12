import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import '../utils/virtual_filesystem.dart';
import 'blinking_cursor.dart';

class TerminalInputBar extends ConsumerStatefulWidget {
  const TerminalInputBar({super.key});

  @override
  ConsumerState<TerminalInputBar> createState() => _TerminalInputBarState();
}

class _TerminalInputBarState extends ConsumerState<TerminalInputBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  int _suggestionIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    ref.read(inputProvider.notifier).set(text);
    _updateSuggestions(text);
  }

  void _updateSuggestions(String text) {
    if (text.isEmpty || text.contains(' ')) {
      // Autocomplete file/dir after first word
      if (text.contains(' ')) {
        final parts = text.split(' ');
        final partial = parts.last;
        if (partial.isNotEmpty) {
          final fs = ref.read(virtualFsProvider);
          final isDir = const ['cd', 'ls', 'rmdir'].contains(parts.first);
          final matches = fs.autocomplete(partial, dirsOnly: isDir);
          setState(() {
            _suggestions = matches;
            _showSuggestions = matches.isNotEmpty;
            _suggestionIndex = -1;
          });
          return;
        }
      }
      setState(() { _showSuggestions = false; _suggestions = []; });
      return;
    }

    // Command autocomplete
    const commands = [
      'help', 'ls', 'cd', 'pwd', 'cat', 'echo', 'clear', 'mkdir', 'touch',
      'rm', 'cp', 'mv', 'env', 'export', 'which', 'date', 'whoami',
      'hostname', 'uname', 'uptime', 'ps', 'df', 'du', 'free', 'top',
      'grep', 'find', 'wc', 'head', 'tail', 'sort', 'uniq', 'history',
      'alias', 'nano', 'vim', 'man', 'curl', 'ping', 'ifconfig', 'ip',
      'ssh', 'git', 'npm', 'python3', 'flutter', 'dart', 'neofetch',
      'banner', 'cowsay', 'fortune', 'cal', 'bc', 'seq', 'sleep', 'exit',
      'write', 'logout', 'yes', 'true', 'false',
    ];
    final matches = commands.where((c) => c.startsWith(text)).toList();
    setState(() {
      _suggestions = matches;
      _showSuggestions = matches.length > 1 || (matches.length == 1 && matches[0] != text);
      _suggestionIndex = -1;
    });
  }

  void _handleTab() {
    if (_suggestions.isEmpty) return;
    final text = _controller.text;
    if (text.contains(' ')) {
      final parts = text.split(' ');
      parts[parts.length - 1] = _suggestions[0];
      final newText = parts.join(' ');
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: newText.length);
    } else {
      final completed = _suggestions[0];
      _controller.text = completed;
      _controller.selection = TextSelection.collapsed(offset: completed.length);
    }
    setState(() { _showSuggestions = false; });
  }

  void _handleEnter() {
    final command = _controller.text.trim();
    if (command.isEmpty) return;

    final activeTab = ref.read(activeTabProvider);
    if (activeTab == null) return;

    final isBusy = ref.read(commandExecutionProvider);
    if (isBusy) return;

    ref.read(commandExecutionProvider.notifier).execute(command, activeTab.id);
    _controller.clear();
    setState(() { _showSuggestions = false; _suggestions = []; });
  }

  void _handleUp() {
    final activeTab = ref.read(activeTabProvider);
    if (activeTab == null) return;
    final hist = activeTab.history;
    if (hist.isEmpty) return;

    final newIdx = (activeTab.historyIndex - 1).clamp(0, hist.length - 1);
    ref.read(tabsProvider.notifier).setHistoryIndex(activeTab.id, newIdx);
    _controller.text = hist[newIdx];
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    setState(() { _showSuggestions = false; });
  }

  void _handleDown() {
    final activeTab = ref.read(activeTabProvider);
    if (activeTab == null) return;
    final hist = activeTab.history;

    final newIdx = activeTab.historyIndex + 1;
    if (newIdx >= hist.length) {
      ref.read(tabsProvider.notifier).setHistoryIndex(activeTab.id, hist.length);
      _controller.clear();
    } else {
      ref.read(tabsProvider.notifier).setHistoryIndex(activeTab.id, newIdx);
      _controller.text = hist[newIdx];
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
    setState(() { _showSuggestions = false; });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;

    // Ctrl+L = clear
    if (event.logicalKey == LogicalKeyboardKey.keyL &&
        HardwareKeyboard.instance.isControlPressed) {
      final activeTab = ref.read(activeTabProvider);
      if (activeTab != null) ref.read(tabsProvider.notifier).clearOutput(activeTab.id);
      return KeyEventResult.handled;
    }

    // Ctrl+T = new tab
    if (event.logicalKey == LogicalKeyboardKey.keyT &&
        HardwareKeyboard.instance.isControlPressed) {
      ref.read(tabsProvider.notifier).addTab();
      return KeyEventResult.handled;
    }

    // Ctrl+F = search
    if (event.logicalKey == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isControlPressed) {
      ref.read(searchProvider.notifier).open();
      return KeyEventResult.handled;
    }

    // Tab
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      _handleTab();
      return KeyEventResult.handled;
    }

    // Arrow up
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_showSuggestions) {
        setState(() {
          _suggestionIndex = (_suggestionIndex - 1).clamp(0, _suggestions.length - 1);
        });
      } else {
        _handleUp();
      }
      return KeyEventResult.handled;
    }

    // Arrow down
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_showSuggestions) {
        setState(() {
          _suggestionIndex = (_suggestionIndex + 1).clamp(0, _suggestions.length - 1);
        });
      } else {
        _handleDown();
      }
      return KeyEventResult.handled;
    }

    // Escape
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() { _showSuggestions = false; });
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(activeTabProvider);
    final settings = ref.watch(settingsProvider);
    final isBusy = ref.watch(commandExecutionProvider);
    final dir = activeTab?.workingDirectory ?? '/home/user';
    final user = 'user';
    final host = 'flutter-terminal';

    // Shorten path
    final shortDir = dir.replaceFirst('/home/user', '~');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Autocomplete suggestions
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TerminalTheme.surfaceElevated,
              border: Border.all(color: TerminalTheme.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _suggestions.asMap().entries.map((e) {
                final isSelected = e.key == _suggestionIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() { _suggestionIndex = e.key; });
                    _handleTab();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? TerminalTheme.blue.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: isSelected ? Border.all(color: TerminalTheme.blue) : null,
                    ),
                    child: Text(
                      e.value,
                      style: TerminalTheme.monoFont.copyWith(
                        fontSize: settings.fontSize - 1,
                        color: isSelected ? TerminalTheme.blue : TerminalTheme.green,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Input line
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: TerminalTheme.surface,
            border: Border(top: BorderSide(color: TerminalTheme.border)),
          ),
          child: Row(
            children: [
              // Prompt
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$user@$host',
                      style: TerminalTheme.monoFont.copyWith(
                        fontSize: settings.fontSize,
                        color: TerminalTheme.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ':',
                      style: TerminalTheme.monoFont.copyWith(
                        fontSize: settings.fontSize,
                        color: TerminalTheme.textMuted,
                      ),
                    ),
                    TextSpan(
                      text: shortDir,
                      style: TerminalTheme.monoFont.copyWith(
                        fontSize: settings.fontSize,
                        color: TerminalTheme.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' ❯ ',
                      style: TerminalTheme.monoFont.copyWith(
                        fontSize: settings.fontSize,
                        color: TerminalTheme.purple,
                      ),
                    ),
                  ],
                ),
              ),
              // Input field
              Expanded(
                child: Focus(
                  onKeyEvent: _handleKey,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: !isBusy,
                    style: TerminalTheme.monoFont.copyWith(
                      fontSize: settings.fontSize,
                      color: TerminalTheme.textPrimary,
                    ),
                    cursorColor: TerminalTheme.cursor,
                    cursorWidth: 8,
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
              if (isBusy)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TerminalTheme.blue,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
