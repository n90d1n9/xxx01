import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_bulk_profile_update_preview_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_bulk_profile_update_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_table_provider.dart';

void main() {
  test('employee directory bulk update preview starts blocked', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    final preview = container.read(
      employeeDirectoryBulkProfileUpdatePreviewProvider,
    );

    expect(preview.selectedCount, 0);
    expect(preview.changedProfileCount, 0);
    expect(preview.effectiveChangeCount, 0);
    expect(preview.isReady, isFalse);
    expect(preview.canApply, isFalse);
    expect(preview.approvalLabel, 'Blocked');
    expect(preview.errors, contains('Select at least one employee profile.'));
  });

  test('employee directory bulk update preview approves effective changes', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['1', '4']);
    final draft = container.read(
      employeeDirectoryBulkProfileUpdateDraftProvider.notifier,
    );
    draft.setManager('People Ops Lead');
    draft.setDepartment('People Operations');
    draft.setAuditNote('Manager and department realignment approved');

    var preview = container.read(
      employeeDirectoryBulkProfileUpdatePreviewProvider,
    );

    expect(preview.selectedCount, 2);
    expect(preview.changedProfileCount, 2);
    expect(preview.effectiveChangeCount, 4);
    expect(preview.targetFieldCount, 2);
    expect(preview.isReady, isTrue);
    expect(preview.isApproved, isFalse);
    expect(preview.canApply, isFalse);
    expect(preview.approvalLabel, 'Needs approval');
    expect(preview.visibleRows.map((row) => row.member.name), [
      'Sarah Johnson',
      'David Kim',
    ]);

    draft.setPreviewApproved(true, approvalSignature: preview.signature);
    preview = container.read(employeeDirectoryBulkProfileUpdatePreviewProvider);

    expect(preview.isApproved, isTrue);
    expect(preview.canApply, isTrue);

    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['2']);
    preview = container.read(employeeDirectoryBulkProfileUpdatePreviewProvider);

    expect(preview.selectedCount, 3);
    expect(preview.isApproved, isFalse);
    expect(preview.canApply, isFalse);
  });

  test('employee directory bulk update preview blocks no-op changes', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(employeeDirectoryTableSelectedIdsProvider.notifier)
        .selectMany(['1']);
    final draft = container.read(
      employeeDirectoryBulkProfileUpdateDraftProvider.notifier,
    );
    draft.setManager('Emma Rodriguez');
    draft.setAuditNote('Manager reviewed and confirmed');

    final preview = container.read(
      employeeDirectoryBulkProfileUpdatePreviewProvider,
    );

    expect(preview.changedProfileCount, 0);
    expect(preview.effectiveChangeCount, 0);
    expect(preview.isReady, isFalse);
    expect(
      preview.errors,
      contains('Change at least one selected profile value.'),
    );
  });
}
