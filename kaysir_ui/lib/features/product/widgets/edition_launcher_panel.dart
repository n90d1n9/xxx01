import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/edition.dart';
import '../models/edition_readiness.dart';
import '../models/experience_profile.dart';
import '../models/experience_profile_launch_target.dart';

typedef ProductEditionLaunchSelection =
    void Function(
      ProductEdition edition,
      ProductExperienceProfileLaunchTarget launchTarget,
    );

/// Launch surface for registered product editions and their setup readiness.
class ProductEditionLauncherPanel extends StatelessWidget {
  const ProductEditionLauncherPanel({
    super.key,
    required this.editions,
    this.experienceProfileRegistry = defaultProductExperienceProfileRegistry,
    this.readiness,
    this.maxVisibleEditions = 8,
    this.onEditionSelected,
  });

  final List<ProductEdition> editions;
  final ProductExperienceProfileRegistry experienceProfileRegistry;
  final ProductEditionRegistryReadiness? readiness;
  final int maxVisibleEditions;
  final ProductEditionLaunchSelection? onEditionSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visibleEditionCount = maxVisibleEditions < 0 ? 0 : maxVisibleEditions;
    final visibleEditions = editions.take(visibleEditionCount).toList();
    final readinessByEditionId = _readinessByEditionId(readiness);

    return AppContentPanel(
      title: 'Product editions',
      subtitle: 'Launch-ready product variants built from reusable modules',
      leadingIcon: Icons.rocket_launch_rounded,
      trailing: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          AppStatusPill(
            label:
                '${editions.length} ${editions.length == 1 ? 'edition' : 'editions'}',
            color: colorScheme.primary,
            icon: Icons.apps_rounded,
            maxWidth: 132,
          ),
          if (readiness != null)
            AppStatusPill(
              label: readiness!.statusLabel,
              color: _registryReadinessColor(colorScheme, readiness!),
              icon: _registryReadinessIcon(readiness!),
              maxWidth: 156,
            ),
          AppStatusPill(
            label: '${_kindCount(editions)} segments',
            color: Colors.teal.shade700,
            icon: Icons.category_rounded,
            maxWidth: 132,
          ),
        ],
      ),
      child:
          editions.isEmpty
              ? const _EmptyEditionLauncher()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EditionSummaryStrip(editions: editions),
                  const SizedBox(height: 14),
                  _EditionGrid(
                    editions: visibleEditions,
                    experienceProfileRegistry: experienceProfileRegistry,
                    readinessByEditionId: readinessByEditionId,
                    onEditionSelected: onEditionSelected,
                  ),
                  if (editions.length > visibleEditionCount) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${editions.length - visibleEditionCount} more editions available in the registry.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

@Preview(name: 'Product edition launcher')
Widget productEditionLauncherPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductEditionLauncherPanel(
          editions: defaultProductEditions,
          readiness: assessProductEditionRegistryReadiness(
            defaultProductEditionRegistry,
          ),
          onEditionSelected: (_, _) {},
        ),
      ),
    ),
  );
}

/// Compact metrics that summarize which product edition families are present.
class _EditionSummaryStrip extends StatelessWidget {
  const _EditionSummaryStrip({required this.editions});

