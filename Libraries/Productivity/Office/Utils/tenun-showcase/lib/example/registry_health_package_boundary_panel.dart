import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' as tenun;
import 'package:tenun_pro/tenun_pro.dart' show TenunPackageBoundaryAudit;

/// Displays core/pro package split health in Registry Health.
class RegistryHealthPackageBoundaryPanel extends StatelessWidget {
  const RegistryHealthPackageBoundaryPanel({
    super.key,
    required this.audit,
    this.issueLimit = 6,
  });

  final TenunPackageBoundaryAudit audit;
  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final issues = registryHealthPackageBoundaryVisibleIssues(
      audit,
      limit: issueLimit,
    );
    final manifestLabel = registryHealthPackageBoundaryManifestLabel(audit);
    final manifestSectionsLabel =
        registryHealthPackageBoundaryManifestSectionsLabel(audit);
    final coreOwnershipLabel = registryHealthPackageBoundaryTypePreviewLabel(
      'Core owns',
      audit.coreTypes,
    );
    final proOwnershipLabel = registryHealthPackageBoundaryTypePreviewLabel(
      'Pro owns',
      audit.proTypes,
    );
    final proSectionOwnershipLabels =
        registryHealthPackageBoundarySectionOwnershipLabels(audit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: Icon(
                audit.isClean
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                size: 16,
                color: registryHealthPackageBoundaryStatusColor(audit),
              ),
              label: Text(registryHealthPackageBoundaryStatusLabel(audit)),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                registryHealthPackageBoundaryCountLabel(
                  'Core',
                  audit.coreTypes.length,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                registryHealthPackageBoundaryCountLabel(
                  'Pro',
                  audit.proTypes.length,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: Text(
                registryHealthPackageBoundaryCountLabel(
                  'Overlap',
                  audit.overlappingTypes.length,
                ),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (manifestLabel != null || manifestSectionsLabel != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (manifestLabel != null)
                Chip(
                  avatar: const Icon(Icons.account_tree_outlined, size: 16),
                  label: Text(manifestLabel),
                  visualDensity: VisualDensity.compact,
                ),
              if (manifestSectionsLabel != null)
                Chip(
                  label: Text(manifestSectionsLabel),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
        if (coreOwnershipLabel != null || proOwnershipLabel != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (coreOwnershipLabel != null)
                Chip(
                  label: Text(coreOwnershipLabel),
                  visualDensity: VisualDensity.compact,
                ),
              if (proOwnershipLabel != null)
                Chip(
                  label: Text(proOwnershipLabel),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
        if (proSectionOwnershipLabels.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in proSectionOwnershipLabels)
                Chip(label: Text(label), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          registryHealthPackageBoundarySummary(audit),
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
          if (audit.issues.length > issues.length)
            Text(
              '+${audit.issues.length - issues.length} more',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ],
    );
  }
}

String registryHealthPackageBoundaryStatusLabel(
  TenunPackageBoundaryAudit audit,
) {
  return audit.isClean ? 'Clean' : 'Issues';
}

Color registryHealthPackageBoundaryStatusColor(
  TenunPackageBoundaryAudit audit,
) {
  return audit.isClean ? Colors.green.shade700 : Colors.red.shade700;
}

String registryHealthPackageBoundarySummary(TenunPackageBoundaryAudit audit) {
  if (audit.isClean) {
    return 'Apache core and Commercial Pro chart types are separated with no catalog overlap.';
  }

  return '${audit.issues.length} package boundary '
      '${audit.issues.length == 1 ? 'issue' : 'issues'} need review.';
}

String registryHealthPackageBoundaryCountLabel(String label, int count) {
  return '$label: $count ${count == 1 ? 'type' : 'types'}';
}

String? registryHealthPackageBoundaryManifestLabel(
  TenunPackageBoundaryAudit audit,
) {
  final manifest = audit.manifest;
  if (manifest == null) {
    return null;
  }

  final corePackage = _emptyToNull(manifest.apacheCorePackage);
  final proPackage = _emptyToNull(manifest.commercialProPackage);

  if (corePackage == null && proPackage == null) {
    return null;
  }

  if (corePackage == null) {
    return 'Manifest: $proPackage';
  }

  if (proPackage == null) {
    return 'Manifest: $corePackage';
  }

  return 'Manifest: $corePackage -> $proPackage';
}

String? registryHealthPackageBoundaryManifestSectionsLabel(
  TenunPackageBoundaryAudit audit, {
  int visibleLimit = 4,
}) {
  final sections = registryHealthPackageBoundaryManifestSectionIds(audit);
  if (sections.isEmpty || visibleLimit <= 0) {
    return null;
  }

  final visibleSections = sections.take(visibleLimit).toList(growable: false);
  final hiddenCount = sections.length - visibleSections.length;
  final suffix = hiddenCount <= 0 ? '' : ' +$hiddenCount';

  return 'Pro sections: ${visibleSections.join(', ')}$suffix';
}

List<String> registryHealthPackageBoundaryManifestSectionIds(
  TenunPackageBoundaryAudit audit,
) {
  final manifest = audit.manifest;
  if (manifest == null) {
    return const <String>[];
  }

  final sections = <String>[];
  final seen = <String>{};

  for (final rawSection in manifest.commercialProSectionIds) {
    final section = rawSection.trim();
    if (section.isEmpty || !seen.add(section)) {
      continue;
    }
    sections.add(section);
  }

  return List.unmodifiable(sections);
}

/// Presentation model for one Commercial Pro section ownership preview.
class RegistryHealthPackageBoundarySectionOwnership {
  const RegistryHealthPackageBoundarySectionOwnership({
    required this.id,
    required this.label,
    required this.chartTypes,
    this.entitlement,
  });

  final String id;
  final String label;
  final List<String> chartTypes;
  final String? entitlement;

  int get chartCount => chartTypes.length;

  String? previewLabel({int visibleLimit = 2}) {
    return _typePreviewLabel(label, chartTypes, visibleLimit: visibleLimit);
  }

  Map<String, dynamic> toJson({int previewLimit = 2}) {
    final preview = previewLabel(visibleLimit: previewLimit);
    return {
      'id': id,
      'label': label,
      if (entitlement != null) 'entitlement': entitlement,
      'count': chartCount,
      'types': chartTypes,
      if (preview != null) 'previewLabel': preview,
    };
  }
}

List<RegistryHealthPackageBoundarySectionOwnership>
registryHealthPackageBoundarySectionOwnerships(
  TenunPackageBoundaryAudit audit,
) {
  final manifest = audit.manifest;
  if (manifest == null) {
    return const <RegistryHealthPackageBoundarySectionOwnership>[];
  }

  final sections = <RegistryHealthPackageBoundarySectionOwnership>[];
  final seen = <String>{};

  for (final rawSection in manifest.commercialProSections) {
    final id = _emptyToNull(rawSection.id);
    if (id == null || !seen.add(id)) {
      continue;
    }

    final label = _emptyToNull(rawSection.label) ?? id;
    final chartTypes = _uniqueSortedStrings(rawSection.chartTypes);

    sections.add(
      RegistryHealthPackageBoundarySectionOwnership(
        id: id,
        label: label,
        entitlement: _emptyToNull(rawSection.entitlement),
        chartTypes: chartTypes,
      ),
    );
  }

  return List.unmodifiable(sections);
}

List<String> registryHealthPackageBoundarySectionOwnershipLabels(
  TenunPackageBoundaryAudit audit, {
  int visibleLimit = 3,
  int typeLimit = 2,
}) {
  if (visibleLimit <= 0) {
    return const <String>[];
  }

  return List.unmodifiable([
    for (final section in registryHealthPackageBoundarySectionOwnerships(
      audit,
    ).take(visibleLimit))
      if (section.previewLabel(visibleLimit: typeLimit) != null)
        section.previewLabel(visibleLimit: typeLimit)!,
  ]);
}

String? registryHealthPackageBoundaryTypePreviewLabel(
  String label,
  Iterable<tenun.ChartType> types, {
  int visibleLimit = 4,
}) {
  final names = registryHealthPackageBoundaryTypeNames(types);
  return _typePreviewLabel(label, names, visibleLimit: visibleLimit);
}

Map<String, dynamic> registryHealthPackageBoundaryOwnershipJson(
  TenunPackageBoundaryAudit audit, {
  int previewLimit = 4,
}) {
  return {
    'core': _ownershipGroupJson(
      'Core owns',
      audit.coreTypes,
      previewLimit: previewLimit,
    ),
    'pro': _ownershipGroupJson(
      'Pro owns',
      audit.proTypes,
      previewLimit: previewLimit,
    ),
    'overlap': _ownershipGroupJson(
      'Overlap',
      audit.overlappingTypes,
      previewLimit: previewLimit,
    ),
    'proSections': [
      for (final section in registryHealthPackageBoundarySectionOwnerships(
        audit,
      ))
        section.toJson(previewLimit: previewLimit),
    ],
  };
}

String? _typePreviewLabel(
  String label,
  List<String> names, {
  required int visibleLimit,
}) {
  if (names.isEmpty || visibleLimit <= 0) {
    return null;
  }

  final visibleNames = names.take(visibleLimit).toList(growable: false);
  final hiddenCount = names.length - visibleNames.length;
  final suffix = hiddenCount <= 0 ? '' : ' +$hiddenCount';

  return '$label: ${visibleNames.join(', ')}$suffix';
}

Map<String, dynamic> _ownershipGroupJson(
  String label,
  Iterable<tenun.ChartType> types, {
  required int previewLimit,
}) {
  final names = registryHealthPackageBoundaryTypeNames(types);
  final previewLabel = _typePreviewLabel(
    label,
    names,
    visibleLimit: previewLimit,
  );

  return {
    'count': names.length,
    'types': names,
    if (previewLabel != null) 'previewLabel': previewLabel,
  };
}

List<String> registryHealthPackageBoundaryTypeNames(
  Iterable<tenun.ChartType> types,
) {
  return _chartTypeStrings(types);
}

List<String> registryHealthPackageBoundaryVisibleIssues(
  TenunPackageBoundaryAudit audit, {
  int limit = 6,
}) {
  if (limit <= 0) {
    return const <String>[];
  }
  return List.unmodifiable(audit.issues.take(limit));
}

Map<String, dynamic> registryHealthPackageBoundaryJson(
  TenunPackageBoundaryAudit audit,
) {
  return {
    ...audit.toJson(),
    'status': registryHealthPackageBoundaryStatusLabel(audit).toLowerCase(),
    'summary': registryHealthPackageBoundarySummary(audit),
    'coreTypes': _chartTypeStrings(audit.coreTypes),
    'proTypes': _chartTypeStrings(audit.proTypes),
    'ownership': registryHealthPackageBoundaryOwnershipJson(audit),
  };
}

List<String> _chartTypeStrings(Iterable<tenun.ChartType> types) {
  final out = [for (final type in types) tenun.chartTypeToString(type)]..sort();
  return List.unmodifiable(out);
}

String? _emptyToNull(String raw) {
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

List<String> _uniqueSortedStrings(Iterable<String> raw) {
  final out = <String>[];
  final seen = <String>{};
  for (final item in raw) {
    final value = _emptyToNull(item);
    if (value == null || !seen.add(value)) {
      continue;
    }
    out.add(value);
  }

  out.sort();
  return List.unmodifiable(out);
}
