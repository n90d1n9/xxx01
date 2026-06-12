import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/terminal_models.dart';
import '../providers/terminal_providers.dart';
import '../theme/terminal_theme.dart';

class TerminalTabBar extends ConsumerWidget {
  const TerminalTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = ref.watch(tabsProvider);
    final settings = ref.watch(settingsProvider);

    return Container(
      height: 38,
      color: TerminalTheme.surface,
      child: Row(
        children: [
          // Tab list
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (_, i) => _TabItem(tab: tabs[i]),
            ),
          ),
          // New tab button
          _IconBtn(
            icon: Icons.add,
            tooltip: 'New tab (Ctrl+T)',
            onTap: () => ref.read(tabsProvider.notifier).addTab(),
          ),
          Container(width: 1, height: 20, color: TerminalTheme.border),
          // Font size controls
          _IconBtn(
            icon: Icons.text_decrease,
            tooltip: 'Decrease font size',
            onTap: () => ref.read(settingsProvider.notifier).decreaseFontSize(),
          ),
          _IconBtn(
            icon: Icons.text_increase,
            tooltip: 'Increase font size',
            onTap: () => ref.read(settingsProvider.notifier).increaseFontSize(),
          ),
          Container(width: 1, height: 20, color: TerminalTheme.border),
          // Sidebar toggle
          _IconBtn(
            icon: settings.sidebarOpen ? Icons.view_sidebar : Icons.view_sidebar_outlined,
            tooltip: 'Toggle sidebar',
            onTap: () => ref.read(settingsProvider.notifier).toggleSidebar(),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TabItem extends ConsumerWidget {
  final TerminalTab tab;
  const _TabItem({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(tabsProvider.notifier).setActiveTab(tab.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: tab.isActive ? TerminalTheme.background : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: tab.isActive ? TerminalTheme.blue : Colors.transparent,
              width: 2,
            ),
            right: const BorderSide(color: TerminalTheme.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal,
              size: 12,
              color: tab.isActive ? TerminalTheme.blue : TerminalTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                tab.title,
                style: TerminalTheme.uiFont.copyWith(
                  fontSize: 12,
                  color: tab.isActive ? TerminalTheme.textPrimary : TerminalTheme.textSecondary,
                  fontWeight: tab.isActive ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            // Close button
            GestureDetector(
              onTap: () => ref.read(tabsProvider.notifier).closeTab(tab.id),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: tab.isActive ? TerminalTheme.textSecondary : TerminalTheme.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 38,
          child: Icon(icon, size: 15, color: TerminalTheme.textSecondary),
        ),
      ),
    );
  }
}
