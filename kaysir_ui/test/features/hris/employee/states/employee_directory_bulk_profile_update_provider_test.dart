import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_bulk_profile_update_provider.dart';

void main() {
  test('employee directory bulk profile draft validates readiness', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeDirectoryBulkProfileUpdateDraftProvider.notifier,
    );

    expect(
      container
          .read(employeeDirectoryBulkProfileUpdateDraftProvider)
          .isReady(2),
      isFalse,
    );

    notifier.setManager('People Ops Lead');
    notifier.setAuditNote('Manager realignment approved');

    final draft = container.read(
      employeeDirectoryBulkProfileUpdateDraftProvider,
    );

    expect(draft.isReady(2), isTrue);
    expect(draft.targetFieldCount, 1);
    expect(draft.changedFieldLabels, ['manager']);
    expect(
      draft.validationErrors(0),
      contains('Select at least one employee profile.'),
    );

    notifier.setPreviewApproved(true, approvalSignature: 'preview-1');
    expect(
      container
          .read(employeeDirectoryBulkProfileUpdateDraftProvider)
          .previewApproved,
      isTrue,
    );
    expect(
      container
          .read(employeeDirectoryBulkProfileUpdateDraftProvider)
          .previewApprovalSignature,
      'preview-1',
    );

    notifier.setAuditNote('Manager realignment confirmed');
    expect(
      container
          .read(employeeDirectoryBulkProfileUpdateDraftProvider)
          .previewApproved,
      isFalse,
    );
    expect(
      container
          .read(employeeDirectoryBulkProfileUpdateDraftProvider)
          .previewApprovalSignature,
      isEmpty,
    );
  });

  test(
    'employee directory bulk profile draft applies selected fields only',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        employeeDirectoryBulkProfileUpdateDraftProvider.notifier,
      );
      notifier.setDepartment('People Operations');
      notifier.setLocation('Jakarta');
      notifier.setAuditNote('Department move approved');

      final updated = container
          .read(employeeDirectoryBulkProfileUpdateDraftProvider)
          .applyTo(_member());

      expect(updated.manager, 'Emma Rodriguez');
      expect(updated.department, 'People Operations');
      expect(updated.location, 'Jakarta');

      notifier.clear();

      expect(
        container
            .read(employeeDirectoryBulkProfileUpdateDraftProvider)
            .hasInput,
        isFalse,
      );
    },
  );
}

EmployeeDirectoryMember _member() {
  return EmployeeDirectoryMember(
    id: '1',
    name: 'Sarah Johnson',
    position: 'UX Designer',
    department: 'Design',
    avatarUrl: 'https://example.com/avatar.png',
    email: 'sarah.johnson@example.com',
    phone: '+62 812 0000 0000',
    joiningDate: DateTime(2022, 4, 15),
    performance: 4.7,
    location: 'Bandung',
    manager: 'Emma Rodriguez',
    status: EmployeeDirectoryStatus.active,
  );
}
