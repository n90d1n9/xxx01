import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';

class TerminalStatusBar extends ConsumerWidget {
  const TerminalStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab      = ref.watch(activeTabProvider);
    final settings = ref.watch(settingsProvider);
    final search   = ref.watch(searchProvider);
    final dir      = tab?.workingDirectory ?? '/home/user';
    final cmdCount = tab?.history.length ?? 0;
    final lineCount = tab?.outputs.where((o) => o.text.isNotEmpty).length ?? 0;
    final isBusy   = tab?.isBusy ?? false;

    return Container(
      height: 22,
      color: TerminalTheme.blue,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          // Left: branch/dir
          const Icon(Icons.terminal, size: 11, color: Colors.white70),
          const SizedBox(width: 5),
          _seg('flutter-terminal', Colors.white),
          _sep(),
          const Icon(Icons.folder_open, size: 10, color: Colors.white70),
          const SizedBox(width: 4),
          _seg(dir.replaceFirst('/home/user', '~'), Colors.white70),

          const Spacer(),

          // Middle: search active
          if (search != null)
            _chip(Icons.search, 'search active',
                onTap: () => ref.read(searchProvider.notifier).close()),

          // Busy
          if (isBusy) ...[
            _sep(),
            const SizedBox(
              width: 10, height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.2, color: Colors.white70),
            ),
            const SizedBox(width: 4),
            _seg('running…', Colors.white70),
          ],

          _sep(),
          _seg('$cmdCount cmd${cmdCount == 1 ? "" : "s"}', Colors.white70),
          _sep(),
          _seg('$lineCount lines', Colors.white70),
          _sep(),
          _seg('${settings.fontSize.toInt()}px', Colors.white70),
          _sep(),
          _seg('UTF-8', Colors.white54),
          _sep(),
          // Shortcuts hint
          _seg('Ctrl+L clear · Tab complete · ↑↓ history', Colors.white38),
        ],
      ),
    );
  }

  Widget _seg(String text, Color color) => Text(
    text,
    style: TextStyle(
      fontFamily: 'JetBrains Mono', fontSize: 10, color: color,
    ),
  );

  Widget _sep() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('·', style: TextStyle(fontSize: 10, color: Colors.white30)),
  );

  Widget _chip(IconData icon, String label, {VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 9, color: Colors.white),
              const SizedBox(width: 3),
              Text(label, style: const TextStyle(fontSize: 9, color: Colors.white)),
            ],
          ),
        ),
      );
}
