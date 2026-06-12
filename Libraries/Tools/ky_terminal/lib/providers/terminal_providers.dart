import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/terminal_models.dart';
import '../utils/virtual_filesystem.dart';
import '../utils/command_processor.dart';
import 'package:collection/collection.dart';

// ── Virtual FS singleton ────────────────────────────────────────────────────
final virtualFsProvider = Provider<VirtualFileSystem>((_) => VirtualFileSystem());

// ── Tab State ───────────────────────────────────────────────────────────────
class TabsNotifier extends Notifier<List<TerminalTab>> {
  int _counter = 1;

  @override
  List<TerminalTab> build() {
    return [_createTab()];
  }

  TerminalTab _createTab() {
    final tab = TerminalTab(
      id: 'tab_${_counter++}',
      title: 'Terminal $_counter',
      workingDirectory: '/home/user',
      isActive: true,
    );
    // Welcome message
    tab.outputs.addAll([
      TerminalOutput.system('Flutter Terminal v1.0.0 — Advanced CLI Emulator'),
      TerminalOutput.system('Type \x1B[32mhelp\x1B[0m for a list of commands. Tab to autocomplete.'),
      TerminalOutput.separator(),
    ]);
    return tab;
  }

  void addTab() {
    state = state.map((t) => t.copyWith(isActive: false)).toList();
    final newTab = _createTab();
    state = [...state, newTab];
  }

  void closeTab(String id) {
    if (state.length == 1) return; // Keep at least one tab
    final idx = state.indexWhere((t) => t.id == id);
    final wasActive = state[idx].isActive;
    final newState = state.where((t) => t.id != id).toList();
    if (wasActive && newState.isNotEmpty) {
      final newIdx = (idx - 1).clamp(0, newState.length - 1);
      newState[newIdx] = newState[newIdx].copyWith(isActive: true);
    }
    state = newState;
  }

  void setActiveTab(String id) {
    state = state.map((t) => t.copyWith(isActive: t.id == id)).toList();
  }

  void addOutput(String tabId, TerminalOutput output) {
    state = state.map((t) {
      if (t.id == tabId) {
        return t.copyWith(outputs: [...t.outputs, output]);
      }
      return t;
    }).toList();
  }

  void clearOutput(String tabId) {
    state = state.map((t) {
      if (t.id == tabId) return t.copyWith(outputs: []);
      return t;
    }).toList();
  }

  void addHistory(String tabId, String command) {
    state = state.map((t) {
      if (t.id == tabId) {
        final hist = [...t.history];
        if (hist.isEmpty || hist.last != command) {
          hist.add(command);
        }
        return t.copyWith(history: hist, historyIndex: hist.length);
      }
      return t;
    }).toList();
  }

  void setHistoryIndex(String tabId, int index) {
    state = state.map((t) {
      if (t.id == tabId) return t.copyWith(historyIndex: index);
      return t;
    }).toList();
  }

  void updateDirectory(String tabId, String dir) {
    state = state.map((t) {
      if (t.id == tabId) {
        // Update title to show last dir component
        final parts = dir.split('/')..removeWhere((p) => p.isEmpty);
        final title = parts.isEmpty ? '/' : parts.last;
        return t.copyWith(workingDirectory: dir, title: title);
      }
      return t;
    }).toList();
  }
}

final tabsProvider = NotifierProvider<TabsNotifier, List<TerminalTab>>(
  TabsNotifier.new,
);

final activeTabProvider = Provider<TerminalTab?>((ref) {
  final tabs = ref.watch(tabsProvider);
  return tabs.firstWhereOrNull((t) => t.isActive);
});

// ── Command Execution ───────────────────────────────────────────────────────
class CommandExecutionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> execute(String command, String tabId) async {
    if (state) return; // busy
    state = true;

    final tabsNotifier = ref.read(tabsProvider.notifier);
    final fs = ref.read(virtualFsProvider);

    // Echo the input
    tabsNotifier.addOutput(tabId, TerminalOutput.input(command));
    tabsNotifier.addHistory(tabId, command);

    final processor = CommandProcessor(
      fs: fs,
      onOutput: (output) => tabsNotifier.addOutput(tabId, output),
      onClear: () => tabsNotifier.clearOutput(tabId),
      onChangeDir: (dir) => tabsNotifier.updateDirectory(tabId, dir),
    );

    await processor.execute(command);
    state = false;
  }
}

final commandExecutionProvider =
    NotifierProvider<CommandExecutionNotifier, bool>(
  CommandExecutionNotifier.new,
);

// ── Input State ─────────────────────────────────────────────────────────────
class InputNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

final inputProvider = NotifierProvider<InputNotifier, String>(InputNotifier.new);

// ── Settings ─────────────────────────────────────────────────────────────────
class TerminalSettings {
  final double fontSize;
  final bool showLineNumbers;
  final bool blinkCursor;
  final bool soundEnabled;
  final String theme;
  final bool sidebarOpen;

  const TerminalSettings({
    this.fontSize = 13.0,
    this.showLineNumbers = false,
    this.blinkCursor = true,
    this.soundEnabled = false,
    this.theme = 'dark',
    this.sidebarOpen = true,
  });

  TerminalSettings copyWith({
    double? fontSize,
    bool? showLineNumbers,
    bool? blinkCursor,
    bool? soundEnabled,
    String? theme,
    bool? sidebarOpen,
  }) {
    return TerminalSettings(
      fontSize: fontSize ?? this.fontSize,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      blinkCursor: blinkCursor ?? this.blinkCursor,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      theme: theme ?? this.theme,
      sidebarOpen: sidebarOpen ?? this.sidebarOpen,
    );
  }
}

class SettingsNotifier extends Notifier<TerminalSettings> {
  @override
  TerminalSettings build() => const TerminalSettings();

  void increaseFontSize() => state = state.copyWith(fontSize: (state.fontSize + 1).clamp(9.0, 24.0));
  void decreaseFontSize() => state = state.copyWith(fontSize: (state.fontSize - 1).clamp(9.0, 24.0));
  void toggleSidebar() => state = state.copyWith(sidebarOpen: !state.sidebarOpen);
  void toggleLineNumbers() => state = state.copyWith(showLineNumbers: !state.showLineNumbers);
  void toggleBlinkCursor() => state = state.copyWith(blinkCursor: !state.blinkCursor);
}

final settingsProvider = NotifierProvider<SettingsNotifier, TerminalSettings>(
  SettingsNotifier.new,
);

// ── Search ───────────────────────────────────────────────────────────────────
class SearchNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void open() => state = '';
  void close() => state = null;
  void set(String query) => state = query;
  bool get isOpen => state != null;
}

final searchProvider = NotifierProvider<SearchNotifier, String?>(SearchNotifier.new);
