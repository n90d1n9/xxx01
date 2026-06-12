import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/holiday_release_package_models.dart';

class HolidayReleasePackagePanel extends StatelessWidget {
  final HolidayReleasePackage package;

  const HolidayReleasePackagePanel({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.inventory_2_outlined,
      title: 'Release package',
      subtitle: package.packageId,
      children: [
        _ReleasePackageSummary(package: package),
        for (final item in package.evidence) _ReleaseEvidenceTile(item: item),
      ],
    );
  }
}

class _ReleasePackageSummary extends StatelessWidget {
  final HolidayReleasePackage package;

  const _ReleasePackageSummary({required this.package});

  @override
  Widget build(BuildContext context) {
    final color = _packageStatusColor(package.status);

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final headline = SizedBox(
            width: constraints.maxWidth < 840 ? double.infinity : 300,
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${package.packageScore}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.status.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        package.releaseWindow,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          final stats = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReleasePackageStat(
                icon: Icons.block_outlined,
                label: 'Blocked',
                value: '${package.blockedCount}',
              ),
              _ReleasePackageStat(
                icon: Icons.rate_review_outlined,
                label: 'Review',
                value: '${package.attentionCount}',
              ),
              _ReleasePackageStat(
                icon: Icons.verified_outlined,
                label: 'Complete',
                value: '${package.completeCount}',
              ),
              _ReleasePackageStat(
                icon: Icons.fact_check_outlined,
                label: 'Evidence',
                value: '${package.evidenceCount}',
              ),
            ],
          );

          final nextAction = _ReleaseNextAction(package: package);

          if (constraints.maxWidth < 840) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headline,
                const SizedBox(height: 14),
                stats,
                const SizedBox(height: 12),
                nextAction,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headline,
              const SizedBox(width: 20),
              Expanded(child: stats),
              const SizedBox(width: 20),
              Expanded(child: nextAction),
            ],
          );
        },
      ),
    );
  }
}

class _ReleaseNextAction extends StatelessWidget {
  final HolidayReleasePackage package;

  const _ReleaseNextAction({required this.package});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.flag_circle_outlined,
          color: HrisColors.primary,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Package action',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HrisColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                package.nextAction,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReleasePackageStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReleasePackageStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: HrisColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReleaseEvidenceTile extends StatelessWidget {
  final HolidayReleaseEvidenceItem item;

  const _ReleaseEvidenceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _evidenceStatusColor(item.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _evidenceStatusIcon(item.status),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          item.owner,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final status = HrisStatusPill(
                label: item.status.label,
                color: color,
              );

              if (constraints.maxWidth < 680) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [heading, const SizedBox(height: 10), status],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  status,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            item.detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.action,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

Color _packageStatusColor(HolidayReleasePackageStatus status) {
  return switch (status) {
    HolidayReleasePackageStatus.blocked => Colors.red.shade700,
    HolidayReleasePackageStatus.assembling => Colors.orange.shade700,
    HolidayReleasePackageStatus.ready => Colors.green.shade700,
  };
}

Color _evidenceStatusColor(HolidayReleaseEvidenceStatus status) {
  return switch (status) {
    HolidayReleaseEvidenceStatus.blocked => Colors.red.shade700,
    HolidayReleaseEvidenceStatus.attention => Colors.orange.shade700,
    HolidayReleaseEvidenceStatus.complete => Colors.green.shade700,
  };
}

IconData _evidenceStatusIcon(HolidayReleaseEvidenceStatus status) {
  return switch (status) {
    HolidayReleaseEvidenceStatus.blocked => Icons.block_outlined,
    HolidayReleaseEvidenceStatus.attention => Icons.rate_review_outlined,
    HolidayReleaseEvidenceStatus.complete => Icons.verified_outlined,
  };
}
