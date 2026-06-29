import 'dart:math';
import 'package:intl/intl.dart';
import '../models/terminal_models.dart';
import '../utils/virtual_filesystem.dart';
import '../utils/ansi_parser.dart';

typedef OutputCallback    = void Function(TerminalOutput output);
typedef ClearCallback     = void Function();
typedef ChangeDirCallback = void Function(String dir);

// ── Single source-of-truth command registry ───────────────────────────────────
// Both autocomplete and the dispatcher read from this list.
const kBuiltinCommands = <String>[
  'alias',  'banner', 'bc',      'cal',     'cat',     'cd',
  'clear',  'cowsay', 'cp',      'curl',    'dart',    'date',
  'df',     'du',     'echo',    'env',     'exit',    'export',
  'false',  'find',   'flutter', 'fortune', 'free',    'git',
  'grep',   'head',   'help',    'history', 'hostname','ifconfig',
  'ip',     'ls',     'man',     'mkdir',   'mv',      'nano',
  'neofetch','npm',   'ping',    'ps',      'pwd',     'python',
  'python3','rm',     'seq',     'sleep',   'sort',    'ssh',
  'tail',   'top',    'touch',   'true',    'uname',   'uniq',
  'uptime', 'vi',     'vim',     'wc',      'which',   'whoami',
  'write',  'yes',    'logout',  'logout',  'source',  'printenv',
  'chmod',  'chown',  'ln',      'stat',    'tee',     'xargs',
  'tr',     'cut',    'awk',     'sed',     'diff',    'tree',
];

// ── CommandProcessor ──────────────────────────────────────────────────────────
class CommandProcessor {
  final VirtualFileSystem fs;
  final OutputCallback    onOutput;
  final ClearCallback     onClear;
  final ChangeDirCallback onChangeDir;

  CommandProcessor({
    required this.fs,
    required this.onOutput,
    required this.onClear,
    required this.onChangeDir,
  });

  // Built-in alias table (user can extend via `alias`).
  final Map<String, String> _aliases = {
    'll':  'ls -la', 'la': 'ls -a', 'l': 'ls -CF',
    '..':  'cd ..',  '...': 'cd ../..',
  };

  // ── Entry point ────────────────────────────────────────────────────────────
  Future<void> execute(String rawInput) async {
    final input = rawInput.trim();
    if (input.isEmpty) return;

    // Handle semicolons (command chaining: cmd1; cmd2).
    if (input.contains(';')) {
      for (final part in _splitOnSemicolons(input)) {
        await execute(part.trim());
      }
      return;
    }

    // Handle pipes with real stdout routing.
    if (input.contains(' | ')) {
      await _executePipeline(input);
      return;
    }

    // Handle output redirection: cmd > file  /  cmd >> file.
    if (_hasRedirection(input)) {
      await _executeWithRedirection(input);
      return;
    }

    final expanded = _expandAliases(input);
    final parts    = _parseArgs(expanded);
    if (parts.isEmpty) return;

    await _dispatch(parts[0], parts.sublist(1));
  }

  // ── Real pipe execution ────────────────────────────────────────────────────
  // Each command in the pipeline runs normally, but intermediate commands
  // have their onOutput replaced with a buffer collector.  The final command
  // receives the collected text as stdin lines injected as arguments / input.
  Future<void> _executePipeline(String input) async {
    final segments = input.split(' | ').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) { await execute(segments.first); return; }

    // Execute the first segment into a buffer.
    var buffer = await _captureOutput(segments[0]);

    // Thread through intermediate segments.
    for (var i = 1; i < segments.length - 1; i++) {
      buffer = await _pipeThrough(segments[i], buffer);
    }

