import 'dart:math';
import 'package:intl/intl.dart';
import '../models/terminal_models.dart';
import '../utils/virtual_filesystem.dart';
import '../utils/ansi_parser.dart';

typedef OutputCallback = void Function(TerminalOutput output);
typedef ClearCallback = void Function();
typedef ChangeDirCallback = void Function(String dir);

class CommandProcessor {
  final VirtualFileSystem fs;
  final OutputCallback onOutput;
  final ClearCallback onClear;
  final ChangeDirCallback onChangeDir;

  CommandProcessor({
    required this.fs,
    required this.onOutput,
    required this.onClear,
    required this.onChangeDir,
  });

  final Map<String, String> _aliases = {
    'll': 'ls -la',
    'la': 'ls -a',
    'l': 'ls -CF',
    '..': 'cd ..',
    '...': 'cd ../..',
  };

  Future<void> execute(String rawInput) async {
    final input = rawInput.trim();
    if (input.isEmpty) return;

    // Expand aliases
    final firstWord = input.split(' ').first;
    final expandedInput = _aliases.containsKey(firstWord)
        ? _aliases[firstWord]! + input.substring(firstWord.length)
        : input;

    // Handle pipe simulation
    if (expandedInput.contains(' | ')) {
      await _handlePipe(expandedInput);
      return;
    }

    // Parse command and args
    final parts = _parseArgs(expandedInput);
    if (parts.isEmpty) return;

    final command = parts[0];
    final args = parts.sublist(1);

    await _dispatch(command, args, expandedInput);
  }

  Future<void> _dispatch(String command, List<String> args, String raw) async {
    switch (command) {
      case 'help': _help(args); break;
      case 'ls': _ls(args); break;
      case 'cd': _cd(args); break;
      case 'pwd': _pwd(); break;
      case 'cat': _cat(args); break;
      case 'echo': _echo(args); break;
      case 'clear': onClear(); break;
      case 'mkdir': _mkdir(args); break;
      case 'touch': _touch(args); break;
      case 'rm': _rm(args); break;
      case 'cp': _cp(args); break;
      case 'mv': _mv(args); break;
      case 'env': _env(args); break;
      case 'export': _export(args); break;
      case 'which': _which(args); break;
      case 'date': _date(args); break;
      case 'whoami': _whoami(); break;
      case 'hostname': _hostname(); break;
      case 'uname': _uname(args); break;
      case 'uptime': _uptime(); break;
      case 'ps': _ps(args); break;
      case 'df': _df(args); break;
      case 'du': _du(args); break;
      case 'free': _free(args); break;
      case 'top': _top(); break;
      case 'grep': _grep(args); break;
      case 'find': _find(args); break;
      case 'wc': _wc(args); break;
      case 'head': _head(args); break;
      case 'tail': _tail(args); break;
      case 'sort': _sort(args); break;
      case 'uniq': _uniq(args); break;
      case 'history': _history([]); break;
      case 'alias': _aliasList(args); break;
      case 'write':
      case 'nano':
      case 'vim':
      case 'vi': _editor(command, args); break;
      case 'man': _man(args); break;
      case 'curl': _curl(args); break;
      case 'ping': _ping(args); break;
      case 'ifconfig':
      case 'ip': _network(command, args); break;
      case 'ssh': _ssh(args); break;
      case 'git': _git(args); break;
      case 'npm': _npm(args); break;
      case 'python3':
      case 'python': _python(args); break;
      case 'flutter': _flutterCmd(args); break;
      case 'dart': _dart(args); break;
      case 'yes': _yes(args); break;
      case 'seq': _seq(args); break;
      case 'sleep': await _sleep(args); break;
      case 'true': break;
      case 'false':
        onOutput(TerminalOutput.error('Command failed with exit code 1')); break;
      case 'exit':
      case 'logout':
        onOutput(TerminalOutput.info('Session ended. Goodbye!')); break;
      case 'neofetch': _neofetch(); break;
      case 'banner': _banner(args); break;
      case 'cowsay': _cowsay(args); break;
      case 'fortune': _fortune(); break;
      case 'cal': _cal(args); break;
      case 'bc': _bc(args); break;
      default:
        onOutput(TerminalOutput.error(
          '$command: command not found\nType "help" for a list of available commands.',
        ));
    }
  }

  // ── Commands ──────────────────────────────────────────────────────────────

