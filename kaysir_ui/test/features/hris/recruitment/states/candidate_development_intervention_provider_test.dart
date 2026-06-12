import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_check_in_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_intervention_models.dart';
import 'package:kaysir/features/hris/recruitment/models/candidate_development_models.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_decision_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_check_in_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_intervention_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/candidate_development_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';

void main() {
  test(
    'candidate development intervention draft initializes from check-in',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = ProviderContainer(
        overrides: [
          recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
          talentAsOfDateProvider.overrideWithValue(asOfDate),
        ],
      );
      addTearDown(container.dispose);

      final checkIn = _submitBlockedCheckIn(container, 'Mira Lestari');

      container
          .read(candidateDevelopmentInterventionDraftProvider.notifier)
          .initializeFromCheckIn(checkIn);

      final draft = container.read(
        candidateDevelopmentInterventionDraftProvider,
      );

      expect(draft.checkInId, 'development-check-in-001');
      expect(draft.objectiveId, 'development-objective-001');
      expect(draft.candidateName, 'Mira Lestari');
      expect(draft.type, CandidateDevelopmentInterventionType.unblock);
      expect(draft.escalationRequired, isTrue);
      expect(draft.dueDate, asOfDate.add(const Duration(days: 7)));
      expect(draft.actionNote, contains('Remove blocker'));
      expect(draft.isReadyToSubmit, isTrue);
    },
  );

  test(
    'candidate development intervention draft validates required fields',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final draft = CandidateDevelopmentInterventionDraft.empty(
        asOfDate,
      ).copyWith(
        actionNote: 'short',
        dueDate: asOfDate.subtract(const Duration(days: 1)),
      );

      expect(draft.isReadyToSubmit, isFalse);
      expect(draft.validationErrors, [
        'Please enter a check-in',
        'Please enter an owner',
        'Intervention action must be at least 12 characters',
        'Due date cannot be in the past',
      ]);
    },
  );

  test(
    'candidate development interventions submit and track status summary',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final container = ProviderContainer(
        overrides: [
          recruitmentAsOfDateProvider.overrideWithValue(asOfDate),
          talentAsOfDateProvider.overrideWithValue(asOfDate),
        ],
      );
      addTearDown(container.dispose);

      final checkIn = _submitBlockedCheckIn(container, 'Mira Lestari');
      final draftNotifier = container.read(
        candidateDevelopmentInterventionDraftProvider.notifier,
      );

      draftNotifier.initializeFromCheckIn(checkIn);

      final intervention = container
          .read(candidateDevelopmentInterventionsProvider.notifier)
          .submitDraft(
            container.read(candidateDevelopmentInterventionDraftProvider),
          );

      expect(intervention.id, 'development-intervention-001');
      expect(intervention.candidateName, 'Mira Lestari');
      expect(intervention.status, CandidateDevelopmentInterventionStatus.open);
      expect(intervention.escalationRequired, isTrue);
      expect(intervention.daysUntilDue(asOfDate), 7);

      var summary = container.read(
        candidateDevelopmentInterventionSummaryProvider,
      );
      expect(summary.totalCount, 1);
      expect(summary.openCount, 1);
      expect(summary.inProgressCount, 0);
      expect(summary.resolvedCount, 0);
      expect(summary.escalationCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.nextAction, 'Escalate 1 development blockers.');

      container
          .read(candidateDevelopmentInterventionsProvider.notifier)
          .start(intervention.id);

      summary = container.read(candidateDevelopmentInterventionSummaryProvider);
      expect(summary.openCount, 0);
      expect(summary.inProgressCount, 1);
      expect(summary.nextAction, 'Escalate 1 development blockers.');

      container
          .read(candidateDevelopmentInterventionsProvider.notifier)
          .resolve(intervention.id);

      summary = container.read(candidateDevelopmentInterventionSummaryProvider);
      expect(summary.inProgressCount, 0);
      expect(summary.resolvedCount, 1);
      expect(summary.escalationCount, 0);
      expect(summary.nextAction, 'Development interventions are progressing.');
    },
  );

  test(
    'candidate development intervention summary detects due soon actions',
    () {
      final asOfDate = DateTime(2026, 5, 30);
      final intervention = CandidateDevelopmentIntervention(
        id: 'development-intervention-001',
        checkInId: 'development-check-in-001',
        objectiveId: 'development-objective-001',
        candidateName: 'Fajar Nugroho',
        role: 'Senior Flutter Engineer',
        department: 'Engineering',
        objectiveTitle: 'Close Flutter architecture readiness gap',
        ownerName: 'Talent Partner',
        type: CandidateDevelopmentInterventionType.coaching,
        actionNote: 'Schedule architecture coaching session.',
        escalationRequired: false,
        dueDate: asOfDate.add(const Duration(days: 5)),
        status: CandidateDevelopmentInterventionStatus.inProgress,
        createdAt: asOfDate,
      );

      final summary = CandidateDevelopmentInterventionSummary.fromInterventions(
        interventions: [intervention],
        asOfDate: asOfDate,
      );

      expect(intervention.isDueSoon(asOfDate), isTrue);
      expect(summary.inProgressCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.nextAction, 'Close 1 interventions due soon.');
    },
  );
}

CandidateDevelopmentCheckIn _submitBlockedCheckIn(
  ProviderContainer container,
  String candidateName,
) {
  final objective = _submitObjective(container, candidateName);
  final draftNotifier = container.read(
    candidateDevelopmentCheckInDraftProvider.notifier,
  );

  draftNotifier.initializeFromObjective(objective);
  draftNotifier.setConfidence('2');
  draftNotifier.setBlockerNote('Mentor capacity is blocked this week.');

  return container
      .read(candidateDevelopmentCheckInsProvider.notifier)
      .submitDraft(container.read(candidateDevelopmentCheckInDraftProvider));
}

CandidateDevelopmentObjective _submitObjective(
  ProviderContainer container,
  String candidateName,
) {
  final packet = container
      .read(candidateDecisionPacketsProvider)
      .singleWhere((item) => item.candidateName == candidateName);

  container
      .read(candidateDevelopmentObjectiveDraftProvider.notifier)
      .initializeFromPacket(packet);

  return container
      .read(candidateDevelopmentObjectivesProvider.notifier)
      .submitDraft(container.read(candidateDevelopmentObjectiveDraftProvider));
}
