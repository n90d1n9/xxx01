import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../models/terminal_models.dart';
import '../utils/virtual_filesystem.dart';
import '../utils/command_processor.dart';

// ── Global input controller ────────────────────────────────────────────────────
// A single TextEditingController shared across the input bar and sidebar history.
// Kept outside Riverpod so widgets that only need to *write* to it don't rebuild.
final globalInputController = TextEditingController();

// ── Per-tab VirtualFilesystem ─────────────────────────────────────────────────
// No singleton. Each tab gets its own FS instance so cd in tab 1 never
// affects tab 2. Stored inside TabsNotifier alongside its TerminalTab.
class _TabEntry {
  final TerminalTab tab;
  final VirtualFileSystem fs;
  const _TabEntry(this.tab, this.fs);
}

// ── Tab state ─────────────────────────────────────────────────────────────────
class TabsNotifier extends Notifier<List<TerminalTab>> {
  // Parallel list; index always matches state list index.
  final List<VirtualFileSystem> _fsList = [];
  int _counter = 0;

  @override
  List<TerminalTab> build() {
    final entry = _makeTab();
    _fsList.add(entry.fs);
    return [entry.tab];
  }

  _TabEntry _makeTab() {
    _counter++;
    final fs = VirtualFileSystem();
    final welcome = [
      TerminalOutput.system('Flutter Terminal v2.0.0 — robust CLI emulator'),
      TerminalOutput.system(
          'Type \x1B[32mhelp\x1B[0m for all commands  •  Tab to complete  •  ↑↓ for history'),
      TerminalOutput.separator(),
    ];
    final tab = TerminalTab(
      id: 'tab_$_counter',
      title: 'bash',
      workingDirectory: '/home/user',
      outputs: welcome,
      historyIndex: 0,
      isActive: true,
    );
    return _TabEntry(tab, fs);
  }

  VirtualFileSystem fsFor(String tabId) {
    final idx = state.indexWhere((t) => t.id == tabId);
    if (idx == -1) return VirtualFileSystem();
    return _fsList[idx];
  }

  // ── Tab lifecycle ───────────────────────────────────────────────────────────
  void addTab() {
    // Deactivate all current tabs.
    state = state.map((t) => t.copyWith(isActive: false)).toList();
    final entry = _makeTab();
    _fsList.add(entry.fs);
    state = [...state, entry.tab];
  }

  void closeTab(String id) {
    if (state.length == 1) return;
    final idx = state.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final wasActive = state[idx].isActive;
    final newState = List<TerminalTab>.of(state)..removeAt(idx);
    _fsList.removeAt(idx);
    if (wasActive && newState.isNotEmpty) {
      final newIdx = (idx - 1).clamp(0, newState.length - 1);
      newState[newIdx] = newState[newIdx].copyWith(isActive: true);
    }
    state = newState;
  }

  void setActiveTab(String id) {
    state = state.map((t) => t.copyWith(isActive: t.id == id)).toList();
  }

  // ── Output mutations ────────────────────────────────────────────────────────
  void addOutput(String tabId, TerminalOutput output) {
    state = [
      for (final t in state)
        if (t.id == tabId) t.withOutput(output) else t,
    ];
  }

  void clearOutput(String tabId) {
    state = [
      for (final t in state)
        if (t.id == tabId) t.copyWith(outputs: []) else t,
    ];
  }

  // ── History mutations ───────────────────────────────────────────────────────
  void pushHistory(String tabId, String command) {
    state = [
      for (final t in state)
        if (t.id == tabId) t.withHistory(command) else t,
    ];
  }

  // historyIndex == history.length means "nothing previewed" (at the live prompt).
  void setHistoryIndex(String tabId, int index) {
    state = [
      for (final t in state)
        if (t.id == tabId) t.copyWith(historyIndex: index) else t,
    ];
  }

  // ── Directory change ────────────────────────────────────────────────────────
  void updateDirectory(String tabId, String dir) {
    state = [
      for (final t in state)
        if (t.id == tabId)
          t.copyWith(
            workingDirectory: dir,
            title: _shortTitle(dir),
          )
        else
          t,
    ];
  }

