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

class TerminalOutput {
  final String text;
  final OutputType type;
  final DateTime timestamp;
  final bool isAnsi;
  final List<AnsiSpan>? spans;

  TerminalOutput({
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.isAnsi = false,
    this.spans,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TerminalOutput.input(String command) => TerminalOutput(
        text: command,
        type: OutputType.input,
      );

  factory TerminalOutput.output(String text) => TerminalOutput(
        text: text,
        type: OutputType.output,
      );

  factory TerminalOutput.error(String text) => TerminalOutput(
        text: text,
        type: OutputType.error,
      );

  factory TerminalOutput.info(String text) => TerminalOutput(
        text: text,
        type: OutputType.info,
      );

  factory TerminalOutput.success(String text) => TerminalOutput(
        text: text,
        type: OutputType.success,
      );

  factory TerminalOutput.system(String text) => TerminalOutput(
        text: text,
        type: OutputType.system,
      );

  factory TerminalOutput.warning(String text) => TerminalOutput(
        text: text,
        type: OutputType.warning,
      );

  factory TerminalOutput.separator() => TerminalOutput(
        text: '',
        type: OutputType.separator,
      );
}

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

class TerminalTab {
  final String id;
  String title;
  String workingDirectory;
  List<TerminalOutput> outputs;
  List<String> history;
  int historyIndex;
  bool isActive;
  String shellType;

  TerminalTab({
    required this.id,
    required this.title,
    required this.workingDirectory,
    List<TerminalOutput>? outputs,
    List<String>? history,
    this.historyIndex = -1,
    this.isActive = false,
    this.shellType = 'bash',
  })  : outputs = outputs ?? [],
        history = history ?? [];

  TerminalTab copyWith({
    String? title,
    String? workingDirectory,
    List<TerminalOutput>? outputs,
    List<String>? history,
    int? historyIndex,
    bool? isActive,
    String? shellType,
  }) {
    return TerminalTab(
      id: id,
      title: title ?? this.title,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      outputs: outputs ?? this.outputs,
      history: history ?? this.history,
      historyIndex: historyIndex ?? this.historyIndex,
      isActive: isActive ?? this.isActive,
      shellType: shellType ?? this.shellType,
    );
  }
}

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
    this.permissions = 'rwxr-xr-x',
    this.isHidden = false,
  });
}

class EnvironmentVar {
  final String key;
  final String value;
  const EnvironmentVar(this.key, this.value);
}
