import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/experience_profile.dart';
import '../models/experience_profile_readiness.dart';

/// Readiness dashboard for product experience profile routing coverage.
class ProductExperienceProfileReadinessPanel extends StatelessWidget {
  const ProductExperienceProfileReadinessPanel({
    super.key,
    required this.readiness,
    this.maxVisibleProfiles = 8,
    this.onProfileSelected,
    this.onReviewProfiles,
  });

  final ProductExperienceProfileRegistryReadiness readiness;
  final int maxVisibleProfiles;
  final ValueChanged<ProductExperienceProfileReadiness>? onProfileSelected;
  final VoidCallback? onReviewProfiles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _registryAccent(colorScheme, readiness);
    final profileCount = readiness.profiles.length;
    final visibleProfileCount = maxVisibleProfiles < 0 ? 0 : maxVisibleProfiles;

    return AppContentPanel(
      title: 'Experience profiles',
      subtitle: 'Reusable product workspaces and destination coverage',
      leadingIcon: Icons.view_quilt_rounded,
      trailing: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label: readiness.statusLabel,
            color: accent,
            icon: _registryIcon(readiness),
            maxWidth: 148,
          ),
          AppStatusPill(
            label:
                '$profileCount ${profileCount == 1 ? 'profile' : 'profiles'}',
            color: colorScheme.primary,
            icon: Icons.layers_rounded,
            maxWidth: 124,
          ),
        ],
      ),
      child:
          readiness.isEmpty
              ? const _EmptyProfileReadiness()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileReadinessSummary(readiness: readiness),
                  const SizedBox(height: 14),
                  _ProfileReadinessGrid(
                    profiles:
                        readiness.profiles.take(visibleProfileCount).toList(),
                    onProfileSelected: onProfileSelected,
                  ),
                  if (readiness.profiles.length > visibleProfileCount) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${readiness.profiles.length - visibleProfileCount} more profiles available in the registry.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (onReviewProfiles != null) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppActionButton(
                        label: 'Review profile setup',
                        icon: Icons.arrow_forward_rounded,
                        variant: AppActionButtonVariant.secondary,
                        onPressed: onReviewProfiles,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Product experience profile readiness')
Widget productExperienceProfileReadinessPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductExperienceProfileReadinessPanel(
          readiness: assessProductExperienceProfileRegistryReadiness(
            defaultProductExperienceProfileRegistry,
          ),
          onProfileSelected: (_) {},
          onReviewProfiles: () {},
        ),
      ),
    ),
  );
}

/// Summary metrics for overall experience profile readiness.
class _ProfileReadinessSummary extends StatelessWidget {
  const _ProfileReadinessSummary({required this.readiness});

  final ProductExperienceProfileRegistryReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readyProfileCount =
        readiness.profiles
            .where(
              (profile) =>
                  profile.level == ProductExperienceProfileReadinessLevel.ready,
            )
            .length;
    final resolvedDestinationCount = readiness.profiles.fold<int>(
      0,
      (total, profile) => total + profile.resolvedDestinationCount,
    );
    final expectedDestinationCount = readiness.profiles.fold<int>(
      0,
      (total, profile) => total + profile.expectedDestinationCount,
    );
    final blockerCount = readiness.profiles.fold<int>(
      0,
      (total, profile) => total + profile.blockingIssues.length,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 760
                ? 3
                : constraints.maxWidth >= 500
                ? 2
                : 1;
        const gap = 10.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: itemWidth,
              child: _ProfileReadinessMetric(
                icon: Icons.task_alt_rounded,
                label: 'Ready profiles',
                value: '$readyProfileCount/${readiness.profiles.length}',
                detail: readiness.statusLabel,
                accent: _registryAccent(colorScheme, readiness),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _ProfileReadinessMetric(
                icon: Icons.route_rounded,
                label: 'Destination coverage',
                value: '$resolvedDestinationCount/$expectedDestinationCount',
                detail: 'registered destinations',
                accent: colorScheme.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _ProfileReadinessMetric(
                icon: Icons.report_problem_rounded,
                label: 'Blocking issues',
                value: '$blockerCount',
                detail:
                    blockerCount == 0
                        ? 'no blocking profile gaps'
                        : 'profile gaps need setup',
                accent:
                    blockerCount == 0
                        ? Colors.green.shade700
                        : colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Compact readiness statistic used by the profile readiness panel.
class _ProfileReadinessMetric extends StatelessWidget {
  const _ProfileReadinessMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Responsive grid for experience profile readiness tiles.
class _ProfileReadinessGrid extends StatelessWidget {
  const _ProfileReadinessGrid({
    required this.profiles,
    required this.onProfileSelected,
  });

  final List<ProductExperienceProfileReadiness> profiles;
  final ValueChanged<ProductExperienceProfileReadiness>? onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 980
                ? 4
                : constraints.maxWidth >= 700
                ? 3
                : constraints.maxWidth >= 460
                ? 2
                : 1;
        const gap = 10.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final profile in profiles)
              SizedBox(
                width: itemWidth,
                child: _ProfileReadinessTile(
                  readiness: profile,
                  onSelected:
                      onProfileSelected == null
                          ? null
                          : () => onProfileSelected!(profile),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Clickable experience profile readiness card.
class _ProfileReadinessTile extends StatelessWidget {
  const _ProfileReadinessTile({required this.readiness, this.onSelected});

  final ProductExperienceProfileReadiness readiness;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _levelAccent(colorScheme, readiness.level);
    final radius = BorderRadius.circular(8);
    final child = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    _profileIcon(readiness.profile.id),
                    color: accent,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileTitle(readiness.profile),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileSubtitle(readiness.profile),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              AppStatusPill(
                label: readiness.statusLabel,
                color: accent,
                icon: _levelIcon(readiness.level),
                maxWidth: 112,
              ),
              AppStatusPill(
                label: readiness.destinationCoverageLabel,
                color: colorScheme.primary,
                showDot: true,
                maxWidth: 154,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _profileIssueLabel(readiness),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  readiness.hasIssues ? accent : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onSelected != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new_rounded, size: 15, color: accent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Open workspace',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.05),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
          borderRadius: radius,
        ),
        child: InkWell(borderRadius: radius, onTap: onSelected, child: child),
      ),
    );
  }
}

/// Empty state shown when no product experience profiles are registered.
class _EmptyProfileReadiness extends StatelessWidget {
  const _EmptyProfileReadiness();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.layers_clear_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No product experience profiles are registered yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _profileTitle(ProductExperienceProfile profile) {
  final title = profile.workspaceTitle.trim();
  if (title.isNotEmpty) return title;

  return profile.id.value;
}

String _profileSubtitle(ProductExperienceProfile profile) {
  final subtitle = profile.workspaceSubtitle.trim();
  if (subtitle.isNotEmpty) return subtitle;

  return 'No workspace subtitle set';
}

String _profileIssueLabel(ProductExperienceProfileReadiness readiness) {
  if (readiness.issues.isEmpty) {
    return 'Routes and metadata ready';
  }

  final blockingCount = readiness.blockingIssues.length;
  final warningCount = readiness.warningIssues.length;
  var leadIssue = readiness.issues.first;
  for (final issue in readiness.issues) {
    if (issue.isBlocking) {
      leadIssue = issue;
      break;
    }
  }

  if (blockingCount > 0 && warningCount > 0) {
    return '$blockingCount blockers, $warningCount warnings: ${leadIssue.message}';
  }
  if (blockingCount > 0) {
    return '$blockingCount blockers: ${leadIssue.message}';
  }

  return '$warningCount warnings: ${leadIssue.message}';
}

IconData _registryIcon(ProductExperienceProfileRegistryReadiness readiness) {
  if (readiness.blockedProfileCount > 0) {
    return Icons.priority_high_rounded;
  }
  if (readiness.warningProfileCount > 0) {
    return Icons.trending_up_rounded;
  }

  return Icons.check_rounded;
}

IconData _levelIcon(ProductExperienceProfileReadinessLevel level) {
  switch (level) {
    case ProductExperienceProfileReadinessLevel.blocked:
      return Icons.priority_high_rounded;
    case ProductExperienceProfileReadinessLevel.warning:
      return Icons.trending_up_rounded;
    case ProductExperienceProfileReadinessLevel.ready:
      return Icons.check_rounded;
  }
}

IconData _profileIcon(ProductExperienceProfileId id) {
  if (id == ProductExperienceProfileId.freshGoods) {
    return Icons.eco_rounded;
  }
  if (id == ProductExperienceProfileId.omnichannelCommerce) {
    return Icons.hub_rounded;
  }
  if (id == ProductExperienceProfileId.stockControl) {
    return Icons.inventory_2_rounded;
  }
  if (id == ProductExperienceProfileId.setupContracts) {
    return Icons.account_tree_rounded;
  }
  if (id == ProductExperienceProfileId.catalogOperations) {
    return Icons.category_rounded;
  }
  if (id == ProductExperienceProfileId.coreOperations) {
    return Icons.dashboard_customize_rounded;
  }

  return Icons.apps_rounded;
}

Color _registryAccent(
  ColorScheme colorScheme,
  ProductExperienceProfileRegistryReadiness readiness,
) {
  if (readiness.blockedProfileCount > 0) return colorScheme.error;
  if (readiness.warningProfileCount > 0) return Colors.orange.shade700;

  return Colors.green.shade700;
}

Color _levelAccent(
  ColorScheme colorScheme,
  ProductExperienceProfileReadinessLevel level,
) {
  switch (level) {
    case ProductExperienceProfileReadinessLevel.blocked:
      return colorScheme.error;
    case ProductExperienceProfileReadinessLevel.warning:
      return Colors.orange.shade700;
    case ProductExperienceProfileReadinessLevel.ready:
      return Colors.green.shade700;
  }
}
