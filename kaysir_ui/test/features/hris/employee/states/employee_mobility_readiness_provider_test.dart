import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_mobility_readiness_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_mobility_readiness_provider.dart';

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

  test('employee mobility readiness highlights blocked gates', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeMobilityReadinessProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.moveType, EmployeeMobilityMoveType.projectAssignment);
    expect(profile.targetSummary, contains('Senior Product Manager'));
    expect(profile.blockedCount, 1);
    expect(profile.overdueCount, 1);
    expect(profile.highRiskOpenCount, 2);
    expect(profile.attentionCount, 3);
    expect(profile.isEffectiveSoon, isTrue);
    expect(profile.nextAction, 'Clear 1 blocked mobility gate.');
  });

  test('employee mobility readiness adds updates and waives gates', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeMobilityGateDraftProvider('2').notifier,
    );
    draftNotifier.setType(EmployeeMobilityGateType.access);
    draftNotifier.setTitle('Confirm production access migration');
    draftNotifier.setOwner('IT Security');
    draftNotifier.setRisk(EmployeeMobilityGateRisk.high);
    draftNotifier.setDueDate(DateTime(2026, 6, 6));
    draftNotifier.setDetail('Move access grants to the leadership group.');

    final draft = container.read(employeeMobilityGateDraftProvider('2'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final readinessNotifier = container.read(
      employeeMobilityReadinessProvider('2').notifier,
    );
    final gate = readinessNotifier.addGate(draft);

    expect(gate.id, 'MOB-2-004');
    expect(gate.status, EmployeeMobilityGateStatus.actionRequired);

    readinessNotifier.updateGateStatus(
      gate.id,
      EmployeeMobilityGateStatus.ready,
    );
    var profile = container.read(employeeMobilityReadinessProvider('2'))!;

    expect(
      profile.gates.singleWhere((entry) => entry.id == gate.id).isComplete,
      isTrue,
    );

    readinessNotifier.waiveGate('2-mobility-access');
    profile = container.read(employeeMobilityReadinessProvider('2'))!;

    expect(profile.waivedCount, 1);
    expect(
      profile.gates
          .singleWhere((entry) => entry.id == '2-mobility-access')
          .status,
      EmployeeMobilityGateStatus.waived,
    );
  });

  test('employee mobility readiness returns null for missing employee', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    expect(
      container.read(employeeMobilityReadinessProvider('missing')),
      isNull,
    );
    expect(
      container.read(employeeMobilityGateDraftProvider('missing')),
      isNull,
    );
  });
}
