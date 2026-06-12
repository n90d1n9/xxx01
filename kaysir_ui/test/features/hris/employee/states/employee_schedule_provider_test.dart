import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_schedule_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_schedule_provider.dart';

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

  test('employee schedule highlights watchlist attendance risk', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeScheduleProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.assignment.pattern, EmployeeSchedulePattern.flexible);
    expect(profile.attendanceRiskCount, 2);
    expect(profile.highSeverityCount, 1);
    expect(profile.pendingAdjustmentCount, 0);
    expect(profile.nextAction, 'Review 1 high-risk attendance signal.');
  });

  test('employee schedule adjustment draft validates and appends request', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeScheduleAdjustmentDraftProvider('3').notifier,
    );
    draftNotifier.setStartTime('10:00');
    draftNotifier.setEndTime('18:00');
    draftNotifier.setReason('Temporary coverage for HR operations desk.');

    final draft = container.read(employeeScheduleAdjustmentDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeScheduleProfileProvider('3').notifier,
    );
    final request = profileNotifier.addDraft(draft);

    expect(request.id, 'ESA-3-001');
    expect(request.status, EmployeeScheduleAdjustmentStatus.pending);
    expect(
      container
          .read(employeeScheduleProfileProvider('3'))!
          .pendingAdjustmentCount,
      1,
    );
  });

  test(
    'employee schedule actions resolve signals and apply approved request',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final watchlistNotifier = container.read(
        employeeScheduleProfileProvider('4').notifier,
      );
      watchlistNotifier.resolveSignal('EAS-4-001');
      watchlistNotifier.resolveSignal('EAS-4-002');

      final watchlistProfile =
          container.read(employeeScheduleProfileProvider('4'))!;
      expect(watchlistProfile.attendanceRiskCount, 0);
      expect(
        watchlistProfile.nextAction,
        'Schedule and attendance are aligned.',
      );

      final highPerformerNotifier = container.read(
        employeeScheduleProfileProvider('1').notifier,
      );
      expect(
        container
            .read(employeeScheduleProfileProvider('1'))!
            .approvedAdjustmentCount,
        1,
      );

      highPerformerNotifier.applyAdjustment('ESA-1-001');

      final highPerformerProfile =
          container.read(employeeScheduleProfileProvider('1'))!;
      expect(highPerformerProfile.approvedAdjustmentCount, 0);
      expect(highPerformerProfile.attentionCount, 0);
      expect(
        highPerformerProfile.adjustments.single.status,
        EmployeeScheduleAdjustmentStatus.applied,
      );
    },
  );
}
