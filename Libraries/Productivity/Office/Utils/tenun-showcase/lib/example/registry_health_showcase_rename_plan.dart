import 'registry_health_showcase_naming.dart';
import 'registry_health_showcase_source_location.dart';
import 'registry_health_showcase_source_map.dart';

enum RegistryHealthShowcaseRenamePlanStatus { clean, ready, blocked }

class RegistryHealthShowcaseRenamePlanItem {
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final String sampleTitle;
  final int? sampleIndex;
  final String jsonPath;
  final String fromType;
  final String toType;
  final RegistryHealthShowcaseNamingStatus status;
  final String reason;

  const RegistryHealthShowcaseRenamePlanItem({
    required this.familyId,
    required this.familyTitle,
    required this.familyIndex,
    required this.sampleTitle,
    required this.sampleIndex,
    required this.jsonPath,
    required this.fromType,
    required this.toType,
    required this.status,
    required this.reason,
  });

  String get targetPath {
    if (familyIndex != null && sampleIndex != null) {
      return 'families[$familyIndex].samples[$sampleIndex].json.$jsonPath';
    }
    return 'families.$familyId.samples.$sampleTitle.json.$jsonPath';
  }

  RegistryHealthShowcaseSourceLocation get sourceLocation {
    return sourceLocationFor();
  }

  RegistryHealthShowcaseSourceLocation sourceLocationFor({
    RegistryHealthShowcaseSourceMap? sourceMap,
  }) {
    if (sourceMap != null) {
      return sourceMap.locationFor(
        familyId: familyId,
        familyTitle: familyTitle,
        familyIndex: familyIndex,
        sampleTitle: sampleTitle,
        sampleIndex: sampleIndex,
        jsonPath: jsonPath,
        chartType: fromType,
      );
    }

    return registryHealthShowcaseFocusedSampleSourceLocation(
      familyId: familyId,
      familyTitle: familyTitle,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      jsonPath: jsonPath,
      chartType: fromType,
    );
  }

  RegistryHealthShowcaseRenamePatchOperation get patchOperation {
    return RegistryHealthShowcaseRenamePatchOperation(
      familyId: familyId,
      familyTitle: familyTitle,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      op: 'replace',
      target: 'showcaseSampleJson',
      field: jsonPath,
      path: targetPath,
      oldValue: fromType,
      value: toType,
    );
  }

  Map<String, dynamic> toJson({RegistryHealthShowcaseSourceMap? sourceMap}) => {
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    'sampleTitle': sampleTitle,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    'jsonPath': jsonPath,
    'targetPath': targetPath,
    'sourceLocation': sourceLocationFor(sourceMap: sourceMap).toJson(),
    'fromType': fromType,
    'toType': toType,
    'status': status.name,
    'reason': reason,
  };
}

class RegistryHealthShowcaseRenamePatchOperation {
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final String sampleTitle;
  final int? sampleIndex;
  final String op;
  final String target;
  final String field;
  final String path;
  final String oldValue;
  final String value;

  const RegistryHealthShowcaseRenamePatchOperation({
    required this.familyId,
    required this.familyTitle,
    required this.familyIndex,
    required this.sampleTitle,
    required this.sampleIndex,
    required this.op,
    required this.target,
    required this.field,
    required this.path,
    required this.oldValue,
    required this.value,
  });

  String get id {
    if (familyIndex != null && sampleIndex != null) {
      return 'rename:$familyIndex:$sampleIndex:$field';
    }
    return 'rename:${_stablePathSegment(familyId)}:${_stablePathSegment(sampleTitle)}:$field';
  }

  String get preview => '$id $path: "$oldValue" -> "$value"';

  RegistryHealthShowcaseSourceLocation get sourceLocation {
    return sourceLocationFor();
  }

  RegistryHealthShowcaseSourceLocation sourceLocationFor({
    RegistryHealthShowcaseSourceMap? sourceMap,
  }) {
    if (sourceMap != null) {
      return sourceMap.locationFor(
        familyId: familyId,
        familyTitle: familyTitle,
        familyIndex: familyIndex,
        sampleTitle: sampleTitle,
        sampleIndex: sampleIndex,
        jsonPath: field,
        chartType: oldValue,
      );
    }

    return registryHealthShowcaseFocusedSampleSourceLocation(
      familyId: familyId,
      familyTitle: familyTitle,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      jsonPath: field,
      chartType: oldValue,
    );
  }

  Map<String, dynamic> toJson({RegistryHealthShowcaseSourceMap? sourceMap}) => {
    'id': id,
    'op': op,
    'target': target,
    'field': field,
    'path': path,
    'oldValue': oldValue,
    'value': value,
    'preview': preview,
    'sourceLocation': sourceLocationFor(sourceMap: sourceMap).toJson(),
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    'sampleTitle': sampleTitle,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
  };
}

