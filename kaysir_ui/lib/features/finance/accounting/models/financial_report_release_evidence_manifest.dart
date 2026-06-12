enum FinancialReportReleaseEvidenceKind {
  closeCertificate,
  packageFingerprint,
  signOffCertificate,
  signOffAuditTrail,
  managementMeasureAuditTrail,
  distributionRegister,
  distributionAuditTrail,
}

enum FinancialReportReleaseEvidenceStatus { ready, attention, missing }

extension FinancialReportReleaseEvidenceStatusLabel
    on FinancialReportReleaseEvidenceStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseEvidenceStatus.ready:
        return 'Ready';
      case FinancialReportReleaseEvidenceStatus.attention:
        return 'Attention';
      case FinancialReportReleaseEvidenceStatus.missing:
        return 'Missing';
    }
  }
}

class FinancialReportReleaseEvidenceManifestItem {
  final FinancialReportReleaseEvidenceKind kind;
  final String title;
  final FinancialReportReleaseEvidenceStatus status;
  final String detail;
  final String reference;
  final bool requiredForArchive;

  const FinancialReportReleaseEvidenceManifestItem({
    required this.kind,
    required this.title,
    required this.status,
    required this.detail,
    required this.reference,
    this.requiredForArchive = true,
  });
}

class FinancialReportReleaseEvidenceManifestSummary {
  final List<FinancialReportReleaseEvidenceManifestItem> items;
  final int readyCount;
  final int attentionCount;
  final int missingCount;
  final bool archiveReady;
  final double completionRatio;
  final String nextAction;

  const FinancialReportReleaseEvidenceManifestSummary({
    required this.items,
    required this.readyCount,
    required this.attentionCount,
    required this.missingCount,
    required this.archiveReady,
    required this.completionRatio,
    required this.nextAction,
  });
}
