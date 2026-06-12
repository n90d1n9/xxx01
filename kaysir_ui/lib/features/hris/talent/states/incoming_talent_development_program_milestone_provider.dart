import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_program_enrollment_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentProgramMilestoneDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentProgramMilestoneDraftNotifier,
      IncomingTalentDevelopmentProgramMilestoneDraft
    >((ref) {
      return IncomingTalentDevelopmentProgramMilestoneDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentProgramMilestoneDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentProgramMilestoneDraft> {
  IncomingTalentDevelopmentProgramMilestoneDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentProgramMilestoneDraft.empty(asOfDate));

  void initializeFromEnrollment(
    IncomingTalentDevelopmentProgramEnrollment enrollment,
  ) {
    state = IncomingTalentDevelopmentProgramMilestoneDraft.fromEnrollment(
      enrollment: enrollment,
      asOfDate: state.asOfDate,
    );
  }

  void setReviewerName(String value) {
    state = state.copyWith(reviewerName: value);
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setEvidenceSummary(String value) {
    state = state.copyWith(evidenceSummary: value);
  }

  void setReviewNotes(String value) {
    state = state.copyWith(reviewNotes: value);
  }

  void setType(IncomingTalentDevelopmentProgramMilestoneType value) {
    state = state.copyWith(type: value);
  }

  void setStatus(IncomingTalentDevelopmentProgramMilestoneStatus value) {
    state = state.copyWith(
      status: value,
      submittedAt:
          value == IncomingTalentDevelopmentProgramMilestoneStatus.submitted
              ? state.asOfDate
              : state.submittedAt,
      reviewedAt:
          value == IncomingTalentDevelopmentProgramMilestoneStatus.accepted ||
                  value ==
                      IncomingTalentDevelopmentProgramMilestoneStatus
                          .needsRevision
              ? state.asOfDate
              : state.reviewedAt,
    );
  }

  void setScore(int value) {
    state = state.copyWith(score: value);
  }

  void setDueDate(DateTime value) {
    state = state.copyWith(dueDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentProgramMilestoneDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentDevelopmentProgramMilestonesProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentProgramMilestonesNotifier,
      List<IncomingTalentDevelopmentProgramMilestone>
    >((ref) {
      return IncomingTalentDevelopmentProgramMilestonesNotifier();
    });

class IncomingTalentDevelopmentProgramMilestonesNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentProgramMilestone>> {
  IncomingTalentDevelopmentProgramMilestonesNotifier() : super(const []);

  IncomingTalentDevelopmentProgramMilestone submitDraft(
    IncomingTalentDevelopmentProgramMilestoneDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (milestone) =>
          !milestone.isClosed && milestone.enrollmentId == draft.enrollmentId,
    )) {
      throw StateError('Program enrollment already has an open milestone');
    }

    final milestone = draft.toMilestone(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [milestone, ...state];
    return milestone;
  }

  void updateStatus({
    required String id,
    required IncomingTalentDevelopmentProgramMilestoneStatus status,
  }) {
    state = [
      for (final milestone in state)
        if (milestone.id == id)
          _copyWithStatus(milestone, status)
        else
          milestone,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-program-milestone-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentDevelopmentProgramMilestone _copyWithStatus(
    IncomingTalentDevelopmentProgramMilestone milestone,
    IncomingTalentDevelopmentProgramMilestoneStatus status,
  ) {
    return IncomingTalentDevelopmentProgramMilestone(
      id: milestone.id,
      enrollmentId: milestone.enrollmentId,
      programId: milestone.programId,
      programTitle: milestone.programTitle,
      candidateId: milestone.candidateId,
      candidateName: milestone.candidateName,
      role: milestone.role,
      department: milestone.department,
      reviewerName: milestone.reviewerName,
      title: milestone.title,
      evidenceSummary: milestone.evidenceSummary,
      reviewNotes: milestone.reviewNotes,
      type: milestone.type,
      status: status,
      score: milestone.score,
      dueDate: milestone.dueDate,
      submittedAt: milestone.submittedAt,
      reviewedAt: milestone.reviewedAt,
      sourceEnrollmentStatus: milestone.sourceEnrollmentStatus,
      createdAt: milestone.createdAt,
    );
  }
}

final milestoneReadyProgramEnrollmentsProvider =
    Provider<List<IncomingTalentDevelopmentProgramEnrollment>>((ref) {
      final openMilestoneEnrollmentIds =
          ref
              .watch(incomingTalentDevelopmentProgramMilestonesProvider)
              .where((milestone) => !milestone.isClosed)
              .map((milestone) => milestone.enrollmentId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentDevelopmentProgramEnrollmentsProvider)
          .where(
            (enrollment) =>
                !enrollment.isClosed &&
                !openMilestoneEnrollmentIds.contains(enrollment.id),
          )
          .toList();
    });

final filteredIncomingTalentDevelopmentProgramMilestonesProvider =
    Provider<List<IncomingTalentDevelopmentProgramMilestone>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentProgramMilestonesProvider)
          .where(
            (milestone) =>
                (selectedDepartment == talentAllDepartments ||
                    milestone.department == selectedDepartment) &&
                (!attentionOnly || milestone.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentProgramMilestoneSummaryProvider =
    Provider<IncomingTalentDevelopmentProgramMilestoneSummary>((ref) {
      return IncomingTalentDevelopmentProgramMilestoneSummary.fromMilestones(
        milestones: ref.watch(
          filteredIncomingTalentDevelopmentProgramMilestonesProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });
