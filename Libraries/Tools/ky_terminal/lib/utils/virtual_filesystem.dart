import '../models/terminal_models.dart';

class VirtualFileSystem {
  static final VirtualFileSystem _instance = VirtualFileSystem._internal();
  factory VirtualFileSystem() => _instance;
  VirtualFileSystem._internal() {
    _initFileSystem();
  }

  String currentDirectory = '/home/user';
  final Map<String, List<FileSystemEntry>> _directories = {};
  final Map<String, String> _files = {};
  final Map<String, String> _envVars = {};

  void _initFileSystem() {
    // Init environment
    _envVars.addAll({
      'HOME': '/home/user',
      'USER': 'user',
      'SHELL': '/bin/bash',
      'TERM': 'xterm-256color',
      'PATH': '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      'LANG': 'en_US.UTF-8',
      'EDITOR': 'nano',
      'HOSTNAME': 'flutter-terminal',
      'PWD': '/home/user',
      'LOGNAME': 'user',
    });

    // Build directory tree
    _directories['/'] = [
      FileSystemEntry(name: 'home', isDirectory: true, modified: DateTime(2024, 1, 15)),
      FileSystemEntry(name: 'usr', isDirectory: true, modified: DateTime(2024, 1, 10)),
      FileSystemEntry(name: 'etc', isDirectory: true, modified: DateTime(2024, 1, 12)),
      FileSystemEntry(name: 'var', isDirectory: true, modified: DateTime(2024, 2, 1)),
      FileSystemEntry(name: 'tmp', isDirectory: true, modified: DateTime.now()),
      FileSystemEntry(name: 'bin', isDirectory: true, modified: DateTime(2024, 1, 1)),
    ];

    _directories['/home'] = [
      FileSystemEntry(name: 'user', isDirectory: true, modified: DateTime(2024, 1, 15)),
    ];

    _directories['/home/user'] = [
      FileSystemEntry(name: 'Documents', isDirectory: true, modified: DateTime(2024, 3, 10)),
      FileSystemEntry(name: 'Downloads', isDirectory: true, modified: DateTime(2024, 3, 15)),
      FileSystemEntry(name: 'Projects', isDirectory: true, modified: DateTime(2024, 3, 20)),
      FileSystemEntry(name: '.bashrc', isDirectory: false, size: 3526, modified: DateTime(2024, 1, 15), isHidden: true),
      FileSystemEntry(name: '.profile', isDirectory: false, size: 807, modified: DateTime(2024, 1, 15), isHidden: true),
      FileSystemEntry(name: '.bash_history', isDirectory: false, size: 2048, modified: DateTime.now(), isHidden: true),
      FileSystemEntry(name: 'README.md', isDirectory: false, size: 1024, modified: DateTime(2024, 3, 1)),
      FileSystemEntry(name: 'notes.txt', isDirectory: false, size: 512, modified: DateTime(2024, 3, 18)),
    ];

    _directories['/home/user/Documents'] = [
      FileSystemEntry(name: 'report.pdf', isDirectory: false, size: 204800, modified: DateTime(2024, 2, 20)),
      FileSystemEntry(name: 'presentation.pptx', isDirectory: false, size: 512000, modified: DateTime(2024, 3, 5)),
      FileSystemEntry(name: 'budget.xlsx', isDirectory: false, size: 35840, modified: DateTime(2024, 3, 1)),
    ];

    _directories['/home/user/Projects'] = [
      FileSystemEntry(name: 'flutter_app', isDirectory: true, modified: DateTime(2024, 3, 20)),
      FileSystemEntry(name: 'api_server', isDirectory: true, modified: DateTime(2024, 3, 18)),
      FileSystemEntry(name: 'scripts', isDirectory: true, modified: DateTime(2024, 3, 10)),
    ];

    _directories['/home/user/Projects/flutter_app'] = [
      FileSystemEntry(name: 'lib', isDirectory: true, modified: DateTime(2024, 3, 20)),
      FileSystemEntry(name: 'pubspec.yaml', isDirectory: false, size: 1024, modified: DateTime(2024, 3, 19)),
      FileSystemEntry(name: 'README.md', isDirectory: false, size: 2048, modified: DateTime(2024, 3, 15)),
    ];

    _directories['/home/user/Downloads'] = [
      FileSystemEntry(name: 'archive.tar.gz', isDirectory: false, size: 10485760, modified: DateTime(2024, 3, 10)),
      FileSystemEntry(name: 'installer.sh', isDirectory: false, size: 4096, modified: DateTime(2024, 3, 12), permissions: 'rwxr-xr-x'),
    ];

    _directories['/etc'] = [
      FileSystemEntry(name: 'hosts', isDirectory: false, size: 221, modified: DateTime(2024, 1, 1)),
      FileSystemEntry(name: 'passwd', isDirectory: false, size: 1653, modified: DateTime(2024, 1, 1)),
      FileSystemEntry(name: 'fstab', isDirectory: false, size: 1024, modified: DateTime(2024, 1, 1)),
      FileSystemEntry(name: 'bash.bashrc', isDirectory: false, size: 2319, modified: DateTime(2024, 1, 1)),
      FileSystemEntry(name: 'os-release', isDirectory: false, size: 371, modified: DateTime(2024, 1, 1)),
    ];

    _directories['/usr'] = [
      FileSystemEntry(name: 'bin', isDirectory: true, modified: DateTime(2024, 1, 1)),
      FileSystemEntry(name: 'lib', isDirectory: true, modified: DateTime(2024, 1, 1)),
      FileSystemEntry(name: 'local', isDirectory: true, modified: DateTime(2024, 1, 1)),
    ];

    _directories['/tmp'] = [];

    // File contents
    _files['/home/user/README.md'] = '''# Welcome to Flutter Terminal

This is an advanced terminal emulator built with Flutter and Riverpod.

## Features
- Multiple tabs
- Command history
- Virtual filesystem
- Syntax-colored output
- Tab completion

## Quick Commands
- `help` — list all commands
- `ls -la` — list directory contents
- `cd [dir]` — change directory
- `cat [file]` — view file contents
- `clear` — clear terminal
''';

    _files['/home/user/notes.txt'] = '''Meeting notes - March 2024

TODO:
- Review quarterly reports
- Update documentation
- Deploy new version

Reminders:
- Team standup at 9am
- Client call at 2pm
''';

    _files['/home/user/.bashrc'] = '''# ~/.bashrc: executed by bash for non-login shells.

# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# Aliases
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."

# Prompt
export PS1="\\u@\\h:\\w\\$ "
''';

    _files['/etc/hosts'] = '''127.0.0.1   localhost
127.0.1.1   flutter-terminal

# IPv6
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
SUPPORT_URL="https://flutter.dev/docs"
''';
  }

  String resolvePath(String path) {
    if (path.startsWith('/')) return _normalizePath(path);
    if (path == '~' || path.startsWith('~/')) {
      return _normalizePath('/home/user${path.substring(1)}');
    }
    if (path == '..') return _getParent(currentDirectory);
    if (path == '.') return currentDirectory;
    return _normalizePath('$currentDirectory/$path');
  }

  String _normalizePath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final result = <String>[];
    for (final part in parts) {
      if (part == '..') {
        if (result.isNotEmpty) result.removeLast();
      } else if (part != '.') {
        result.add(part);
      }
    }
    return '/${result.join('/')}';
  }

  String _getParent(String path) {
    if (path == '/') return '/';
    final parts = path.split('/')..removeLast();
    return parts.isEmpty ? '/' : parts.join('/').isEmpty ? '/' : parts.join('/');
  }

  bool directoryExists(String path) => _directories.containsKey(path);
  bool fileExists(String path) => _files.containsKey(path);

  List<FileSystemEntry>? listDirectory(String path, {bool showHidden = false}) {
    final entries = _directories[path];
    if (entries == null) return null;
    return showHidden ? entries : entries.where((e) => !e.isHidden).toList();
  }

  String? readFile(String path) => _files[path];

  bool createDirectory(String path) {
    if (_directories.containsKey(path)) return false;
    _directories[path] = [];
    final parent = _getParent(path);
    final name = path.split('/').last;
    _directories[parent]?.add(
      FileSystemEntry(name: name, isDirectory: true, modified: DateTime.now()),
    );
    return true;
  }

  bool writeFile(String path, String content) {
    _files[path] = content;
    final parent = _getParent(path);
    final name = path.split('/').last;
    final entries = _directories[parent];
    if (entries != null) {
      entries.removeWhere((e) => e.name == name);
      entries.add(FileSystemEntry(
        name: name,
        isDirectory: false,
        size: content.length,
        modified: DateTime.now(),
      ));
    }
    return true;
  }

  bool removeFile(String path) {
    if (!_files.containsKey(path)) return false;
    _files.remove(path);
    final parent = _getParent(path);
    final name = path.split('/').last;
    _directories[parent]?.removeWhere((e) => e.name == name);
    return true;
  }

  bool removeDirectory(String path) {
    if (!_directories.containsKey(path)) return false;
    _directories.remove(path);
    final parent = _getParent(path);
    final name = path.split('/').last;
    _directories[parent]?.removeWhere((e) => e.name == name);
    return true;
  }

  String getEnv(String key) => _envVars[key] ?? '';
  void setEnv(String key, String value) => _envVars[key] = value;
  Map<String, String> getAllEnv() => Map.unmodifiable(_envVars);

  List<String> autocomplete(String partial, {bool dirsOnly = false}) {
    final entries = _directories[currentDirectory] ?? [];
    return entries
        .where((e) => e.name.startsWith(partial) && (!dirsOnly || e.isDirectory))
        .map((e) => e.isDirectory ? '${e.name}/' : e.name)
        .toList();
  }
}
