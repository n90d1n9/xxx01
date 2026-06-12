import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_package_preset.dart';

void main() {
  test('report package preset matches default analysis package', () {
    final preset = ReportPackagePreset.fromRequest(
      const ReportGenerationRequest(),
    );

    expect(preset, ReportPackagePreset.analysis);
  });

  test(
    'report package preset applies content bundles without changing scope',
    () {
      const request = ReportGenerationRequest(
        period: ReportPeriod.lastYear,
        department: ReportDepartmentScope.finance,
        format: ReportFileFormat.excel,
      );

      final updated = ReportPackagePreset.audit.applyTo(request);

      expect(updated.period, ReportPeriod.lastYear);
      expect(updated.department, ReportDepartmentScope.finance);
      expect(updated.format, ReportFileFormat.excel);
      expect(updated.includeExecutiveSummary, isTrue);
      expect(updated.includeTrendCharts, isTrue);
      expect(updated.includeRawData, isTrue);
    },
  );

  test('report package preset returns null for custom content mixes', () {
    final preset = ReportPackagePreset.fromRequest(
      const ReportGenerationRequest(
        includeExecutiveSummary: false,
        includeTrendCharts: true,
        includeRawData: true,
      ),
    );

    expect(preset, isNull);
  });
}
