// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// process_run: ^0.12.5+2
// file_picker: ^6.1.1
// animated_text_kit: ^4.2.2
// window_manager: ^0.3.7
// bitsdojo_window: ^0.1.6
// desktop_drop: ^1.4.0
// path_provider: ^2.1.1

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/process_run.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path_provider/path_provider.dart';

// Providers
final selectedDirectoryProvider = StateProvider<String?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final commandOutputProvider = StateProvider<String>((ref) => '');
final themeProvider = StateProvider<bool>((ref) => true);
final windowProvider = StateProvider<bool>((ref) => false);

// Models
class SystemCommand {
  final String name;
  final String description;
  final String command;
  final IconData icon;
  final Color color;
  final bool requiresPath;
  final bool requiresSudo;
  final String? alternativeCommand;

  SystemCommand({
    required this.name,
    required this.description,
    required this.command,
    required this.icon,
    required this.color,
    this.requiresPath = false,
    this.requiresSudo = false,
    this.alternativeCommand,
  });
}

// Command Service
class CommandService {
  static final List<SystemCommand> commands = [
    SystemCommand(
      name: 'Large Files',
      description: 'Find files larger than 100MB',
      command:
          'find "{path}" -type f -size +100M -exec ls -lh {} \\; 2>/dev/null | sort -k 5 -rh',
      icon: Icons.file_present,
      color: Colors.orange,
      requiresPath: true,
    ),
    SystemCommand(
      name: 'Directory Sizes',
      description: 'Show largest directories',
      command: 'du -sh "{path}"/* 2>/dev/null | sort -hr | head -n 20',
      icon: Icons.folder_open,
      color: Colors.blue,
      requiresPath: true,
    ),
    SystemCommand(
      name: 'User Cache',
      description: 'Show user cache directories',
      command: 'du -sh ~/Library/Caches/* 2>/dev/null | sort -hr | head -n 10',
      icon: Icons.cleaning_services,
      color: Colors.red,
      alternativeCommand:
          'find ~/Library/Caches -type d -maxdepth 1 2>/dev/null',
    ),
    SystemCommand(
      name: 'Port Check',
      description: 'Check active network ports',
      command: 'lsof -i -P -n 2>/dev/null | grep LISTEN',
      icon: Icons.network_check,
      color: Colors.green,
      alternativeCommand: 'netstat -an | grep LISTEN',
    ),
    SystemCommand(
      name: 'Memory Usage',
      description: 'Show memory consumption',
      command: 'ps aux 2>/dev/null | sort -k 4 -rn | head -n 20',
      icon: Icons.memory,
      color: Colors.purple,
    ),
    SystemCommand(
      name: 'Disk Usage',
      description: 'Check disk space usage',
      command: 'df -h',
      icon: Icons.storage,
      color: Colors.teal,
    ),
    SystemCommand(
      name: 'Docker Containers',
      description: 'List running Docker containers',
      command:
          'docker ps -a --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}" 2>/dev/null',
      icon: Icons.developer_board,
      color: Colors.cyan,
      alternativeCommand: 'echo "Docker not installed or not running"',
    ),
    SystemCommand(
      name: 'Temp Files',
      description: 'Show temporary files',
      command: 'find /tmp -type f -size +10M 2>/dev/null | head -n 20',
      icon: Icons.delete_sweep,
      color: Colors.pink,
    ),
  ];

  static Future<String> executeCommand(String command) async {
    try {
      // Create a safe shell environment
      final shell = Shell(
        environment: {'PATH': '/usr/local/bin:/usr/bin:/bin'},
        workingDirectory: Platform.environment['HOME'] ?? '/tmp',
      );

      final result = await shell.run(command);
      final output = result.map((e) => e.stdout.toString()).join('\n');

      // If output is empty, try to get stderr for more info
      if (output.trim().isEmpty) {
        final errorOutput = result.map((e) => e.stderr.toString()).join('\n');
        if (errorOutput.trim().isNotEmpty) {
          return 'Command completed with warnings:\n$errorOutput';
        }
        return 'Command completed successfully (no output)';
      }

      return output;
    } catch (e) {
      // Try alternative approach for permission-sensitive commands
      return 'Error: ${e.toString()}\n\nTip: Some commands may require running the app with elevated permissions or may not be available in sandboxed environments.';
    }
  }

  static Future<String> executeCommandWithFallback(
    SystemCommand cmd,
    String? path,
  ) async {
    String commandToExecute = cmd.command;

    if (cmd.requiresPath && path != null) {
      commandToExecute = commandToExecute.replaceAll('{path}', path);
    }

    try {
      return await executeCommand(commandToExecute);
    } catch (e) {
      // Try alternative command if available
      if (cmd.alternativeCommand != null) {
        try {
          String altCommand = cmd.alternativeCommand!;
          if (cmd.requiresPath && path != null) {
            altCommand = altCommand.replaceAll('{path}', path);
          }
          final result = await executeCommand(altCommand);
          return 'Used alternative method:\n$result';
        } catch (altError) {
          return 'Primary command failed: $e\nAlternative command also failed: $altError';
        }
      }
      return 'Command failed: $e';
    }
  }

