import '../models/financial_period_close.dart';
import '../models/financial_report_package_fingerprint.dart';
import '../models/financial_report_package_integrity.dart';

class FinancialReportPackageIntegrityService {
  const FinancialReportPackageIntegrityService();

  FinancialReportPackageIntegrity verify({
    required FinancialPeriodCloseRecord? closeRecord,
    required FinancialReportPackageFingerprint currentFingerprint,
  }) {
    if (closeRecord == null || !closeRecord.isClosed) {
      return FinancialReportPackageIntegrity(
        status: FinancialReportPackageIntegrityStatus.notClosed,
        closeRecord: closeRecord,
        currentFingerprint: currentFingerprint,
      );
    }

    final closedHash = closeRecord.reportPackageHash;
    if (closedHash == null || closedHash.isEmpty) {
      return FinancialReportPackageIntegrity(
        status: FinancialReportPackageIntegrityStatus.missingFingerprint,
        closeRecord: closeRecord,
        currentFingerprint: currentFingerprint,
      );
    }

    final closedAlgorithm = closeRecord.reportPackageHashAlgorithm;
    final matchesHash = closedHash == currentFingerprint.hash;
    final matchesAlgorithm =
        closedAlgorithm == null ||
        closedAlgorithm.isEmpty ||
        closedAlgorithm == currentFingerprint.algorithm;

    return FinancialReportPackageIntegrity(
      status:
          matchesHash && matchesAlgorithm
              ? FinancialReportPackageIntegrityStatus.verified
              : FinancialReportPackageIntegrityStatus.changed,
      closeRecord: closeRecord,
      currentFingerprint: currentFingerprint,
    );
  }
}
