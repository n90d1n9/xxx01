import 'package:flutter/material.dart';

import '../utils/billing_product_package_release_bundle.dart';

class BillingProductPackageReleaseBundleGrid extends StatelessWidget {
  final BillingProductPackageReleaseBundleCatalog catalog;

  const BillingProductPackageReleaseBundleGrid({
    super.key,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        final itemWidth =
            isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              catalog.bundles
                  .map(
                    (bundle) => SizedBox(
                      width: itemWidth,
                      child: BillingProductPackageReleaseBundleCard(
                        bundle: bundle,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductPackageReleaseBundleCard extends StatelessWidget {
  final BillingProductPackageReleaseBundle bundle;

  const BillingProductPackageReleaseBundleCard({
    super.key,
    required this.bundle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BundleIcon(state: bundle.state),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bundle.manifestCount} manifests - ${bundle.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BillingProductPackageReleaseBundleStateBadge(bundle: bundle),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            bundle.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _BundleReleaseKeys(bundle: bundle),
          const SizedBox(height: 12),
          _BundleActionBlock(bundle: bundle),
        ],
      ),
    );
  }
}

class BillingProductPackageReleaseBundleStateBadge extends StatelessWidget {
  final BillingProductPackageReleaseBundle bundle;

  const BillingProductPackageReleaseBundleStateBadge({
    super.key,
    required this.bundle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _stateColors(bundle.state);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          bundle.stateLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.foreground,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BundleIcon extends StatelessWidget {
  final BillingProductPackageReleaseBundleState state;

  const _BundleIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = _stateColors(state);
    final icon = switch (state) {
      BillingProductPackageReleaseBundleState.publishNow =>
        Icons.publish_outlined,
      BillingProductPackageReleaseBundleState.review =>
        Icons.fact_check_outlined,
      BillingProductPackageReleaseBundleState.blocked => Icons.report_outlined,
    };

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: colors.foreground, size: 21),
    );
  }
}

class _BundleReleaseKeys extends StatelessWidget {
  final BillingProductPackageReleaseBundle bundle;

  const _BundleReleaseKeys({required this.bundle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          bundle.releaseKeys
              .take(3)
              .map((key) => _ReleaseKeyChip(label: key))
              .toList(),
    );
  }
}

class _ReleaseKeyChip extends StatelessWidget {
  final String label;

  const _ReleaseKeyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BundleActionBlock extends StatelessWidget {
  final BillingProductPackageReleaseBundle bundle;

  const _BundleActionBlock({required this.bundle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_forward_outlined,
            size: 17,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bundle.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bundle.actionDetail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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

class _StateColors {
  final Color foreground;
  final Color background;
  final Color border;

  const _StateColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}

_StateColors _stateColors(BillingProductPackageReleaseBundleState state) {
  return switch (state) {
    BillingProductPackageReleaseBundleState.publishNow => const _StateColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    ),
    BillingProductPackageReleaseBundleState.review => const _StateColors(
      foreground: Color(0xFFB45309),
      background: Color(0xFFFEF3C7),
      border: Color(0xFFFDE68A),
    ),
    BillingProductPackageReleaseBundleState.blocked => const _StateColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    ),
  };
}
