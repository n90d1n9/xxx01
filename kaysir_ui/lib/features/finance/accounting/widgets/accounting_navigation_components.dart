import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/helper.dart';
import '../accounting_path.dart';
import '../models/accounting_menu_catalog.dart';
import 'accounting_navigation_destination_menu_components.dart';
import 'accounting_navigation_section_summary_components.dart';

/// Header for the accounting workspace with compact route-level actions.
class AccountingNavigationHeader extends StatelessWidget {
  const AccountingNavigationHeader({
    this.onCopyLink,
    this.onDestinationSelected,
    this.destinationSections = accountingMenuSections,
    super.key,
  });

  final VoidCallback? onCopyLink;
  final ValueChanged<AccountingMenuDestination>? onDestinationSelected;
  final List<AccountingMenuSection> destinationSections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accounting Workspace',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Close, ledger, reconciliation, reporting, payables, and receivables.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
                ),
              ],
            );
            final copyAction = Tooltip(
              message: 'Copy current workspace link',
              child: FilledButton.tonalIcon(
                key: const ValueKey('accounting-workspace-copy-link'),
                onPressed: onCopyLink,
                icon: const Icon(Icons.link_rounded, size: 18),
                label: const Text('Copy link'),
              ),
            );
            final destinationAction =
                onDestinationSelected == null
                    ? null
                    : AccountingNavigationDestinationMenu(
                      sections: destinationSections,
                      onSelected: onDestinationSelected!,
                      includeShortcuts: true,
                      menuButtonKey: const ValueKey(
                        'accounting-header-destination-menu',
                      ),
                      buttonColor: colorScheme.surface.withValues(alpha: 0.78),
                      foregroundColor: colorScheme.onSurface,
                    );
            final actions = [
              if (destinationAction != null) destinationAction,
              if (onCopyLink != null) copyAction,
            ];
            final facts = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeaderFact(
                  label: '${accountingMenuSections.length}',
                  helper: 'Sections',
                ),
                _HeaderFact(
                  label: '${accountingMenuScreenDestinations.length}',
                  helper: 'Screens',
                ),
                _HeaderFact(
                  label: '${accountingMenuShortcutDestinations.length}',
                  helper: 'Shortcuts',
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                  const SizedBox(height: 14),
                  facts,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: title),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (actions.isNotEmpty) ...[
                      Wrap(spacing: 8, runSpacing: 8, children: actions),
                      const SizedBox(height: 12),
                    ],
                    facts,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Accounting navigation header')
Widget accountingNavigationHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationHeader(
          onCopyLink: () {},
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  );
}

class AccountingNavigationSectionGrid extends StatelessWidget {
  const AccountingNavigationSectionGrid({super.key, required this.section});

  final AccountingMenuSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(getIconData(section.icon), color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    section.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AccountingNavigationSectionSummaryPills(section: section),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns =
                constraints.maxWidth >= 1180
                    ? 3
                    : constraints.maxWidth >= 760
                    ? 2
                    : 1;
            final destinations = section.screenDestinations.toList();
            final shortcuts = section.shortcutDestinations.toList();
            final width =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final destination in destinations)
                      SizedBox(
                        width: width,
                        child: AccountingNavigationTile(
                          destination: destination,
                        ),
                      ),
                  ],
                ),
                if (shortcuts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AccountingNavigationShortcutStrip(shortcuts: shortcuts),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class AccountingNavigationShortcutStrip extends StatelessWidget {
  const AccountingNavigationShortcutStrip({super.key, required this.shortcuts});

  final List<AccountingMenuDestination> shortcuts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groups = _groupShortcuts(shortcuts);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 640;
            final title = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shortcut_rounded,
                  color: colorScheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Focus Shortcuts',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );

            final shortcutGroups = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < groups.length; index += 1) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _ShortcutGroupRow(group: groups[index]),
                ],
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 10), shortcutGroups],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(width: 16),
                Expanded(child: shortcutGroups),
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Accounting focus shortcuts')
Widget accountingNavigationShortcutStripPreview() {
  final reportingSection = accountingMenuSections.singleWhere(
    (section) => section.name == 'Financial Reporting',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationShortcutStrip(
          shortcuts: reportingSection.shortcutDestinations.toList(),
        ),
      ),
    ),
  );
}

class AccountingNavigationTile extends StatelessWidget {
  const AccountingNavigationTile({super.key, required this.destination});

  final AccountingMenuDestination destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(destination.path),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    getIconData(destination.icon),
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
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
              const SizedBox(width: 8),
              Tooltip(
                message: 'Open ${destination.name}',
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders one labeled row of shortcut chips for a shared destination screen.
class _ShortcutGroupRow extends StatelessWidget {
  const _ShortcutGroupRow({required this.group});

  final _ShortcutGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      key: ValueKey('accounting-shortcut-group-${group.label}'),
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            group.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (final shortcut in group.shortcuts)
          ActionChip(
            key: ValueKey('accounting-shortcut-${shortcut.path}'),
            avatar: Icon(getIconData(shortcut.icon), size: 17),
            label: Text(
              _shortcutChipLabel(shortcut.name),
              overflow: TextOverflow.ellipsis,
            ),
            tooltip: shortcut.subtitle,
            onPressed: () => context.go(shortcut.path),
          ),
      ],
    );
  }
}

/// Groups shortcut destinations by the screen that owns their query focus.
class _ShortcutGroup {
  const _ShortcutGroup({required this.label, required this.shortcuts});

  final String label;
  final List<AccountingMenuDestination> shortcuts;
}

List<_ShortcutGroup> _groupShortcuts(
  List<AccountingMenuDestination> shortcuts,
) {
  final grouped = <String, List<AccountingMenuDestination>>{};
  for (final shortcut in shortcuts) {
    grouped.putIfAbsent(shortcut.routePath, () => []).add(shortcut);
  }

  return [
    for (final entry in grouped.entries)
      _ShortcutGroup(
        label: _shortcutGroupLabel(entry.key),
        shortcuts: List.unmodifiable(entry.value),
      ),
  ];
}

String _shortcutGroupLabel(String routePath) {
  return switch (routePath) {
    AccountingPath.managementMeasures => 'Management Measures',
    AccountingPath.reportRelease => 'Report Release',
    _ => 'Jump Points',
  };
}

String _shortcutChipLabel(String name) {
  const prefixes = ['Management ', 'Release '];
  for (final prefix in prefixes) {
    if (name.startsWith(prefix)) {
      return name.substring(prefix.length);
    }
  }
  return name;
}

class _HeaderFact extends StatelessWidget {
  const _HeaderFact({required this.label, required this.helper});

  final String label;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              helper,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
