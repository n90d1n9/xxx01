import 'package:flutter/material.dart';

import '../../models/survey_role.dart';
import 'survey_workspace_navigation.dart';

class SurveyWorkspaceMenu extends StatelessWidget {
  final SurveyRole role;
  final List<SurveyWorkspaceSection> sections;
  final SurveyWorkspaceSection selectedSection;
  final ValueChanged<SurveyWorkspaceSection> onSectionSelected;
  final List<SurveyWorkspaceShortcut> shortcuts;
  final Map<SurveyWorkspaceSection, SurveyWorkspaceSectionBadge> sectionBadges;
  final EdgeInsetsGeometry padding;
  final bool showFooter;

  const SurveyWorkspaceMenu({
    super.key,
    required this.role,
    required this.sections,
    required this.selectedSection,
    required this.onSectionSelected,
    this.shortcuts = const [],
    this.sectionBadges = const {},
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 16),
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: _WorkspaceMenuHeader(role: role),
        ),
        Expanded(
          child: ListView(
            padding: padding,
            children: [
              const _WorkspaceMenuGroupLabel(label: 'Modules'),
              const SizedBox(height: 8),
              for (final section in sections)
                _WorkspaceMenuSectionItem(
                  section: section,
                  selected: section == selectedSection,
                  badge: sectionBadges[section],
                  onTap: () => onSectionSelected(section),
                ),
              if (shortcuts.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _WorkspaceMenuGroupLabel(label: 'Screens'),
                const SizedBox(height: 8),
                for (final shortcut in shortcuts)
                  _WorkspaceMenuShortcutItem(shortcut: shortcut),
              ],
            ],
          ),
        ),
        if (showFooter)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Text(
              role.workspaceTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _WorkspaceMenuHeader extends StatelessWidget {
  final SurveyRole role;

  const _WorkspaceMenuHeader({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fact_check_outlined,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kaysir Survey',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkspaceMenuGroupLabel extends StatelessWidget {
  final String label;

  const _WorkspaceMenuGroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _WorkspaceMenuSectionItem extends StatelessWidget {
  final SurveyWorkspaceSection section;
  final bool selected;
  final SurveyWorkspaceSectionBadge? badge;
  final VoidCallback onTap;

  const _WorkspaceMenuSectionItem({
    required this.section,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _WorkspaceMenuItem(
      icon: surveyWorkspaceSectionIcon(section, selected: selected),
      label: section.label,
      subtitle: surveyWorkspaceSectionDescription(section),
      badge: badge,
      selected: selected,
      onTap: onTap,
    );
  }
}

class _WorkspaceMenuShortcutItem extends StatelessWidget {
  final SurveyWorkspaceShortcut shortcut;

  const _WorkspaceMenuShortcutItem({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    return _WorkspaceMenuItem(
      icon: shortcut.icon,
      label: shortcut.label,
      subtitle: shortcut.subtitle,
      enabled: shortcut.onPressed != null,
      onTap: shortcut.onPressed,
    );
  }
}

class _WorkspaceMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final SurveyWorkspaceSectionBadge? badge;
  final VoidCallback? onTap;

  const _WorkspaceMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.selected = false,
    this.enabled = true,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemColor = selected
        ? colorScheme.onPrimaryContainer
        : enabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.55);
    final subtitleColor = selected
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: enabled ? 0.65 : 0.35,
                          ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: itemColor, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: itemColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  _WorkspaceMenuBadge(badge: badge!, selected: selected),
                ],
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onPrimaryContainer,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders a compact module signal for the workspace menu.
class _WorkspaceMenuBadge extends StatelessWidget {
  final SurveyWorkspaceSectionBadge badge;
  final bool selected;

  const _WorkspaceMenuBadge({required this.badge, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = surveyWorkspaceSectionBadgeColor(colorScheme, badge.tone);
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.surface.withValues(alpha: 0.72)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: selected ? 0.38 : 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          badge.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? colorScheme.onSurface : color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );

    final tooltip = badge.tooltip;
    if (tooltip == null || tooltip.isEmpty) {
      return child;
    }

    return Tooltip(message: tooltip, child: child);
  }
}
