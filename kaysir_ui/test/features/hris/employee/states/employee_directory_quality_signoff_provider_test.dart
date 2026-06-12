import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_quality_gate_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_quality_signoff_provider.dart';

void main() {
  test('employee directory quality sign-off blocks critical gate', () {
    final container = ProviderContainer(
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
            _member(id: '2', name: 'Maya Santoso', email: 'shared@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final review = container.read(
      employeeDirectoryQualityGateSignoffReviewProvider,
    );

    expect(review.canSubmit, isFalse);
    expect(review.statusLabel, 'Blocked');
    expect(review.errors.first, 'Resolve 2 payroll blockers before sign-off.');
  });

  test('employee directory quality sign-off accepts review items', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(
              id: '1',
              name: 'Sarah Johnson',
              email: 'sarah@example.com',
              manager: '',
            ),
            _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final draft = container.read(
      employeeDirectoryQualityGateSignoffDraftProvider.notifier,
    );
    draft.setReviewer('Alya Rahman');
    draft.setNote('Reviewed manager routing before cutoff.');

    var review = container.read(
      employeeDirectoryQualityGateSignoffReviewProvider,
    );
    expect(review.canSubmit, isFalse);
    expect(
      review.errors.first,
      'Accept 1 review item or resolve before sign-off.',
    );

    draft.setAcceptReviewItems(true);
    review = container.read(employeeDirectoryQualityGateSignoffReviewProvider);

    expect(review.canSubmit, isTrue);
    expect(review.statusLabel, 'Ready');

    final signoff = review.toSignoff(
      id: 'quality-gate-1',
      signedAt: DateTime(2026, 5, 30),
    );
    expect(signoff.gateStatus, EmployeeDirectoryQualityGateStatus.review);
    expect(signoff.acceptedReviewCount, 1);
    expect(signoff.summaryLabel, '50% readiness with 1 accepted review item.');
  });

  test('employee directory quality sign-off records ready gate history', () {
    final container = ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
        employeeDirectoryMembersProvider.overrideWith(
          (ref) => EmployeeDirectoryNotifier([
            _member(id: '1', name: 'Sarah Johnson', email: 'sarah@example.com'),
            _member(id: '2', name: 'Maya Santoso', email: 'maya@example.com'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final draft = container.read(
      employeeDirectoryQualityGateSignoffDraftProvider.notifier,
    );
    draft.setReviewer('Alya Rahman');
    draft.setNote('Roster gate reviewed and ready.');

    final review = container.read(
      employeeDirectoryQualityGateSignoffReviewProvider,
    );
    final signoff = review.toSignoff(
      id: 'quality-gate-1',
      signedAt: DateTime(2026, 5, 30),
    );
    container
        .read(employeeDirectoryQualityGateSignoffsProvider.notifier)
        .add(signoff);

    final history = container.read(
      employeeDirectoryQualityGateSignoffsProvider,
    );
    expect(review.canSubmit, isTrue);
    expect(history, hasLength(1));
    expect(history.first.statusLabel, 'Ready');
    expect(history.first.summaryLabel, '100% readiness across 2 profiles.');
  });
}

EmployeeDirectoryMember _member({
  required String id,
  required String name,
  String email = 'person@example.com',
  String phone = '+62 812 0000 0000',
  String manager = 'Emma Rodriguez',
}) {
  return EmployeeDirectoryMember(
    id: id,
    name: name,
    position: 'HR Analyst',
    department: 'People Operations',
    avatarUrl: 'https://example.com/avatar.png',
    email: email,
    phone: phone,
    joiningDate: DateTime(2024, 1, 1),
    performance: 4.4,
    location: 'Jakarta',
    manager: manager,
    status: EmployeeDirectoryStatus.active,
  );
}
