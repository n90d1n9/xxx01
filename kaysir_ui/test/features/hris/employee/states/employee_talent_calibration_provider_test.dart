import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/employee/models/employee_talent_calibration_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_talent_calibration_provider.dart';

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

  test('employee talent calibration highlights overdue watchlist actions', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeTalentCalibrationProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.performanceBand, EmployeeTalentPerformanceBand.inconsistent);
    expect(profile.potentialBand, EmployeeTalentPotentialBand.growth);
    expect(profile.riskLevel, EmployeeTalentRiskLevel.high);
    expect(profile.decision, EmployeeTalentCalibrationDecision.stabilize);
    expect(profile.status, EmployeeTalentCalibrationStatus.actionDue);
    expect(profile.isReviewDue, isTrue);
    expect(profile.openFollowUpCount, 2);
    expect(profile.overdueFollowUpCount, 1);
    expect(profile.attentionCount, 4);
    expect(profile.talentScore, 38);
    expect(profile.nextAction, 'Complete 1 overdue calibration follow-up.');
  });

  test('employee talent follow-up draft validates and appends action', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeTalentFollowUpDraftProvider('2').notifier,
    );
    draftNotifier.setType(EmployeeTalentFollowUpType.compensationReview);
    draftNotifier.setTitle('Review retention award');
    draftNotifier.setOwner('Talent Council');
    draftNotifier.setNotes('Align reward with platform leadership slate.');

    final draft = container.read(employeeTalentFollowUpDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeeTalentCalibrationProvider('2').notifier,
    );
    final followUp = notifier.addFollowUp(draft);

    expect(followUp.id, 'ETC-2-002');
    expect(followUp.status, EmployeeTalentFollowUpStatus.open);

    notifier.startFollowUp(followUp.id);
    var profile = container.read(employeeTalentCalibrationProvider('2'))!;
    var stored = profile.followUps.singleWhere(
      (item) => item.id == followUp.id,
    );
    expect(stored.status, EmployeeTalentFollowUpStatus.inProgress);

    notifier.completeFollowUp(followUp.id);
    profile = container.read(employeeTalentCalibrationProvider('2'))!;
    stored = profile.followUps.singleWhere((item) => item.id == followUp.id);
    expect(stored.status, EmployeeTalentFollowUpStatus.completed);

    notifier.markDisputed();
    profile = container.read(employeeTalentCalibrationProvider('2'))!;
    expect(profile.status, EmployeeTalentCalibrationStatus.disputed);

    notifier.markCalibrated();
    profile = container.read(employeeTalentCalibrationProvider('2'))!;
    expect(profile.status, EmployeeTalentCalibrationStatus.calibrated);
    expect(profile.lastCalibratedDate, DateTime(2026, 5, 30));

    notifier.removeFollowUp(followUp.id);
    profile = container.read(employeeTalentCalibrationProvider('2'))!;
    expect(profile.followUps.any((item) => item.id == followUp.id), isFalse);
  });

  test('employee talent calibration returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeTalentCalibrationProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeeTalentFollowUpDraftProvider('missing')),
      isNull,
    );
  });
}
