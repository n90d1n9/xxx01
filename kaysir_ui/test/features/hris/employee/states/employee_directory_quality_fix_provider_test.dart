import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_fix_provider.dart';

void main() {
  test(
    'employee directory quality fix review is empty when roster is clean',
    () {
      final container = ProviderContainer(
        overrides: [
          employeeDirectoryAsOfDateProvider.overrideWithValue(
            DateTime(2026, 5, 30),
          ),
        ],
      );
      addTearDown(container.dispose);

      final review = container.read(employeeDirectoryQualityFixReviewProvider);

      expect(review.hasIssue, isFalse);
      expect(review.issueCount, 0);
      expect(review.statusLabel, 'No issue');
      expect(review.canSubmit, isFalse);
    },
  );

  test(
    'employee directory quality fix review validates duplicate email fix',
    () {
      final container = _containerWithIssues();
      addTearDown(container.dispose);

      final draft = container.read(
        employeeDirectoryQualityFixDraftProvider.notifier,
      );
      draft.selectIssue(
        '2:${EmployeeDirectoryQualityIssueType.duplicateEmail.name}',
      );
      draft.setEmail('maya.fixed@example.com');
      draft.setAuditNote('Duplicate email corrected');

      final review = container.read(employeeDirectoryQualityFixReviewProvider);

      expect(review.hasIssue, isTrue);
      expect(review.issue!.employeeName, 'Maya Santoso');
      expect(
        review.issue!.type,
        EmployeeDirectoryQualityIssueType.duplicateEmail,
      );
      expect(review.requiresEmail, isTrue);
      expect(review.requiredFieldCount, 1);
      expect(review.canSubmit, isTrue);

      final updated = review.applyToMember();
      expect(updated.email, 'maya.fixed@example.com');
      expect(updated.manager, isEmpty);
    },
  );

  test(
    'employee directory quality fix review validates missing manager fix',
    () {
      final container = _containerWithIssues();
      addTearDown(container.dispose);

      final draft = container.read(
        employeeDirectoryQualityFixDraftProvider.notifier,
      );
      draft.selectIssue(
        '2:${EmployeeDirectoryQualityIssueType.missingManager.name}',
      );
      draft.setManager('People Ops Lead');
      draft.setAuditNote('Manager assigned');

      final review = container.read(employeeDirectoryQualityFixReviewProvider);

      expect(
        review.issue!.type,
        EmployeeDirectoryQualityIssueType.missingManager,
      );
      expect(review.requiresManager, isTrue);
      expect(review.canSubmit, isTrue);
      expect(review.applyToMember().manager, 'People Ops Lead');
    },
  );

  test(
    'employee directory quality fix review blocks duplicate replacement email',
    () {
      final container = _containerWithIssues();
      addTearDown(container.dispose);

      final draft = container.read(
        employeeDirectoryQualityFixDraftProvider.notifier,
      );
      draft.selectIssue(
        '2:${EmployeeDirectoryQualityIssueType.duplicateEmail.name}',
      );
      draft.setEmail('sarah@example.com');
      draft.setAuditNote('Duplicate email corrected');

      final review = container.read(employeeDirectoryQualityFixReviewProvider);

      expect(review.canSubmit, isFalse);
      expect(
        review.errors,
        contains('Email must be unique across the directory.'),
      );
    },
  );
}

ProviderContainer _containerWithIssues() {
  return ProviderContainer(
    overrides: [
      employeeDirectoryAsOfDateProvider.overrideWithValue(
        DateTime(2026, 5, 30),
      ),
      employeeDirectoryMembersProvider.overrideWith(
        (ref) => EmployeeDirectoryNotifier([
          _member(id: '1', name: 'Sarah Johnson', email: 'sarah@example.com'),
          _member(
            id: '2',
            name: 'Maya Santoso',
            email: 'shared@example.com',
            manager: '',
          ),
          _member(id: '3', name: 'Rafi Pratama', email: 'shared@example.com'),
        ]),
      ),
    ],
  );
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  required String email,
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
