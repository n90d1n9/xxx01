import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart'
    show
        TenunProEntrypointProfile,
        TenunProReleaseReadinessAudit,
        TenunProSourceMigrationLayerInfo,
        TenunProSourceMigrationLayerStatus;

import 'registry_health_pro_entrypoint_profiles_panel.dart';

const registryHealthProReadinessRuntimeScanNote =
    'Runtime showcase reports manifest-level readiness; filesystem export leak checks run in tests.';

/// Displays Commercial Pro release readiness status in Registry Health.
class RegistryHealthProReadinessPanel extends StatelessWidget {
  const RegistryHealthProReadinessPanel({
    super.key,
    required this.audit,
    required this.entrypointProfiles,
    this.issueLimit = 6,
    this.entrypointLimit = 3,
  });

  final TenunProReleaseReadinessAudit audit;
  final List<TenunProEntrypointProfile> entrypointProfiles;
  final int issueLimit;
  final int entrypointLimit;

  @override
  Widget build(BuildContext context) {
    final issues = registryHealthProReadinessVisibleIssues(
      audit,
      limit: issueLimit,
    );
    final nextBatch = audit.migrationReadiness.nextImplementationBatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(
                registryHealthProReadinessStatusIcon(audit),
                size: 16,
                color: registryHealthProReadinessStatusColor(audit),
              ),
              label: Text(registryHealthProReadinessStatusLabel(audit)),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                registryHealthProReadinessBooleanLabel(
                  'Manifest',
                  audit.manifestValidation.isValid,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                registryHealthProReadinessBooleanLabel(
                  'Adapters',
                  audit.migrationReadiness.areAdaptersComplete,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                registryHealthProReadinessBooleanLabel(
                  'Implementation',
                  audit.isImplementationMigrationComplete,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          registryHealthProReadinessSummary(audit),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Text(
          registryHealthProReadinessRuntimeScanNote,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        _RegistryHealthProReadinessLayerRows(
          layers: audit.migrationReadiness.layerStatuses,
        ),
        const SizedBox(height: 10),
        RegistryHealthProEntrypointProfilesPanel(
          profiles: entrypointProfiles,
          visibleLimit: entrypointLimit,
        ),
        if (nextBatch != null) ...[
          const SizedBox(height: 10),
          Text(
            registryHealthProReadinessNextBatchLabel(audit),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (issues.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...issues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      issue,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (audit.strictReleaseIssues.length > issues.length)
            Text(
              '+${audit.strictReleaseIssues.length - issues.length} more',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ],
    );
  }
}

String registryHealthProReadinessStatusLabel(
  TenunProReleaseReadinessAudit audit,
) {
  if (audit.isReadyForStrictCorePackageRelease) {
    return 'Manifest Ready';
  }
  if (audit.isReadyForRelease) {
    return 'Release Ready';
  }
  if (audit.isReadyForImplementationMigration) {
    return 'Migration Ready';
  }
  return 'Blocked';
}

IconData registryHealthProReadinessStatusIcon(
  TenunProReleaseReadinessAudit audit,
) {
  if (audit.isReadyForRelease) {
    return Icons.verified_outlined;
  }
  if (audit.isReadyForImplementationMigration) {
    return Icons.route_outlined;
  }
  return Icons.error_outline;
}

Color registryHealthProReadinessStatusColor(
  TenunProReleaseReadinessAudit audit,
) {
  if (audit.isReadyForStrictCorePackageRelease) {
    return Colors.green.shade700;
  }
  if (audit.isReadyForRelease || audit.isReadyForImplementationMigration) {
    return Colors.orange.shade800;
  }
  return Colors.red.shade700;
}

String registryHealthProReadinessSummary(TenunProReleaseReadinessAudit audit) {
  if (audit.isReadyForStrictCorePackageRelease) {
    return 'Pro manifest, package boundary, adapters, and implementation migration are ready.';
  }
  if (audit.isReadyForRelease) {
    return 'Pro is release-ready, but strict core package release still needs legacy compatibility review.';
  }
  if (audit.isReadyForImplementationMigration) {
    return 'Pro adapters are clean; implementation migration can continue.';
  }

  return '${audit.strictReleaseIssues.length} Pro readiness '
      '${audit.strictReleaseIssues.length == 1 ? 'issue' : 'issues'} need review.';
}

String registryHealthProReadinessBooleanLabel(String label, bool value) {
  return '$label: ${value ? 'Ready' : 'Review'}';
}

String registryHealthProReadinessLayerLabel(
  TenunProSourceMigrationLayerStatus layer,
) {
  return '${layer.layer.label}: ${layer.completedCount}/${layer.totalCount} sections';
}

String registryHealthProReadinessNextBatchLabel(
  TenunProReleaseReadinessAudit audit,
) {
  final batch = audit.migrationReadiness.nextImplementationBatch;
  if (batch == null) {
    return 'Next implementation batch: none';
  }

  return 'Next implementation batch: phase ${batch.phase} - '
      '${batch.sectionLabels.join(', ')}';
}

List<String> registryHealthProReadinessVisibleIssues(
  TenunProReleaseReadinessAudit audit, {
  int limit = 6,
}) {
  if (limit <= 0) {
    return const <String>[];
  }
  return List.unmodifiable(audit.strictReleaseIssues.take(limit));
}

Map<String, dynamic> registryHealthProReadinessJson(
  TenunProReleaseReadinessAudit audit, {
  required List<TenunProEntrypointProfile> entrypointProfiles,
}) {
  return {
    ...audit.toJson(),
    'status': registryHealthProReadinessStatusLabel(
      audit,
    ).toLowerCase().replaceAll(' ', '_'),
    'statusLabel': registryHealthProReadinessStatusLabel(audit),
    'summary': registryHealthProReadinessSummary(audit),
    'strictReleaseIssueCount': audit.strictReleaseIssues.length,
    'runtimeScanNote': registryHealthProReadinessRuntimeScanNote,
    'nextImplementationBatchLabel': registryHealthProReadinessNextBatchLabel(
      audit,
    ),
    'layerLabels': [
      for (final layer in audit.migrationReadiness.layerStatuses)
        registryHealthProReadinessLayerLabel(layer),
    ],
    'entrypoints': registryHealthProEntrypointProfilesJson(entrypointProfiles),
  };
}

/// Renders migration layer completion chips for the Pro readiness panel.
class _RegistryHealthProReadinessLayerRows extends StatelessWidget {
  const _RegistryHealthProReadinessLayerRows({required this.layers});

  final List<TenunProSourceMigrationLayerStatus> layers;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final layer in layers)
          Chip(
            label: Text(registryHealthProReadinessLayerLabel(layer)),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