  static Future<List<int>> getProcessesOnPort(int port) async {
    try {
      final result = await executeCommand('lsof -ti:$port 2>/dev/null');
      if (result.trim().isNotEmpty) {
        return result
            .trim()
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => int.tryParse(line.trim()))
            .where((pid) => pid != null)
            .cast<int>()
            .toList();
      }
    } catch (e) {
      // Fallback to netstat approach
      try {
        final netstatResult = await executeCommand(
          'netstat -an | grep ":$port "',
        );
        if (netstatResult.contains('LISTEN')) {
          return []; // Port is in use but can't get PID without elevated permissions
        }
      } catch (e2) {
        // Ignore
      }
    }
    return [];
  }

  static Future<bool> killProcess(int pid) async {
    try {
      await executeCommand('kill $pid');
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if process still exists
      try {
        await executeCommand('kill -0 $pid');
        // If no error, process still exists, try force kill
        await executeCommand('kill -9 $pid');
      } catch (e) {
        // Process doesn't exist anymore, success
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'System Cleaner Pro',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: SystemCleanerApp()));
}

class SystemCleanerApp extends ConsumerWidget {
  const SystemCleanerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'System Cleaner Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.black26,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      const Color(0xFF1a1a2e),
                      const Color(0xFF16213e),
                      const Color(0xFF0f3460),
                    ]
                    : [
                      Colors.blue.shade50,
                      Colors.purple.shade50,
                      Colors.pink.shade50,
                    ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomTitleBar(context, ref),
              _buildHeader(context, ref),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildPathSelector(context, ref),
                            const SizedBox(height: 24),
                            _buildCommandGrid(context, ref),
                            const SizedBox(height: 24),
                            _buildPortKiller(context, ref),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: _buildOutputSection(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTitleBar(BuildContext context, WidgetRef ref) {
    return Container(
      height: 32,
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Row(
            children: [
              _buildTitleBarButton(
                Icons.minimize,
                () => windowManager.minimize(),
                Colors.grey,
              ),
              _buildTitleBarButton(Icons.crop_square, () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              }, Colors.grey),
              _buildTitleBarButton(
                Icons.close,
                () => windowManager.close(),
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBarButton(
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return SizedBox(
      width: 46,
      height: 32,
      child: InkWell(
        onTap: onPressed,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple.shade300],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.cleaning_services,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'System Cleaner Pro',
                      textStyle: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
                Text(
                  'Advanced desktop file system management',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showAboutDialog(context),
                icon: const Icon(Icons.info_outline),
                tooltip: 'About',
              ),
              IconButton(
                onPressed:
                    () => ref.read(themeProvider.notifier).state = !isDarkMode,
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: isDarkMode ? Colors.yellow : Colors.grey.shade700,
                ),
                tooltip: 'Toggle theme',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPathSelector(BuildContext context, WidgetRef ref) {
    final selectedPath = ref.watch(selectedDirectoryProvider);

    return DropTarget(
      onDragDone: (detail) {
        if (detail.files.isNotEmpty) {
          final file = detail.files.first;
          final directory = Directory(file.path);
          if (directory.existsSync()) {
            ref.read(selectedDirectoryProvider.notifier).state = file.path;
          }
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_outlined, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Target Directory',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: const Text('Drag & Drop'),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedPath != null
                          ? Icons.folder
                          : Icons.folder_outlined,
                      color: selectedPath != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedPath ??
                            'No directory selected - drag folder here or click browse',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selectedPath != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _selectDirectory(ref),
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Browse Directory'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _setHomeDirectory(ref),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandGrid(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: CommandService.commands.length,
      itemBuilder: (context, index) {
        final command = CommandService.commands[index];
        return _buildCommandCard(context, ref, command);
      },
    );
  }

  Widget _buildCommandCard(
    BuildContext context,
    WidgetRef ref,
    SystemCommand command,
  ) {
    final isLoading = ref.watch(isLoadingProvider);
    final selectedPath = ref.watch(selectedDirectoryProvider);
    final canExecute = !command.requiresPath || selectedPath != null;

    return Card(
      elevation: canExecute ? 8 : 2,
      child: InkWell(
        onTap:
            canExecute && !isLoading
                ? () => _executeCommand(ref, command)
                : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                canExecute
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        command.color.withOpacity(0.1),
                        command.color.withOpacity(0.05),
                      ],
                    )
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canExecute ? command.color : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      canExecute
                          ? [
                            BoxShadow(
                              color: command.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Icon(command.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                command.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                command.description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (command.requiresSudo)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Requires Admin',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortKiller(BuildContext context, WidgetRef ref) {
    final portController = TextEditingController();
    final isLoading = ref.watch(isLoadingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.power_off, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Text(
                  'Port Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Enter port number (e.g., 3000)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.radio_button_checked),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed:
                      isLoading
                          ? null
                          : () => _checkPort(ref, portController.text),
                  icon: const Icon(Icons.search),
                  label: const Text('Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      isLoading
                          ? null
                          : () => _killPort(ref, portController.text),
                  icon: const Icon(Icons.close),
                  label: const Text('Kill'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context, WidgetRef ref) {
    final output = ref.watch(commandOutputProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.terminal, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Output',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (output.isNotEmpty) ...[
                  IconButton(
                    onPressed: () => _saveOutput(context, output),
                    icon: const Icon(Icons.save),
                    tooltip: 'Save to file',
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context, output),
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                  ),
                  IconButton(
                    onPressed:
                        () =>
                            ref.read(commandOutputProvider.notifier).state = '',
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear output',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade700, width: 1),
                ),
                child:
                    isLoading
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.green),
                              SizedBox(height: 16),
                              Text(
                                'Executing command...',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        )
                        : SingleChildScrollView(
                          child: SelectableText(
                            output.isEmpty
                                ? 'Ready to execute commands...'
                                : output,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDirectory(WidgetRef ref) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      ref.read(selectedDirectoryProvider.notifier).state = selectedDirectory;
    }
  }

  Future<void> _setHomeDirectory(WidgetRef ref) async {
    final homeDir = Platform.environment['HOME'];
    if (homeDir != null) {
      ref.read(selectedDirectoryProvider.notifier).state = homeDir;
    }
  }

  Future<void> _executeCommand(WidgetRef ref, SystemCommand command) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(commandOutputProvider.notifier).state =
        'Executing: ${command.name}...\n';

    try {
      final selectedPath = ref.read(selectedDirectoryProvider);
      final result = await CommandService.executeCommandWithFallback(
        command,
        selectedPath,
      );
      ref.read(commandOutputProvider.notifier).state =
          '=== ${command.name} ===\n$result\n\n${DateTime.now().toString()}\n';
    } catch (e) {
      ref.read(commandOutputProvider.notifier).state =
          '=== ${command.name} - ERROR ===\n$e\n\n${DateTime.now().toString()}\n';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _killPort(WidgetRef ref, String portText) async {
    if (portText.isEmpty) return;

    final port = int.tryParse(portText);
    if (port == null) return;

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final pids = await CommandService.getProcessesOnPort(port);
      if (pids.isNotEmpty) {
        List<String> results = [];
        for (final pid in pids) {
          final killed = await CommandService.killProcess(pid);
          results.add('Process $pid: ${killed ? 'killed' : 'failed to kill'}');
        }
        ref.read(commandOutputProvider.notifier).state =
            '=== Kill Port $port ===\n${results.join('\n')}\n\n${DateTime.now().toString()}\n';
      } else {
        ref.read(commandOutputProvider.notifier).state =
            '=== Kill Port $port ===\nNo processes found on port $port\n\n${DateTime.now().toString()}\n';
      }
    } catch (e) {
      ref.read(commandOutputProvider.notifier).state =
          '=== Kill Port $port - ERROR ===\n$e\n\n${DateTime.now().toString()}\n';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Output copied to clipboard'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _saveOutput(BuildContext context, String output) async {
    try {
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Command Output',
        fileName:
            'system_cleaner_output_${DateTime.now().millisecondsSinceEpoch}.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(output);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.save, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Output saved to: ${file.path}')),
                ],
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to save file: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purple.shade300],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('System Cleaner Pro'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Advanced desktop file system management tool'),
                const SizedBox(height: 16),
                const Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Find large files and directories'),
                    Text('• Monitor system resources'),
                    Text('• Manage network ports'),
                    Text('• Clean cache and temporary files'),
                    Text('• Export results to file'),
                    Text('• Drag & drop directory selection'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Some commands may require elevated permissions or may not work in sandboxed environments.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _checkPort(WidgetRef ref, String portText) async {
    if (portText.isEmpty) return;

    final port = int.tryParse(portText);
    if (port == null) return;

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final pids = await CommandService.getProcessesOnPort(port);
      if (pids.isNotEmpty) {
        ref.read(commandOutputProvider.notifier).state =
            '=== Port $port Status ===\nPort is in use by process(es): ${pids.join(', ')}\n\n${DateTime.now().toString()}\n';
      } else {
        ref.read(commandOutputProvider.notifier).state =
            '=== Port $port Status ===\nPort is available or no processes found\n\n${DateTime.now().toString()}\n';
      }
    } catch (e) {
      ref.read(commandOutputProvider.notifier).state =
          '=== Port $port Check - ERROR ===\n$e\n\n${DateTime.now().toString()}\n';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}

/* 
      

  
    
    */
