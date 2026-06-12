import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_org_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_org_provider.dart';

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

  test('employee org profile detects reporting loop and span risk', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeOrgProfileProvider('5'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'Olivia Wilson');
    expect(profile.manager!.name, 'Emma Rodriguez');
    expect(profile.directReportCount, 2);
    expect(profile.peerCount, 1);
    expect(profile.pendingRelationshipCount, 1);
    expect(profile.risks.map((risk) => risk.type), [
      EmployeeOrgRiskType.reportingLoop,
      EmployeeOrgRiskType.managerSpan,
      EmployeeOrgRiskType.watchlistReport,
      EmployeeOrgRiskType.successionGap,
    ]);
    expect(profile.attentionCount, 5);
    expect(profile.nextAction, 'Resolve reporting-line loop.');
  });

  test(
    'employee org relationship draft validates and appends relationship',
    () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final draftNotifier = container.read(
        employeeOrgRelationshipDraftProvider('1').notifier,
      );
      draftNotifier.setType(EmployeeOrgRelationshipType.matrixPartner);
      draftNotifier.setRelatedEmployeeName('Michael Chen');
      draftNotifier.setReason('Pair on design systems delivery coverage.');

      final draft = container.read(employeeOrgRelationshipDraftProvider('1'))!;
      expect(draft.isReadyToSubmit, isTrue);
      expect(draft.completionRatio, 1);

      final profileNotifier = container.read(
        employeeOrgProfileProvider('1').notifier,
      );
      final relationship = profileNotifier.addDraft(draft);

      expect(relationship.id, 'EOR-1-002');
      expect(relationship.status, EmployeeOrgRelationshipStatus.pending);
      expect(
        container.read(employeeOrgProfileProvider('1'))!.attentionCount,
        1,
      );
    },
  );

  test('employee org actions activate backup and acknowledge risks', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeOrgRelationshipDraftProvider('4').notifier,
    );
    draftNotifier.setType(EmployeeOrgRelationshipType.backupApprover);
    draftNotifier.setRelatedEmployeeName('Michael Chen');
    draftNotifier.setReason('Backup approval coverage for platform delivery.');

    final profileNotifier = container.read(
      employeeOrgProfileProvider('4').notifier,
    );
    final backup = profileNotifier.addDraft(
      container.read(employeeOrgRelationshipDraftProvider('4'))!,
    );
    profileNotifier.activateRelationship(backup.id);

    final updated = container.read(employeeOrgProfileProvider('4'))!;

    expect(updated.riskCount, 0);
    expect(updated.activeRelationshipCount, 1);
    expect(updated.pendingRelationshipCount, 1);
    expect(updated.nextAction, 'Activate 1 pending org relationship.');

    final loopProfileNotifier = container.read(
      employeeOrgProfileProvider('5').notifier,
    );
    loopProfileNotifier.acknowledgeRisk('EORISK-5-loop');

    final loopUpdated = container.read(employeeOrgProfileProvider('5'))!;
    expect(loopUpdated.riskCount, 3);
    expect(loopUpdated.nextAction, 'Activate 1 pending org relationship.');
  });
}
