import 'package:flutter/material.dart';

enum OutputType {
  input,
  output,
  error,
  warning,
  info,
  success,
  system,
  separator,
}

// ── TerminalOutput ────────────────────────────────────────────────────────────
// spans are parsed once at creation and cached — never re-parsed in build().
class TerminalOutput {
  final String text;
  final OutputType type;
  final DateTime timestamp;
  // Pre-parsed ANSI spans; null until first parse, then frozen.
  List<AnsiSpan>? _cachedSpans;

  TerminalOutput({
    required this.text,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Call once; subsequent calls return the same list.
  List<AnsiSpan> getSpans() {
    _cachedSpans ??= _parseAnsi(text);
    return _cachedSpans!;
  }

  // Lightweight inline ANSI parser (no import cycle with ansi_parser.dart).
  static const Map<int, Color> _ansiColors = {
    30: Color(0xFF484F58), 31: Color(0xFFF85149), 32: Color(0xFF3FB950),
    33: Color(0xFFD29922), 34: Color(0xFF58A6FF), 35: Color(0xFFBC8CFF),
    36: Color(0xFF76E3EA), 37: Color(0xFFE6EDF3), 90: Color(0xFF484F58),
    91: Color(0xFFFF7B72), 92: Color(0xFF56D364), 93: Color(0xFFF0883E),
    94: Color(0xFF58A6FF), 95: Color(0xFFBC8CFF), 96: Color(0xFF39C5CF),
    97: Color(0xFFFFFFFF),
  };

  static List<AnsiSpan> _parseAnsi(String text) {
    if (!text.contains('\x1B[')) return [AnsiSpan(text: text)];
    final spans = <AnsiSpan>[];
    final regex = RegExp(r'\x1B\[([0-9;]*)m');
    int lastEnd = 0;
    Color? color; Color? bg; bool bold = false, italic = false, underline = false;
    for (final m in regex.allMatches(text)) {
      if (m.start > lastEnd) {
        final t = text.substring(lastEnd, m.start);
        if (t.isNotEmpty) spans.add(AnsiSpan(text: t, color: color, background: bg, bold: bold, italic: italic, underline: underline));
      }
      for (final code in (m.group(1) ?? '0').split(';')) {
        final n = int.tryParse(code) ?? 0;
        if (n == 0) { color = null; bg = null; bold = false; italic = false; underline = false; }
        else if (n == 1) bold = true;
        else if (n == 3) italic = true;
        else if (n == 4) underline = true;
        else if (_ansiColors.containsKey(n)) color = _ansiColors[n];
        else if (n >= 40 && n <= 47) bg = _ansiColors[n - 10];
      }
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      spans.add(AnsiSpan(text: text.substring(lastEnd), color: color, background: bg, bold: bold, italic: italic, underline: underline));
    }
    return spans;
  }

  factory TerminalOutput.input(String command) => TerminalOutput(text: command, type: OutputType.input);
  factory TerminalOutput.output(String text)   => TerminalOutput(text: text,    type: OutputType.output);
  factory TerminalOutput.error(String text)    => TerminalOutput(text: text,    type: OutputType.error);
  factory TerminalOutput.info(String text)     => TerminalOutput(text: text,    type: OutputType.info);
  factory TerminalOutput.success(String text)  => TerminalOutput(text: text,    type: OutputType.success);
  factory TerminalOutput.system(String text)   => TerminalOutput(text: text,    type: OutputType.system);
  factory TerminalOutput.warning(String text)  => TerminalOutput(text: text,    type: OutputType.warning);
  factory TerminalOutput.separator()           => TerminalOutput(text: '',      type: OutputType.separator);
}

// ── AnsiSpan ──────────────────────────────────────────────────────────────────
class AnsiSpan {
  final String text;
  final Color? color;
  final Color? background;
  final bool bold;
  final bool italic;
  final bool underline;

  const AnsiSpan({
    required this.text,
    this.color,
    this.background,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });
}

// ── TerminalTab ───────────────────────────────────────────────────────────────
// All fields are final. Mutations go through copyWith which always creates
// new List instances so Riverpod equality checks work correctly.
class TerminalTab {
  final String id;
  final String title;
  final String workingDirectory;
  final List<TerminalOutput> outputs;   // always a fresh copy on write
  final List<String> history;           // always a fresh copy on write
  final int historyIndex;               // points at the currently previewed entry; == history.length when idle
  final bool isActive;
  final String shellType;
  final bool isBusy;                    // per-tab execution lock

  const TerminalTab({
    required this.id,
    required this.title,
    required this.workingDirectory,
    this.outputs = const [],
    this.history = const [],
    this.historyIndex = 0,
    this.isActive = false,
    this.shellType = 'bash',
    this.isBusy = false,
  });

  TerminalTab copyWith({
    String? title,
    String? workingDirectory,
    List<TerminalOutput>? outputs,
    List<String>? history,
    int? historyIndex,
    bool? isActive,
    String? shellType,
    bool? isBusy,
  }) {
    return TerminalTab(
      id: id,
      title: title ?? this.title,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      outputs: outputs ?? List.of(this.outputs),
      history: history ?? List.of(this.history),
      historyIndex: historyIndex ?? this.historyIndex,
      isActive: isActive ?? this.isActive,
      shellType: shellType ?? this.shellType,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  // Append output without cloning the entire list unnecessarily.
  TerminalTab withOutput(TerminalOutput output) {
    return copyWith(outputs: [...outputs, output]);
  }

  // Add to history; deduplicate consecutive identical entries; reset index.
  TerminalTab withHistory(String command) {
    final next = List<String>.of(history);
    if (next.isEmpty || next.last != command) next.add(command);
    return copyWith(history: next, historyIndex: next.length);
  }
}

// ── FileSystemEntry ───────────────────────────────────────────────────────────
class FileSystemEntry {
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime modified;
  final String permissions;
  final bool isHidden;

  const FileSystemEntry({
    required this.name,
    required this.isDirectory,
    this.size = 0,
    required this.modified,
    this.permissions = 'rw-r--r--',
    this.isHidden = false,
  });
}
