import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';
import '../widgets/terminal_tab_bar.dart';
import '../widgets/terminal_output_view.dart';
import '../widgets/terminal_input_bar.dart';
import '../widgets/terminal_sidebar.dart';
import '../widgets/terminal_status_bar.dart';

class TerminalScreen extends ConsumerWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final searchQuery = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: TerminalTheme.background,
      body: Column(
        children: [
          // Title bar (custom window chrome feel)
          _TitleBar(),
          // Tab bar
          const TerminalTabBar(),
          // Search bar
          if (searchQuery != null) const SearchBar(),
          // Main content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                if (settings.sidebarOpen)
                  const TerminalSidebar(),
                // Terminal area
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
          // Status bar
          const TerminalStatusBar(),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: TerminalTheme.surface,
        border: Border(bottom: BorderSide(color: TerminalTheme.border)),
      ),
      child: Row(
        children: [
          // Traffic lights
          const SizedBox(width: 12),
          _trafficLight(const Color(0xFFFF5F56)),
          const SizedBox(width: 8),
          _trafficLight(const Color(0xFFFFBD2E)),
          const SizedBox(width: 8),
          _trafficLight(const Color(0xFF27C93F)),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.terminal, size: 14, color: TerminalTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Flutter Terminal',
                    style: TerminalTheme.uiFont.copyWith(
                      fontSize: 13,
                      color: TerminalTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _trafficLight(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
