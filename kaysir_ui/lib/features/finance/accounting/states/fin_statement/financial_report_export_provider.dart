import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../services/financial_report_export_service.dart';

final financialReportExportServiceProvider =
    Provider<FinancialReportExportService>((ref) {
      return const FinancialReportExportService();
    });
