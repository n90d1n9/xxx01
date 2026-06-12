import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_catalog.dart';

/// Compact menu for opening accounting screens without scrolling the workspace.
class AccountingNavigationDestinationMenu extends StatelessWidget {
  const AccountingNavigationDestinationMenu({
    required this.sections,
    required this.onSelected,
    this.includeShortcuts = false,
    this.menuButtonKey = const ValueKey('accounting-destination-menu'),
    this.buttonColor,
    this.foregroundColor,
    super.key,
  });

  final List<AccountingMenuSection> sections;
  final ValueChanged<AccountingMenuDestination> onSelected;
  final bool includeShortcuts;
  final Key menuButtonKey;
  final Color? buttonColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final screenCount = sections.fold<int>(
      0,
      (total, section) => total + section.screenDestinations.length,
    );

    return Tooltip(
      message:
          includeShortcuts
              ? 'Open accounting screen or shortcut'
              : 'Open accounting screen',
      child: PopupMenuButton<AccountingMenuDestination>(
        key: menuButtonKey,
        tooltip:
            includeShortcuts
                ? 'Open accounting screen or shortcut'
                : 'Open accounting screen',
        onSelected: onSelected,
        itemBuilder: (context) => _buildMenuEntries(context),
        child: _DestinationMenuButtonLabel(
          screenCount: screenCount,
          buttonColor: buttonColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }

  List<PopupMenuEntry<AccountingMenuDestination>> _buildMenuEntries(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entries = <PopupMenuEntry<AccountingMenuDestination>>[];

    for (final section in sections) {
      final screens = section.screenDestinations.toList();
      final shortcuts =
          includeShortcuts
              ? section.shortcutDestinations.toList()
              : const <AccountingMenuDestination>[];
      if (screens.isEmpty && shortcuts.isEmpty) continue;

      if (entries.isNotEmpty) {
        entries.add(const PopupMenuDivider(height: 8));
      }

      entries.add(
        PopupMenuItem<AccountingMenuDestination>(
          enabled: false,
          height: 34,
          child: Text(
            section.name,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );

      for (final destination in screens) {
        entries.add(
          PopupMenuItem<AccountingMenuDestination>(
            key: ValueKey(
              'accounting-destination-menu-item-'
              '${accountingDestinationMenuId(destination.name)}',
            ),
            value: destination,
            child: _DestinationMenuItem(destination: destination),
          ),
        );
      }

      if (shortcuts.isNotEmpty) {
        entries.add(
          PopupMenuItem<AccountingMenuDestination>(
            enabled: false,
            height: 30,
            child: Text(
              'Focus shortcuts',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );

        for (final destination in shortcuts) {
          entries.add(
            PopupMenuItem<AccountingMenuDestination>(
              key: ValueKey(
                'accounting-destination-menu-item-'
                '${accountingDestinationMenuId(destination.name)}',
              ),
              value: destination,
              child: _DestinationMenuItem(
                destination: destination,
                isShortcut: true,
              ),
            ),
          );
        }
      }
    }

    return entries;
  }
}

@Preview(name: 'Accounting destination menu')
Widget accountingNavigationDestinationMenuPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: AccountingNavigationDestinationMenu(
          sections: accountingMenuSections,
          includeShortcuts: true,
          onSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Stable id for testing and route-launcher keys in the destination menu.
String accountingDestinationMenuId(String name) {
  final slug = name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return slug.isEmpty ? 'destination' : slug;
}

/// Fixed-size label for the compact accounting destination launcher.
class _DestinationMenuButtonLabel extends StatelessWidget {
  const _DestinationMenuButtonLabel({
    required this.screenCount,
    this.buttonColor,
    this.foregroundColor,
  });

  final int screenCount;
  final Color? buttonColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: buttonColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apps_rounded,
              size: 18,
              color: foregroundColor ?? colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              '$screenCount screens',
              style: theme.textTheme.labelMedium?.copyWith(
                color: foregroundColor ?? colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One accounting screen entry shown inside the compact destination menu.
class _DestinationMenuItem extends StatelessWidget {
  const _DestinationMenuItem({
    required this.destination,
    this.isShortcut = false,
  });

  final AccountingMenuDestination destination;
  final bool isShortcut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 320,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            getIconData(destination.icon),
            size: 19,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  destination.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isShortcut) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shortcut_rounded,
                        size: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Jump point',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  destination.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
