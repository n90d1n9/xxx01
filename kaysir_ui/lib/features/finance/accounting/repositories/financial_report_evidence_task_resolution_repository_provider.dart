import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'financial_report_evidence_task_resolution_repository.dart';
import 'local_financial_report_evidence_task_resolution_repository.dart';

export 'financial_report_evidence_task_resolution_repository.dart';

final financialReportEvidenceTaskResolutionRepositoryProvider =
    Provider<FinancialReportEvidenceTaskResolutionRepository>((ref) {
      return LocalFinancialReportEvidenceTaskResolutionRepository(
        store: LocalDbFinancialReportEvidenceTaskResolutionSnapshotStore(),
      );
    });
