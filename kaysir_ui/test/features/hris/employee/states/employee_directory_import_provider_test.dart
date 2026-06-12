import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_import_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

void main() {
  test('employee directory import preview validates ready and error rows', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectoryImportCsvProvider.notifier).state = '''
name,email,phone,position,department,manager,location,joining_date,performance,status
Maya Santoso,maya.santoso@example.com,+62 812 1111 2222,HR Analyst,People Operations,Emma Rodriguez,Jakarta,2026-05-15,4.3,Onboarding
Sarah Copy,sarah.johnson@company.com,+62 812 1111 3333,Designer,Design,Emma Rodriguez,Jakarta,2026-05-16,4.5,Active
Broken Row,broken@example.com,+62 812 1111 4444,Analyst,People Operations,Emma Rodriguez,Jakarta,not-a-date,8.1,Pending
''';

    final preview = container.read(employeeDirectoryImportPreviewProvider);

    expect(preview.totalRows, 3);
    expect(preview.validCount, 1);
    expect(preview.errorCount, 2);
    expect(preview.duplicateEmailCount, 1);
    expect(preview.validRows.single.draft.name, 'Maya Santoso');
    expect(
      preview.errorRows.first.errors,
      contains('Email already exists in directory'),
    );
    expect(
      preview.errorRows.last.errors,
      contains('Status must be Active, Onboarding, or Watchlist'),
    );
  });

  test('employee directory import preview reports missing columns', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(employeeDirectoryImportCsvProvider.notifier).state =
        'name,email\nMissing Columns,missing@example.com';

    final preview = container.read(employeeDirectoryImportPreviewProvider);

    expect(preview.rows, isEmpty);
    expect(preview.validCount, 0);
    expect(preview.errorCount, 1);
    expect(preview.headerErrors.single, contains('Missing columns'));
  });

  test('employee directory import template produces ready rows', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(employeeDirectoryImportCsvProvider.notifier).state =
        employeeDirectoryImportTemplateCsv;

    final preview = container.read(employeeDirectoryImportPreviewProvider);

    expect(preview.totalRows, 2);
    expect(preview.validCount, 2);
    expect(preview.errorCount, 0);
  });
}
