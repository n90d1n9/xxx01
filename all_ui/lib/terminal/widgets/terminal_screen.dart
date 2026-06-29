import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import 'terminal_tab_bar.dart';
import 'terminal_output_view.dart';
import 'terminal_input_bar.dart';
import 'terminal_sidebar.dart';
import 'terminal_status_bar.dart';

class TerminalScreen extends ConsumerWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings    = ref.watch(settingsProvider);
    final searchOpen  = ref.watch(searchProvider) != null;

    return Focus(
      // Global shortcuts that work even when the input field loses focus
      // (e.g. user clicked on the output area).
      autofocus: false,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final ctrl = HardwareKeyboard.instance.isControlPressed;
        if (ctrl && event.logicalKey == LogicalKeyboardKey.keyF) {
          ref.read(searchProvider.notifier).open();
          return KeyEventResult.handled;
        }
        if (ctrl && event.logicalKey == LogicalKeyboardKey.keyT) {
          ref.read(tabsProvider.notifier).addTab();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: TerminalTheme.background,
        body: Column(
          children: [
            // macOS-style window title bar
            const _TitleBar(),
            // Tab bar
            const TerminalTabBar(),
            // Search bar (shown/hidden)
            if (searchOpen) const TerminalSearchBar(),
            // Body
            Expanded(
              child: Row(
                children: [
                  if (settings.sidebarOpen) const TerminalSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        const Expanded(child: TerminalOutputView()),
                        const TerminalInputBar(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const TerminalStatusBar(),
          ],
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: TerminalTheme.surface,
        border: Border(bottom: BorderSide(color: TerminalTheme.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          // Traffic lights
          _dot(const Color(0xFFFF5F56)),
          const SizedBox(width: 7),
          _dot(const Color(0xFFFFBD2E)),
          const SizedBox(width: 7),
          _dot(const Color(0xFF27C93F)),
          const Spacer(),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terminal, size: 13, color: TerminalTheme.textMuted),
              SizedBox(width: 6),
              Text(
                'Flutter Terminal',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: TerminalTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Placeholder to balance traffic lights
          const SizedBox(width: 66),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 12, height: 12,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
