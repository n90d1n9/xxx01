import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';

class TerminalStatusBar extends ConsumerWidget {
  const TerminalStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);
    final settings = ref.watch(settingsProvider);
    final isBusy = ref.watch(commandExecutionProvider);
    final searchQuery = ref.watch(searchProvider);

    final dir = activeTab?.workingDirectory ?? '/home/user';
    final outputCount = activeTab?.outputs.length ?? 0;
    final historyCount = activeTab?.history.length ?? 0;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: TerminalTheme.blue,
      child: Row(
        children: [
          // Git-like branch indicator
          const Icon(Icons.terminal, size: 12, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'flutter-terminal',
            style: TerminalTheme.monoFont.copyWith(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          // Working dir
          const Icon(Icons.folder, size: 11, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            dir.replaceFirst('/home/user', '~'),
            style: TerminalTheme.monoFont.copyWith(fontSize: 11, color: Colors.white70),
          ),
          const Spacer(),
          // Search status
          if (searchQuery != null)
            _StatusChip(
              icon: Icons.search,
              label: 'Search: "${searchQuery}"',
              onTap: () => ref.read(searchProvider.notifier).close(),
            ),
          const SizedBox(width: 8),
          // Busy indicator
          if (isBusy)
            const Row(
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white70),
                ),
                SizedBox(width: 4),
                Text('Running...', style: TextStyle(fontSize: 10, color: Colors.white70)),
                SizedBox(width: 8),
              ],
            ),
          // Stats
          Text(
            '$historyCount cmds  •  ${settings.fontSize.toInt()}px',
            style: TerminalTheme.monoFont.copyWith(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(width: 8),
          // Keyboard shortcut hints
          Text(
            'Ctrl+L: clear  •  Tab: autocomplete  •  ↑↓: history',
            style: TerminalTheme.monoFont.copyWith(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _StatusChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: Colors.white),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
