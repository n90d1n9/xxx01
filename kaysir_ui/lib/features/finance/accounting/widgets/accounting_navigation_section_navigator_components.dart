import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../utils/helper.dart';
import '../models/accounting_menu_catalog.dart';
import 'accounting_navigation_destination_menu_components.dart';

/// Compact accounting section jump bar with an optional screen launcher.
class AccountingNavigationSectionNavigator extends StatelessWidget {
  const AccountingNavigationSectionNavigator({
    required this.sections,
    required this.onSelected,
    this.onDestinationSelected,
    super.key,
  });

  final List<AccountingMenuSection> sections;
  final ValueChanged<AccountingMenuSection> onSelected;
  final ValueChanged<AccountingMenuDestination>? onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final title = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route_rounded, color: colorScheme.primary, size: 19),
                const SizedBox(width: 8),
                Text(
                  'Section Navigator',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            );
            final destinationMenu =
                onDestinationSelected == null
                    ? null
                    : AccountingNavigationDestinationMenu(
                      sections: sections,
                      onSelected: onDestinationSelected!,
                      menuButtonKey: const ValueKey(
                        'accounting-section-destination-menu',
                      ),
                    );
            final chips = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final section in sections)
                  ActionChip(
                    key: ValueKey(
                      'accounting-section-jump-${accountingSectionAnchorId(section.name)}',
                    ),
                    avatar: Icon(getIconData(section.icon), size: 17),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 170),
                          child: Text(
                            section.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        _SectionDestinationCountBadge(
                          count: section.destinations.length,
                        ),
                      ],
                    ),
                    tooltip:
                        '${section.destinations.length} destination'
                        '${section.destinations.length == 1 ? '' : 's'}',
                    onPressed: () => onSelected(section),
                  ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      title,
                      const Spacer(),
                      if (destinationMenu != null) destinationMenu,
                    ],
                  ),
                  const SizedBox(height: 10),
                  chips,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(width: 16),
                Expanded(child: chips),
                if (destinationMenu != null) ...[
                  const SizedBox(width: 12),
                  destinationMenu,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Accounting section navigator')
Widget accountingNavigationSectionNavigatorPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: AccountingNavigationSectionNavigator(
          sections: accountingMenuSections,
          onSelected: (_) {},
          onDestinationSelected: (_) {},
        ),
      ),
    ),
  );
}

String accountingSectionAnchorId(String name) {
  final normalized = name.trim().toLowerCase();
  final slug = normalized
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return slug.isEmpty ? 'section' : slug;
}

class _SectionDestinationCountBadge extends StatelessWidget {
  const _SectionDestinationCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        child: Text(
          '$count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
