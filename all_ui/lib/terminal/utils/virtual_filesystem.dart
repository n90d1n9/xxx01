import '../models/terminal_models.dart';

// ── VirtualFileSystem ─────────────────────────────────────────────────────────
// NOT a singleton any more. Each TerminalTab owns its own instance so that
// `cd` in tab 1 never affects tab 2's working directory.
//
// The shared read-only data (directory tree, file contents, default env) lives
// in a static _initialData class that every instance reads from on construction
// — this avoids duplicating several KB of strings per tab while still keeping
// per-tab mutable state fully isolated.
class VirtualFileSystem {
  String currentDirectory;
  final Map<String, List<FileSystemEntry>> _directories = {};
  final Map<String, String> _files = {};
  final Map<String, String> _envVars = {};

  VirtualFileSystem({String? initialDirectory})
      : currentDirectory = initialDirectory ?? '/home/user' {
    _init();
  }

  // Deep-clone from another instance (used when opening a new tab).
  VirtualFileSystem.from(VirtualFileSystem other)
      : currentDirectory = other.currentDirectory {
    for (final e in other._directories.entries) {
      _directories[e.key] = List.of(e.value);
    }
    _files.addAll(other._files);
    _envVars.addAll(other._envVars);
  }

  void _init() {
    _envVars.addAll({
      'HOME': '/home/user', 'USER': 'user', 'SHELL': '/bin/bash',
      'TERM': 'xterm-256color',
      'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      'LANG': 'en_US.UTF-8', 'EDITOR': 'nano',
      'HOSTNAME': 'flutter-terminal', 'PWD': '/home/user', 'LOGNAME': 'user',
    });

    _directories['/'] = [
      _dir('home', DateTime(2024, 1, 15)), _dir('usr',  DateTime(2024, 1, 10)),
      _dir('etc',  DateTime(2024, 1, 12)), _dir('var',  DateTime(2024, 2,  1)),
      _dir('tmp',  DateTime.now()),        _dir('bin',  DateTime(2024, 1,  1)),
      _dir('proc', DateTime.now()),        _dir('dev',  DateTime(2024, 1,  1)),
    ];
    _directories['/home'] = [_dir('user', DateTime(2024, 1, 15))];
    _directories['/home/user'] = [
      _dir('Documents',  DateTime(2024, 3, 10)),
      _dir('Downloads',  DateTime(2024, 3, 15)),
      _dir('Projects',   DateTime(2024, 3, 20)),
      _dir('.config',    DateTime(2024, 1, 15), hidden: true),
      _dir('.local',     DateTime(2024, 1, 15), hidden: true),
      _file('.bashrc',       3526, DateTime(2024, 1, 15), hidden: true),
      _file('.profile',       807, DateTime(2024, 1, 15), hidden: true),
      _file('.bash_history', 2048, DateTime.now(),        hidden: true),
      _file('README.md',     1024, DateTime(2024, 3,  1)),
      _file('notes.txt',      512, DateTime(2024, 3, 18)),
      _file('todo.md',        256, DateTime(2024, 3, 22)),
    ];
    _directories['/home/user/Documents'] = [
      _file('report.pdf',        204800, DateTime(2024, 2, 20)),
      _file('presentation.pptx', 512000, DateTime(2024, 3,  5)),
      _file('budget.xlsx',        35840, DateTime(2024, 3,  1)),
      _file('meeting-notes.md',    4096, DateTime(2024, 3, 20)),
    ];
    _directories['/home/user/Projects'] = [
      _dir('flutter_terminal', DateTime(2024, 3, 20)),
      _dir('api_server',       DateTime(2024, 3, 18)),
      _dir('scripts',          DateTime(2024, 3, 10)),
    ];
    _directories['/home/user/Projects/flutter_terminal'] = [
      _dir('lib', DateTime(2024, 3, 20)),
      _file('pubspec.yaml', 1024, DateTime(2024, 3, 19)),
      _file('README.md',    2048, DateTime(2024, 3, 15)),
      _file('.gitignore',    128, DateTime(2024, 3, 15), hidden: true),
    ];
    _directories['/home/user/Projects/flutter_terminal/lib'] = [
      _dir('models',    DateTime(2024, 3, 20)),
      _dir('providers', DateTime(2024, 3, 20)),
      _dir('utils',     DateTime(2024, 3, 20)),
      _dir('widgets',   DateTime(2024, 3, 20)),
      _dir('theme',     DateTime(2024, 3, 20)),
      _file('main.dart', 512, DateTime(2024, 3, 20)),
    ];
    _directories['/home/user/Projects/api_server'] = [
      _dir('src',  DateTime(2024, 3, 18)),
      _file('package.json', 512, DateTime(2024, 3, 18)),
      _file('README.md',    1024, DateTime(2024, 3, 15)),
    ];
    _directories['/home/user/Projects/scripts'] = [
      _file('build.sh',   1024, DateTime(2024, 3, 10), perms: 'rwxr-xr-x'),
      _file('deploy.sh',  2048, DateTime(2024, 3, 12), perms: 'rwxr-xr-x'),
      _file('backup.sh',   512, DateTime(2024, 3,  5), perms: 'rwxr-xr-x'),
    ];
    _directories['/home/user/Downloads'] = [
      _file('archive.tar.gz', 10485760, DateTime(2024, 3, 10)),
      _file('installer.sh',       4096, DateTime(2024, 3, 12), perms: 'rwxr-xr-x'),
      _file('flutter-linux.tar.xz', 234881024, DateTime(2024, 3,  1)),
    ];
    _directories['/home/user/.config'] = [
      _dir('git',    DateTime(2024, 1, 15), hidden: false),
      _dir('flutter',DateTime(2024, 1, 15), hidden: false),
    ];
    _directories['/etc'] = [
      _file('hosts',      221,  DateTime(2024, 1, 1)),
      _file('passwd',     1653, DateTime(2024, 1, 1)),
      _file('group',       800, DateTime(2024, 1, 1)),
      _file('fstab',      1024, DateTime(2024, 1, 1)),
      _file('bash.bashrc',2319, DateTime(2024, 1, 1)),
      _file('os-release',  371, DateTime(2024, 1, 1)),
      _file('hostname',     16, DateTime(2024, 1, 1)),
      _file('timezone',     12, DateTime(2024, 1, 1)),
    ];
    _directories['/usr'] = [_dir('bin',DateTime(2024,1,1)),_dir('lib',DateTime(2024,1,1)),_dir('local',DateTime(2024,1,1)),_dir('share',DateTime(2024,1,1))];
    _directories['/usr/local'] = [_dir('bin',DateTime(2024,1,1)),_dir('lib',DateTime(2024,1,1))];
    _directories['/tmp'] = [];
    _directories['/var'] = [_dir('log',DateTime(2024,1,1)),_dir('tmp',DateTime.now()),_dir('cache',DateTime(2024,1,1))];
    _directories['/proc'] = [_file('version',128,DateTime.now()),_file('uptime',32,DateTime.now()),_file('meminfo',2048,DateTime.now())];
    _directories['/dev'] = [_file('null',0,DateTime(2024,1,1)),_file('zero',0,DateTime(2024,1,1)),_file('random',0,DateTime(2024,1,1))];
    _directories['/bin'] = []; _directories['/usr/bin'] = [];

    // ── file contents ──────────────────────────────────────────────────────
    _files['/home/user/README.md'] = '''# Flutter Terminal

An advanced terminal emulator built with Flutter & Riverpod.

## Features
- Multi-tab sessions with isolated filesystems
- 50+ built-in commands
- ANSI colour rendering (cached, zero-jank)
- Tab-completion (commands + paths)
- Command history with ↑/↓ navigation
- Live output search (Ctrl+F)
- Pipe chaining: cmd | grep | head

## Quick start
  help          list all commands
  ls -la        detailed directory listing
  cat README.md view this file
  git status    check repo status
  neofetch      system info + ASCII art
''';

    _files['/home/user/notes.txt'] = '''Meeting notes — March 2024

TODO:
- Review quarterly reports
- Update documentation
- Deploy new version v2.1

Reminders:
- Team standup at 9am
- Client call at 2pm
- PR review for @alice
''';

    _files['/home/user/todo.md'] = '''# Todo

## In Progress
- [x] Fix ANSI parser caching
- [x] Per-tab filesystem isolation
- [ ] Real pipe execution
- [ ] Write mode (nano-style editor)

## Backlog
- [ ] Split pane
- [ ] Theme switcher
- [ ] Export session log
''';

    _files['/home/user/.bashrc'] = r'''# ~/.bashrc
case $- in *i*) ;; *) return;; esac
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
export PS1="\u@\h:\w\$ "
''';

    _files['/etc/hosts'] = '''127.0.0.1   localhost
127.0.1.1   flutter-terminal
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
''';

    _files['/etc/os-release'] = '''PRETTY_NAME="Flutter Terminal OS 1.0"
NAME="FlutterOS"
VERSION_ID="1.0"
VERSION="1.0 (stable)"
ID=flutteros
ID_LIKE=debian
HOME_URL="https://flutter.dev/"
''';

    _files['/etc/hostname'] = 'flutter-terminal\n';

    _files['/proc/version'] = 'FlutterOS version 6.1.0-flutter (user@build) (Dart 3.3.0) #1 SMP PREEMPT\n';

    _files['/proc/uptime'] = '259200.00 245000.00\n';

    _files['/proc/meminfo'] = '''MemTotal:        7864320 kB
MemFree:         3932160 kB
MemAvailable:    5242880 kB
Buffers:          204800 kB
Cached:          1638400 kB
SwapTotal:       2097152 kB
SwapFree:        2097152 kB
''';

    _files['/home/user/Projects/flutter_terminal/pubspec.yaml'] = '''name: flutter_terminal
description: Advanced Terminal/CLI Emulator
version: 1.0.0+1
environment:
  sdk: ">=3.0.0 <4.0.0"
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  google_fonts: ^6.2.1
  collection: ^1.18.0
  intl: ^0.19.0
''';
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  static FileSystemEntry _dir(String name, DateTime mod, {bool hidden = false}) =>
      FileSystemEntry(name: name, isDirectory: true, modified: mod, isHidden: hidden,
          permissions: 'rwxr-xr-x');
  static FileSystemEntry _file(String name, int size, DateTime mod,
      {bool hidden = false, String perms = 'rw-r--r--'}) =>
      FileSystemEntry(name: name, isDirectory: false, size: size, modified: mod,
          isHidden: hidden, permissions: perms);

  // ── path resolution ───────────────────────────────────────────────────────
  String resolvePath(String path) {
    if (path == '-') return currentDirectory; // cd - not implemented but guard
    if (path.startsWith('/')) return _normalize(path);
    if (path == '~' || path.startsWith('~/')) return _normalize('/home/user${path.substring(1)}');
    return _normalize('$currentDirectory/$path');
  }

  String _normalize(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final out = <String>[];
    for (final p in parts) {
      if (p == '..') { if (out.isNotEmpty) out.removeLast(); }
      else if (p != '.') out.add(p);
    }
    return '/${out.join('/')}';
  }

  String parentOf(String path) {
    if (path == '/') return '/';
    final parts = path.split('/')..removeLast();
    final joined = parts.join('/');
    return joined.isEmpty ? '/' : joined;
  }

  // ── queries ───────────────────────────────────────────────────────────────
  bool directoryExists(String path) => _directories.containsKey(path);
  bool fileExists(String path) => _files.containsKey(path);
  bool exists(String path) => directoryExists(path) || fileExists(path);

  List<FileSystemEntry>? listDirectory(String path, {bool showHidden = false}) {
    final entries = _directories[path];
    if (entries == null) return null;
    final list = showHidden ? List.of(entries) : entries.where((e) => !e.isHidden).toList();
    list.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  String? readFile(String path) => _files[path];

  // ── mutations ─────────────────────────────────────────────────────────────
  bool createDirectory(String path) {
    if (_directories.containsKey(path)) return false;
    _directories[path] = [];
    final parent = parentOf(path);
    final name = path.split('/').last;
    _directories[parent]?.add(_dir(name, DateTime.now()));
    return true;
  }

  bool writeFile(String path, String content) {
    final existed = _files.containsKey(path);
    _files[path] = content;
    final parent = parentOf(path);
    final name = path.split('/').last;
    final entries = _directories[parent];
    if (entries != null) {
      entries.removeWhere((e) => e.name == name);
      entries.add(_file(name, content.length, DateTime.now()));
    }
    return true;
  }

  bool removeFile(String path) {
    if (!_files.containsKey(path)) return false;
    _files.remove(path);
    _removeFromParent(path);
    return true;
  }

  bool removeDirectory(String path, {bool recursive = false}) {
    if (!_directories.containsKey(path)) return false;
    if (!recursive) {
      final entries = _directories[path] ?? [];
      if (entries.isNotEmpty) return false; // not empty
    } else {
      // Recursively remove all children first.
      for (final key in _directories.keys.where((k) => k.startsWith('$path/')).toList()) {
        _directories.remove(key);
      }
      for (final key in _files.keys.where((k) => k.startsWith('$path/')).toList()) {
        _files.remove(key);
      }
    }
    _directories.remove(path);
    _removeFromParent(path);
    return true;
  }

  void _removeFromParent(String path) {
    final parent = parentOf(path);
    final name = path.split('/').last;
    _directories[parent]?.removeWhere((e) => e.name == name);
  }

  // ── env ───────────────────────────────────────────────────────────────────
  String getEnv(String key) => _envVars[key] ?? '';
  void setEnv(String key, String value) {
    _envVars[key] = value;
    if (key == 'PWD') currentDirectory = value;
  }
  Map<String, String> getAllEnv() => Map.unmodifiable(_envVars);

  // ── autocomplete ──────────────────────────────────────────────────────────
  // Returns completions for a partial path token relative to cwd.
  List<String> autocomplete(String partial, {bool dirsOnly = false}) {
    String dir = currentDirectory;
    String prefix = partial;

    // If partial has a slash, split into dir-part and name-part.
    if (partial.contains('/')) {
      final lastSlash = partial.lastIndexOf('/');
      final dirPart = partial.substring(0, lastSlash);
      prefix = partial.substring(lastSlash + 1);
      dir = resolvePath(dirPart.isEmpty ? '/' : dirPart);
    }

    final entries = _directories[dir] ?? [];
    return entries
        .where((e) =>
            e.name.startsWith(prefix) &&
            (!e.isHidden || prefix.startsWith('.')) &&
            (!dirsOnly || e.isDirectory))
        .map((e) {
          final fullName = partial.contains('/')
              ? '${partial.substring(0, partial.lastIndexOf('/') + 1)}${e.name}'
              : e.name;
          return e.isDirectory ? '$fullName/' : fullName;
        })
        .toList()
      ..sort();
  }
}