  final List<ProductEdition> editions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final groceryCount =
        editions
            .where((edition) => edition.kind == ProductEditionKind.grocery)
            .length;
    final commerceCount =
        editions
            .where(
              (edition) =>
                  edition.kind == ProductEditionKind.digitalCommerce ||
                  edition.kind == ProductEditionKind.kiosk,
            )
            .length;
    final operationsCount =
        editions
            .where(
              (edition) =>
                  edition.kind == ProductEditionKind.operations ||
                  edition.kind == ProductEditionKind.setup,
            )
            .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 760
                ? 4
                : constraints.maxWidth >= 520
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
              child: _EditionMetric(
                icon: Icons.storefront_rounded,
                label: 'Reusable editions',
                value: '${editions.length}',
                detail: '${_kindCount(editions)} product segments',
                accent: colorScheme.primary,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _EditionMetric(
                icon: Icons.eco_rounded,
                label: 'Fresh goods',
                value: '$groceryCount',
                detail: 'expiry-aware workflows',
                accent: Colors.green.shade700,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _EditionMetric(
                icon: Icons.hub_rounded,
                label: 'Commerce',
                value: '$commerceCount',
                detail: 'online and kiosk launches',
                accent: Colors.indigo.shade600,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _EditionMetric(
                icon: Icons.fact_check_rounded,
                label: 'Operations',
                value: '$operationsCount',
                detail: 'stock, setup, and contracts',
                accent: Colors.blueGrey.shade700,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Small edition summary statistic used by the launcher header area.
class _EditionMetric extends StatelessWidget {
  const _EditionMetric({
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

/// Responsive grid that adapts edition tiles across desktop and mobile widths.
class _EditionGrid extends StatelessWidget {
  const _EditionGrid({
    required this.editions,
    required this.experienceProfileRegistry,
    required this.readinessByEditionId,
    required this.onEditionSelected,
  });

  final List<ProductEdition> editions;
  final ProductExperienceProfileRegistry experienceProfileRegistry;
  final Map<ProductEditionId, ProductEditionReadiness> readinessByEditionId;
  final ProductEditionLaunchSelection? onEditionSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 1040
                ? 4
                : constraints.maxWidth >= 760
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
            for (final edition in editions)
              SizedBox(
                width: itemWidth,
                child: _EditionTile(
                  edition: edition,
                  readiness: readinessByEditionId[edition.id],
                  launchTarget: edition.launchTarget(
                    profileRegistry: experienceProfileRegistry,
                  ),
                  onSelected:
                      onEditionSelected == null
                          ? null
                          : (target) => onEditionSelected!(edition, target),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Clickable product edition card with readiness-aware launch gating.
class _EditionTile extends StatelessWidget {
  const _EditionTile({
    required this.edition,
    required this.readiness,
    required this.launchTarget,
    required this.onSelected,
  });

  final ProductEdition edition;
  final ProductEditionReadiness? readiness;
  final ProductExperienceProfileLaunchTarget launchTarget;
  final ValueChanged<ProductExperienceProfileLaunchTarget>? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _kindColor(colorScheme, edition.kind);
    final readinessAccent =
        readiness == null ? accent : _readinessColor(colorScheme, readiness!);
    final canLaunch =
        onSelected != null &&
        readiness?.level != ProductEditionReadinessLevel.blocked;
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
                  child: Icon(_kindIcon(edition.kind), size: 18, color: accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edition.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      edition.subtitle,
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
                label: edition.kindLabel,
                color: accent,
                icon: _kindIcon(edition.kind),
                maxWidth: 148,
              ),
              AppStatusPill(
                label: launchTarget.modeSourceLabel,
                color: colorScheme.primary,
                showDot: true,
                maxWidth: 132,
              ),
              if (readiness != null)
                AppStatusPill(
                  label: readiness!.statusLabel,
                  color: readinessAccent,
                  icon: _readinessIcon(readiness!),
                  maxWidth: 132,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            edition.capabilitySummaryLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (readiness?.hasIssues ?? false) ...[
            const SizedBox(height: 8),
            Text(
              _editionIssueLabel(readiness!),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: readinessAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            edition.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onSelected != null ||
              readiness?.level == ProductEditionReadinessLevel.blocked) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  canLaunch ? Icons.open_in_new_rounded : Icons.lock_rounded,
                  size: 15,
                  color: canLaunch ? accent : readinessAccent,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    canLaunch
                        ? launchTarget.actionLabel
                        : 'Resolve edition setup',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: canLaunch ? accent : readinessAccent,
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
        child: InkWell(
          key: ValueKey('product-edition-${edition.id.value}'),
          borderRadius: radius,
          onTap: canLaunch ? () => onSelected!(launchTarget) : null,
          child: child,
        ),
      ),
    );
  }
}

/// Empty state shown when no product editions have been registered.
class _EmptyEditionLauncher extends StatelessWidget {
  const _EmptyEditionLauncher();

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
            Icon(Icons.apps_outage_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No product editions are registered yet.',
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

int _kindCount(List<ProductEdition> editions) {
  return editions.map((edition) => edition.kind).toSet().length;
}

Map<ProductEditionId, ProductEditionReadiness> _readinessByEditionId(
  ProductEditionRegistryReadiness? readiness,
) {
  if (readiness == null) return const {};

  return {
    for (final editionReadiness in readiness.editions)
      editionReadiness.edition.id: editionReadiness,
  };
}

String _editionIssueLabel(ProductEditionReadiness readiness) {
  if (!readiness.hasIssues) return 'Ready to launch';

  var leadIssue = readiness.issues.first;
  for (final issue in readiness.issues) {
    if (issue.isBlocking) {
      leadIssue = issue;
      break;
    }
  }

  final blockingCount = readiness.blockingIssues.length;
  final warningCount = readiness.warningIssues.length;
  if (blockingCount > 0 && warningCount > 0) {
    return '$blockingCount blockers, $warningCount warnings: ${leadIssue.message}';
  }
  if (blockingCount > 0) {
    return '$blockingCount blockers: ${leadIssue.message}';
  }

  return '$warningCount warnings: ${leadIssue.message}';
}

IconData _registryReadinessIcon(ProductEditionRegistryReadiness readiness) {
  if (readiness.blockedEditionCount > 0) {
    return Icons.priority_high_rounded;
  }
  if (readiness.warningEditionCount > 0) {
    return Icons.trending_up_rounded;
  }

  return Icons.check_rounded;
}

Color _registryReadinessColor(
  ColorScheme colorScheme,
  ProductEditionRegistryReadiness readiness,
) {
  if (readiness.blockedEditionCount > 0) return colorScheme.error;
  if (readiness.warningEditionCount > 0) return Colors.orange.shade700;

  return Colors.green.shade700;
}

IconData _readinessIcon(ProductEditionReadiness readiness) {
  return switch (readiness.level) {
    ProductEditionReadinessLevel.blocked => Icons.priority_high_rounded,
    ProductEditionReadinessLevel.warning => Icons.trending_up_rounded,
    ProductEditionReadinessLevel.ready => Icons.check_rounded,
  };
}

Color _readinessColor(
  ColorScheme colorScheme,
  ProductEditionReadiness readiness,
) {
  return switch (readiness.level) {
    ProductEditionReadinessLevel.blocked => colorScheme.error,
    ProductEditionReadinessLevel.warning => Colors.orange.shade700,
    ProductEditionReadinessLevel.ready => Colors.green.shade700,
  };
}

IconData _kindIcon(ProductEditionKind kind) {
  return switch (kind) {
    ProductEditionKind.retail => Icons.storefront_rounded,
    ProductEditionKind.grocery => Icons.eco_rounded,
    ProductEditionKind.counterService => Icons.point_of_sale_rounded,
    ProductEditionKind.digitalCommerce => Icons.public_rounded,
    ProductEditionKind.kiosk => Icons.qr_code_scanner_rounded,
    ProductEditionKind.operations => Icons.inventory_2_rounded,
    ProductEditionKind.setup => Icons.fact_check_rounded,
  };
}

Color _kindColor(ColorScheme colorScheme, ProductEditionKind kind) {
  return switch (kind) {
    ProductEditionKind.retail => colorScheme.primary,
    ProductEditionKind.grocery => Colors.green.shade700,
    ProductEditionKind.counterService => Colors.deepOrange.shade600,
    ProductEditionKind.digitalCommerce => Colors.indigo.shade600,
    ProductEditionKind.kiosk => Colors.cyan.shade700,
    ProductEditionKind.operations => Colors.blueGrey.shade700,
    ProductEditionKind.setup => Colors.teal.shade700,
  };
}
