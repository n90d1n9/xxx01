import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_export_package_profile.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/report_generation_request.dart';

void main() {
  test('report export package profile estimates default report package', () {
    final profile = ReportExportPackageProfile.fromRequest(
      const ReportGenerationRequest(),
    );

    expect(profile.selectedSectionCount, 2);
    expect(profile.sectionCountLabel, '2 sections');
    expect(profile.estimatedKilobytes, 1700);
    expect(profile.estimatedSizeLabel, 'Est. 1.7 MB');
    expect(profile.estimatedGenerationSeconds, 80);
    expect(profile.estimatedGenerationLabel, '~1m 20s generation');
  });

  test('report export package profile estimates raw csv packages', () {
    final profile = ReportExportPackageProfile.fromRequest(
      const ReportGenerationRequest(
        format: ReportFileFormat.csv,
        includeRawData: true,
      ),
    );

    expect(profile.selectedSectionCount, 3);
    expect(profile.sectionCountLabel, '3 sections');
    expect(profile.estimatedKilobytes, 2380);
    expect(profile.estimatedSizeLabel, 'Est. 2.3 MB');
    expect(profile.estimatedGenerationSeconds, 80);
    expect(profile.estimatedGenerationLabel, '~1m 20s generation');
  });

  test('report export package profile handles empty packages', () {
    final profile = ReportExportPackageProfile.fromRequest(
      const ReportGenerationRequest(
        includeExecutiveSummary: false,
        includeTrendCharts: false,
      ),
    );

    expect(profile.selectedSectionCount, 0);
    expect(profile.sectionCountLabel, '0 sections');
    expect(profile.estimatedSizeLabel, 'Est. 520 KB');
    expect(profile.estimatedGenerationSeconds, 35);
    expect(profile.estimatedGenerationLabel, '~35s generation');
  });
}