  // ── Busy flag (per tab, not global) ────────────────────────────────────────
  void setBusy(String tabId, bool busy) {
    state = [
      for (final t in state)
        if (t.id == tabId) t.copyWith(isBusy: busy) else t,
    ];
  }

  String _shortTitle(String dir) {
    if (dir == '/home/user') return '~';
    if (dir.startsWith('/home/user/')) return dir.substring('/home/user/'.length);
    final parts = dir.split('/')..removeWhere((p) => p.isEmpty);
    return parts.isEmpty ? '/' : parts.last;
  }
}

final tabsProvider = NotifierProvider<TabsNotifier, List<TerminalTab>>(
  TabsNotifier.new,
);

final activeTabProvider = Provider<TerminalTab?>((ref) {
  return ref.watch(tabsProvider).firstWhereOrNull((t) => t.isActive);
});

// ── Command execution (per-tab isBusy, not a single global bool) ──────────────
class CommandExecutionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> execute(String command, String tabId) async {
    final tabsN = ref.read(tabsProvider.notifier);
    final tab   = ref.read(tabsProvider).firstWhereOrNull((t) => t.id == tabId);
    if (tab == null || tab.isBusy) return;

    tabsN.setBusy(tabId, true);

    // Echo input first.
    tabsN.addOutput(tabId, TerminalOutput.input(command));
    tabsN.pushHistory(tabId, command);

    // Each execution gets the tab's own FS.
    final fs = tabsN.fsFor(tabId);

    final processor = CommandProcessor(
      fs: fs,
      onOutput:    (o) => tabsN.addOutput(tabId, o),
      onClear:     ()  => tabsN.clearOutput(tabId),
      onChangeDir: (d) => tabsN.updateDirectory(tabId, d),
    );

    try {
      await processor.execute(command);
    } catch (e) {
      tabsN.addOutput(tabId, TerminalOutput.error('Internal error: $e'));
    } finally {
      tabsN.setBusy(tabId, false);
    }
  }
}

final commandExecutionProvider =
    NotifierProvider<CommandExecutionNotifier, void>(CommandExecutionNotifier.new);

// ── Settings ──────────────────────────────────────────────────────────────────
class TerminalSettings {
  final double fontSize;
  final bool showLineNumbers;
  final bool blinkCursor;
  final bool sidebarOpen;
  final bool compactMode;

  const TerminalSettings({
    this.fontSize       = 13.0,
    this.showLineNumbers= false,
    this.blinkCursor    = true,
    this.sidebarOpen    = true,
    this.compactMode    = false,
  });

  TerminalSettings copyWith({
    double? fontSize,
    bool?   showLineNumbers,
    bool?   blinkCursor,
    bool?   sidebarOpen,
    bool?   compactMode,
  }) => TerminalSettings(
    fontSize:        fontSize        ?? this.fontSize,
    showLineNumbers: showLineNumbers ?? this.showLineNumbers,
    blinkCursor:     blinkCursor     ?? this.blinkCursor,
    sidebarOpen:     sidebarOpen     ?? this.sidebarOpen,
    compactMode:     compactMode     ?? this.compactMode,
  );
}

class SettingsNotifier extends Notifier<TerminalSettings> {
  @override
  TerminalSettings build() => const TerminalSettings();

  void increaseFontSize()  => state = state.copyWith(fontSize: (state.fontSize + 1).clamp(8.0, 26.0));
  void decreaseFontSize()  => state = state.copyWith(fontSize: (state.fontSize - 1).clamp(8.0, 26.0));
  void toggleSidebar()     => state = state.copyWith(sidebarOpen:     !state.sidebarOpen);
  void toggleLineNumbers() => state = state.copyWith(showLineNumbers: !state.showLineNumbers);
  void toggleBlinkCursor() => state = state.copyWith(blinkCursor:     !state.blinkCursor);
  void toggleCompact()     => state = state.copyWith(compactMode:     !state.compactMode);
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, TerminalSettings>(SettingsNotifier.new);

// ── Search ────────────────────────────────────────────────────────────────────
class SearchNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void open()         => state = '';
  void close()        => state = null;
  void update(String q) => state = q;
}

final searchProvider =
    NotifierProvider<SearchNotifier, String?>(SearchNotifier.new);
