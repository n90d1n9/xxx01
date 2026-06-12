class FinancialReportExportIdentity {
  final String generatedBy;
  final DateTime generatedAt;
  final String entityName;
  final String periodLabel;
  final String frameworkName;
  final String jurisdiction;
  final String currency;
  final String packageStatus;
  final String packageDetail;
  final String periodLockHash;
  final String closedPackageAlgorithm;
  final String currentPackageHash;
  final String currentPackageAlgorithm;
  final int? evidenceReadyCount;
  final int? evidenceAttentionCount;
  final int? evidenceMissingCount;
  final double? evidenceCompletionRatio;
  final bool? archiveReady;
  final String? releaseNextAction;

  const FinancialReportExportIdentity({
    required this.generatedBy,
    required this.generatedAt,
    required this.entityName,
    required this.periodLabel,
    required this.frameworkName,
    required this.jurisdiction,
    required this.currency,
    required this.packageStatus,
    required this.packageDetail,
    required this.periodLockHash,
    required this.closedPackageAlgorithm,
    required this.currentPackageHash,
    required this.currentPackageAlgorithm,
    this.evidenceReadyCount,
    this.evidenceAttentionCount,
    this.evidenceMissingCount,
    this.evidenceCompletionRatio,
    this.archiveReady,
    this.releaseNextAction,
  });

  bool get hasEvidenceManifest {
    return evidenceReadyCount != null &&
        evidenceAttentionCount != null &&
        evidenceMissingCount != null &&
        evidenceCompletionRatio != null;
  }

  String get periodLockHashLabel {
    return _fallback(periodLockHash, 'Not locked');
  }

  String get closedPackageAlgorithmLabel {
    return _fallback(closedPackageAlgorithm, 'Not locked');
  }

  String get currentPackageHashLabel {
    return _fallback(currentPackageHash, 'Not computed');
  }

  String get currentPackageAlgorithmLabel {
    return _fallback(currentPackageAlgorithm, 'Not computed');
  }

  String get evidenceManifestLabel {
    if (!hasEvidenceManifest) {
      return 'Not attached';
    }
    final completion = (evidenceCompletionRatio! * 100).round();
    return '$completion% ($evidenceReadyCount ready / '
        '$evidenceAttentionCount attention / $evidenceMissingCount missing)';
  }

  String get archiveReadyLabel {
    final ready = archiveReady;
    if (ready == null) {
      return 'Not assessed';
    }
    return ready ? 'Ready' : 'Blocked';
  }

  String get releaseNextActionLabel {
    return _fallback(
      releaseNextAction ?? '',
      'No release evidence manifest attached.',
    );
  }

  String _fallback(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