class RegistryHealthShowcaseRenamePatchIssue {
  final String code;
  final String message;
  final String operationId;
  final String path;

  const RegistryHealthShowcaseRenamePatchIssue({
    required this.code,
    required this.message,
    required this.operationId,
    required this.path,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'operationId': operationId,
    'path': path,
  };
}

class RegistryHealthShowcaseRenameBlocker {
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final String sampleTitle;
  final int? sampleIndex;
  final String jsonPath;
  final String providedType;
  final RegistryHealthShowcaseNamingStatus status;
  final String reason;
  final String suggestedAction;

  const RegistryHealthShowcaseRenameBlocker({
    required this.familyId,
    required this.familyTitle,
    required this.familyIndex,
    required this.sampleTitle,
    required this.sampleIndex,
    required this.jsonPath,
    required this.providedType,
    required this.status,
    required this.reason,
    required this.suggestedAction,
  });

  RegistryHealthShowcaseSourceLocation get sourceLocation {
    return sourceLocationFor();
  }

  RegistryHealthShowcaseSourceLocation sourceLocationFor({
    RegistryHealthShowcaseSourceMap? sourceMap,
  }) {
    if (sourceMap != null) {
      return sourceMap.locationFor(
        familyId: familyId,
        familyTitle: familyTitle,
        familyIndex: familyIndex,
        sampleTitle: sampleTitle,
        sampleIndex: sampleIndex,
        jsonPath: jsonPath,
        chartType: providedType,
      );
    }

    return registryHealthShowcaseFocusedSampleSourceLocation(
      familyId: familyId,
      familyTitle: familyTitle,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      jsonPath: jsonPath,
      chartType: providedType,
    );
  }

  Map<String, dynamic> toJson({RegistryHealthShowcaseSourceMap? sourceMap}) => {
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    'sampleTitle': sampleTitle,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    'jsonPath': jsonPath,
    'providedType': providedType,
    'sourceLocation': sourceLocationFor(sourceMap: sourceMap).toJson(),
    'status': status.name,
    'reason': reason,
    'suggestedAction': suggestedAction,
  };
}

class RegistryHealthShowcaseRenamePlanReport {
  final List<RegistryHealthShowcaseRenamePlanItem> items;
  final List<RegistryHealthShowcaseRenameBlocker> blockers;

  const RegistryHealthShowcaseRenamePlanReport({
    required this.items,
    required this.blockers,
  });

  RegistryHealthShowcaseRenamePlanStatus get status {
    if (blockers.isNotEmpty) {
      return RegistryHealthShowcaseRenamePlanStatus.blocked;
    }
    if (items.isNotEmpty) {
      return RegistryHealthShowcaseRenamePlanStatus.ready;
    }
    return RegistryHealthShowcaseRenamePlanStatus.clean;
  }

  String get statusLabel => status.label;
  bool get isReady => blockers.isEmpty;
  int get count => items.length;
  int get safeRenameCount => items.length;
  int get manifestWorkCount => blockers.length;
  int get patchOperationCount => items.length;

  List<RegistryHealthShowcaseRenamePatchOperation> get patchOperations {
    return [for (final item in items) item.patchOperation];
  }

  List<RegistryHealthShowcaseRenamePatchIssue> get patchIssues {
    final seenIds = <String>{};
    final seenPaths = <String>{};
    final issues = <RegistryHealthShowcaseRenamePatchIssue>[];

    for (final operation in patchOperations) {
      if (!seenIds.add(operation.id)) {
        issues.add(
          RegistryHealthShowcaseRenamePatchIssue(
            code: 'DUPLICATE_PATCH_ID',
            message: 'Patch operation id is duplicated.',
            operationId: operation.id,
            path: operation.path,
          ),
        );
      }
      if (!seenPaths.add(operation.path)) {
        issues.add(
          RegistryHealthShowcaseRenamePatchIssue(
            code: 'DUPLICATE_PATCH_PATH',
            message: 'Patch operation target path is duplicated.',
            operationId: operation.id,
            path: operation.path,
          ),
        );
      }
    }

    return List<RegistryHealthShowcaseRenamePatchIssue>.unmodifiable(issues);
  }

  bool get patchIsValid => patchIssues.isEmpty;
  int get patchIssueCount => patchIssues.length;

  List<String> get patchPreviewLines {
    return [for (final operation in patchOperations) operation.preview];
  }

  List<RegistryHealthShowcaseRenamePlanItem> visibleItems({int limit = 8}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return items.take(safeLimit).toList(growable: false);
  }

