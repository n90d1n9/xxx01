import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_relations_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_relations_provider.dart';

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

  test('employee relations profile highlights overdue corrective events', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeRelationsProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.correctiveOpenCount, 2);
    expect(profile.overdueFollowUpCount, 1);
    expect(profile.highSeverityOpenCount, 1);
    expect(profile.attentionCount, 1);
    expect(
      profile.nextAction,
      'Follow up on 1 overdue employee relations event.',
    );
  });

  test('employee relations draft records recognition event', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeRelationsEventDraftProvider('3').notifier,
    );
    draftNotifier.setType(EmployeeRelationsEventType.commendation);
    draftNotifier.setTitle('Commend customer recovery work');
    draftNotifier.setSummary(
      'Recognized calm ownership during a customer escalation.',
    );
    draftNotifier.setVisibility(EmployeeRelationsVisibility.team);

    final draft = container.read(employeeRelationsEventDraftProvider('3'))!;
    expect(draft.isReadyToAdd, isTrue);
    expect(draft.completionRatio, 1);

    final profileNotifier = container.read(
      employeeRelationsProfileProvider('3').notifier,
    );
    final event = profileNotifier.recordEvent(draft);

    expect(event.id, 'ERL-3-002');
    expect(event.status, EmployeeRelationsStatus.documented);
    expect(event.followUpDate, isNull);

    final profile = container.read(employeeRelationsProfileProvider('3'))!;
    expect(profile.recognitionCount, 2);
    expect(profile.events.first.title, 'Commend customer recovery work');
  });

  test('employee relations actions start and resolve follow-up', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeRelationsProfileProvider('4').notifier,
    );

    notifier.startFollowUp('ERL-4-001');
    var profile = container.read(employeeRelationsProfileProvider('4'))!;
    expect(
      profile.events.singleWhere((event) => event.id == 'ERL-4-001').status,
      EmployeeRelationsStatus.inProgress,
    );
    expect(profile.attentionCount, 1);

    notifier.resolveEvent('ERL-4-001');
    profile = container.read(employeeRelationsProfileProvider('4'))!;

    expect(profile.attentionCount, 0);
    expect(profile.correctiveOpenCount, 1);
    expect(
      profile.events.singleWhere((event) => event.id == 'ERL-4-001').status,
      EmployeeRelationsStatus.resolved,
    );
  });
}
