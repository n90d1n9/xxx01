import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/screens/financial_report_release_center_screen.dart';

void main() {
  test('parses report release section focus from route query', () {
    expect(
      financialReportReleaseCenterFocusFromQuery(
        AccountingPath.reportReleaseSignOffFocus,
      ),
      FinancialReportReleaseCenterFocus.signOff,
    );
    expect(
      financialReportReleaseCenterFocusFromQuery(
        AccountingPath.reportReleaseEvidenceFocus,
      ),
      FinancialReportReleaseCenterFocus.evidenceManifest,
    );
    expect(
      financialReportReleaseCenterFocusFromQuery(
        AccountingPath.reportReleaseDistributionFocus,
      ),
      FinancialReportReleaseCenterFocus.distribution,
    );
    expect(
      financialReportReleaseCenterFocusFromQuery(
        AccountingPath.reportReleaseArchiveFocus,
      ),
      FinancialReportReleaseCenterFocus.archive,
    );
    expect(
      financialReportReleaseCenterFocusFromQuery(
        AccountingPath.reportReleaseRetentionFocus,
      ),
      FinancialReportReleaseCenterFocus.retention,
    );
    expect(
      financialReportReleaseCenterFocusFromQuery(
        AccountingPath.reportReleaseStatutoryFilingFocus,
      ),
      FinancialReportReleaseCenterFocus.statutoryFiling,
    );
    expect(
      financialReportReleaseCenterFocusFromQuery(null),
      FinancialReportReleaseCenterFocus.overview,
    );
  });

  test('builds report release section focus paths', () {
    expect(
      AccountingPath.reportReleaseWithFocus(
        AccountingPath.reportReleaseSignOffFocus,
      ),
      '/financial-report-release?focus=sign-off',
    );
    expect(
      AccountingPath.reportReleaseWithFocus(
        AccountingPath.reportReleaseEvidenceFocus,
      ),
      '/financial-report-release?focus=evidence',
    );
    expect(
      AccountingPath.reportReleaseWithFocus(
        AccountingPath.reportReleaseStatutoryFilingFocus,
      ),
      '/financial-report-release?focus=statutory-filing',
    );
  });
}
