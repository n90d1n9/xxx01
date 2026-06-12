import 'financial_period_close.dart';
import 'financial_report_package_fingerprint.dart';

enum FinancialReportPackageIntegrityStatus {
  notClosed,
  missingFingerprint,
  verified,
  changed,
}

extension FinancialReportPackageIntegrityStatusLabel
    on FinancialReportPackageIntegrityStatus {
  String get label {
    switch (this) {
      case FinancialReportPackageIntegrityStatus.notClosed:
        return 'Not closed';
      case FinancialReportPackageIntegrityStatus.missingFingerprint:
        return 'Fingerprint missing';
      case FinancialReportPackageIntegrityStatus.verified:
        return 'Package verified';
      case FinancialReportPackageIntegrityStatus.changed:
        return 'Package changed';
    }
  }
}

class FinancialReportPackageIntegrity {
  final FinancialReportPackageIntegrityStatus status;
  final FinancialPeriodCloseRecord? closeRecord;
  final FinancialReportPackageFingerprint currentFingerprint;

  const FinancialReportPackageIntegrity({
    required this.status,
    required this.closeRecord,
    required this.currentFingerprint,
  });

  bool get isVerified =>
      status == FinancialReportPackageIntegrityStatus.verified;

  bool get hasWarning {
    return status == FinancialReportPackageIntegrityStatus.changed ||
        status == FinancialReportPackageIntegrityStatus.missingFingerprint;
  }

  String? get closedHash => closeRecord?.reportPackageHash;

  String get currentHash => currentFingerprint.hash;

  String? get closedAlgorithm => closeRecord?.reportPackageHashAlgorithm;

  String get currentAlgorithm => currentFingerprint.algorithm;

  String? get closedShortHash => closeRecord?.reportPackageShortHash;

  String get currentShortHash => currentFingerprint.shortHash;

  bool get hasClosedHash {
    final hash = closedHash;
    return hash != null && hash.trim().isNotEmpty;
  }

  bool get hashMatches => hasClosedHash && closedHash == currentHash;

  bool get algorithmMatches {
    final algorithm = closedAlgorithm;
    return algorithm == null ||
        algorithm.trim().isEmpty ||
        algorithm == currentAlgorithm;
  }

  String get detail {
    switch (status) {
      case FinancialReportPackageIntegrityStatus.notClosed:
        return 'Close the period to certify this report package.';
      case FinancialReportPackageIntegrityStatus.missingFingerprint:
        return 'This close record was created before package fingerprints were captured.';
      case FinancialReportPackageIntegrityStatus.verified:
        return 'The displayed report package matches the closed package fingerprint.';
      case FinancialReportPackageIntegrityStatus.changed:
        return _changedDetail();
    }
  }

  String _changedDetail() {
    final issues = <String>[];
    if (!hashMatches) {
      issues.add(
        'closed hash ${closedShortHash ?? 'missing'} differs from current $currentShortHash',
      );
    }
    if (!algorithmMatches) {
      issues.add(
        'closed algorithm ${closedAlgorithm ?? 'missing'} differs from current $currentAlgorithm',
      );
    }
    if (issues.isEmpty) {
      return 'The displayed report package no longer matches the package that was closed.';
    }
    return 'The displayed report package changed: ${issues.join('; ')}.';
  }
}
