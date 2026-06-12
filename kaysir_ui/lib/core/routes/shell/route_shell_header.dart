import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import '../../../widgets/ui/app_search_field.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../../features/features_registry.dart';
import 'route_search_dialog.dart';
import 'route_shell_header_state.dart';
import 'route_shell_layout.dart';
import 'route_shell_shortcuts.dart';

/// Top workspace bar for the route shell.
class RouteShellHeader extends StatelessWidget {
  const RouteShellHeader({super.key, required this.layout, this.currentPath});

  final RouteShellLayout layout;
  final String? currentPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final features = FeaturesRegistry.getFeatures();
    final path = currentPath?.trim();
    final headerState =
        path == null || path.isEmpty
            ? RouteShellHeaderState.fromRoutes(
              routes: features,
              context: context,
            )
            : RouteShellHeaderState.fromCurrentPath(
              routes: features,
              currentPath: path,
            );

    return Material(
      color: colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            if (layout.usesDrawer) ...[
              Builder(
                builder:
                    (context) => AppIconActionButton(
                      icon: Icons.menu_rounded,
                      tooltip: 'Open navigation',
                      variant: AppIconActionButtonVariant.outlined,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: _HeaderTitle(
                title: headerState.title,
                subtitle: headerState.subtitle,
                breadcrumbItems: headerState.breadcrumbItems,
              ),
            ),
            if (layout.usesDrawer) ...[
              const SizedBox(width: 12),
              AppIconActionButton(
                icon: Icons.search_rounded,
                tooltip: 'Search workspace',
                variant: AppIconActionButtonVariant.outlined,
                onPressed:
                    () => showRouteSearchDialog(context, features: features),
              ),
            ] else ...[
              const SizedBox(width: 16),
              AppSearchField(
                hintText: 'Search workspace',
                readOnly: true,
                width: layout.isCompact ? 220 : 320,
                tooltip:
                    'Search workspace (${RouteShellShortcuts.searchShortcutLabel})',
                trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                onTap: () => showRouteSearchDialog(context, features: features),
              ),
            ],
            const SizedBox(width: 12),
            AppStatusPill(
              label: 'Live workspace',
              color: colorScheme.primary,
              icon: Icons.bolt_rounded,
              maxWidth: layout.usesDrawer ? 150 : 190,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Route shell header')
Widget routeShellHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      body: RouteShellHeader(layout: RouteShellLayout.fromWidth(1280)),
    ),
  );
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.title,
    required this.subtitle,
    required this.breadcrumbItems,
  });

  final String title;
  final String subtitle;
  final List<RouteShellBreadcrumbItem> breadcrumbItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (breadcrumbItems.length > 1) ...[
          const SizedBox(height: 6),
          _HeaderBreadcrumbTrail(
            items: breadcrumbItems,
            onSelected: (item) => _openBreadcrumb(context, item),
          ),
        ],
      ],
    );
  }
}

/// Compact breadcrumb strip that shows route ancestry in the shell header.
class _HeaderBreadcrumbTrail extends StatelessWidget {
  const _HeaderBreadcrumbTrail({
    required this.items,
    required this.onSelected,
  });

  final List<RouteShellBreadcrumbItem> items;
  final ValueChanged<RouteShellBreadcrumbItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 24,
      child: ListView.separated(
        key: const ValueKey('route-shell-header-breadcrumbs'),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder:
            (context, index) => Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
        itemBuilder: (context, index) {
          final item = items[index];
          final canOpen = item.canOpen && item.location != null;
          final borderRadius = BorderRadius.circular(8);

          return Tooltip(
            message: canOpen ? 'Open ${item.label}' : item.label,
            child: Semantics(
              button: canOpen,
              selected: item.isCurrent,
              child: InkWell(
                key: ValueKey(
                  'route-shell-header-breadcrumb-${item.location ?? item.label}',
                ),
                onTap: canOpen ? () => onSelected(item) : null,
                borderRadius: borderRadius,
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(maxWidth: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color:
                        item.isCurrent
                            ? colorScheme.primaryContainer.withValues(alpha: 0.64)
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: borderRadius,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color:
                          item.isCurrent
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                      fontWeight:
                          item.isCurrent ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _openBreadcrumb(BuildContext context, RouteShellBreadcrumbItem item) {
  final location = item.location?.trim();
  if (location == null || location.isEmpty) return;
  GoRouter.maybeOf(context)?.go(location);
}
