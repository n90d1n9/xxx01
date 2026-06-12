import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_package_integrity.dart';
import '../../services/financial_report_package_integrity_service.dart';
import 'financial_period_close_provider.dart';
import 'financial_report_package_fingerprint_provider.dart';

final financialReportPackageIntegrityServiceProvider =
    Provider<FinancialReportPackageIntegrityService>((ref) {
      return const FinancialReportPackageIntegrityService();
    });

final currentFinancialReportPackageIntegrityProvider =
    Provider<FinancialReportPackageIntegrity>((ref) {
      return ref
          .watch(financialReportPackageIntegrityServiceProvider)
          .verify(
            closeRecord: ref.watch(currentFinancialPeriodCloseRecordProvider),
            currentFingerprint: ref.watch(
              currentFinancialReportPackageFingerprintProvider,
            ),
          );
    });