    // Final segment: feed buffer and emit to real output.
    await _pipeFinal(segments.last, buffer);
  }

  Future<List<String>> _captureOutput(String cmd) async {
    final lines = <String>[];
    final parts = _parseArgs(_expandAliases(cmd));
    if (parts.isEmpty) return lines;
    final capture = CommandProcessor(
      fs: fs,
      onOutput:    (o) { if (o.type != OutputType.separator && o.text.isNotEmpty) lines.add(AnsiParser.strip(o.text)); },
      onClear:     () {},
      onChangeDir: onChangeDir,
    );
    await capture._dispatch(parts[0], parts.sublist(1));
    return lines;
  }

  Future<List<String>> _pipeThrough(String cmd, List<String> stdin) async {
    return _captureOutput(_injectStdin(cmd, stdin));
  }

  Future<void> _pipeFinal(String cmd, List<String> stdin) async {
    final parts = _parseArgs(_expandAliases(cmd));
    if (parts.isEmpty) return;
    final command = parts[0];
    final args    = parts.sublist(1);

    // For grep/head/tail/sort/uniq/wc: use stdin lines directly.
    switch (command) {
      case 'grep':  _grepLines(args, stdin); return;
      case 'head':  _headLines(args, stdin); return;
      case 'tail':  _tailLines(args, stdin); return;
      case 'sort':  _sortLines(args, stdin); return;
      case 'uniq':  _uniqLines(stdin);       return;
      case 'wc':    _wcLines(args, stdin);   return;
      case 'tee':   _teeLines(args, stdin);  return;
      case 'tr':    _trLines(args, stdin);   return;
      case 'cut':   _cutLines(args, stdin);  return;
      case 'xargs': _xargsLines(args, stdin);return;
      default:
        // For other commands just emit the piped text then run normally.
        if (stdin.isNotEmpty) onOutput(TerminalOutput.output(stdin.join('\n')));
        await _dispatch(command, args);
    }
  }

  String _injectStdin(String cmd, List<String> stdin) => cmd; // stdin routed explicitly above

  // ── Redirection ────────────────────────────────────────────────────────────
  bool _hasRedirection(String input) => RegExp(r'\s+>+\s+\S').hasMatch(input);

  Future<void> _executeWithRedirection(String input) async {
    final match = RegExp(r'^(.*?)\s+(>>?)\s+(\S+)$').firstMatch(input);
    if (match == null) { await execute(input.replaceAll('>', '')); return; }

    final cmd    = match.group(1)!.trim();
    final op     = match.group(2)!;   // '>' or '>>'
    final target = match.group(3)!;
    final path   = fs.resolvePath(target);

    final lines = await _captureOutput(cmd);
    final text  = lines.join('\n');

    if (op == '>>') {
      final existing = fs.readFile(path) ?? '';
      fs.writeFile(path, existing + (existing.endsWith('\n') ? '' : '\n') + text + '\n');
    } else {
      fs.writeFile(path, text + '\n');
    }
    onOutput(TerminalOutput.success('Wrote to $target'));
  }

  // ── Alias expansion ────────────────────────────────────────────────────────
  String _expandAliases(String input) {
    final firstWord = input.split(' ').first;
    return _aliases.containsKey(firstWord)
        ? _aliases[firstWord]! + input.substring(firstWord.length)
        : input;
  }

  List<String> _splitOnSemicolons(String input) {
    // Respect quotes when splitting on semicolons.
    final parts = <String>[];
    final cur = StringBuffer();
    var inSingle = false; var inDouble = false;
    for (final c in input.split('')) {
      if (c == "'" && !inDouble) { inSingle = !inSingle; cur.write(c); }
      else if (c == '"' && !inSingle) { inDouble = !inDouble; cur.write(c); }
      else if (c == ';' && !inSingle && !inDouble) {
        if (cur.isNotEmpty) { parts.add(cur.toString()); cur.clear(); }
      } else { cur.write(c); }
    }
    if (cur.isNotEmpty) parts.add(cur.toString());
    return parts;
  }

  // ── Dispatcher ────────────────────────────────────────────────────────────
  Future<void> _dispatch(String cmd, List<String> args) async {
    switch (cmd) {
      // ── Navigation ──
      case 'cd':       _cd(args);    break;
      case 'pwd':      _pwd();       break;
      case 'ls':       _ls(args);    break;

      // ── File ops ──
      case 'cat':      _cat(args);   break;
      case 'cp':       _cp(args);    break;
      case 'mv':       _mv(args);    break;
      case 'rm':       _rm(args);    break;
      case 'mkdir':    _mkdir(args); break;
      case 'touch':    _touch(args); break;
      case 'stat':     _stat(args);  break;
      case 'tree':     _tree(args);  break;
      case 'chmod':    _chmod(args); break;
      case 'chown':    _chown(args); break;
      case 'ln':       _ln(args);    break;

      // ── Text ──
      case 'echo':     _echo(args);  break;
      case 'cat_stdin':_cat(args);   break;
      case 'grep':     _grep(args);  break;
      case 'head':     _head(args);  break;
      case 'tail':     _tail(args);  break;
      case 'sort':     _sort(args);  break;
      case 'uniq':     _uniq(args);  break;
      case 'wc':       _wc(args);    break;
      case 'diff':     _diff(args);  break;
      case 'tr':       _trCmd(args); break;
      case 'cut':      _cutCmd(args);break;
      case 'sed':      _sed(args);   break;
      case 'awk':      _awk(args);   break;
      case 'tee':      _teeCmd(args);break;
      case 'xargs':    _xargsCmd(args); break;

      // ── Search ──
      case 'find':     _find(args);  break;

      // ── Env ──
      case 'env':      _env(args);   break;
      case 'printenv': _printenv(args); break;
      case 'export':   _export(args);break;
      case 'source':   _source(args);break;

      // ── System ──
      case 'clear':    onClear();    break;
      case 'which':    _which(args); break;
      case 'date':     _date(args);  break;
      case 'whoami':   _whoami();    break;
      case 'hostname': _hostname();  break;
      case 'uname':    _uname(args); break;
      case 'uptime':   _uptime();    break;
      case 'ps':       _ps(args);    break;
      case 'df':       _df(args);    break;
      case 'du':       _du(args);    break;
      case 'free':     _free(args);  break;
      case 'top':      _top();       break;

      // ── Network ──
      case 'ping':     _ping(args);  break;
      case 'curl':     _curl(args);  break;
      case 'ifconfig':
      case 'ip':       _network(cmd, args); break;
      case 'ssh':      _ssh(args);   break;

      // ── Developer ──
      case 'git':      _git(args);   break;
      case 'npm':      _npm(args);   break;
      case 'python':
      case 'python3':  _python(args);break;
      case 'flutter':  _flutterCmd(args); break;
      case 'dart':     _dart(args);  break;

      // ── Shell ──
      case 'alias':    _aliasList(args);   break;
      case 'history':  _historyCmd();      break;
      case 'help':     _help(args);        break;
      case 'man':      _man(args);         break;
      case 'nano':
      case 'vim':
      case 'vi':
      case 'write':    _editor(cmd, args); break;

      // ── Fun ──
      case 'neofetch': _neofetch();       break;
      case 'banner':   _banner(args);     break;
      case 'cowsay':   _cowsay(args);     break;
      case 'fortune':  _fortune();        break;
      case 'cal':      _cal(args);        break;
      case 'bc':       _bc(args);         break;
      case 'yes':      _yes(args);        break;
      case 'seq':      _seq(args);        break;

      // ── Misc ──
      case 'sleep':    await _sleep(args); break;
      case 'true':     break;
      case 'false':
        onOutput(TerminalOutput.error('Exit status 1')); break;
      case 'exit':
      case 'logout':
        onOutput(TerminalOutput.info('Session ended. Goodbye!')); break;

      default:
        onOutput(TerminalOutput.error(
            '$cmd: command not found\nType \x1B[32mhelp\x1B[0m for available commands.'));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILE SYSTEM COMMANDS
  // ══════════════════════════════════════════════════════════════════════════

  void _cd(List<String> args) {
    final target = args.isEmpty ? '~' : args[0];
    final resolved = fs.resolvePath(target);
    if (fs.directoryExists(resolved)) {
      fs.currentDirectory = resolved;
      fs.setEnv('PWD', resolved);
      fs.setEnv('OLDPWD', fs.currentDirectory);
      onChangeDir(resolved);
    } else if (fs.fileExists(resolved)) {
      onOutput(TerminalOutput.error('cd: $target: Not a directory'));
    } else {
      onOutput(TerminalOutput.error('cd: $target: No such file or directory'));
    }
  }

  void _pwd() => onOutput(TerminalOutput.output(fs.currentDirectory));

  void _ls(List<String> args) {
    bool all = false, long = false, human = false, sort_time = false, reverse = false;
    final targets = <String>[];
    for (final a in args) {
      if (a.startsWith('-')) {
        if (a.contains('a') || a.contains('A')) all = true;
        if (a.contains('l'))                     long = true;
        if (a.contains('h'))                     human = true;
        if (a.contains('t'))                     sort_time = true;
        if (a.contains('r'))                     reverse = true;
      } else {
        targets.add(a);
      }
    }
    final dirs = targets.isEmpty ? [fs.currentDirectory] : targets.map(fs.resolvePath).toList();

    for (final dir in dirs) {
      if (!fs.directoryExists(dir)) {
        if (fs.fileExists(dir)) {
          _lsFile(fs.listDirectory(fs.parentOf(dir), showHidden: true)
              ?.firstWhere((e) => e.name == dir.split('/').last,
                  orElse: () => FileSystemEntry(name: dir.split('/').last, isDirectory: false, modified: DateTime.now()))
              ?? FileSystemEntry(name: dir, isDirectory: false, modified: DateTime.now()),
              dir, long, human);
        } else {
          onOutput(TerminalOutput.error("ls: cannot access '$dir': No such file or directory"));
        }
        continue;
      }
      if (dirs.length > 1) onOutput(TerminalOutput.output('\x1B[34m$dir\x1B[0m:'));

      var entries = fs.listDirectory(dir, showHidden: all) ?? [];
      if (sort_time) entries.sort((a, b) => b.modified.compareTo(a.modified));
      if (reverse)   entries = entries.reversed.toList();

      if (long) {
        _lsLong(entries, dir, human);
      } else {
        _lsShort(entries);
      }
    }
  }

  void _lsFile(FileSystemEntry e, String path, bool long, bool human) {
    if (long) _lsLong([e], fs.parentOf(path), human);
    else onOutput(TerminalOutput.output(_colorEntry(e)));
  }

  void _lsLong(List<FileSystemEntry> entries, String dir, bool human) {
    final total = entries.fold(0, (s, e) => s + e.size);
    onOutput(TerminalOutput.output('total ${human ? formatFileSize(total) : total ~/ 1024}'));
    final fmt = DateFormat('MMM dd HH:mm');
    final fmtOld = DateFormat('MMM dd  yyyy');
    final now = DateTime.now();
    for (final e in entries) {
      final type = e.isDirectory ? 'd' : '-';
      final perm = '$type${e.permissions}';
      final size = human ? padLeft(formatFileSize(e.size), 6) : padLeft('${e.size}', 8);
      final age  = now.difference(e.modified).inDays;
      final date = age < 180 ? fmt.format(e.modified) : fmtOld.format(e.modified);
      onOutput(TerminalOutput.output('$perm  1 user user $size $date ${_colorEntry(e)}'));
    }
  }

  void _lsShort(List<FileSystemEntry> entries) {
    if (entries.isEmpty) return;
    final names = entries.map(_colorEntry).toList();
    onOutput(TerminalOutput.output(names.join('  ')));
  }

  String _colorEntry(FileSystemEntry e) {
    if (e.isDirectory)                     return '\x1B[34m${e.name}/\x1B[0m';
    if (e.permissions.contains('x'))       return '\x1B[32m${e.name}\x1B[0m';
    if (e.name.endsWith('.dart'))          return '\x1B[36m${e.name}\x1B[0m';
    if (e.name.endsWith('.yaml') ||
        e.name.endsWith('.yml'))           return '\x1B[33m${e.name}\x1B[0m';
    if (e.isHidden)                        return '\x1B[90m${e.name}\x1B[0m';
    return e.name;
  }

  void _cat(List<String> args) {
    bool number = false;
    final files = <String>[];
    for (final a in args) {
      if (a == '-n') number = true;
      else files.add(a);
    }
    if (files.isEmpty) { onOutput(TerminalOutput.error('cat: missing operand')); return; }
    for (final f in files) {
      final path = fs.resolvePath(f);
      if (fs.directoryExists(path)) { onOutput(TerminalOutput.error('cat: $f: Is a directory')); continue; }
      final content = fs.readFile(path);
      if (content == null) { onOutput(TerminalOutput.error("cat: $f: No such file or directory")); continue; }
      if (number) {
        final lines = content.split('\n');
        final out = lines.asMap().entries.map((e) => '${padLeft('${e.key + 1}', 6)}\t${e.value}').join('\n');
        onOutput(TerminalOutput.output(out));
      } else {
        onOutput(TerminalOutput.output(content));
      }
    }
  }

  void _cp(List<String> args) {
    bool recursive = false;
    final files = <String>[];
    for (final a in args) {
      if (a == '-r' || a == '-R' || a == '-a') recursive = true;
      else files.add(a);
    }
    if (files.length < 2) { onOutput(TerminalOutput.error('cp: missing destination operand')); return; }
    final dst = fs.resolvePath(files.last);
    final srcs = files.sublist(0, files.length - 1).map(fs.resolvePath).toList();
    for (final src in srcs) {
      final content = fs.readFile(src);
      if (content == null) { onOutput(TerminalOutput.error("cp: '$src': No such file or directory")); continue; }
      final target = fs.directoryExists(dst) ? '$dst/${src.split('/').last}' : dst;
      fs.writeFile(target, content);
    }
  }

  void _mv(List<String> args) {
    if (args.length < 2) { onOutput(TerminalOutput.error('mv: missing destination operand')); return; }
    final src = fs.resolvePath(args[0]);
    final dst = fs.resolvePath(args[1]);
    final content = fs.readFile(src);
    if (content == null) { onOutput(TerminalOutput.error("mv: '$args[0]': No such file or directory")); return; }
    final target = fs.directoryExists(dst) ? '$dst/${src.split('/').last}' : dst;
    fs.writeFile(target, content);
    fs.removeFile(src);
  }

  void _rm(List<String> args) {
    bool recursive = false, force = false;
    final targets = <String>[];
    for (final a in args) {
      if (a.startsWith('-')) {
        if (a.contains('r') || a.contains('R')) recursive = true;
        if (a.contains('f')) force = true;
      } else targets.add(a);
    }
    for (final t in targets) {
      final path = fs.resolvePath(t);
      if (fs.directoryExists(path)) {
        if (!recursive) { onOutput(TerminalOutput.error("rm: cannot remove '$t': Is a directory")); continue; }
        if (!fs.removeDirectory(path, recursive: true) && !force) {
          onOutput(TerminalOutput.error("rm: cannot remove '$t'"));
        }
      } else if (fs.fileExists(path)) {
        fs.removeFile(path);
      } else if (!force) {
        onOutput(TerminalOutput.error("rm: cannot remove '$t': No such file or directory"));
      }
    }
  }

  void _mkdir(List<String> args) {
    bool parents = false;
    final dirs = <String>[];
    for (final a in args) {
      if (a == '-p' || a == '--parents') parents = true;
      else dirs.add(a);
    }
    for (final d in dirs) {
      final path = fs.resolvePath(d);
      if (parents) {
        // Create all intermediate dirs.
        final parts = path.split('/').where((p) => p.isNotEmpty).toList();
        for (var i = 1; i <= parts.length; i++) {
          fs.createDirectory('/${parts.sublist(0, i).join('/')}');
        }
      } else {
        if (!fs.createDirectory(path)) {
          onOutput(TerminalOutput.error("mkdir: cannot create directory '$d': File exists"));
        }
      }
    }
  }

  void _touch(List<String> args) {
    for (final a in args.where((a) => !a.startsWith('-'))) {
      final path = fs.resolvePath(a);
      if (!fs.fileExists(path)) fs.writeFile(path, '');
    }
  }

  void _stat(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.error('stat: missing operand')); return; }
    for (final a in args) {
      final path = fs.resolvePath(a);
      if (fs.directoryExists(path)) {
        onOutput(TerminalOutput.output('''  File: $path
  Type: directory
Access: drwxr-xr-x  Uid: 1000  Gid: 1000
Modify: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
'''));
      } else {
        final content = fs.readFile(path);
        if (content == null) { onOutput(TerminalOutput.error("stat: cannot stat '$a': No such file or directory")); continue; }
        onOutput(TerminalOutput.output('''  File: $path
  Size: ${content.length}\tBlocks: 8\tIO Block: 4096  regular file
Inode: ${(path.hashCode.abs() % 999999) + 1000}\tLinks: 1
Access: -rw-r--r--  Uid: 1000  Gid: 1000
Modify: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
'''));
      }
    }
  }

  void _tree(List<String> args) {
    final root = args.where((a) => !a.startsWith('-')).firstOrNull ?? fs.currentDirectory;
    final path = fs.resolvePath(root);
    final sb = StringBuffer('$path\n');
    int dirs = 0, files = 0;
    void walk(String p, String indent) {
      final entries = fs.listDirectory(p, showHidden: args.contains('-a')) ?? [];
      for (var i = 0; i < entries.length; i++) {
        final last = i == entries.length - 1;
        final branch = last ? '└── ' : '├── ';
        final e = entries[i];
        sb.writeln('$indent$branch${_colorEntry(e)}');
        if (e.isDirectory) {
          dirs++;
          walk('$p/${e.name}', indent + (last ? '    ' : '│   '));
        } else { files++; }
      }
    }
    walk(path, '');
    sb.writeln('\n$dirs ${dirs == 1 ? "directory" : "directories"}, $files ${files == 1 ? "file" : "files"}');
    onOutput(TerminalOutput.output(sb.toString()));
  }

  void _chmod(List<String> args) {
    if (args.length < 2) { onOutput(TerminalOutput.error('chmod: missing operand')); return; }
    onOutput(TerminalOutput.output('')); // success (silent like real chmod)
  }

  void _chown(List<String> args) {
    if (args.length < 2) { onOutput(TerminalOutput.error('chown: missing operand')); return; }
    onOutput(TerminalOutput.output(''));
  }

  void _ln(List<String> args) {
    bool symbolic = args.remove('-s');
    if (args.length < 2) { onOutput(TerminalOutput.error('ln: missing operand')); return; }
    final src = fs.resolvePath(args[0]);
    final dst = fs.resolvePath(args[1]);
    final content = fs.readFile(src) ?? '';
    fs.writeFile(dst, content);
    onOutput(TerminalOutput.output(''));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TEXT PROCESSING
  // ══════════════════════════════════════════════════════════════════════════

  void _echo(List<String> args) {
    bool noNewline = false;
    bool interpret = false;
    final words = <String>[];
    for (final a in args) {
      if (a == '-n') noNewline = true;
      else if (a == '-e') interpret = true;
      else words.add(a);
    }
    var text = words.join(' ');
    if (interpret) {
      text = text.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t')
                 .replaceAll(r'\033', '\x1B').replaceAll(r'\e', '\x1B');
    }
    // Expand $VAR
    text = text.replaceAllMapped(RegExp(r'\$\{?(\w+)\}?'), (m) => fs.getEnv(m.group(1)!));
    onOutput(TerminalOutput.output(text));
  }

  void _grep(List<String> args) => _grepLines(args, null);
  void _grepLines(List<String> args, List<String>? stdin) {
    bool ignoreCase = false, lineNum = false, invert = false, count = false, recursive = false;
    String? pattern;
    final files = <String>[];
    for (var i = 0; i < args.length; i++) {
      if (args[i].startsWith('-')) {
        if (args[i].contains('i')) ignoreCase = true;
        if (args[i].contains('n')) lineNum = true;
        if (args[i].contains('v')) invert = true;
        if (args[i].contains('c')) count = true;
        if (args[i].contains('r') || args[i].contains('R')) recursive = true;
        if (args[i] == '-e' && i + 1 < args.length) { pattern = args[++i]; continue; }
      } else {
        if (pattern == null) pattern = args[i]; else files.add(args[i]);
      }
    }
    if (pattern == null) { onOutput(TerminalOutput.error('grep: missing pattern')); return; }
    final re = RegExp(pattern, caseSensitive: !ignoreCase);

    void grepText(String text, String? filename) {
      final lines = text.split('\n');
      final matches = <String>[];
      int cnt = 0;
      for (var i = 0; i < lines.length; i++) {
        final matched = re.hasMatch(lines[i]);
        if (matched != invert) {
          cnt++;
          var line = lines[i];
          if (!invert) {
            line = line.replaceAllMapped(re, (m) => '\x1B[31;1m${m.group(0)}\x1B[0m');
          }
          final prefix = [
            if (filename != null) '\x1B[35m$filename\x1B[0m:',
            if (lineNum) '\x1B[36m${i+1}\x1B[0m:',
          ].join('');
          matches.add('$prefix$line');
        }
      }
      if (count) onOutput(TerminalOutput.output('${filename != null ? "$filename:" : ""}$cnt'));
      else if (matches.isNotEmpty) onOutput(TerminalOutput.output(matches.join('\n')));
    }

    if (stdin != null) { grepText(stdin.join('\n'), null); return; }
    if (files.isEmpty) { onOutput(TerminalOutput.error('grep: missing file operand')); return; }
    for (final f in files) {
      final path = fs.resolvePath(f);
      final content = fs.readFile(path);
      if (content == null) { onOutput(TerminalOutput.error("grep: $f: No such file or directory")); continue; }
      grepText(content, files.length > 1 ? f : null);
    }
  }

  void _head(List<String> args) => _headLines(args, null);
  void _headLines(List<String> args, List<String>? stdin) {
    int n = 10; String? file;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-n' && i + 1 < args.length) n = int.tryParse(args[++i]) ?? 10;
      else if (args[i].startsWith('-') && int.tryParse(args[i].substring(1)) != null) n = int.parse(args[i].substring(1));
      else file = args[i];
    }
    final lines = stdin ?? (file != null ? (fs.readFile(fs.resolvePath(file)) ?? '').split('\n') : []);
    onOutput(TerminalOutput.output(lines.take(n).join('\n')));
  }

  void _tail(List<String> args) => _tailLines(args, null);
  void _tailLines(List<String> args, List<String>? stdin) {
    int n = 10; bool follow = false; String? file;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-n' && i + 1 < args.length) n = int.tryParse(args[++i]) ?? 10;
      else if (args[i] == '-f') follow = true;
      else if (!args[i].startsWith('-')) file = args[i];
    }
    final lines = stdin ?? (file != null ? (fs.readFile(fs.resolvePath(file)) ?? '').split('\n') : []);
    final result = lines.skip(max(0, lines.length - n)).join('\n');
    onOutput(TerminalOutput.output(result));
    if (follow) onOutput(TerminalOutput.info('(tail -f: live follow not supported in emulator)'));
  }

  void _sort(List<String> args) => _sortLines(args, null);
  void _sortLines(List<String> args, List<String>? stdin) {
    bool reverse = false, unique = false, numeric = false;
    String? file;
    for (final a in args) {
      if (a == '-r') reverse = true;
      else if (a == '-u') unique = true;
      else if (a == '-n') numeric = true;
      else if (!a.startsWith('-')) file = a;
    }
    var lines = stdin ?? (file != null ? (fs.readFile(fs.resolvePath(file)) ?? '').split('\n') : []);
    if (numeric) {
      lines.sort((a, b) => (num.tryParse(a) ?? 0).compareTo(num.tryParse(b) ?? 0));
    } else {
      lines.sort();
    }
    if (reverse) lines = lines.reversed.toList();
    if (unique)  lines = lines.toSet().toList();
    onOutput(TerminalOutput.output(lines.join('\n')));
  }

  void _uniq(List<String> args) => _uniqLines(null, args: args);
  void _uniqLines(List<String>? stdin, {List<String> args = const []}) {
    bool count = args.contains('-c');
    String? file = args.where((a) => !a.startsWith('-')).firstOrNull;
    final lines = stdin ?? (file != null ? (fs.readFile(fs.resolvePath(file)) ?? '').split('\n') : []);
    final result = <String>[];
    String? last; int cnt = 0;
    for (final l in lines) {
      if (l == last) { cnt++; }
      else {
        if (last != null) result.add(count ? '${padLeft('$cnt', 7)} $last' : last!);
        last = l; cnt = 1;
      }
    }
    if (last != null) result.add(count ? '${padLeft('$cnt', 7)} $last' : last!);
    onOutput(TerminalOutput.output(result.join('\n')));
  }

  void _wc(List<String> args) => _wcLines(args, null);
  void _wcLines(List<String> args, List<String>? stdin) {
    bool lines = false, words = false, chars = false;
    String? file;
    for (final a in args) {
      if (a == '-l') lines = true; else if (a == '-w') words = true;
      else if (a == '-c' || a == '-m') chars = true;
      else if (!a.startsWith('-')) file = a;
    }
    if (!lines && !words && !chars) { lines = true; words = true; chars = true; }
    final content = stdin?.join('\n') ?? (file != null ? fs.readFile(fs.resolvePath(file)) ?? '' : '');
    final lc = content.split('\n').length;
    final wc = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final cc = content.length;
    final parts = [
      if (lines) padLeft('$lc', 8),
      if (words) padLeft('$wc', 8),
      if (chars) padLeft('$cc', 8),
    ];
    onOutput(TerminalOutput.output('${parts.join('')}${file != null ? " $file" : ""}'));
  }

  void _diff(List<String> args) {
    final files = args.where((a) => !a.startsWith('-')).toList();
    if (files.length < 2) { onOutput(TerminalOutput.error('diff: missing operand')); return; }
    final a = (fs.readFile(fs.resolvePath(files[0])) ?? '').split('\n');
    final b = (fs.readFile(fs.resolvePath(files[1])) ?? '').split('\n');
    if (a.join('\n') == b.join('\n')) { onOutput(TerminalOutput.output('')); return; }
    // Simple unified diff (line-by-line).
    onOutput(TerminalOutput.output('--- ${files[0]}\n+++ ${files[1]}'));
    for (var i = 0; i < max(a.length, b.length); i++) {
      final la = i < a.length ? a[i] : null;
      final lb = i < b.length ? b[i] : null;
      if (la == lb) { if (la != null) onOutput(TerminalOutput.output(' $la')); }
      else {
        if (la != null) onOutput(TerminalOutput.output('\x1B[31m-$la\x1B[0m'));
        if (lb != null) onOutput(TerminalOutput.output('\x1B[32m+$lb\x1B[0m'));
      }
    }
  }

  void _trCmd(List<String> args) => _trLines(args, null);
  void _trLines(List<String> args, List<String>? stdin) {
    if (args.length < 2) { onOutput(TerminalOutput.error('tr: missing operand')); return; }
    var text = stdin?.join('\n') ?? '';
    // Only handle simple char-set translation.
    final from = args[0]; final to = args[1];
    for (var i = 0; i < min(from.length, to.length); i++) {
      text = text.replaceAll(from[i], to[i]);
    }
    onOutput(TerminalOutput.output(text));
  }

  void _cutCmd(List<String> args) => _cutLines(args, null);
  void _cutLines(List<String> args, List<String>? stdin) {
    String delim = '\t'; String? fields; String? file;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-d' && i+1 < args.length) delim = args[++i];
      else if (args[i] == '-f' && i+1 < args.length) fields = args[++i];
      else if (!args[i].startsWith('-')) file = args[i];
    }
    final fieldNums = fields?.split(',').map((f) => int.tryParse(f) ?? 1).toList() ?? [1];
    final content = stdin?.join('\n') ?? (file != null ? fs.readFile(fs.resolvePath(file)) ?? '' : '');
    final result = content.split('\n').map((line) {
      final parts = line.split(delim);
      return fieldNums.map((f) => f <= parts.length ? parts[f - 1] : '').join(delim);
    }).join('\n');
    onOutput(TerminalOutput.output(result));
  }

  void _sed(List<String> args) {
    String? expr; String? file;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-e' && i+1 < args.length) expr = args[++i];
      else if (!args[i].startsWith('-')) {
        if (expr == null) expr = args[i]; else file = args[i];
      }
    }
    if (expr == null) { onOutput(TerminalOutput.error('sed: missing script')); return; }
    var content = file != null ? fs.readFile(fs.resolvePath(file)) ?? '' : '';
    // s/pattern/replace/flags
    final sMatch = RegExp(r'^s([^a-zA-Z])(.+?)\1(.*?)\1([gi]*)$').firstMatch(expr);
    if (sMatch != null) {
      final pat   = sMatch.group(2)!;
      final repl  = sMatch.group(3)!;
      final flags = sMatch.group(4)!;
      final global = flags.contains('g');
      final re = RegExp(pat, caseSensitive: !flags.contains('i'));
      content = global ? content.replaceAll(re, repl) : content.replaceFirst(re, repl);
      onOutput(TerminalOutput.output(content));
    } else {
      onOutput(TerminalOutput.error('sed: unsupported expression: $expr'));
    }
  }

  void _awk(List<String> args) {
    onOutput(TerminalOutput.info('awk: basic field-splitting only (NR, NF, \$1...\$9 supported in echo)\n'
        'Tip: use cut -d -f for field extraction.'));
  }

  void _teeCmd(List<String> args) => _teeLines(args, null);
  void _teeLines(List<String> args, List<String>? stdin) {
    if (stdin == null || args.isEmpty) { onOutput(TerminalOutput.error('tee: missing file operand')); return; }
    final text = stdin.join('\n');
    for (final f in args.where((a) => !a.startsWith('-'))) {
      fs.writeFile(fs.resolvePath(f), text);
    }
    onOutput(TerminalOutput.output(text));
  }

  void _xargsCmd(List<String> args) => _xargsLines(args, null);
  void _xargsLines(List<String> args, List<String>? stdin) {
    if (stdin == null || stdin.isEmpty) return;
    final cmd  = args.isEmpty ? 'echo' : args[0];
    final rest = args.length > 1 ? args.sublist(1) : <String>[];
    onOutput(TerminalOutput.info('xargs: running $cmd with ${stdin.length} arguments'));
  }

  void _find(List<String> args) {
    String dir = fs.currentDirectory;
    String? nameGlob, type;
    int? maxDepth;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-name' && i+1 < args.length)     nameGlob = args[++i];
      else if (args[i] == '-type' && i+1 < args.length) type = args[++i];
      else if (args[i] == '-maxdepth' && i+1 < args.length) maxDepth = int.tryParse(args[++i]);
      else if (!args[i].startsWith('-'))                 dir = fs.resolvePath(args[i]);
    }
    final results = <String>[];
    void search(String path, int depth) {
      if (maxDepth != null && depth > maxDepth!) return;
      final entries = fs.listDirectory(path, showHidden: true) ?? [];
      for (final e in entries) {
        final full = '$path/${e.name}';
        final nameMatch = nameGlob == null || _globMatch(e.name, nameGlob!);
        final typeMatch = type == null || (type == 'd') == e.isDirectory;
        if (nameMatch && typeMatch) results.add(full);
        if (e.isDirectory) search(full, depth + 1);
      }
    }
    search(dir, 0);
    onOutput(TerminalOutput.output(results.isEmpty ? '' : results.join('\n')));
  }

  bool _globMatch(String name, String glob) {
    final pattern = glob.replaceAll('.', r'\.').replaceAll('*', '.*').replaceAll('?', '.');
    return RegExp('^$pattern\$').hasMatch(name);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ENVIRONMENT
  // ══════════════════════════════════════════════════════════════════════════

  void _env(List<String> args) {
    final env = fs.getAllEnv();
    final lines = env.entries.map((e) => '\x1B[32m${e.key}\x1B[0m=\x1B[33m${e.value}\x1B[0m').toList()..sort();
    onOutput(TerminalOutput.output(lines.join('\n')));
  }

  void _printenv(List<String> args) {
    if (args.isEmpty) { _env([]); return; }
    for (final a in args) {
      final v = fs.getEnv(a);
      if (v.isEmpty) onOutput(TerminalOutput.error('printenv: $a: not set'));
      else onOutput(TerminalOutput.output(v));
    }
  }

  void _export(List<String> args) {
    for (final a in args) {
      if (a.contains('=')) {
        final idx = a.indexOf('=');
        fs.setEnv(a.substring(0, idx), a.substring(idx + 1).replaceAll(RegExp(r'''^["']|["']$'''), ''));
      } else {
        onOutput(TerminalOutput.error("export: '$a': not a valid identifier"));
      }
    }
  }

  void _source(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.error('source: missing file')); return; }
    final path = fs.resolvePath(args[0]);
    final content = fs.readFile(path);
    if (content == null) { onOutput(TerminalOutput.error("source: $args[0]: No such file")); return; }
    onOutput(TerminalOutput.info('Sourced ${args[0]} (aliases and exports applied)'));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SYSTEM INFO
  // ══════════════════════════════════════════════════════════════════════════

  void _which(List<String> args) {
    for (final a in args) {
      if (kBuiltinCommands.contains(a)) onOutput(TerminalOutput.output('/usr/bin/$a'));
      else onOutput(TerminalOutput.error('which: $a not found'));
    }
  }

  void _date(List<String> args) {
    final now = DateTime.now();
    final fmt = args.firstOrNull?.startsWith('+') == true ? args.first.substring(1) : null;
    if (fmt != null) {
      final result = fmt
          .replaceAll('%Y', '${now.year}').replaceAll('%y', '${now.year % 100}')
          .replaceAll('%m', now.month.toString().padLeft(2, '0'))
          .replaceAll('%d', now.day.toString().padLeft(2, '0'))
          .replaceAll('%H', now.hour.toString().padLeft(2, '0'))
          .replaceAll('%M', now.minute.toString().padLeft(2, '0'))
          .replaceAll('%S', now.second.toString().padLeft(2, '0'))
          .replaceAll('%A', DateFormat('EEEE').format(now))
          .replaceAll('%B', DateFormat('MMMM').format(now))
          .replaceAll('%s', '${now.millisecondsSinceEpoch ~/ 1000}');
      onOutput(TerminalOutput.output(result));
    } else {
      onOutput(TerminalOutput.output(DateFormat('EEE MMM d HH:mm:ss zzz yyyy').format(now)));
    }
  }

  void _whoami()   => onOutput(TerminalOutput.output(fs.getEnv('USER')));
  void _hostname() => onOutput(TerminalOutput.output(fs.getEnv('HOSTNAME')));

  void _uname(List<String> args) {
    const full = 'FlutterOS flutter-terminal 6.1.0-flutter #1 SMP PREEMPT Dart-arm64 GNU/Linux';
    if (args.contains('-a')) onOutput(TerminalOutput.output(full));
    else if (args.contains('-r')) onOutput(TerminalOutput.output('6.1.0-flutter'));
    else if (args.contains('-m')) onOutput(TerminalOutput.output('x86_64'));
    else onOutput(TerminalOutput.output('FlutterOS'));
  }

  void _uptime() {
    final now = DateTime.now();
    onOutput(TerminalOutput.output(
        ' ${DateFormat('HH:mm:ss').format(now)} up 3 days,  4:22,  1 user,  load average: 0.42, 0.38, 0.31'));
  }

  void _ps(List<String> args) {
    final wide = args.any((a) => a.contains('a') || a.contains('u') || a.contains('x'));
    if (wide) {
      onOutput(TerminalOutput.output('''USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
user           1  0.0  0.1   2316   840 ?        Ss   09:00   0:00 /sbin/init
user         156  0.0  0.2  15432  2048 ?        Ss   09:00   0:00 /usr/sbin/sshd
user         823  0.3  1.8 124532 18432 ?        Sl   09:15   0:22 flutter_terminal
user         824  0.1  0.5  12432  4096 pts/0    Ss   09:15   0:01 /bin/bash
user        1024  0.0  0.1   9432   960 pts/0    R+   now     0:00 ps aux'''));
    } else {
      onOutput(TerminalOutput.output('  PID TTY          TIME CMD\n  824 pts/0    00:00:01 bash\n 1024 pts/0    00:00:00 ps'));
    }
  }

  void _df(List<String> args) {
    final h = args.contains('-h');
    onOutput(TerminalOutput.output(h
        ? 'Filesystem      Size  Used Avail Use% Mounted on\n/dev/sda1        50G   18G   30G  37% /\ntmpfs           3.8G  1.2M  3.8G   1% /dev/shm\n/dev/sda2       200G   82G  108G  44% /home'
        : 'Filesystem     1K-blocks    Used Available Use% Mounted on\n/dev/sda1       52428800 18874368  31457280  38% /\ntmpfs            3932160     1200   3930960   1% /dev/shm'));
  }

  void _du(List<String> args) {
    bool h = false, s = false;
    String target = fs.currentDirectory;
    for (final a in args) {
      if (a == '-h') h = true; else if (a == '-s') s = true;
      else if (a == '-sh' || a == '-hs') { h = true; s = true; }
      else if (!a.startsWith('-')) target = fs.resolvePath(a);
    }
    final size = h ? '4.0K' : '4';
    if (s) { onOutput(TerminalOutput.output('$size\t$target')); return; }
    final entries = fs.listDirectory(target, showHidden: true) ?? [];
    final lines = entries.map((e) {
      final sz = h ? formatFileSize(e.size) : '${e.size}';
      return '$sz\t$target/${e.name}';
    }).toList();
    lines.add('$size\t$target');
    onOutput(TerminalOutput.output(lines.join('\n')));
  }

  void _free(List<String> args) {
    final h = args.contains('-h');
    onOutput(TerminalOutput.output(h
        ? '              total        used        free      shared  buff/cache   available\nMem:           7.5G        2.1G        3.8G        128M        1.6G        5.0G\nSwap:          2.0G          0B        2.0G'
        : '              total        used        free      shared  buff/cache   available\nMem:        7864320     2097152     3932160      131072     1835008     5242880\nSwap:       2097152           0     2097152'));
  }

  void _top() {
    onOutput(TerminalOutput.output('''top - ${DateFormat('HH:mm:ss').format(DateTime.now())} up 3 days,  4:22,  1 user
Tasks:  95 total,   1 running,  94 sleeping
%Cpu(s):  2.3 us,  1.1 sy,  96.2 id,  0.3 wa
MiB Mem :   7680.0 total,   3840.0 free,   2048.0 used
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used

\x1B[7m    PID USER      PR  NI    VIRT    RES  %CPU  %MEM     TIME+ COMMAND\x1B[0m
    823 user      20   0  124532  18432   0.3   0.2   0:22.34 flutter_terminal
    824 user      20   0   12432   4096   0.1   0.1   0:01.22 bash
      1 root      20   0    2316    840   0.0   0.0   0:00.18 init
    156 user      20   0   15432   2048   0.0   0.0   0:00.44 sshd
\x1B[90m(Simulated snapshot)\x1B[0m'''));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NETWORK
  // ══════════════════════════════════════════════════════════════════════════

  void _ping(List<String> args) {
    final host = args.firstWhere((a) => !a.startsWith('-'), orElse: () => '');
    if (host.isEmpty) { onOutput(TerminalOutput.error('ping: missing host')); return; }
    final count = args.contains('-c') ? int.tryParse(args[args.indexOf('-c') + 1]) ?? 4 : 4;
    final rng = Random();
    final lines = List.generate(count, (i) =>
        '64 bytes from $host: icmp_seq=$i ttl=52 time=${(rng.nextDouble() * 8 + 8).toStringAsFixed(3)} ms');
    final avg = (rng.nextDouble() * 3 + 9).toStringAsFixed(3);
    onOutput(TerminalOutput.output(
        'PING $host: 56 data bytes\n${lines.join('\n')}\n\n--- $host ping statistics ---\n'
        '$count packets transmitted, $count received, 0% packet loss\nrtt min/avg/max = 8.0/$avg/12.0 ms'));
  }

  void _curl(List<String> args) {
    final url = args.lastWhere((a) => !a.startsWith('-'), orElse: () => '');
    if (url.isEmpty) { onOutput(TerminalOutput.error('curl: try "curl --help"')); return; }
    final verbose = args.contains('-v');
    if (verbose) onOutput(TerminalOutput.output('> GET / HTTP/1.1\n> Host: $url\n< HTTP/1.1 200 OK'));
    onOutput(TerminalOutput.output('{\n  "url": "$url",\n  "status": "ok",\n  "simulated": true\n}'));
  }

  void _network(String cmd, List<String> args) {
    onOutput(TerminalOutput.output('''eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.105  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::1  prefixlen 64  scopeid 0x20<link>
        ether aa:bb:cc:dd:ee:ff  txqueuelen 1000  (Ethernet)
        RX packets 12430  bytes 9485123 (9.0 MiB)
        TX packets 8932   bytes 2305481 (2.2 MiB)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>'''));
  }

  void _ssh(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.error('ssh: missing hostname')); return; }
    onOutput(TerminalOutput.info('ssh: connection to ${args.last} simulated\nThis is a virtual session.'));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DEVELOPER TOOLS
  // ══════════════════════════════════════════════════════════════════════════

  void _git(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output(
          'usage: git <command> [<args>]\n\nCommon commands:\n  clone, init, add, commit, status, push, pull, log, diff, branch, checkout, merge, rebase, stash'));
      return;
    }
    switch (args[0]) {
      case 'status':
        onOutput(TerminalOutput.output('''On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
\x1B[31m\tmodified:   lib/main.dart\x1B[0m
\x1B[31m\tmodified:   lib/providers/terminal_providers.dart\x1B[0m

Untracked files:
\x1B[31m\tlib/utils/pipe_engine.dart\x1B[0m

no changes added to commit (use "git add")'''));
        break;
      case 'log':
        final n = args.contains('--oneline') ? 5 : 3;
        final commits = [
          ('a1b2c3d', 'feat: real pipe execution engine'),
          ('b2c3d4e', 'fix: per-tab filesystem isolation'),
          ('c3d4e5f', 'fix: ANSI span caching in TerminalOutput'),
          ('d4e5f6g', 'refactor: immutable TerminalTab model'),
          ('e5f6g7h', 'chore: initial commit'),
        ].take(n);
        if (args.contains('--oneline')) {
          onOutput(TerminalOutput.output(commits.map((c) => '\x1B[33m${c.$1}\x1B[0m ${c.$2}').join('\n')));
        } else {
          onOutput(TerminalOutput.output(commits.map((c) =>
              '\x1B[33mcommit ${c.$1}abcdef1234567890abcdef\x1B[0m\nAuthor: user <user@example.com>\nDate:   ${DateFormat('EEE MMM d HH:mm:ss yyyy').format(DateTime.now())} +0000\n\n    ${c.$2}\n').join('\n')));
        }
        break;
      case 'branch':
        final all = args.contains('-a');
        onOutput(TerminalOutput.output('* \x1B[32mmain\x1B[0m\n  develop\n  feature/pipe-engine${all ? "\n  remotes/origin/main\n  remotes/origin/develop" : ""}'));
        break;
      case 'diff':
        onOutput(TerminalOutput.output('\x1B[33m@@ -1,3 +1,5 @@\x1B[0m\n \x1B[0m// Terminal providers\n\x1B[31m-class CommandExecutionNotifier extends Notifier<bool> {\x1B[0m\n\x1B[32m+// Per-tab busy state — no global lock\x1B[0m\n\x1B[32m+class CommandExecutionNotifier extends Notifier<Map<String,bool>> {\x1B[0m'));
        break;
      case 'add':    onOutput(TerminalOutput.output('')); break;
      case 'init':   onOutput(TerminalOutput.output('Initialized empty Git repository in ${fs.currentDirectory}/.git/')); break;
      case 'commit':
        final msg = args.contains('-m') ? args[args.indexOf('-m') + 1] : 'Update';
        onOutput(TerminalOutput.output('[main a1b2c3d] $msg\n 2 files changed, 14 insertions(+), 3 deletions(-)'));
        break;
      case 'push':   onOutput(TerminalOutput.output('Enumerating objects: 5, done.\nCompressing objects: 100% (3/3), done.\nTo origin/main\n   b2c3d4e..a1b2c3d  main -> main')); break;
      case 'pull':   onOutput(TerminalOutput.output('Already up to date.')); break;
      case 'stash':  onOutput(TerminalOutput.output('Saved working directory and index state WIP on main: a1b2c3d feat: update')); break;
      case 'checkout':
        final branch = args.where((a) => !a.startsWith('-')).skip(1).firstOrNull;
        if (branch != null) onOutput(TerminalOutput.output("Switched to branch '$branch'"));
        break;
      case 'clone':  onOutput(TerminalOutput.output("Cloning into '${args.lastOrNull?.split('/').last ?? 'repo'}'...\ndone.")); break;
      default:
        onOutput(TerminalOutput.error("git: '${args[0]}' is not a git command. See 'git --help'."));
    }
  }

  void _npm(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.info('npm <command>\nCommands: install, run, build, test, publish')); return; }
    switch (args[0]) {
      case 'install': case 'i':
        onOutput(TerminalOutput.output('added 342 packages in 4.2s\n24 packages are looking for funding'));
        break;
      case 'run':
        final script = args.elementAtOrNull(1) ?? 'start';
        onOutput(TerminalOutput.output('> project@1.0.0 $script\n> node index.js\nServer running on http://localhost:3000'));
        break;
      case 'build':   onOutput(TerminalOutput.output('> project@1.0.0 build\n> vite build\n✓ built in 1.24s')); break;
      case 'test':    onOutput(TerminalOutput.output('PASS src/app.test.js\nTests: 12 passed')); break;
      case 'publish': onOutput(TerminalOutput.output('+ package@1.0.0')); break;
      default:        onOutput(TerminalOutput.error("npm: unknown command '${args[0]}'"));
    }
  }

  void _python(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('Python 3.11.4 (main)\nType "help" or "exit()" to exit.\n\x1B[90m>>> (Interactive mode not supported in emulator)\x1B[0m'));
    } else {
      onOutput(TerminalOutput.info('python3: Executing ${args[0]} (simulated)'));
    }
  }

  void _flutterCmd(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('Flutter 3.19.0 • channel stable\nDart 3.3.0 • DevTools 2.28.2\n\nUsage: flutter <command>\n  run, build, pub, test, clean, doctor, create, analyze'));
      return;
    }
    switch (args[0]) {
      case 'doctor':
        onOutput(TerminalOutput.output('Doctor summary:\n[\x1B[32m✓\x1B[0m] Flutter (3.19.0)\n[\x1B[32m✓\x1B[0m] Android toolchain\n[\x1B[32m✓\x1B[0m] Chrome\n[\x1B[32m✓\x1B[0m] VS Code\n[\x1B[32m✓\x1B[0m] Connected device (3 available)\n\n• No issues found!'));
        break;
      case 'pub':
        if (args.elementAtOrNull(1) == 'get') {
          onOutput(TerminalOutput.output('Resolving dependencies...\n+ flutter_riverpod 2.5.1\n+ google_fonts 6.2.1\n+ collection 1.18.0\nGot dependencies!'));
        } else if (args.elementAtOrNull(1) == 'add') {
          onOutput(TerminalOutput.output('+ ${args.elementAtOrNull(2) ?? "package"}\nGot dependencies!'));
        } else {
          onOutput(TerminalOutput.output('flutter pub get|add|remove|upgrade|outdated'));
        }
        break;
      case 'clean':   onOutput(TerminalOutput.output('Deleting build/...\nDeleted .dart_tool/')); break;
      case 'build':   onOutput(TerminalOutput.output('Building ${args.elementAtOrNull(1) ?? "app"}...\n✓ Built in 12.4s')); break;
      case 'run':     onOutput(TerminalOutput.output('Launching lib/main.dart on Chrome in debug mode...\nFlutter run key commands.\n  r — Hot reload\n  R — Hot restart\n  q — Quit')); break;
      case 'test':    onOutput(TerminalOutput.output('00:03 +24: All tests passed!')); break;
      case 'analyze': onOutput(TerminalOutput.output('Analyzing project...\nNo issues found!')); break;
      case 'create':  onOutput(TerminalOutput.output('Creating project ${args.elementAtOrNull(1) ?? "my_app"}...\nAll done!')); break;
      default:        onOutput(TerminalOutput.error("flutter: '${args[0]}' is not a flutter command."));
    }
  }

  void _dart(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('Dart SDK 3.3.0\nUsage: dart <command|dart-file>\n  analyze, format, test, compile, run, pub'));
      return;
    }
    switch (args[0]) {
      case 'analyze': onOutput(TerminalOutput.output('Analyzing...\nNo issues found!')); break;
      case 'format':  onOutput(TerminalOutput.output('Formatted ${args.elementAtOrNull(1) ?? "."}')); break;
      case 'test':    onOutput(TerminalOutput.output('00:01 +12: All tests passed!')); break;
      case 'compile': onOutput(TerminalOutput.output('Compiled to ${args.elementAtOrNull(2) ?? "output.exe"}')); break;
      case 'run':     onOutput(TerminalOutput.output('Running ${args.elementAtOrNull(1) ?? "main.dart"}...')); break;
      default:        onOutput(TerminalOutput.error("dart: unknown command '${args[0]}'"));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHELL BUILTINS
  // ══════════════════════════════════════════════════════════════════════════

  void _aliasList(List<String> args) {
    if (args.isEmpty) {
      final out = _aliases.entries.map((e) => "alias \x1B[32m${e.key}\x1B[0m='\x1B[33m${e.value}\x1B[0m'").join('\n');
      onOutput(TerminalOutput.output(out));
      return;
    }
    // alias name=value
    for (final a in args) {
      if (a.contains('=')) {
        final idx = a.indexOf('=');
        _aliases[a.substring(0, idx)] = a.substring(idx + 1).replaceAll("'", '').replaceAll('"', '');
        onOutput(TerminalOutput.output(''));
      }
    }
  }

  void _historyCmd() {
    onOutput(TerminalOutput.info('Use ↑/↓ arrows to navigate history, or check the HISTORY tab in the sidebar.'));
  }

  void _help(List<String> args) {
    if (args.isNotEmpty) { _man(args); return; }
    onOutput(TerminalOutput.output(r'''
[1m[34mFlutter Terminal — Command Reference[0m
[90m────────────────────────────────────────────────────────────────────[0m

[33mFILE SYSTEM[0m
  [32mls[0m [-lahrt]          List directory   [32mtree[0m [dir]         Directory tree
  [32mcd[0m [dir]             Change directory  [32mstat[0m [file]        File metadata
  [32mpwd[0m                  Print cwd         [32mchmod[0m [mode] [f]   Change mode
  [32mcat[0m [-n] [file]      Show file         [32mchown[0m [own] [f]   Change owner
  [32mmkdir[0m [-p] [dir]     Create dir        [32mln[0m [-s] [src][dst] Link file
  [32mtouch[0m [file]         Create/update     [32mrm[0m [-rf] [path]   Remove
  [32mcp[0m [src] [dst]       Copy              [32mmv[0m [src] [dst]   Move/rename

[33mTEXT PROCESSING[0m
  [32mgrep[0m [-invrc] pat f  Search pattern    [32mhead[0m [-n] [file]  First N lines
  [32mtail[0m [-n] [file]     Last N lines      [32msort[0m [-rnu] [f]  Sort lines
  [32muniq[0m [-c] [file]     Deduplicate       [32mwc[0m [-lwc] [f]   Count
  [32msed[0m 's/a/b/' [file]  Stream edit       [32mtr[0m [a] [b]      Translate chars
  [32mcut[0m [-d] [-f] [file] Cut fields        [32mdiff[0m [f1] [f2]  Compare files
  [32mtee[0m [file]           Fork output       [32mxargs[0m [cmd]      Build commands

[33mPIPES & REDIRECTION[0m
  cmd | grep pat        Real pipe routing to text-filter commands
  cmd > file            Redirect stdout to file (overwrite)
  cmd >> file           Redirect stdout to file (append)
  cmd1; cmd2            Sequential execution

[33mSYSTEM[0m
  [32mps[0m [-aux]            Processes         [32mdf[0m [-h]          Disk free
  [32mfree[0m [-h]            Memory            [32mdu[0m [-sh] [path]  Disk usage
  [32muname[0m [-arm]         Kernel info       [32muptime[0m           System uptime
  [32mdate[0m [+fmt]          Date/time         [32mtop[0m              Process view
  [32mwhoami[0m               Current user      [32mhostname[0m         Hostname

[33mENVIRONMENT[0m
  [32menv[0m                  All variables     [32mprintenv[0m [KEY]   Print var
  [32mexport[0m KEY=VAL        Set variable      [32msource[0m [file]   Execute script
  [32malias[0m [name=val]      Manage aliases    [32mwhich[0m [cmd]     Find command

[33mNETWORK[0m
  [32mping[0m [-c N] [host]   Ping host         [32mcurl[0m [-v] [url]  HTTP request
  [32mifconfig[0m / [32mip[0m       Network info      [32mssh[0m [user@host]  Connect (sim)

[33mDEVELOPER[0m
  [32mgit[0m [cmd]             Version control   [32mflutter[0m [cmd]   Flutter SDK
  [32mdart[0m [cmd]            Dart runtime      [32mnpm[0m [cmd]       Node packages
  [32mpython3[0m [script]      Python interpreter

[33mFUN[0m
  [32mneofetch[0m             System art        [32mcowsay[0m [text]   Talking cow
  [32mfortune[0m              Random quote      [32mban ner[0m [text]  Banner
  [32mcal[0m [m] [y]           Calendar          [32mbc[0m [expr]       Calculator

[90mShortcuts: Ctrl+L clear · Ctrl+T new tab · Ctrl+F search · Tab autocomplete · ↑↓ history[0m
'''.replaceAll('[', '\x1B[').replaceAll('ban ner', 'banner')));
  }

  void _man(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.error('man: what manual page do you want?')); return; }
    const pages = <String, String>{
      'ls':   'ls — list directory contents\n\nSYNOPSIS\n  ls [-lahrt] [FILE]\n\nFLAGS\n  -l  long format\n  -a  show hidden\n  -h  human sizes\n  -r  reverse\n  -t  sort by time',
      'grep': 'grep — search for patterns\n\nSYNOPSIS\n  grep [-invrc] PATTERN [FILE]\n\nFLAGS\n  -i  ignore case\n  -n  line numbers\n  -v  invert match\n  -r  recursive\n  -c  count only',
      'find': 'find — search for files\n\nSYNOPSIS\n  find [DIR] [-name GLOB] [-type d|f] [-maxdepth N]',
      'sed':  'sed — stream editor\n\nSYNOPSIS\n  sed s/PATTERN/REPLACE/[g] [FILE]\n\nFLAGS in expression\n  g  replace all occurrences\n  i  case-insensitive',
      'git':  'git — version control\n\nCOMMANDS\n  status, log [--oneline], diff, branch [-a]\n  add, commit -m MSG, push, pull, stash, clone',
    };
    final page = pages[args[0]];
    if (page == null) {
      onOutput(TerminalOutput.error('No manual entry for ${args[0]}'));
    } else {
      onOutput(TerminalOutput.output('\x1B[1m${args[0].toUpperCase()}(1)\x1B[0m\n\n$page'));
    }
  }

  void _editor(String cmd, List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.info('$cmd: no file specified')); return; }
    onOutput(TerminalOutput.info(
        '✏️  Editor mode not yet supported.\nTip: use output redirection to write files:\n  echo "content" > ${args[0]}'));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FUN
  // ══════════════════════════════════════════════════════════════════════════

  void _neofetch() {
    onOutput(TerminalOutput.output('''
\x1B[34m    ████████████████    \x1B[0m   \x1B[1muser\x1B[0m@\x1B[1mflutter-terminal\x1B[0m
\x1B[34m  ██              ██  \x1B[0m   \x1B[90m──────────────────────────\x1B[0m
\x1B[34m ██  \x1B[36m████  ████\x1B[34m  ██ \x1B[0m   \x1B[33mOS:\x1B[0m       FlutterOS 1.0 x86_64
\x1B[34m ██  \x1B[36m████  ████\x1B[34m  ██ \x1B[0m   \x1B[33mHost:\x1B[0m     Flutter Terminal v1.0
\x1B[34m ██              ██  \x1B[0m   \x1B[33mKernel:\x1B[0m   Dart 3.3.0
\x1B[34m ██  \x1B[36m██████████\x1B[34m  ██ \x1B[0m   \x1B[33mUptime:\x1B[0m   3 days, 4 hours
\x1B[34m  ██              ██  \x1B[0m   \x1B[33mShell:\x1B[0m    flutter_bash 1.0
\x1B[34m    ████████████████    \x1B[0m   \x1B[33mTerminal:\x1B[0m flutter_terminal
                         \x1B[33mCPU:\x1B[0m      Dart VM (8 isolates)
                         \x1B[33mMemory:\x1B[0m   2.1G / 7.5G

                         \x1B[30m███\x1B[31m███\x1B[32m███\x1B[33m███\x1B[34m███\x1B[35m███\x1B[36m███\x1B[37m███\x1B[0m
'''));
  }

  void _banner(List<String> args) {
    final text = args.join(' ');
    if (text.isEmpty) return;
    onOutput(TerminalOutput.output('\x1B[36m${'═' * (text.length + 4)}\x1B[0m\n\x1B[36m║\x1B[0m \x1B[1m$text\x1B[0m \x1B[36m║\x1B[0m\n\x1B[36m${'═' * (text.length + 4)}\x1B[0m'));
  }

  void _cowsay(List<String> args) {
    final msg = args.isEmpty ? 'Moo!' : args.join(' ');
    final bar = '-' * (msg.length + 2);
    onOutput(TerminalOutput.output(' $bar\n< $msg >\n $bar\n        \\   ^__^\n         \\  (oo)\\_______\n            (__)\\       )\\/\\\n                ||----w |\n                ||     ||'));
  }

  void _fortune() {
    const quotes = [
      'Talk is cheap. Show me the code. — Linus Torvalds',
      'The best way to predict the future is to implement it.',
      'Programs must be written for people to read. — Harold Abelson',
      'First, solve the problem. Then, write the code. — John Johnson',
      'Any fool can write code a computer understands. Good programmers write code humans understand.',
      'In Flutter we trust.',
      'Premature optimisation is the root of all evil. — Donald Knuth',
      'Simplicity is the soul of efficiency.',
      'The function of good software is to make the complex appear simple.',
      'Make it work, make it right, make it fast. — Kent Beck',
    ];
    onOutput(TerminalOutput.output('\x1B[33m"${quotes[Random().nextInt(quotes.length)]}"\x1B[0m'));
  }

  void _cal(List<String> args) {
    final now = DateTime.now();
    final month = args.isNotEmpty ? (int.tryParse(args[0]) ?? now.month) : now.month;
    final year  = args.length > 1 ? (int.tryParse(args[1]) ?? now.year)  : now.year;
    final name  = DateFormat('MMMM yyyy').format(DateTime(year, month));
    final first = DateTime(year, month, 1);
    final days  = DateTime(year, month + 1, 0).day;
    final sb    = StringBuffer('\x1B[1m${name.padLeft(16)}\x1B[0m\nSu Mo Tu We Th Fr Sa\n');
    var dow = first.weekday % 7;
    sb.write('   ' * dow);
    for (var d = 1; d <= days; d++) {
      final today = d == now.day && month == now.month && year == now.year;
      final s = d.toString().padLeft(2);
      sb.write(today ? '\x1B[7m$s\x1B[0m ' : '$s ');
      dow++;
      if (dow == 7 && d < days) { sb.writeln(); dow = 0; }
    }
    onOutput(TerminalOutput.output(sb.toString()));
  }

  void _bc(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.info('bc: usage: bc <expr>  e.g. bc 3 + 4 * 2')); return;
    }
    try {
      final result = _evalExpr(args.join(' '));
      onOutput(TerminalOutput.output(result % 1 == 0 ? '${result.toInt()}' : '$result'));
    } catch (_) {
      onOutput(TerminalOutput.error('bc: syntax error'));
    }
  }

  // Respects operator precedence (* / before + -) via a recursive-descent parser.
  double _evalExpr(String expr) {
    final tokens = expr.trim().split(RegExp(r'\s*([+\-*/%()])\s*|\s+')).where((t) => t.isNotEmpty).toList();
    int pos = 0;
    late double Function() parseExpr;

    double parsePrimary() {
      if (pos < tokens.length) {
        final t = tokens[pos++];
        if (t == '(') { final v = parseExpr(); pos++; return v; }
        return double.parse(t);
      }
      return 0;
    }

    double parseTerm() {
      var v = parsePrimary();
      while (pos < tokens.length && (tokens[pos] == '*' || tokens[pos] == '/' || tokens[pos] == '%')) {
        final op = tokens[pos++];
        final r  = parsePrimary();
        if (op == '*') v *= r; else if (op == '/') v /= r; else v = v % r;
      }
      return v;
    }

    parseExpr = () {
      var v = parseTerm();
      while (pos < tokens.length && (tokens[pos] == '+' || tokens[pos] == '-')) {
        final op = tokens[pos++];
        final r  = parseTerm();
        if (op == '+') v += r; else v -= r;
      }
      return v;
    };

    return parseExpr();
  }

  void _yes(List<String> args) {
    final text = args.isEmpty ? 'y' : args.join(' ');
    onOutput(TerminalOutput.output(List.filled(20, text).join('\n') + '\n\x1B[90m(truncated after 20 lines)\x1B[0m'));
  }

  void _seq(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.error('seq: missing operand')); return; }
    int start = 1, end, step = 1;
    if (args.length == 1) { end = int.tryParse(args[0]) ?? 1; }
    else if (args.length == 2) { start = int.tryParse(args[0]) ?? 1; end = int.tryParse(args[1]) ?? 1; }
    else { start = int.tryParse(args[0]) ?? 1; step = int.tryParse(args[1]) ?? 1; end = int.tryParse(args[2]) ?? 1; }
    final nums = <int>[];
    for (var i = start; step > 0 ? i <= end : i >= end; i += step) nums.add(i);
    onOutput(TerminalOutput.output(nums.join('\n')));
  }

  Future<void> _sleep(List<String> args) async {
    final secs = double.tryParse(args.firstOrNull ?? '') ?? 1;
    await Future.delayed(Duration(milliseconds: (secs.clamp(0, 10) * 1000).toInt()));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARG PARSING
  // ══════════════════════════════════════════════════════════════════════════

  List<String> _parseArgs(String input) {
    final args = <String>[];
    var cur = StringBuffer();
    var inS = false; var inD = false;
    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (c == "'" && !inD) { inS = !inS; }
      else if (c == '"' && !inS) { inD = !inD; }
      else if (c == '\\' && i + 1 < input.length && !inS) { cur.write(input[++i]); }
      else if (c == ' ' && !inS && !inD) {
        if (cur.isNotEmpty) { args.add(cur.toString()); cur = StringBuffer(); }
      } else { cur.write(c); }
    }
    if (cur.isNotEmpty) args.add(cur.toString());
    return args;
  }
}

// ── Extensions ────────────────────────────────────────────────────────────────
extension ListExt<T> on List<T> {
  T? get firstOrNull  => isEmpty ? null : first;
  T? get lastOrNull   => isEmpty ? null : last;
  T? elementAtOrNull(int i) => i < length ? this[i] : null;
}
