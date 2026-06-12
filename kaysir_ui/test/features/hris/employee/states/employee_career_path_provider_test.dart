import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_career_path_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_career_path_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';

void main() {
  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        employeeDirectoryAsOfDateProvider.overrideWithValue(
          DateTime(2026, 5, 30),
        ),
      ],
    );
  }

  test('employee career path highlights succession and review gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeCareerPathProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.path.readiness, EmployeeCareerReadiness.developing);
    expect(
      profile.path.successionCoverage,
      EmployeeSuccessionCoverage.uncovered,
    );
    expect(profile.successionGapCount, 1);
    expect(profile.reviewDueCount, 1);
    expect(profile.proposedMoveCount, 1);
    expect(profile.attentionCount, 3);
    expect(
      profile.nextAction,
      'Close uncovered critical-role succession coverage.',
    );
  });

  test('employee career move draft submits proposal', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeCareerMoveDraftProvider('3').notifier,
    );
    draftNotifier.setType(EmployeeCareerMoveType.promotion);
    draftNotifier.setTitle('Promotion readiness panel');
    draftNotifier.setTargetRole('People Operations Lead');
    draftNotifier.setSummary(
      'Prepare promotion panel after readiness calibration.',
    );

    final draft = container.read(employeeCareerMoveDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeCareerPathProfileProvider('3').notifier,
    );
    final request = profileNotifier.submitDraft(draft);

    expect(request.id, 'ECP-3-001');
    expect(request.status, EmployeeCareerMoveStatus.proposed);

    final profile = container.read(employeeCareerPathProfileProvider('3'))!;
    expect(profile.proposedMoveCount, 1);
    expect(profile.moves.first.title, 'Promotion readiness panel');
  });

  test('employee career path actions resolve review and move queue', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeCareerPathProfileProvider('4').notifier,
    );

    notifier.markReviewed();
    notifier.setSuccessionCoverage(EmployeeSuccessionCoverage.covered);
    notifier.approveMove('ECP-4-001');
    notifier.activateMove('ECP-4-001');
    notifier.completeMove('ECP-4-001');

    final profile = container.read(employeeCareerPathProfileProvider('4'))!;

    expect(profile.successionGapCount, 0);
    expect(profile.reviewDueCount, 0);
    expect(profile.proposedMoveCount, 0);
    expect(profile.activeMoveCount, 0);
    expect(profile.attentionCount, 0);
    expect(
      profile.moves.singleWhere((move) => move.id == 'ECP-4-001').status,
      EmployeeCareerMoveStatus.completed,
    );
  });
}
