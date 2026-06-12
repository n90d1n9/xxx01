import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/employee/models/employee_timeline_models.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_timeline_provider.dart';

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

  test('employee timeline profile highlights overdue follow-ups', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final profile = container.read(employeeTimelineProfileProvider('4'));

    expect(profile, isNotNull);
    expect(profile!.employeeName, 'David Kim');
    expect(profile.pinnedCount, 2);
    expect(profile.openFollowUpCount, 2);
    expect(profile.overdueCount, 1);
    expect(profile.attentionCount, 2);
    expect(profile.nextAction, 'Resolve 1 overdue timeline follow-up.');
  });

  test('employee timeline draft validates and appends entry', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final draftNotifier = container.read(
      employeeTimelineDraftProvider('3').notifier,
    );
    draftNotifier
      ..setTitle('Manager follow-up')
      ..setDetail('Confirm HR operations coverage plan.');

    final draft = container.read(employeeTimelineDraftProvider('3'))!;
    expect(draft.isReadyToSubmit, isTrue);

    final profileNotifier = container.read(
      employeeTimelineProfileProvider('3').notifier,
    );
    final entry = profileNotifier.addDraft(draft);
    final profile = container.read(employeeTimelineProfileProvider('3'))!;

    expect(entry.id, 'ETL-3-002');
    expect(entry.status, EmployeeTimelineStatus.open);
    expect(profile.openFollowUpCount, 1);
    expect(profile.entries.first.detail, contains('coverage'));
  });

  test('employee timeline actions resolve reopen and pin entries', () {
    final container = buildContainer();
    addTearDown(container.dispose);

    final notifier = container.read(
      employeeTimelineProfileProvider('4').notifier,
    );

    notifier.resolveEntry('ETL-4-001');
    var profile = container.read(employeeTimelineProfileProvider('4'))!;
    expect(profile.overdueCount, 0);
    expect(profile.attentionCount, 1);

    notifier.reopenEntry('ETL-4-001');
    profile = container.read(employeeTimelineProfileProvider('4'))!;
    expect(profile.overdueCount, 1);

    notifier.togglePinned('ETL-4-002');
    profile = container.read(employeeTimelineProfileProvider('4'))!;
    expect(profile.pinnedCount, 3);
  });
}
