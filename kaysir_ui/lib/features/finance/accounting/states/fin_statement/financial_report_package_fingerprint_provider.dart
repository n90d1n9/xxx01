import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../models/financial_report_package_fingerprint.dart';
import '../../services/financial_report_package_fingerprint_service.dart';
import 'financial_close_checklist_provider.dart';
import 'financial_report_exception_resolution_provider.dart';
import 'financial_report_pack_provider.dart';

final financialReportPackageFingerprintServiceProvider =
    Provider<FinancialReportPackageFingerprintService>((ref) {
      return const FinancialReportPackageFingerprintService();
    });

final currentFinancialReportPackageFingerprintProvider =
    Provider<FinancialReportPackageFingerprint>((ref) {
      return ref
          .watch(financialReportPackageFingerprintServiceProvider)
          .build(
            pack: ref.watch(financialReportPackProvider),
            checklist: ref.watch(financialCloseChecklistProvider),
            exceptionResolutions: ref.watch(
              currentFinancialReportExceptionResolutionsProvider,
            ),
          );
    });