  List<RegistryHealthShowcaseRenameBlocker> visibleBlockers({int limit = 6}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return blockers.take(safeLimit).toList(growable: false);
  }

  List<RegistryHealthShowcaseRenamePatchOperation> visiblePatchOperations({
    int limit = 24,
  }) {
    final safeLimit = limit < 0 ? 0 : limit;
    return patchOperations.take(safeLimit).toList(growable: false);
  }

  List<String> visiblePatchPreviewLines({int limit = 24}) {
    final safeLimit = limit < 0 ? 0 : limit;
    return patchPreviewLines.take(safeLimit).toList(growable: false);
  }

  Map<String, dynamic> toJson({
    int itemLimit = 24,
    int blockerLimit = 12,
    RegistryHealthShowcaseSourceMap? sourceMap,
  }) {
    final safeLimit = itemLimit < 0 ? 0 : itemLimit;
    final safeBlockerLimit = blockerLimit < 0 ? 0 : blockerLimit;
    final exportedItems = items.take(safeLimit).toList(growable: false);
    final exportedPatchOperations = exportedItems
        .map((item) => item.patchOperation)
        .toList(growable: false);
    final exportedBlockers = blockers
        .take(safeBlockerLimit)
        .toList(growable: false);
    final patchIntegrityIssues = patchIssues;

    return {
      'status': status.name,
      'statusLabel': statusLabel,
      'isReady': isReady,
      'count': count,
      'safeRenameCount': safeRenameCount,
      'exportedCount': exportedItems.length,
      'hiddenCount': items.length - exportedItems.length,
      'patchOperationCount': patchOperationCount,
      'patchOperationsExportedCount': exportedPatchOperations.length,
      'patchOperationsHiddenCount':
          patchOperationCount - exportedPatchOperations.length,
      'patchIsValid': patchIntegrityIssues.isEmpty,
      'patchIssueCount': patchIntegrityIssues.length,
      'manifestWorkCount': manifestWorkCount,
      'manifestWorkExportedCount': exportedBlockers.length,
      'manifestWorkHiddenCount': blockers.length - exportedBlockers.length,
      'items': [
        for (final item in exportedItems) item.toJson(sourceMap: sourceMap),
      ],
      'patchOperations': [
        for (final operation in exportedPatchOperations)
          operation.toJson(sourceMap: sourceMap),
      ],
      'patchPreview': [
        for (final operation in exportedPatchOperations) operation.preview,
      ],
      'patchIssues': [for (final issue in patchIntegrityIssues) issue.toJson()],
      'manifestWorkItems': [
        for (final item in exportedBlockers) item.toJson(sourceMap: sourceMap),
      ],
    };
  }
}

RegistryHealthShowcaseRenamePlanReport registryHealthShowcaseRenamePlanReport(
  RegistryHealthShowcaseNamingReport report, {
  bool includeAliases = true,
  bool includeNormalized = true,
}) {
  final items = <RegistryHealthShowcaseRenamePlanItem>[];
  final blockers = <RegistryHealthShowcaseRenameBlocker>[];

  for (final row in report.rows) {
    if (row.status == RegistryHealthShowcaseNamingStatus.unknown) {
      blockers.add(_renameBlockerForRow(row));
      continue;
    }

    final item = _renamePlanItemForRow(
      row,
      includeAliases: includeAliases,
      includeNormalized: includeNormalized,
    );
    if (item != null) items.add(item);
  }

  return RegistryHealthShowcaseRenamePlanReport(
    items: List<RegistryHealthShowcaseRenamePlanItem>.unmodifiable(items),
    blockers: List<RegistryHealthShowcaseRenameBlocker>.unmodifiable(blockers),
  );
}

List<RegistryHealthShowcaseRenamePlanItem>
registryHealthShowcaseRenamePlanItems(
  RegistryHealthShowcaseNamingReport report, {
  bool includeAliases = true,
  bool includeNormalized = true,
}) {
  return registryHealthShowcaseRenamePlanReport(
    report,
    includeAliases: includeAliases,
    includeNormalized: includeNormalized,
  ).items;
}

List<RegistryHealthShowcaseRenameBlocker>
registryHealthShowcaseRenamePlanBlockers(
  RegistryHealthShowcaseNamingReport report,
) {
  return registryHealthShowcaseRenamePlanReport(report).blockers;
}

RegistryHealthShowcaseRenamePlanStatus registryHealthShowcaseRenamePlanStatus(
  RegistryHealthShowcaseNamingReport report,
) {
  return registryHealthShowcaseRenamePlanReport(report).status;
}

String registryHealthShowcaseRenamePlanStatusLabel(
  RegistryHealthShowcaseNamingReport report,
) {
  return registryHealthShowcaseRenamePlanStatus(report).label;
}

String registryHealthShowcaseRenamePlanReportLabel(
  RegistryHealthShowcaseRenamePlanReport report,
) {
  return report.statusLabel;
}

List<RegistryHealthShowcaseRenamePlanItem>
registryHealthShowcaseRenamePlanVisibleItems(
  RegistryHealthShowcaseNamingReport report, {
  int limit = 8,
}) {
  return registryHealthShowcaseRenamePlanReport(
    report,
  ).visibleItems(limit: limit);
}

List<RegistryHealthShowcaseRenameBlocker>
registryHealthShowcaseRenamePlanVisibleBlockers(
  RegistryHealthShowcaseNamingReport report, {
  int limit = 6,
}) {
  return registryHealthShowcaseRenamePlanReport(
    report,
  ).visibleBlockers(limit: limit);
}

Map<String, dynamic> registryHealthShowcaseRenamePlanJson(
  RegistryHealthShowcaseNamingReport report, {
  int itemLimit = 24,
  int blockerLimit = 12,
  RegistryHealthShowcaseSourceMap? sourceMap,
}) {
  return registryHealthShowcaseRenamePlanReport(report).toJson(
    itemLimit: itemLimit,
    blockerLimit: blockerLimit,
    sourceMap: sourceMap,
  );
}

extension on RegistryHealthShowcaseRenamePlanStatus {
  String get label {
    switch (this) {
      case RegistryHealthShowcaseRenamePlanStatus.clean:
        return 'Clean';
      case RegistryHealthShowcaseRenamePlanStatus.ready:
        return 'Ready';
      case RegistryHealthShowcaseRenamePlanStatus.blocked:
        return 'Blocked';
    }
  }
}

String _renamePlanReason(RegistryHealthShowcaseNamingStatus status) {
  switch (status) {
    case RegistryHealthShowcaseNamingStatus.normalized:
      return 'Matches manifest after normalization.';
    case RegistryHealthShowcaseNamingStatus.alias:
      return 'Uses a manifest alias.';
    case RegistryHealthShowcaseNamingStatus.canonical:
      return 'Already canonical.';
    case RegistryHealthShowcaseNamingStatus.unknown:
      return 'No manifest entry found.';
  }
}

RegistryHealthShowcaseRenamePlanItem? _renamePlanItemForRow(
  RegistryHealthShowcaseNamingRow row, {
  required bool includeAliases,
  required bool includeNormalized,
}) {
  final canonicalKey = row.canonicalKey;
  if (canonicalKey == null || canonicalKey == row.providedKey) return null;
  if (row.status == RegistryHealthShowcaseNamingStatus.alias &&
      !includeAliases) {
    return null;
  }
  if (row.status == RegistryHealthShowcaseNamingStatus.normalized &&
      !includeNormalized) {
    return null;
  }
  if (row.status != RegistryHealthShowcaseNamingStatus.alias &&
      row.status != RegistryHealthShowcaseNamingStatus.normalized) {
    return null;
  }

  return RegistryHealthShowcaseRenamePlanItem(
    familyId: row.familyId,
    familyTitle: row.familyTitle,
    familyIndex: row.familyIndex,
    sampleTitle: row.sampleTitle,
    sampleIndex: row.sampleIndex,
    jsonPath: 'type',
    fromType: row.providedKey,
    toType: canonicalKey,
    status: row.status,
    reason: _renamePlanReason(row.status),
  );
}

RegistryHealthShowcaseRenameBlocker _renameBlockerForRow(
  RegistryHealthShowcaseNamingRow row,
) {
  return RegistryHealthShowcaseRenameBlocker(
    familyId: row.familyId,
    familyTitle: row.familyTitle,
    familyIndex: row.familyIndex,
    sampleTitle: row.sampleTitle,
    sampleIndex: row.sampleIndex,
    jsonPath: 'type',
    providedType: row.providedKey,
    status: row.status,
    reason: row.providedKey.isEmpty
        ? 'Missing a string type key.'
        : 'No manifest entry matches this type key.',
    suggestedAction: row.suggestion,
  );
}

String _stablePathSegment(String value) {
  final normalized = value.trim().toLowerCase();
  final out = StringBuffer();
  var lastWasSeparator = false;

  for (final codeUnit in normalized.codeUnits) {
    final isLetter = codeUnit >= 97 && codeUnit <= 122;
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    if (isLetter || isDigit) {
      out.writeCharCode(codeUnit);
      lastWasSeparator = false;
      continue;
    }
    if (!lastWasSeparator) {
      out.write('-');
      lastWasSeparator = true;
    }
  }

  final text = out.toString();
  final trimmed = text.replaceAll(RegExp('^-+|-+\$'), '');
  return trimmed.isEmpty ? 'unknown' : trimmed;
}
