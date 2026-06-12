import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_succession_plan_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_succession_plan_provider.dart';

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

  test('employee succession profile highlights critical coverage gaps', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeSuccessionProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.criticality, EmployeeSuccessionCriticality.critical);
    expect(profile.coverageStatus, EmployeeSuccessionCoverageStatus.gap);
    expect(profile.readyNowCount, 0);
    expect(profile.readySoonCount, 1);
    expect(profile.developingCount, 1);
    expect(profile.coverageGapCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.highRiskCount, 1);
    expect(profile.attentionCount, 3);
    expect(profile.benchStrength, closeTo(0.3676, 0.0001));
    expect(
      profile.nextAction,
      'Nominate a ready-now successor for Product Manager.',
    );
  });

  test('employee succession draft validates and appends candidate', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeSuccessionCandidateDraftProvider('2').notifier,
    );
    draftNotifier.setName('Lina Wijaya');
    draftNotifier.setCurrentRole('Platform Engineer');
    draftNotifier.setTargetRole('Senior Developer');
    draftNotifier.setReadiness(EmployeeSuccessionReadiness.readyNow);
    draftNotifier.setRisk(EmployeeSuccessionRisk.low);
    draftNotifier.setActionType(EmployeeSuccessionActionType.retentionCheck);
    draftNotifier.setOwner('Engineering Talent Council');
    draftNotifier.setReviewDate(DateTime(2026, 6, 20));
    draftNotifier.setBenchScore(86);
    draftNotifier.setNotes('Ready for interim leadership coverage.');

    final draft =
        container.read(employeeSuccessionCandidateDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final notifier = container.read(
      employeeSuccessionProfileProvider('2').notifier,
    );
    final candidate = notifier.addCandidate(draft);

    expect(candidate.id, 'ESP-2-003');
    expect(candidate.readiness, EmployeeSuccessionReadiness.readyNow);

    notifier.updateRisk(candidate.id, EmployeeSuccessionRisk.high);
    var profile = container.read(employeeSuccessionProfileProvider('2'))!;

    expect(
      profile.candidates.singleWhere((entry) => entry.id == candidate.id).risk,
      EmployeeSuccessionRisk.high,
    );

    notifier.removeCandidate(candidate.id);
    profile = container.read(employeeSuccessionProfileProvider('2'))!;

    expect(
      profile.candidates.any((entry) => entry.id == candidate.id),
      isFalse,
    );
  });

  test('employee succession provider returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeSuccessionProfileProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeeSuccessionCandidateDraftProvider('missing')),
      isNull,
    );
  });
}
