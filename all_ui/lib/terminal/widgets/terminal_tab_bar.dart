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
    return Container(
      height: 36,
      color: TerminalTheme.surface,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (_, i) => _TabChip(tab: tabs[i]),
            ),
          ),
          _Divider(),
          _TBarBtn(
            icon: Icons.add,
            tooltip: 'New tab  Ctrl+T',
            onTap: () => ref.read(tabsProvider.notifier).addTab(),
          ),
          _Divider(),
          _TBarBtn(
            icon: Icons.search,
            tooltip: 'Search  Ctrl+F',
            onTap: () => ref.read(searchProvider.notifier).open(),
          ),
          _Divider(),
          _TBarBtn(
            icon: ref.watch(settingsProvider).sidebarOpen
                ? Icons.view_sidebar
                : Icons.view_sidebar_outlined,
            tooltip: 'Toggle sidebar',
            onTap: () => ref.read(settingsProvider.notifier).toggleSidebar(),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TabChip extends ConsumerWidget {
  final TerminalTab tab;
  const _TabChip({required this.tab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = tab.isActive;
    return GestureDetector(
      onTap: () => ref.read(tabsProvider.notifier).setActiveTab(tab.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minWidth: 90, maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? TerminalTheme.background : Colors.transparent,
          border: Border(
            top: BorderSide(
              color: active ? TerminalTheme.blue : Colors.transparent,
              width: 2,
            ),
            right: const BorderSide(color: TerminalTheme.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Busy dot
            if (tab.isBusy)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: SizedBox(
                  width: 8, height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: active ? TerminalTheme.blue : TerminalTheme.textMuted,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.terminal,
                  size: 11,
                  color: active ? TerminalTheme.blue : TerminalTheme.textMuted,
                ),
              ),
            Flexible(
              child: Text(
                tab.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: active ? TerminalTheme.textPrimary : TerminalTheme.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Close
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => ref.read(tabsProvider.notifier).closeTab(tab.id),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 11,
                    color: active ? TerminalTheme.textSecondary : TerminalTheme.textMuted,
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

class _TBarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _TBarBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 30, height: 36,
        child: Icon(icon, size: 14, color: TerminalTheme.textSecondary),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 18, color: TerminalTheme.border);
}
