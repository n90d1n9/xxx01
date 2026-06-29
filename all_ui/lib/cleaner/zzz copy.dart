// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// process_run: ^0.12.5+2
// file_picker: ^6.1.1
// animated_text_kit: ^4.2.2
// glassmorphism: ^3.0.0

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:process_run/process_run.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Providers
final selectedDirectoryProvider = StateProvider<String?>((ref) => null);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final commandOutputProvider = StateProvider<String>((ref) => '');
final themeProvider = StateProvider<bool>((ref) => true); // true = dark mode

// Models
class SystemCommand {
  final String name;
  final String description;
  final String command;
  final IconData icon;
  final Color color;
  final bool requiresPath;

  SystemCommand({
    required this.name,
    required this.description,
    required this.command,
    required this.icon,
    required this.color,
    this.requiresPath = false,
  });
}

// Command Service
class CommandService {
  static final List<SystemCommand> commands = [
    SystemCommand(
      name: 'Large Files',
      description: 'Find files larger than 100MB',
      command:
          'find "{path}" -type f -size +100M -exec ls -lh {} \\; | sort -k 5 -rh',
      icon: Icons.file_present,
      color: Colors.orange,
      requiresPath: true,
    ),
    SystemCommand(
      name: 'Directory Sizes',
      description: 'Show largest directories',
      command: 'du -sh {path}/* | sort -hr | head -n 20',
      icon: Icons.folder_open,
      color: Colors.blue,
      requiresPath: true,
    ),
    SystemCommand(
      name: 'Clear System Cache',
      description: 'Remove system cache files',
      command: 'sudo rm -rf /Library/Caches/*',
      icon: Icons.cleaning_services,
      color: Colors.red,
    ),
    SystemCommand(
      name: 'Port Check',
      description: 'Check active network ports',
      command: 'sudo lsof -i -P -n | grep LISTEN',
      icon: Icons.network_check,
      color: Colors.green,
    ),
    SystemCommand(
      name: 'Memory Usage',
      description: 'Show memory consumption',
      command: 'ps aux --sort=-%mem | head -n 20',
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
  ];

  static Future<String> executeCommand(String command) async {
    try {
      final result = await Shell().run(command);
      return result.map((e) => e.stdout.toString()).join('\n');
    } catch (e) {
      return 'Error executing command: $e';
    }
  }

  static Future<int?> getProcessOnPort(int port) async {
    try {
      final result = await Shell().run('sudo lsof -ti:$port');
      if (result.isNotEmpty &&
          result.first.stdout.toString().trim().isNotEmpty) {
        return int.tryParse(result.first.stdout.toString().trim());
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  static Future<bool> killProcess(int pid) async {
    try {
      await Shell().run('kill -9 $pid');
      return true;
    } catch (e) {
      return false;
    }
  }
}

void main() {
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
              _buildHeader(context, ref),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPathSelector(context, ref),
                      const SizedBox(height: 24),
                      _buildCommandGrid(context, ref),
                      const SizedBox(height: 24),
                      _buildPortKiller(context, ref),
                      const SizedBox(height: 24),
                      _buildOutputSection(context, ref),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                  'Advanced file system management',
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
          IconButton(
            onPressed:
                () => ref.read(themeProvider.notifier).state = !isDarkMode,
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.yellow : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathSelector(BuildContext context, WidgetRef ref) {
    final selectedPath = ref.watch(selectedDirectoryProvider);

    return Card(
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
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Text(
                selectedPath ?? 'No directory selected',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _selectDirectory(ref),
                icon: const Icon(Icons.folder_open),
                label: const Text('Select Directory'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandGrid(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortKiller(BuildContext context, WidgetRef ref) {
    final portController = TextEditingController();

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
                  'Port Killer',
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
                      hintText: 'Enter port number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.radio_button_checked),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _killPort(ref, portController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.close),
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
                  'Command Output',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (output.isNotEmpty)
                  IconButton(
                    onPressed: () => _copyToClipboard(context, output),
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
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
                        child: Text(
                          output.isEmpty ? 'No output yet...' : output,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.green,
                            fontSize: 12,
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

  Future<void> _executeCommand(WidgetRef ref, SystemCommand command) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(commandOutputProvider.notifier).state = '';

    try {
      String commandToExecute = command.command;

      if (command.requiresPath) {
        final selectedPath = ref.read(selectedDirectoryProvider);
        if (selectedPath != null) {
          commandToExecute = commandToExecute.replaceAll(
            '{path}',
            selectedPath,
          );
        }
      }

      final result = await CommandService.executeCommand(commandToExecute);
      ref.read(commandOutputProvider.notifier).state = result;
    } catch (e) {
      ref.read(commandOutputProvider.notifier).state = 'Error: $e';
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
      final pid = await CommandService.getProcessOnPort(port);
      if (pid != null) {
        final killed = await CommandService.killProcess(pid);
        ref.read(commandOutputProvider.notifier).state =
            killed
                ? 'Successfully killed process $pid on port $port'
                : 'Failed to kill process $pid';
      } else {
        ref.read(commandOutputProvider.notifier).state =
            'No process found on port $port';
      }
    } catch (e) {
      ref.read(commandOutputProvider.notifier).state = 'Error: $e';
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Output copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
