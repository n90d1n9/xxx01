import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_table_layout_models.dart';
import 'package:kaysir/features/hris/employee/screens/employee_directory_table_screen.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

void main() {
  testWidgets('employee directory table renders searchable employee rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    expect(find.text('Employee list table'), findsOneWidget);
    expect(find.text('Workforce insights'), findsOneWidget);
    expect(find.text('Roster quality'), findsOneWidget);
    expect(find.text('100% ready, 0 issues across 0 profiles'), findsOneWidget);
    expect(find.text('Selection review'), findsOneWidget);
    expect(
      find.text('Select rows to review cohort mix before bulk updates'),
      findsOneWidget,
    );
    expect(find.text('Bulk update preview'), findsOneWidget);
    expect(find.text('Custom saved views'), findsOneWidget);
    expect(find.text('0 custom views saved'), findsOneWidget);
    expect(find.text('View readiness'), findsOneWidget);
    expect(find.text('All employees: 5 of 5 profiles visible'), findsOneWidget);
    expect(find.text('Roster-wide view'), findsOneWidget);
    expect(find.text('Table layout'), findsOneWidget);
    expect(find.text('10 visible columns, comfortable rows'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Review watchlist profiles'), findsWidgets);
    expect(find.text('HR action queue'), findsOneWidget);
    expect(find.text('Payroll run console'), findsOneWidget);
    expect(
      find.text('Launch payroll run after import validation.'),
      findsWidgets,
    );
    expect(find.text('4 open actions from visible employees'), findsOneWidget);
    expect(find.text('Sarah Johnson'), findsOneWidget);
    expect(find.text('Dept'), findsWidgets);
    expect(find.text('Manager'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-table-search-field')),
      'michael',
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('employee-directory-table-name-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-1')),
      findsNothing,
    );
    expect(find.text('1 visible of 1 matching profiles'), findsOneWidget);
  });

  testWidgets('employee directory table can filter watchlist rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final statusFilter = find.byKey(
      const ValueKey('employee-directory-table-status-filter'),
    );
    await tester.ensureVisible(statusFilter);
    await tester.pump();
    await tester.tap(statusFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watchlist').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('employee-directory-table-name-4')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-1')),
      findsNothing,
    );
    expect(find.text('1 visible of 5 matching profiles'), findsOneWidget);
  });

  testWidgets('employee directory table supports bulk export selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final selectVisible = find.byKey(
      const ValueKey('employee-directory-table-select-visible-button'),
    );
    await tester.ensureVisible(selectVisible);
    await tester.tap(selectVisible);
    await tester.pumpAndSettle();

    expect(
      find.text('5 selected profiles ready for bulk actions'),
      findsOneWidget,
    );
    expect(
      find.text('5 selected profiles across 5 departments'),
      findsOneWidget,
    );
    expect(find.text('Mixed departments'), findsOneWidget);
    expect(find.text('Multi-location cohort'), findsOneWidget);

    final exportSelected = find.byKey(
      const ValueKey('employee-directory-table-export-selected-button'),
    );
    await tester.tap(exportSelected);
    await tester.pumpAndSettle();

    expect(find.text('5 employee rows prepared as CSV'), findsOneWidget);
    expect(find.text('5 rows exported'), findsOneWidget);
    expect(find.text('Exported rows'), findsOneWidget);
  });

  testWidgets('employee directory table resolves action queue items', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final resolveButton = find.byKey(
      const ValueKey('employee-directory-action-resolve-watchlistReview-4'),
    );
    await tester.ensureVisible(resolveButton);
    await tester.tap(resolveButton);
    await tester.pumpAndSettle();

    expect(find.text('Review watchlist profiles resolved'), findsWidgets);
    expect(find.text('3 open actions from visible employees'), findsOneWidget);
    expect(find.text('Action queue'), findsOneWidget);
  });

  testWidgets('employee directory table imports valid CSV rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    const csv = '''
name,email,phone,position,department,manager,location,joining_date,performance,status
Maya Santoso,maya.santoso@example.com,+62 812 1111 2222,HR Analyst,People Operations,Emma Rodriguez,Jakarta,2026-05-15,4.3,Onboarding
''';

    final csvField = find.byKey(
      const ValueKey('employee-directory-import-csv-field'),
    );
    await tester.ensureVisible(csvField);
    await tester.enterText(csvField, csv);
    await tester.pumpAndSettle();

    expect(find.text('1 ready, 0 need review'), findsOneWidget);
    expect(find.text('Row 2: Maya Santoso'), findsOneWidget);

    final importButton = find.byKey(
      const ValueKey('employee-directory-import-submit-button'),
    );
    await tester.tap(importButton);
    await tester.pumpAndSettle();

    expect(find.text('1 employee profile imported'), findsOneWidget);
    expect(find.text('1 row imported'), findsOneWidget);
    expect(find.text('Imported rows'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-6')),
      findsOneWidget,
    );
  });

  testWidgets('employee directory table filters by roster quality issue', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
          employeeDirectoryMembersProvider.overrideWith(
            (ref) => EmployeeDirectoryNotifier([
              _member(
                id: '1',
                name: 'Sarah Johnson',
                email: 'shared@example.com',
              ),
              _member(
                id: '2',
                name: 'Maya Santoso',
                email: 'shared@example.com',
                manager: '',
              ),
              _member(id: '3', name: 'Rafi Pratama'),
            ]),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    expect(find.text('33% ready, 3 issues across 2 profiles'), findsOneWidget);
    expect(find.text('Roster readiness gate'), findsOneWidget);
    expect(
      find.text('2 payroll blockers must clear before cutoff'),
      findsWidgets,
    );
    expect(find.text('Payroll blocked'), findsWidgets);
    expect(find.text('Identity and contact'), findsOneWidget);
    expect(find.text('Roster gate sign-off'), findsOneWidget);
    expect(
      find.text('Resolve 2 payroll blockers before sign-off.'),
      findsOneWidget,
    );
    expect(find.text('Roster release packet'), findsOneWidget);
    expect(
      find.text('Resolve 2 payroll blockers before publishing.'),
      findsOneWidget,
    );
    expect(find.text('Roster release diff'), findsOneWidget);
    expect(
      find.text('Publish a roster packet to start diff review.'),
      findsWidgets,
    );
    expect(find.text('Quality fix plan'), findsOneWidget);
    expect(
      find.text('3 fixes planned across 2 profiles, 19 min estimated'),
      findsOneWidget,
    );
    expect(
      find.text('Clear critical lane to reach 67% readiness'),
      findsOneWidget,
    );

    final duplicateFilter = find.byKey(
      const ValueKey('employee-directory-quality-filter-duplicateEmail'),
    );
    await tester.ensureVisible(duplicateFilter);
    await tester.tap(duplicateFilter);
    await tester.pumpAndSettle();

    expect(find.text('2 visible of 3 matching profiles'), findsOneWidget);
    expect(find.text('Custom view: 2 of 3 profiles visible'), findsOneWidget);
    expect(find.text('Manual view active'), findsOneWidget);
    expect(find.text('Critical data issues'), findsOneWidget);
    expect(find.text('2 affected'), findsWidgets);
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-3')),
      findsNothing,
    );

    expect(find.text('Quality fix workspace'), findsOneWidget);
    expect(find.text('Duplicate email: Maya Santoso'), findsWidgets);

    final focusFix = find.byKey(
      const ValueKey('employee-directory-quality-plan-focus-button'),
    );
    await tester.ensureVisible(focusFix);
    await tester.tap(focusFix);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-quality-fix-email-field')),
      'maya.fixed@example.com',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-quality-fix-audit-note-field'),
      ),
      'Duplicate email corrected',
    );
    await tester.pumpAndSettle();

    final submitFix = find.byKey(
      const ValueKey('employee-directory-quality-fix-submit-button'),
    );
    await tester.ensureVisible(submitFix);
    await tester.tap(submitFix);
    await tester.pumpAndSettle();

    expect(find.text('Maya Santoso quality issue fixed'), findsOneWidget);
    expect(find.text('67% ready, 1 issues across 1 profiles'), findsOneWidget);
    expect(
      find.text('1 fix planned across 1 profile, 5 min estimated'),
      findsOneWidget,
    );
    expect(
      find.text('Clear warning lane to reach 100% readiness'),
      findsOneWidget,
    );
    expect(find.text('1 review item before cutoff'), findsWidgets);
    expect(find.text('HR review'), findsWidgets);

    final reviewerField = find.byKey(
      const ValueKey('employee-directory-quality-signoff-reviewer-field'),
    );
    await tester.ensureVisible(reviewerField);
    await tester.enterText(reviewerField, 'Alya Rahman');
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-quality-signoff-note-field'),
      ),
      'Manager routing reviewed for cutoff.',
    );
    final acceptReviewToggle = find.byKey(
      const ValueKey('employee-directory-quality-signoff-accept-review-toggle'),
    );
    await tester.ensureVisible(acceptReviewToggle);
    await tester.tap(acceptReviewToggle);
    await tester.pumpAndSettle();

    final submitSignoff = find.byKey(
      const ValueKey('employee-directory-quality-signoff-submit-button'),
    );
    await tester.ensureVisible(submitSignoff);
    await tester.tap(submitSignoff);
    await tester.pumpAndSettle();

    expect(find.text('Roster gate signed off by Alya Rahman'), findsOneWidget);
    expect(find.text('Gate signed off'), findsOneWidget);
    expect(
      find.text('67% readiness with 1 accepted review item.'),
      findsOneWidget,
    );

    final preparerField = find.byKey(
      const ValueKey('employee-directory-roster-publish-preparer-field'),
    );
    await tester.ensureVisible(preparerField);
    await tester.enterText(preparerField, 'Alya Rahman');
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-roster-publish-note-field'),
      ),
      'Roster packet approved for payroll handoff.',
    );
    final payrollHandoffToggle = find.byKey(
      const ValueKey('employee-directory-roster-publish-payroll-toggle'),
    );
    await tester.ensureVisible(payrollHandoffToggle);
    await tester.tap(payrollHandoffToggle);
    await tester.pumpAndSettle();

    final publishPacket = find.byKey(
      const ValueKey('employee-directory-roster-publish-submit-button'),
    );
    await tester.ensureVisible(publishPacket);
    await tester.tap(publishPacket);
    await tester.pumpAndSettle();

    expect(find.text('2026.05.30-001 roster packet published'), findsOneWidget);
    expect(find.text('Roster published'), findsOneWidget);
    expect(
      find.text('3 profiles, 1 department, 67% readiness.'),
      findsOneWidget,
    );
    expect(
      find.text('2026.05.30-001 is the first roster release baseline.'),
      findsWidgets,
    );
    expect(find.text('First release baseline'), findsOneWidget);
    expect(find.text('Roster handoff tracker'), findsOneWidget);
    expect(
      find.text('0 acknowledged, 3 pending for 2026.05.30-001.'),
      findsWidgets,
    );
    expect(find.text('Payroll sync reconciliation'), findsOneWidget);
    expect(
      find.text('Complete 3 handoff acknowledgements before payroll sync.'),
      findsOneWidget,
    );

    final acknowledgePayroll = find.byKey(
      const ValueKey('employee-directory-roster-handoff-acknowledge-payroll'),
    );
    await tester.ensureVisible(acknowledgePayroll);
    await tester.tap(acknowledgePayroll);
    await tester.pumpAndSettle();

    expect(
      find.text('Payroll Operations acknowledged 2026.05.30-001'),
      findsOneWidget,
    );
    expect(
      find.text('1 acknowledged, 2 pending for 2026.05.30-001.'),
      findsWidgets,
    );

    final escalateFinance = find.byKey(
      const ValueKey('employee-directory-roster-handoff-escalate-finance'),
    );
    await tester.ensureVisible(escalateFinance);
    await tester.tap(escalateFinance);
    await tester.pumpAndSettle();

    expect(
      find.text('Finance Control escalated for 2026.05.30-001'),
      findsOneWidget,
    );
    expect(find.text('Escalated'), findsWidgets);

    final acknowledgeFinance = find.byKey(
      const ValueKey('employee-directory-roster-handoff-acknowledge-finance'),
    );
    await tester.ensureVisible(acknowledgeFinance);
    await tester.tap(acknowledgeFinance);
    await tester.pumpAndSettle();

    final acknowledgePeopleOps = find.byKey(
      const ValueKey('employee-directory-roster-handoff-acknowledge-peopleOps'),
    );
    await tester.ensureVisible(acknowledgePeopleOps);
    await tester.tap(acknowledgePeopleOps);
    await tester.pumpAndSettle();

    expect(find.text('3 acknowledged for 2026.05.30-001.'), findsWidgets);

    final payrollOperator = find.byKey(
      const ValueKey('employee-directory-roster-payroll-sync-operator-field'),
    );
    await tester.ensureVisible(payrollOperator);
    await tester.enterText(payrollOperator, 'Payroll Lead');
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-roster-payroll-sync-note-field'),
      ),
      'Control totals matched staging import.',
    );
    final controlTotals = find.byKey(
      const ValueKey('employee-directory-roster-payroll-sync-totals-toggle'),
    );
    await tester.ensureVisible(controlTotals);
    await tester.tap(controlTotals);
    await tester.pumpAndSettle();

    final syncPayroll = find.byKey(
      const ValueKey('employee-directory-roster-payroll-sync-submit-button'),
    );
    await tester.ensureVisible(syncPayroll);
    await tester.tap(syncPayroll);
    await tester.pumpAndSettle();

    expect(find.text('2026.05.30-001 synced to payroll'), findsOneWidget);
    expect(find.text('Payroll synced'), findsOneWidget);
    expect(
      find.text('3 profiles synced with 0 payroll-impacting changes reviewed.'),
      findsOneWidget,
    );
    expect(find.text('Payroll import packet'), findsOneWidget);
    expect(find.text('Import batch label is required.'), findsOneWidget);

    final importBatch = find.byKey(
      const ValueKey('employee-directory-roster-payroll-import-batch-field'),
    );
    await tester.ensureVisible(importBatch);
    await tester.enterText(importBatch, 'PAY-202605-001');
    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-directory-roster-payroll-import-preparer-field',
        ),
      ),
      'Payroll Lead',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-roster-payroll-import-note-field'),
      ),
      'Column mapping matched payroll preview controls.',
    );
    final importMapping = find.byKey(
      const ValueKey('employee-directory-roster-payroll-import-mapping-toggle'),
    );
    await tester.ensureVisible(importMapping);
    await tester.tap(importMapping);
    await tester.pumpAndSettle();

    final importPreview = find.byKey(
      const ValueKey('employee-directory-roster-payroll-import-preview-toggle'),
    );
    await tester.ensureVisible(importPreview);
    await tester.tap(importPreview);
    await tester.pumpAndSettle();

    final stageImport = find.byKey(
      const ValueKey('employee-directory-roster-payroll-import-submit-button'),
    );
    await tester.ensureVisible(stageImport);
    await tester.tap(stageImport);
    await tester.pumpAndSettle();

    expect(
      find.text('PAY-202605-001 staged for payroll import'),
      findsOneWidget,
    );
    expect(find.text('Payroll import staged'), findsOneWidget);
    expect(
      find.text(
        '3 profiles staged across 1 department with 0 attention profiles reviewed.',
      ),
      findsOneWidget,
    );
    expect(find.text('Payroll import validation'), findsOneWidget);
    expect(
      find.text('Confirm payroll import file loaded successfully.'),
      findsOneWidget,
    );

    final validationOwner = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-validation-owner-field',
      ),
    );
    await tester.ensureVisible(validationOwner);
    await tester.enterText(validationOwner, 'Payroll Lead');
    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-directory-roster-payroll-validation-note-field',
        ),
      ),
      'Import loaded and payroll controls matched.',
    );
    final validationFile = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-validation-file-toggle',
      ),
    );
    await tester.ensureVisible(validationFile);
    await tester.tap(validationFile);
    await tester.pumpAndSettle();

    final validationControls = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-validation-controls-toggle',
      ),
    );
    await tester.ensureVisible(validationControls);
    await tester.tap(validationControls);
    await tester.pumpAndSettle();

    final approveValidation = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-validation-submit-button',
      ),
    );
    await tester.ensureVisible(approveValidation);
    await tester.tap(approveValidation);
    await tester.pumpAndSettle();

    expect(
      find.text('PAY-202605-001 payroll import validated'),
      findsOneWidget,
    );
    expect(find.text('Payroll import validated'), findsOneWidget);
    expect(
      find.text('3 loaded profiles approved with 0 validation items reviewed.'),
      findsOneWidget,
    );
    expect(find.text('Payroll run kickoff'), findsOneWidget);
    expect(find.text('Payroll run reference is required.'), findsOneWidget);

    final runReference = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-reference-field',
      ),
    );
    await tester.ensureVisible(runReference);
    await tester.enterText(runReference, 'RUN-202605-001');
    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-directory-roster-payroll-run-kickoff-owner-field',
        ),
      ),
      'Payroll Lead',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey(
          'employee-directory-roster-payroll-run-kickoff-note-field',
        ),
      ),
      'Funding and payroll launch controls prepared.',
    );
    final fundingToggle = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-funding-toggle',
      ),
    );
    await tester.ensureVisible(fundingToggle);
    await tester.tap(fundingToggle);
    await tester.pumpAndSettle();

    final payslipToggle = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-payslip-toggle',
      ),
    );
    await tester.ensureVisible(payslipToggle);
    await tester.tap(payslipToggle);
    await tester.pumpAndSettle();

    final auditToggle = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-audit-toggle',
      ),
    );
    await tester.ensureVisible(auditToggle);
    await tester.tap(auditToggle);
    await tester.pumpAndSettle();

    final launchRun = find.byKey(
      const ValueKey(
        'employee-directory-roster-payroll-run-kickoff-submit-button',
      ),
    );
    await tester.ensureVisible(launchRun);
    await tester.tap(launchRun);
    await tester.pumpAndSettle();

    expect(find.text('RUN-202605-001 payroll run launched'), findsOneWidget);
    expect(find.text('Payroll run launched'), findsOneWidget);
    expect(
      find.text('3 loaded profiles launched with 0 validation items cleared.'),
      findsOneWidget,
    );
    expect(find.text('Payroll run console'), findsOneWidget);
    expect(
      find.text('RUN-202605-001 from PAY-202605-001, 0/3 exported.'),
      findsOneWidget,
    );
    expect(find.text('Export 3 employee payroll runs.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('employee-payroll-run-console-name-3')),
      findsOneWidget,
    );
    expect(find.text('Maya Santoso updated'), findsOneWidget);
    expect(find.text('Updated profile'), findsOneWidget);
  });

  testWidgets('employee directory table saved views apply presets', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final watchlistPreset = find.byKey(
      const ValueKey('employee-directory-table-preset-watchlistReview'),
    );
    await tester.ensureVisible(watchlistPreset);
    await tester.tap(watchlistPreset);
    await tester.pumpAndSettle();

    expect(find.text('Watchlist review view, 1 rows visible'), findsOneWidget);
    expect(
      find.text('Watchlist review: 1 of 5 profiles visible'),
      findsOneWidget,
    );
    expect(find.text('Focused cohort'), findsOneWidget);
    expect(find.text('1 active filter'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-4')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-1')),
      findsNothing,
    );
    expect(find.text('1 visible of 5 matching profiles'), findsOneWidget);
  });

  testWidgets('employee directory table creates and reapplies custom views', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final watchlistPreset = find.byKey(
      const ValueKey('employee-directory-table-preset-watchlistReview'),
    );
    await tester.ensureVisible(watchlistPreset);
    await tester.tap(watchlistPreset);
    await tester.pumpAndSettle();

    final nameField = find.byKey(
      const ValueKey('employee-directory-saved-view-name-field'),
    );
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'Watchlist cleanup');
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-saved-view-description-field'),
      ),
      'Daily People Ops review',
    );
    final pinnedToggle = find.byKey(
      const ValueKey('employee-directory-saved-view-pinned-toggle'),
    );
    await tester.ensureVisible(pinnedToggle);
    await tester.pumpAndSettle();
    await tester.tap(pinnedToggle);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('employee-directory-saved-view-save-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Watchlist cleanup saved view captured'), findsOneWidget);
    expect(find.text('Watchlist cleanup active'), findsOneWidget);
    expect(
      find.text('Watchlist cleanup: 1 of 5 profiles visible'),
      findsOneWidget,
    );
    expect(find.text('Pinned'), findsWidgets);

    final allEmployeesPreset = find.byKey(
      const ValueKey('employee-directory-table-preset-allEmployees'),
    );
    await tester.ensureVisible(allEmployeesPreset);
    await tester.tap(allEmployeesPreset);
    await tester.pumpAndSettle();

    expect(find.text('All employees view, 5 rows visible'), findsOneWidget);

    final applyCustomView = find.byKey(
      const ValueKey('employee-directory-saved-view-apply-custom-view-1'),
    );
    await tester.ensureVisible(applyCustomView);
    await tester.tap(applyCustomView);
    await tester.pumpAndSettle();

    expect(find.text('Watchlist cleanup view applied'), findsOneWidget);
    expect(find.text('Watchlist cleanup active'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-4')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-1')),
      findsNothing,
    );

    final deleteCustomView = find.byKey(
      const ValueKey('employee-directory-saved-view-delete-custom-view-1'),
    );
    await tester.ensureVisible(deleteCustomView);
    await tester.tap(deleteCustomView);
    await tester.pumpAndSettle();

    expect(find.text('Watchlist cleanup saved view deleted'), findsOneWidget);
    expect(find.text('0 custom views saved'), findsOneWidget);
  });

  testWidgets(
    'employee directory table customizes layout columns and density',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            employeeDirectoryAsOfDateProvider.overrideWithValue(
              DateTime(2026, 5, 30),
            ),
          ],
          child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
        ),
      );

      expect(
        find.byKey(const ValueKey('employee-directory-table-column-manager')),
        findsOneWidget,
      );

      final managerToggle = find.byKey(
        const ValueKey(
          'employee-directory-table-layout-column-manager-checkbox',
        ),
      );
      await tester.ensureVisible(managerToggle);
      await tester.tap(managerToggle);
      await tester.pumpAndSettle();

      expect(find.text('9 visible columns, comfortable rows'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('employee-directory-table-column-manager')),
        findsNothing,
      );

      final compactDensity = find.text(
        EmployeeDirectoryTableDensity.compact.label,
      );
      await tester.ensureVisible(compactDensity);
      await tester.pumpAndSettle();
      await tester.tap(compactDensity);
      await tester.pumpAndSettle();

      expect(find.text('9 visible columns, compact rows'), findsOneWidget);

      final resetButton = find.byKey(
        const ValueKey('employee-directory-table-layout-reset'),
      );
      await tester.ensureVisible(resetButton);
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      expect(find.text('10 visible columns, comfortable rows'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('employee-directory-table-column-manager')),
        findsOneWidget,
      );
    },
  );

  testWidgets('employee directory table applies bulk profile updates', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final selectVisible = find.byKey(
      const ValueKey('employee-directory-table-select-visible-button'),
    );
    await tester.ensureVisible(selectVisible);
    await tester.tap(selectVisible);
    await tester.pumpAndSettle();

    expect(
      find.text('5 selected profiles ready for bulk actions'),
      findsOneWidget,
    );
    expect(
      find.text('5 selected profiles ready for governed updates'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-bulk-profile-manager-field'),
      ),
      'People Ops Lead',
    );
    await tester.enterText(
      find.byKey(
        const ValueKey('employee-directory-bulk-profile-department-field'),
      ),
      'People Operations',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-bulk-profile-note-field')),
      'Manager and department realignment approved',
    );
    await tester.pumpAndSettle();

    expect(find.text('Needs approval'), findsOneWidget);
    expect(find.text('Emma Rodriguez -> People Ops Lead'), findsOneWidget);
    expect(find.text('Design -> People Operations'), findsOneWidget);

    final approvalCheckbox = find.byKey(
      const ValueKey(
        'employee-directory-bulk-profile-preview-approval-checkbox',
      ),
    );
    await tester.ensureVisible(approvalCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(approvalCheckbox);
    await tester.pumpAndSettle();

    expect(find.text('Approved'), findsOneWidget);

    final submitButton = find.byKey(
      const ValueKey('employee-directory-bulk-profile-submit-button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('5 employee profiles updated'), findsWidgets);
    expect(find.text('Bulk profile update'), findsWidgets);
    expect(find.text('People Ops Lead'), findsWidgets);
    expect(
      find.text('Select visible rows or use the table checkboxes'),
      findsOneWidget,
    );
  });

  testWidgets('employee directory table creates employee from intake form', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final addButton = find.byKey(
      const ValueKey('employee-directory-table-add-button'),
    );
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('employee-directory-intake-sheet')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-name-field')),
      'Aisha Putri',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-email-field')),
      'aisha.putri@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-phone-field')),
      '+62 812 0000 0000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-location-field')),
      'Jakarta',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-position-field')),
      'HR Operations Analyst',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-department-field')),
      'People Operations',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-manager-field')),
      'Emma Rodriguez',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-performance-field')),
      '4.4',
    );

    final submitButton = find.byKey(
      const ValueKey('employee-directory-intake-submit-button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Aisha Putri added to the directory'), findsOneWidget);
    expect(find.text('Aisha Putri created'), findsOneWidget);
    expect(find.text('Created profile'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('employee-directory-table-name-6')),
      findsOneWidget,
    );
  });

  testWidgets('employee directory table edits employee from profile detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
        child: const MaterialApp(home: EmployeeDirectoryTableScreen()),
      ),
    );

    final profileCell = find.byKey(
      const ValueKey('employee-directory-table-name-1'),
    );
    await tester.ensureVisible(profileCell);
    await tester.tap(profileCell);
    await tester.pumpAndSettle();

    final editButton = find.byKey(
      const ValueKey('employee-directory-detail-edit-icon-button'),
    );
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    expect(find.text('Update employee profile'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-name-field')),
      'Sarah Johnson Lee',
    );
    await tester.enterText(
      find.byKey(const ValueKey('employee-directory-intake-position-field')),
      'Lead UX Designer',
    );

    final submitButton = find.byKey(
      const ValueKey('employee-directory-intake-submit-button'),
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Sarah Johnson Lee profile updated'), findsOneWidget);
    expect(find.text('Sarah Johnson Lee updated'), findsOneWidget);
    expect(find.text('Updated profile'), findsOneWidget);
    expect(find.text('Sarah Johnson Lee'), findsOneWidget);
    expect(find.text('Lead UX Designer'), findsOneWidget);
    expect(find.text('Sarah Johnson'), findsNothing);
  });
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: '+62 812 0000 0000',
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
