import 'package:flutter/material.dart';

import '../utils/billing_product_package_release_manifest.dart';

class BillingProductPackageReleaseManifestGrid extends StatelessWidget {
  final BillingProductPackageReleaseManifestCatalog catalog;

  const BillingProductPackageReleaseManifestGrid({
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
              catalog.manifests
                  .map(
                    (manifest) => SizedBox(
                      width: itemWidth,
                      child: BillingProductPackageReleaseManifestCard(
                        manifest: manifest,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

class BillingProductPackageReleaseManifestCard extends StatelessWidget {
  final BillingProductPackageReleaseManifest manifest;

  const BillingProductPackageReleaseManifestCard({
    super.key,
    required this.manifest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 242),
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
              _ManifestIcon(state: manifest.state),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manifest.packageLabel,
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
                      manifest.releaseKey,
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
              BillingProductPackageReleaseStateBadge(manifest: manifest),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            manifest.description,
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
          _ManifestScopeRow(manifest: manifest),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                manifest.requiredSignalLabels
                    .map((label) => _SignalChip(label: label))
                    .toList(),
          ),
          const SizedBox(height: 12),
          _ManifestActionBlock(manifest: manifest),
        ],
      ),
    );
  }
}

class BillingProductPackageReleaseStateBadge extends StatelessWidget {
  final BillingProductPackageReleaseManifest manifest;

  const BillingProductPackageReleaseStateBadge({
    super.key,
    required this.manifest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _stateColors(manifest.state);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          manifest.stateLabel,
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

class _ManifestIcon extends StatelessWidget {
  final BillingProductPackageReleaseState state;

  const _ManifestIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = _stateColors(state);
    final icon = switch (state) {
      BillingProductPackageReleaseState.releaseReady =>
        Icons.assignment_turned_in_outlined,
      BillingProductPackageReleaseState.needsHardening =>
        Icons.build_circle_outlined,
      BillingProductPackageReleaseState.blocked => Icons.report_outlined,
      BillingProductPackageReleaseState.needsFit => Icons.rule_folder_outlined,
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

class _ManifestScopeRow extends StatelessWidget {
  final BillingProductPackageReleaseManifest manifest;

  const _ManifestScopeRow({required this.manifest});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.hub_outlined, color: Color(0xFF64748B), size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '${manifest.domainLabel} - ${manifest.channelLabel}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignalChip extends StatelessWidget {
  final String label;

  const _SignalChip({required this.label});

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

class _ManifestActionBlock extends StatelessWidget {
  final BillingProductPackageReleaseManifest manifest;

  const _ManifestActionBlock({required this.manifest});

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
                  manifest.stageLabel,
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
                  manifest.primaryActionDetail,
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

_StateColors _stateColors(BillingProductPackageReleaseState state) {
  return switch (state) {
    BillingProductPackageReleaseState.releaseReady => const _StateColors(
      foreground: Color(0xFF047857),
      background: Color(0xFFD1FAE5),
      border: Color(0xFFA7F3D0),
    ),
    BillingProductPackageReleaseState.needsHardening => const _StateColors(
      foreground: Color(0xFFB45309),
      background: Color(0xFFFEF3C7),
      border: Color(0xFFFDE68A),
    ),
    BillingProductPackageReleaseState.blocked => const _StateColors(
      foreground: Color(0xFFB91C1C),
      background: Color(0xFFFEE2E2),
      border: Color(0xFFFECACA),
    ),
    BillingProductPackageReleaseState.needsFit => const _StateColors(
      foreground: Color(0xFF475569),
      background: Color(0xFFF1F5F9),
      border: Color(0xFFCBD5E1),
    ),
  };
}