  void _help(List<String> args) {
    if (args.isNotEmpty) {
      _man(args); return;
    }
    onOutput(TerminalOutput.output('''
\x1B[1m\x1B[34mFlutter Terminal — Available Commands\x1B[0m
\x1B[90m────────────────────────────────────────────────────────────────\x1B[0m

\x1B[33mFILE SYSTEM\x1B[0m
  \x1B[32mls\x1B[0m [-la]            List directory contents
  \x1B[32mcd\x1B[0m [dir]            Change directory
  \x1B[32mpwd\x1B[0m                 Print working directory
  \x1B[32mcat\x1B[0m [file]          Display file contents
  \x1B[32mmkdir\x1B[0m [dir]         Create directory
  \x1B[32mtouch\x1B[0m [file]        Create empty file
  \x1B[32mrm\x1B[0m [-rf] [path]     Remove file or directory
  \x1B[32mcp\x1B[0m [src] [dst]      Copy file
  \x1B[32mmv\x1B[0m [src] [dst]      Move/rename file
  \x1B[32mfind\x1B[0m [dir] [name]   Search for files
  \x1B[32mdu\x1B[0m [-sh] [path]     Disk usage

\x1B[33mTEXT PROCESSING\x1B[0m
  \x1B[32mgrep\x1B[0m [pat] [file]   Search text in file
  \x1B[32mhead\x1B[0m [-n] [file]    First N lines
  \x1B[32mtail\x1B[0m [-n] [file]    Last N lines
  \x1B[32mwc\x1B[0m [-lwc] [file]    Word/line/char count
  \x1B[32msort\x1B[0m [file]         Sort lines
  \x1B[32muniq\x1B[0m [file]         Remove duplicates
  \x1B[32mecho\x1B[0m [text]         Print text

\x1B[33mSYSTEM\x1B[0m
  \x1B[32mps\x1B[0m [-aux]           Process status
  \x1B[32mdf\x1B[0m [-h]             Disk free space
  \x1B[32mfree\x1B[0m [-h]           Memory usage
  \x1B[32mtop\x1B[0m                 Process monitor
  \x1B[32muname\x1B[0m [-a]          System info
  \x1B[32muptime\x1B[0m              System uptime
  \x1B[32mdate\x1B[0m                Current date/time
  \x1B[32mwhoami\x1B[0m              Current user
  \x1B[32mhostname\x1B[0m            System hostname
  \x1B[32menv\x1B[0m                 Environment variables
  \x1B[32mexport\x1B[0m KEY=VAL       Set env variable
  \x1B[32mhistory\x1B[0m             Command history

\x1B[33mNETWORK\x1B[0m
  \x1B[32mping\x1B[0m [host]          Ping hostname
  \x1B[32mcurl\x1B[0m [url]           HTTP request
  \x1B[32mifconfig\x1B[0m            Network interfaces
  \x1B[32mssh\x1B[0m [user@host]     SSH (simulated)

\x1B[33mDEVELOPER\x1B[0m
  \x1B[32mgit\x1B[0m [command]        Git version control
  \x1B[32mflutter\x1B[0m [command]    Flutter SDK
  \x1B[32mdart\x1B[0m [command]       Dart runtime
  \x1B[32mnpm\x1B[0m [command]        Node package manager
  \x1B[32mpython3\x1B[0m [script]     Python interpreter

\x1B[33mFUN\x1B[0m
  \x1B[32mneofetch\x1B[0m             System info art
  \x1B[32mcowsay\x1B[0m [text]        Talking cow
  \x1B[32mfortune\x1B[0m              Random quote
  \x1B[32mcal\x1B[0m                  Calendar
  \x1B[32mbc\x1B[0m [expr]           Calculator

\x1B[90mTip: Use ↑/↓ for history, Tab for completion, Ctrl+L to clear\x1B[0m
'''));
  }

  void _ls(List<String> args) {
    bool showHidden = false;
    bool longFormat = false;
    bool colorized = true;
    String targetDir = fs.currentDirectory;

    for (final arg in args) {
      if (arg.startsWith('-')) {
        if (arg.contains('a')) showHidden = true;
        if (arg.contains('l')) longFormat = true;
        if (arg.contains('A')) showHidden = true;
      } else {
        final resolved = fs.resolvePath(arg);
        if (fs.directoryExists(resolved)) {
          targetDir = resolved;
        } else {
          onOutput(TerminalOutput.error('ls: cannot access \'$arg\': No such file or directory'));
          return;
        }
      }
    }

    final entries = fs.listDirectory(targetDir, showHidden: showHidden);
    if (entries == null) {
      onOutput(TerminalOutput.error('ls: cannot access directory'));
      return;
    }

    if (entries.isEmpty) return;

    if (longFormat) {
      final header = 'total ${entries.length * 4}';
      final lines = <String>[header];
      final now = DateTime.now();
      final df = DateFormat('MMM dd HH:mm');
      final dy = DateFormat('MMM dd  yyyy');

      for (final e in entries) {
        final type = e.isDirectory ? 'd' : '-';
        final perm = '$type${e.permissions}';
        final size = padLeft(formatFileSize(e.size), 6);
        final dateStr = now.difference(e.modified).inDays < 180
            ? df.format(e.modified)
            : dy.format(e.modified);
        String name;
        if (e.isDirectory) {
          name = '\x1B[34m${e.name}\x1B[0m';
        } else if (e.permissions.contains('x')) {
          name = '\x1B[32m${e.name}\x1B[0m';
        } else if (e.name.startsWith('.')) {
          name = '\x1B[90m${e.name}\x1B[0m';
        } else {
          name = e.name;
        }
        lines.add('$perm  1 user user $size $dateStr $name');
      }
      onOutput(TerminalOutput.output(lines.join('\n')));
    } else {
      // Grid layout
      final names = entries.map((e) {
        if (e.isDirectory) return '\x1B[34m${e.name}/\x1B[0m';
        if (e.permissions.contains('x')) return '\x1B[32m${e.name}\x1B[0m';
        if (e.isHidden) return '\x1B[90m${e.name}\x1B[0m';
        return e.name;
      }).toList();
      onOutput(TerminalOutput.output(names.join('  ')));
    }
  }

  void _cd(List<String> args) {
    final target = args.isEmpty ? '/home/user' : args[0];
    final resolved = fs.resolvePath(target);

    if (fs.directoryExists(resolved)) {
      fs.currentDirectory = resolved;
      fs.setEnv('PWD', resolved);
      onChangeDir(resolved);
    } else {
      onOutput(TerminalOutput.error('cd: $target: No such file or directory'));
    }
  }

  void _pwd() {
    onOutput(TerminalOutput.output(fs.currentDirectory));
  }

