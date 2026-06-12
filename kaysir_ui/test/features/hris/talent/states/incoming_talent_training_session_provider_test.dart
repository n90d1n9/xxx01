import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_development_program_models.dart';
import 'package:kaysir/features/hris/talent/models/incoming_talent_training_session_models.dart';
import 'package:kaysir/features/hris/talent/states/incoming_talent_training_session_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test('training session draft defaults from development program', () {
    final asOfDate = DateTime(2026, 6, 9);
    final program = _program(asOfDate);

    final draft = IncomingTalentTrainingSessionDraft.fromProgram(
      program: program,
      asOfDate: asOfDate,
    );

    expect(draft.programId, program.id);
    expect(draft.programTitle, program.title);
    expect(draft.trainerName, program.ownerName);
    expect(draft.format, IncomingTalentTrainingSessionFormat.hybrid);
    expect(draft.status, IncomingTalentTrainingSessionStatus.scheduled);
    expect(draft.capacity, 12);
    expect(draft.sessionDate, asOfDate.add(const Duration(days: 7)));
    expect(draft.followUpDate, asOfDate.add(const Duration(days: 21)));
    expect(draft.isReadyToSubmit, isTrue);
  });

  test('training sessions submit, prevent duplicates, and summarize', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate);
    addTearDown(container.dispose);
    final program = _program(asOfDate);

    final session = _submitSession(container, program, reservedSeats: 8);

    expect(session.id, 'talent-training-session-001');
    expect(session.fillRatio, closeTo(8 / 12, 0.001));
    expect(session.needsAttention, isFalse);
    expect(session.openSeats, 4);

    expect(
      () => _submitSession(container, program, reservedSeats: 6),
      throwsStateError,
    );

    final summary = container.read(
      incomingTalentTrainingSessionSummaryProvider,
    );
    expect(summary.totalCount, 1);
    expect(summary.scheduledCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.reservedSeatCount, 8);
    expect(summary.totalCapacity, 12);
    expect(summary.nextAction, 'Prepare 1 training sessions starting soon.');
  });

  test('training session draft validates schedule fields', () {
    final asOfDate = DateTime(2026, 6, 9);
    final draft = IncomingTalentTrainingSessionDraft.empty(asOfDate).copyWith(
      prerequisite: 'short',
      outcomeCheckpoint: 'tiny',
      capacity: 0,
      reservedSeats: -1,
      sessionDate: asOfDate.subtract(const Duration(days: 1)),
      followUpDate: asOfDate.subtract(const Duration(days: 1)),
    );

    expect(draft.isReadyToSubmit, isFalse);
    expect(draft.validationErrors, [
      'Please enter a development program',
      'Please enter a trainer',
      'Please enter a location',
      'Prerequisite must be at least 12 characters',
      'Outcome checkpoint must be at least 12 characters',
      'Capacity must be at least 1',
      'Reserved seats cannot be negative',
      'Session date cannot be in the past',
      'Follow-up date must be after the session date',
    ]);
  });

  test('training sessions follow department and attention filters', () {
    final asOfDate = DateTime(2026, 6, 9);
    final container = _container(asOfDate);
    addTearDown(container.dispose);
    final engineeringProgram = _program(asOfDate);
    final financeProgram = _program(
      asOfDate,
      id: 'program-finance',
      title: 'Finance recovery academy',
      department: 'Finance',
      track: IncomingTalentDevelopmentProgramTrack.recovery,
      intensity: IncomingTalentDevelopmentProgramIntensity.accelerated,
    );

    _submitSession(container, engineeringProgram, reservedSeats: 8);
    _submitSession(
      container,
      financeProgram,
      status: IncomingTalentTrainingSessionStatus.draft,
      reservedSeats: 0,
    );

    container.read(talentDepartmentProvider.notifier).state = 'Finance';
    container.read(talentNeedsAttentionProvider.notifier).state = true;

    final filtered = container.read(
      filteredIncomingTalentTrainingSessionsProvider,
    );
    final summary = container.read(
      incomingTalentTrainingSessionSummaryProvider,
    );

    expect(filtered.map((session) => session.programTitle), [
      'Finance recovery academy',
    ]);
    expect(filtered.single.needsAttention, isTrue);
    expect(summary.attentionCount, 1);
    expect(
      summary.nextAction,
      'Resolve 1 training sessions needing attention.',
    );
  });
}

IncomingTalentDevelopmentProgram _program(
  DateTime asOfDate, {
  String id = 'program-engineering',
  String title = 'Engineering growth accelerator',
  String department = 'Engineering',
  IncomingTalentDevelopmentProgramTrack track =
      IncomingTalentDevelopmentProgramTrack.leadership,
  IncomingTalentDevelopmentProgramIntensity intensity =
      IncomingTalentDevelopmentProgramIntensity.standard,
}) {
  return IncomingTalentDevelopmentProgram(
    id: id,
    title: title,
    department: department,
    ownerName: '$department HRBP',
    track: track,
    status: IncomingTalentDevelopmentProgramStatus.active,
    intensity: intensity,
    skillFocus: '$department leadership capability',
    expectedOutcome: 'Ready talent can lead a scoped operating review.',
    capacity: 12,
    durationDays: 60,
    startDate: asOfDate.add(const Duration(days: 7)),
    endDate: asOfDate.add(const Duration(days: 67)),
    createdAt: asOfDate,
  );
}

ProviderContainer _container(DateTime asOfDate) {
  return ProviderContainer(
    overrides: [talentAsOfDateProvider.overrideWithValue(asOfDate)],
  );
}

IncomingTalentTrainingSession _submitSession(
  ProviderContainer container,
  IncomingTalentDevelopmentProgram program, {
  IncomingTalentTrainingSessionStatus status =
      IncomingTalentTrainingSessionStatus.scheduled,
  int reservedSeats = 8,
}) {
  final asOfDate = container.read(talentAsOfDateProvider);
  final draft = IncomingTalentTrainingSessionDraft.fromProgram(
    program: program,
    asOfDate: asOfDate,
  ).copyWith(status: status, reservedSeats: reservedSeats);

  return container
      .read(incomingTalentTrainingSessionsProvider.notifier)
      .submitDraft(draft);
}