  void _cat(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.error('cat: missing file operand'));
      return;
    }
    for (final arg in args) {
      final path = fs.resolvePath(arg);
      final content = fs.readFile(path);
      if (content == null) {
        if (fs.directoryExists(path)) {
          onOutput(TerminalOutput.error('cat: $arg: Is a directory'));
        } else {
          onOutput(TerminalOutput.error('cat: $arg: No such file or directory'));
        }
      } else {
        onOutput(TerminalOutput.output(content));
      }
    }
  }

  void _echo(List<String> args) {
    final text = args.join(' ')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\t', '\t');
    // Expand env vars
    final expanded = text.replaceAllMapped(
      RegExp(r'\$(\w+)'),
      (m) => fs.getEnv(m.group(1)!) ,
    );
    onOutput(TerminalOutput.output(expanded));
  }

  void _mkdir(List<String> args) {
    bool parents = false;
    for (final arg in args) {
      if (arg == '-p') { parents = true; continue; }
      final path = fs.resolvePath(arg);
      if (!fs.createDirectory(path)) {
        onOutput(TerminalOutput.error('mkdir: cannot create directory \'$arg\': File exists'));
      }
    }
  }

  void _touch(List<String> args) {
    for (final arg in args) {
      final path = fs.resolvePath(arg);
      if (!fs.fileExists(path)) {
        fs.writeFile(path, '');
      }
    }
  }

  void _rm(List<String> args) {
    bool recursive = false;
    bool force = false;
    for (final arg in args) {
      if (arg.startsWith('-')) {
        if (arg.contains('r') || arg.contains('R')) recursive = true;
        if (arg.contains('f')) force = true;
        continue;
      }
      final path = fs.resolvePath(arg);
      if (fs.directoryExists(path)) {
        if (!recursive) {
          onOutput(TerminalOutput.error('rm: cannot remove \'$arg\': Is a directory'));
        } else {
          fs.removeDirectory(path);
        }
      } else if (fs.fileExists(path)) {
        fs.removeFile(path);
      } else if (!force) {
        onOutput(TerminalOutput.error('rm: cannot remove \'$arg\': No such file or directory'));
      }
    }
  }

  void _cp(List<String> args) {
    if (args.length < 2) {
      onOutput(TerminalOutput.error('cp: missing destination file operand'));
      return;
    }
    final src = fs.resolvePath(args[0]);
    final dst = fs.resolvePath(args[1]);
    final content = fs.readFile(src);
    if (content == null) {
      onOutput(TerminalOutput.error('cp: \'${args[0]}\': No such file or directory'));
    } else {
      fs.writeFile(dst, content);
    }
  }

  void _mv(List<String> args) {
    if (args.length < 2) {
      onOutput(TerminalOutput.error('mv: missing destination'));
      return;
    }
    final src = fs.resolvePath(args[0]);
    final dst = fs.resolvePath(args[1]);
    final content = fs.readFile(src);
    if (content == null) {
      onOutput(TerminalOutput.error('mv: \'${args[0]}\': No such file or directory'));
    } else {
      fs.writeFile(dst, content);
      fs.removeFile(src);
    }
  }

  void _env(List<String> args) {
    final env = fs.getAllEnv();
    final lines = env.entries.map((e) => '\x1B[32m${e.key}\x1B[0m=\x1B[33m${e.value}\x1B[0m').toList();
    lines.sort();
    onOutput(TerminalOutput.output(lines.join('\n')));
  }

  void _export(List<String> args) {
    for (final arg in args) {
      if (arg.contains('=')) {
        final idx = arg.indexOf('=');
        final key = arg.substring(0, idx);
        final value = arg.substring(idx + 1).replaceAll('"', '').replaceAll("'", '');
        fs.setEnv(key, value);
      } else {
        onOutput(TerminalOutput.error('export: \'$arg\': not a valid identifier'));
      }
    }
  }

  void _which(List<String> args) {
    const commands = {'ls', 'cd', 'pwd', 'cat', 'echo', 'grep', 'find', 'git', 'flutter', 'dart', 'npm', 'python3', 'curl', 'ping'};
    for (final arg in args) {
      if (commands.contains(arg)) {
        onOutput(TerminalOutput.output('/usr/bin/$arg'));
      } else {
        onOutput(TerminalOutput.error('which: $arg not found'));
      }
    }
  }

  void _date(List<String> args) {
    final now = DateTime.now();
    final fmt = args.isNotEmpty && args[0].startsWith('+')
        ? args[0].substring(1)
        : null;
    if (fmt != null) {
      final result = fmt
          .replaceAll('%Y', now.year.toString())
          .replaceAll('%m', now.month.toString().padLeft(2, '0'))
          .replaceAll('%d', now.day.toString().padLeft(2, '0'))
          .replaceAll('%H', now.hour.toString().padLeft(2, '0'))
          .replaceAll('%M', now.minute.toString().padLeft(2, '0'))
          .replaceAll('%S', now.second.toString().padLeft(2, '0'))
          .replaceAll('%A', DateFormat('EEEE').format(now))
          .replaceAll('%B', DateFormat('MMMM').format(now));
      onOutput(TerminalOutput.output(result));
    } else {
      onOutput(TerminalOutput.output(DateFormat('EEE MMM d HH:mm:ss zzz yyyy').format(now)));
    }
  }

  void _whoami() => onOutput(TerminalOutput.output(fs.getEnv('USER')));
  void _hostname() => onOutput(TerminalOutput.output(fs.getEnv('HOSTNAME')));

  void _uname(List<String> args) {
    final all = args.contains('-a');
    if (all) {
      onOutput(TerminalOutput.output('FlutterOS flutter-terminal 6.1.0-flutter #1 SMP PREEMPT_DYNAMIC Flutter dart-arm64 GNU/Linux'));
    } else {
      onOutput(TerminalOutput.output('FlutterOS'));
    }
  }

  void _uptime() {
    final now = DateTime.now();
    onOutput(TerminalOutput.output(
      ' ${DateFormat('HH:mm:ss').format(now)} up 3 days,  4:22,  1 user,  load average: 0.42, 0.38, 0.31',
    ));
  }

  void _ps(List<String> args) {
    final wide = args.any((a) => a.contains('a') || a.contains('u') || a.contains('x'));
    if (wide) {
      onOutput(TerminalOutput.output('''USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
user         1  0.0  0.1   2316   840 ?        Ss   09:00   0:00 /sbin/init
user       156  0.0  0.2  15432  2048 ?        Ss   09:00   0:00 /usr/sbin/sshd
user       823  0.2  1.8 124532 18432 ?        Sl   09:15   0:12 flutter_terminal
user       824  0.1  0.5  12432  4096 pts/0    Ss   09:15   0:01 /bin/bash
user      1024  0.0  0.1   9432   960 pts/0    R+   09:45   0:00 ps aux'''));
    } else {
      onOutput(TerminalOutput.output('''  PID TTY          TIME CMD
  824 pts/0    00:00:01 bash
 1024 pts/0    00:00:00 ps'''));
    }
  }

  void _df(List<String> args) {
    final human = args.contains('-h');
    if (human) {
      onOutput(TerminalOutput.output('''Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   18G   30G  37% /
tmpfs           3.8G  1.2M  3.8G   1% /dev/shm
/dev/sda2       200G   82G  108G  44% /home
tmpfs           3.8G  4.0K  3.8G   1% /tmp'''));
    } else {
      onOutput(TerminalOutput.output('''Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/sda1       52428800 18874368  31457280  38% /
tmpfs            3932160     1200   3930960   1% /dev/shm'''));
    }
  }

  void _du(List<String> args) {
    bool human = false;
    bool summary = false;
    String target = fs.currentDirectory;
    for (final a in args) {
      if (a == '-h') human = true;
      else if (a == '-s') summary = true;
      else if (a == '-sh') { human = true; summary = true; }
      else target = fs.resolvePath(a);
    }
    final size = human ? '4.0K' : '4';
    if (summary) {
      onOutput(TerminalOutput.output('$size\t$target'));
    } else {
      final entries = fs.listDirectory(target, showHidden: true) ?? [];
      final lines = entries
          .where((e) => !e.isDirectory)
          .map((e) => '${human ? formatFileSize(e.size) : e.size}\t$target/${e.name}')
          .toList();
      lines.add('$size\t$target');
      onOutput(TerminalOutput.output(lines.join('\n')));
    }
  }

  void _free(List<String> args) {
    final human = args.contains('-h');
    if (human) {
      onOutput(TerminalOutput.output('''              total        used        free      shared  buff/cache   available
Mem:           7.5G        2.1G        3.8G        128M        1.6G        5.0G
Swap:          2.0G          0B        2.0G'''));
    } else {
      onOutput(TerminalOutput.output('''              total        used        free      shared  buff/cache   available
Mem:        7864320     2097152     3932160      131072     1835008     5242880
Swap:       2097152           0     2097152'''));
    }
  }

  void _top() {
    onOutput(TerminalOutput.output('''top - ${DateFormat('HH:mm:ss').format(DateTime.now())} up 3 days,  4:22,  1 user,  load average: 0.42, 0.38, 0.31
Tasks:  95 total,   1 running,  94 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.3 us,  1.1 sy,  0.0 ni, 96.2 id,  0.3 wa,  0.0 hi,  0.1 si
MiB Mem :   7680.0 total,   3840.0 free,   2048.0 used,   1792.0 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   5120.0 avail Mem

\x1B[7m    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND\x1B[0m
    823 user      20   0  124532  18432   8192 S   0.3   0.2   0:12.34 flutter_terminal
    824 user      20   0   12432   4096   3072 S   0.1   0.1   0:01.22 bash
      1 root      20   0    2316    840    756 S   0.0   0.0   0:00.18 init
    156 user      20   0   15432   2048   1792 S   0.0   0.0   0:00.44 sshd

\x1B[90m(Simulated snapshot — not live)\x1B[0m'''));
  }

  void _grep(List<String> args) {
    if (args.length < 2) {
      onOutput(TerminalOutput.error('grep: usage: grep PATTERN FILE'));
      return;
    }
    bool ignoreCase = false;
    bool lineNum = false;
    String? pattern;
    String? filePath;

    for (final a in args) {
      if (a == '-i') { ignoreCase = true; continue; }
      if (a == '-n') { lineNum = true; continue; }
      if (pattern == null) { pattern = a; continue; }
      filePath = a;
    }
    if (pattern == null || filePath == null) {
      onOutput(TerminalOutput.error('grep: usage: grep PATTERN FILE'));
      return;
    }

    final path = fs.resolvePath(filePath);
    final content = fs.readFile(path);
    if (content == null) {
      onOutput(TerminalOutput.error('grep: $filePath: No such file or directory'));
      return;
    }

    final lines = content.split('\n');
    final results = <String>[];
    final re = RegExp(pattern, caseSensitive: !ignoreCase);

    for (var i = 0; i < lines.length; i++) {
      if (re.hasMatch(lines[i])) {
        final highlighted = lines[i].replaceAllMapped(
          re, (m) => '\x1B[31m${m.group(0)}\x1B[0m',
        );
        results.add(lineNum ? '\x1B[36m${i+1}\x1B[0m:$highlighted' : highlighted);
      }
    }
    if (results.isEmpty) {
      // No output on no match (standard grep behavior)
    } else {
      onOutput(TerminalOutput.output(results.join('\n')));
    }
  }

  void _find(List<String> args) {
    String dir = fs.currentDirectory;
    String? namePattern;
    String? type;

    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-name' && i + 1 < args.length) {
        namePattern = args[++i].replaceAll('*', '').replaceAll('?', '');
      } else if (args[i] == '-type' && i + 1 < args.length) {
        type = args[++i];
      } else if (!args[i].startsWith('-')) {
        dir = fs.resolvePath(args[i]);
      }
    }

    final results = <String>[];
    void search(String path) {
      final entries = fs.listDirectory(path, showHidden: true) ?? [];
      for (final e in entries) {
        final fullPath = '$path/${e.name}';
        final typeMatch = type == null || (type == 'd' && e.isDirectory) || (type == 'f' && !e.isDirectory);
        final nameMatch = namePattern == null || e.name.contains(namePattern!);
        if (typeMatch && nameMatch) results.add(fullPath);
        if (e.isDirectory) search(fullPath);
      }
    }

    search(dir);
    if (results.isEmpty) {
      onOutput(TerminalOutput.output('(no results)'));
    } else {
      onOutput(TerminalOutput.output(results.join('\n')));
    }
  }

  void _wc(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.error('wc: missing file operand'));
      return;
    }
    bool lines = false, words = false, chars = false;
    String? filePath;
    for (final a in args) {
      if (a == '-l') { lines = true; continue; }
      if (a == '-w') { words = true; continue; }
      if (a == '-c') { chars = true; continue; }
      filePath = a;
    }
    if (!lines && !words && !chars) { lines = true; words = true; chars = true; }
    if (filePath == null) { onOutput(TerminalOutput.error('wc: missing file')); return; }

    final content = fs.readFile(fs.resolvePath(filePath));
    if (content == null) {
      onOutput(TerminalOutput.error('wc: $filePath: No such file or directory'));
      return;
    }
    final lineCount = content.split('\n').length;
    final wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final charCount = content.length;
    final parts = <String>[];
    if (lines) parts.add(padLeft('$lineCount', 8));
    if (words) parts.add(padLeft('$wordCount', 8));
    if (chars) parts.add(padLeft('$charCount', 8));
    onOutput(TerminalOutput.output('${parts.join('')} $filePath'));
  }

  void _head(List<String> args) {
    int n = 10;
    String? filePath;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-n' && i + 1 < args.length) {
        n = int.tryParse(args[++i]) ?? 10;
      } else if (args[i].startsWith('-') && int.tryParse(args[i].substring(1)) != null) {
        n = int.parse(args[i].substring(1));
      } else {
        filePath = args[i];
      }
    }
    if (filePath == null) { onOutput(TerminalOutput.error('head: missing file')); return; }
    final content = fs.readFile(fs.resolvePath(filePath));
    if (content == null) { onOutput(TerminalOutput.error('head: $filePath: No such file')); return; }
    onOutput(TerminalOutput.output(content.split('\n').take(n).join('\n')));
  }

  void _tail(List<String> args) {
    int n = 10;
    String? filePath;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '-n' && i + 1 < args.length) {
        n = int.tryParse(args[++i]) ?? 10;
      } else if (!args[i].startsWith('-')) {
        filePath = args[i];
      }
    }
    if (filePath == null) { onOutput(TerminalOutput.error('tail: missing file')); return; }
    final content = fs.readFile(fs.resolvePath(filePath));
    if (content == null) { onOutput(TerminalOutput.error('tail: $filePath: No such file')); return; }
    final all = content.split('\n');
    onOutput(TerminalOutput.output(all.skip(max(0, all.length - n)).join('\n')));
  }

  void _sort(List<String> args) {
    bool reverse = false;
    String? filePath;
    for (final a in args) {
      if (a == '-r') { reverse = true; continue; }
      filePath = a;
    }
    if (filePath == null) return;
    final content = fs.readFile(fs.resolvePath(filePath));
    if (content == null) { onOutput(TerminalOutput.error('sort: $filePath: No such file')); return; }
    final lines = content.split('\n')..sort();
    if (reverse) lines.reversed;
    onOutput(TerminalOutput.output(lines.join('\n')));
  }

  void _uniq(List<String> args) {
    final filePath = args.firstWhere((a) => !a.startsWith('-'), orElse: () => '');
    if (filePath.isEmpty) return;
    final content = fs.readFile(fs.resolvePath(filePath));
    if (content == null) return;
    final lines = content.split('\n');
    final result = <String>[];
    for (final l in lines) {
      if (result.isEmpty || result.last != l) result.add(l);
    }
    onOutput(TerminalOutput.output(result.join('\n')));
  }

  void _history(List<String> args) {
    // History is managed by the provider; we just show a message
    onOutput(TerminalOutput.info('History is displayed in the sidebar. Use ↑/↓ arrows to navigate.'));
  }

  void _aliasList(List<String> args) {
    if (args.isEmpty) {
      final out = _aliases.entries.map((e) => "alias \x1B[32m${e.key}\x1B[0m='\x1B[33m${e.value}\x1B[0m'").join('\n');
      onOutput(TerminalOutput.output(out));
    }
  }

  void _editor(String cmd, List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.info('$cmd: no file specified. Usage: $cmd <filename>'));
      return;
    }
    onOutput(TerminalOutput.info(
      '✏️  Editor mode is not supported in this emulator.\n'
      'Use: write <filename> <content>  to write text to a file.',
    ));
  }

  void _man(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.error('man: what manual page do you want?'));
      return;
    }
    const pages = {
      'ls': 'ls — list directory contents\n\nSYNOPSIS\n  ls [OPTION]... [FILE]...\n\nOPTIONS\n  -a    do not ignore entries starting with .\n  -l    use a long listing format\n  -h    human-readable sizes',
      'cat': 'cat — concatenate files and print on the standard output\n\nSYNOPSIS\n  cat [FILE]...',
      'grep': 'grep — print lines that match patterns\n\nSYNOPSIS\n  grep [OPTIONS] PATTERN [FILE]\n\nOPTIONS\n  -i    ignore case\n  -n    print line numbers',
      'cd': 'cd — change the working directory\n\nSYNOPSIS\n  cd [DIR]',
    };
    final page = pages[args[0]];
    if (page == null) {
      onOutput(TerminalOutput.error('No manual entry for ${args[0]}'));
    } else {
      onOutput(TerminalOutput.output('\x1B[1m${args[0].toUpperCase()}(1)\x1B[0m\n\n$page'));
    }
  }

  void _curl(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.error('curl: try \'curl --help\' for more information'));
      return;
    }
    final url = args.lastWhere((a) => !a.startsWith('-'), orElse: () => '');
    if (url.isEmpty) { onOutput(TerminalOutput.error('curl: no URL specified')); return; }
    onOutput(TerminalOutput.info('  % Total    % Received % Xferd  Average Speed   Time\n'
        '  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0'));
    onOutput(TerminalOutput.output('{\n  "status": "ok",\n  "url": "$url",\n  "simulated": true\n}'));
  }

  void _ping(List<String> args) {
    final host = args.firstWhere((a) => !a.startsWith('-'), orElse: () => '');
    if (host.isEmpty) { onOutput(TerminalOutput.error('ping: usage error')); return; }
    final rng = Random();
    onOutput(TerminalOutput.output('''PING $host: 56 data bytes
64 bytes from $host: icmp_seq=0 ttl=52 time=${(rng.nextDouble() * 10 + 8).toStringAsFixed(3)} ms
64 bytes from $host: icmp_seq=1 ttl=52 time=${(rng.nextDouble() * 10 + 8).toStringAsFixed(3)} ms
64 bytes from $host: icmp_seq=2 ttl=52 time=${(rng.nextDouble() * 10 + 8).toStringAsFixed(3)} ms
64 bytes from $host: icmp_seq=3 ttl=52 time=${(rng.nextDouble() * 10 + 8).toStringAsFixed(3)} ms

--- $host ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
round-trip min/avg/max/stddev = 8.123/9.245/11.432/1.023 ms'''));
  }

  void _network(String cmd, List<String> args) {
    onOutput(TerminalOutput.output('''eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.105  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::1  prefixlen 64  scopeid 0x20<link>
        ether aa:bb:cc:dd:ee:ff  txqueuelen 1000  (Ethernet)
        RX packets 12430  bytes 9485123 (9.0 MiB)
        TX packets 8932  bytes 2305481 (2.2 MiB)

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)'''));
  }

  void _ssh(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.error('ssh: missing hostname')); return; }
    onOutput(TerminalOutput.info('ssh: Connection to ${args.last} simulated (not a real SSH session)'));
  }

  void _git(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('''usage: git [-v | --version] [-h | --help] <command> [<args>]

These are common Git commands:
   clone      Clone a repository
   init       Create an empty Git repository
   add        Add file contents to the index
   commit     Record changes to the repository
   status     Show the working tree status
   push       Update remote refs
   pull       Fetch from and integrate with remote
   log        Show commit logs
   diff       Show changes between commits
   branch     List, create, or delete branches'''));
      return;
    }
    switch (args[0]) {
      case 'status':
        onOutput(TerminalOutput.output('''On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
\x1B[31m\tmodified:   lib/main.dart\x1B[0m

Untracked files:
\x1B[31m\tlib/new_feature.dart\x1B[0m

no changes added to commit'''));
        break;
      case 'log':
        onOutput(TerminalOutput.output('''\x1B[33mcommit a1b2c3d4e5f6789012345678901234567890abcd\x1B[0m
Author: user <user@example.com>
Date:   ${DateFormat('EEE MMM d HH:mm:ss yyyy').format(DateTime.now())} +0000

    feat: add advanced terminal features

\x1B[33mcommit b2c3d4e5f6789012345678901234567890abcde\x1B[0m
Author: user <user@example.com>
Date:   Mon Mar 18 10:22:31 2024 +0000

    chore: initial commit'''));
        break;
      case 'branch':
        onOutput(TerminalOutput.output('* \x1B[32mmain\x1B[0m\n  develop\n  feature/ui-improvements'));
        break;
      case 'init':
        onOutput(TerminalOutput.output('Initialized empty Git repository in ${fs.currentDirectory}/.git/'));
        break;
      case 'add':
        onOutput(TerminalOutput.output('')); // silent like real git add
        break;
      case 'commit':
        final msg = args.contains('-m') ? args[args.indexOf('-m') + 1] : 'Update';
        onOutput(TerminalOutput.output('[main a1b2c3d] $msg\n 1 file changed, 1 insertion(+)'));
        break;
      default:
        onOutput(TerminalOutput.error('git: \'${args[0]}\' is not a git command. See \'git --help\'.'));
    }
  }

  void _npm(List<String> args) {
    if (args.isEmpty) { onOutput(TerminalOutput.info('npm <command>\nTry: npm install, npm run dev')); return; }
    switch (args[0]) {
      case 'install': case 'i':
        onOutput(TerminalOutput.output('added 342 packages in 4.2s\n\n24 packages are looking for funding\n  run `npm fund` for details'));
        break;
      case 'run':
        onOutput(TerminalOutput.output('> project@1.0.0 ${args.elementAtOrNull(1) ?? "start"}\n> node index.js\n\nServer running on http://localhost:3000'));
        break;
      default:
        onOutput(TerminalOutput.error('npm: unknown command \'${args[0]}\''));
    }
  }

  void _python(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('Python 3.11.4 (main, Jul  5 2023, 00:00:00)\nType "help", "copyright", "credits" or "license" for more information.\n\x1B[90m[Interpreter mode not supported]\x1B[0m'));
    } else {
      onOutput(TerminalOutput.info('python3: Script execution is simulated. File: ${args[0]}'));
    }
  }

  void _flutterCmd(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('''Flutter 3.19.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision abc123 • 2024-01-01
Engine • revision def456
Tools • Dart 3.3.0 • DevTools 2.28.2

Usage: flutter <command> [arguments]

Global options:
  -h, --help       Print this usage information.
  -v, --verbose    Noisy logging.

Available commands:
  run              Run your Flutter app on an attached device.
  build            Build your project.
  pub              Commands for managing Flutter packages.
  test             Run Flutter unit tests.
  clean            Delete the build/ directory.
  doctor           Show information about the installed tooling.
  create           Create a new Flutter project.'''));
      return;
    }
    switch (args[0]) {
      case 'doctor':
        onOutput(TerminalOutput.output('''Doctor summary (to see all details, run flutter doctor -v):
[\x1B[32m✓\x1B[0m] Flutter (Channel stable, 3.19.0)
[\x1B[32m✓\x1B[0m] Android toolchain - develop for Android devices
[\x1B[32m✓\x1B[0m] Xcode - develop for iOS and macOS
[\x1B[32m✓\x1B[0m] Chrome - develop for the web
[\x1B[32m✓\x1B[0m] VS Code (version 1.87.0)
[\x1B[32m✓\x1B[0m] Connected device (3 available)
[\x1B[32m✓\x1B[0m] Network resources

• No issues found!'''));
        break;
      case 'pub':
        if (args.elementAtOrNull(1) == 'get') {
          onOutput(TerminalOutput.output('Resolving dependencies...\n  + flutter_riverpod 2.5.1\n  + google_fonts 6.2.1\nGot dependencies!'));
        } else {
          onOutput(TerminalOutput.output('flutter pub: manage dependencies'));
        }
        break;
      case 'build':
        onOutput(TerminalOutput.output('Building ${args.elementAtOrNull(1) ?? "app"}...\n✓ Built in 12.4s'));
        break;
      case 'clean':
        onOutput(TerminalOutput.output('Deleting build/...\nDeleted build/.\nDeleting .dart_tool/...\nDeleted .dart_tool/.'));
        break;
      case 'run':
        onOutput(TerminalOutput.output('Launching... lib/main.dart on Chrome\nFlutter run key commands.\n  r Hot reload.\n  R Hot restart.\n  q Quit.'));
        break;
      default:
        onOutput(TerminalOutput.error('flutter: \'${args[0]}\' is not a flutter command.'));
    }
  }

  void _dart(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.output('Dart SDK version: 3.3.0 (stable)\nUsage: dart <command|dart-file> [arguments]'));
      return;
    }
    switch (args[0]) {
      case 'analyze':
        onOutput(TerminalOutput.output('Analyzing project...\nNo issues found!'));
        break;
      case 'format':
        onOutput(TerminalOutput.output('Formatted ${args.elementAtOrNull(1) ?? "."}.'));
        break;
      case 'test':
        onOutput(TerminalOutput.output('00:01 +12: All tests passed!'));
        break;
      case 'compile':
        onOutput(TerminalOutput.output('Compiled to native binary.'));
        break;
      default:
        onOutput(TerminalOutput.output('dart: ${args[0]}'));
    }
  }

  void _yes(List<String> args) {
    final text = args.isEmpty ? 'y' : args.join(' ');
    onOutput(TerminalOutput.output(List.filled(20, text).join('\n') + '\n\x1B[90m(truncated)\x1B[0m'));
  }

  void _seq(List<String> args) {
    if (args.isEmpty) return;
    int start = 1, end = 1, step = 1;
    if (args.length == 1) { end = int.tryParse(args[0]) ?? 1; }
    else if (args.length == 2) { start = int.tryParse(args[0]) ?? 1; end = int.tryParse(args[1]) ?? 1; }
    else { start = int.tryParse(args[0]) ?? 1; step = int.tryParse(args[1]) ?? 1; end = int.tryParse(args[2]) ?? 1; }
    final nums = <int>[];
    for (var i = start; i <= end; i += step) nums.add(i);
    onOutput(TerminalOutput.output(nums.join('\n')));
  }

  Future<void> _sleep(List<String> args) async {
    final secs = int.tryParse(args.firstOrNull ?? '') ?? 1;
    onOutput(TerminalOutput.info('Sleeping for ${secs}s...'));
    await Future.delayed(Duration(seconds: secs.clamp(0, 5)));
  }

  void _neofetch() {
    onOutput(TerminalOutput.output('''
\x1B[34m    ████████████████    \x1B[0m   \x1B[1muser\x1B[0m@\x1B[1mflutter-terminal\x1B[0m
\x1B[34m  ██              ██  \x1B[0m   \x1B[90m──────────────────────────\x1B[0m
\x1B[34m ██  \x1B[36m████  ████\x1B[34m  ██ \x1B[0m   \x1B[33mOS:\x1B[0m       FlutterOS 1.0 x86_64
\x1B[34m ██  \x1B[36m████  ████\x1B[34m  ██ \x1B[0m   \x1B[33mHost:\x1B[0m     Flutter Terminal v1.0.0
\x1B[34m ██              ██  \x1B[0m   \x1B[33mKernel:\x1B[0m   Dart 3.3.0
\x1B[34m ██  \x1B[36m██████████\x1B[34m  ██ \x1B[0m   \x1B[33mUptime:\x1B[0m   3 days, 4 hours
\x1B[34m  ██              ██  \x1B[0m   \x1B[33mShell:\x1B[0m    flutter_bash 1.0
\x1B[34m    ████████████████    \x1B[0m   \x1B[33mResolution:\x1B[0m Dynamic
                         \x1B[33mDE:\x1B[0m       Material 3
                         \x1B[33mWM:\x1B[0m       Flutter
                         \x1B[33mTerminal:\x1B[0m Flutter Terminal
                         \x1B[33mCPU:\x1B[0m      Dart VM (8 isolates)
                         \x1B[33mMemory:\x1B[0m   2.1G / 7.5G
                         \x1B[33mPackages:\x1B[0m 12 (pub)

                         \x1B[30m███\x1B[31m███\x1B[32m███\x1B[33m███\x1B[34m███\x1B[35m███\x1B[36m███\x1B[37m███\x1B[0m
'''));
  }

  void _banner(List<String> args) {
    final text = args.join(' ');
    onOutput(TerminalOutput.output('\x1B[36m${'═' * 50}\n  $text\n${'═' * 50}\x1B[0m'));
  }

  void _cowsay(List<String> args) {
    final msg = args.isEmpty ? 'Moo!' : args.join(' ');
    final border = '-' * (msg.length + 2);
    onOutput(TerminalOutput.output(''' $border
< $msg >
 $border
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||'''));
  }

  void _fortune() {
    const fortunes = [
      'The best way to predict the future is to implement it.',
      'Talk is cheap. Show me the code. — Linus Torvalds',
      'Simplicity is the soul of efficiency. — Austin Freeman',
      'First, solve the problem. Then, write the code. — John Johnson',
      'Code is like humor. When you have to explain it, it\'s bad.',
      'Programs must be written for people to read. — Harold Abelson',
      'Dart is not a language, it\'s a lifestyle.',
      'In Flutter we trust.',
      'Any fool can write code that a computer can understand. Good programmers write code that humans can understand.',
      'The function of good software is to make the complex appear to be simple.',
    ];
    final rng = Random();
    onOutput(TerminalOutput.output(
      '\x1B[33m"${fortunes[rng.nextInt(fortunes.length)]}"\x1B[0m',
    ));
  }

  void _cal(List<String> args) {
    final now = DateTime.now();
    final month = args.isNotEmpty ? (int.tryParse(args[0]) ?? now.month) : now.month;
    final year = args.length > 1 ? (int.tryParse(args[1]) ?? now.year) : now.year;
    final monthName = DateFormat('MMMM').format(DateTime(year, month));
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final sb = StringBuffer();
    sb.writeln('\x1B[1m${monthName.padLeft(15)} $year\x1B[0m');
    sb.writeln('Su Mo Tu We Th Fr Sa');

    var dayOfWeek = firstDay.weekday % 7;
    sb.write('   ' * dayOfWeek);

    for (var d = 1; d <= daysInMonth; d++) {
      final isToday = d == now.day && month == now.month && year == now.year;
      final dayStr = d.toString().padLeft(2);
      if (isToday) {
        sb.write('\x1B[7m$dayStr\x1B[0m ');
      } else {
        sb.write('$dayStr ');
      }
      dayOfWeek++;
      if (dayOfWeek == 7) {
        sb.writeln();
        dayOfWeek = 0;
      }
    }
    onOutput(TerminalOutput.output(sb.toString()));
  }

  void _bc(List<String> args) {
    if (args.isEmpty) {
      onOutput(TerminalOutput.info('bc: basic calculator\nUsage: bc <expression>\nExample: bc 2 + 2'));
      return;
    }
    try {
      final expr = args.join(' ');
      final result = _evalSimple(expr);
      onOutput(TerminalOutput.output(result.toString()));
    } catch (_) {
      onOutput(TerminalOutput.error('bc: syntax error'));
    }
  }

  num _evalSimple(String expr) {
    expr = expr.trim();
    // Very simple: handle +, -, *, /
    final parts = expr.split(RegExp(r'\s*([+\-*/])\s*'));
    if (parts.length == 1) return num.parse(parts[0]);
    final ops = RegExp(r'[+\-*/]').allMatches(expr).map((m) => m.group(0)!).toList();
    final nums = expr.split(RegExp(r'[+\-*/]')).map((s) => num.parse(s.trim())).toList();
    num result = nums[0];
    for (var i = 0; i < ops.length; i++) {
      switch (ops[i]) {
        case '+': result += nums[i + 1]; break;
        case '-': result -= nums[i + 1]; break;
        case '*': result *= nums[i + 1]; break;
        case '/': result /= nums[i + 1]; break;
      }
    }
    return result;
  }

  Future<void> _handlePipe(String input) async {
    final commands = input.split(' | ');
    final outputs = <String>[];
    for (final cmd in commands) {
      // Simplified pipe: just collect output strings
      final parts = _parseArgs(cmd.trim());
      if (parts.isEmpty) continue;
      // For now, output message
    }
    onOutput(TerminalOutput.info('Pipe: ${commands.length} commands chained (simulated)'));
  }

  List<String> _parseArgs(String input) {
    final args = <String>[];
    var current = StringBuffer();
    var inSingle = false;
    var inDouble = false;

    for (var i = 0; i < input.length; i++) {
      final c = input[i];
      if (c == "'" && !inDouble) {
        inSingle = !inSingle;
      } else if (c == '"' && !inSingle) {
        inDouble = !inDouble;
      } else if (c == ' ' && !inSingle && !inDouble) {
        if (current.isNotEmpty) {
          args.add(current.toString());
          current = StringBuffer();
        }
      } else {
        current.write(c);
      }
    }
    if (current.isNotEmpty) args.add(current.toString());
    return args;
  }
}

extension ListExt<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? elementAtOrNull(int index) => index < length ? this[index] : null;
}
