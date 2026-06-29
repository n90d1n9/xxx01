import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/incoming_talent_development_portfolio_models.dart';
import '../models/incoming_talent_development_program_models.dart';
import 'incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_program_provider.dart';
import 'talent_provider.dart';

final incomingTalentDevelopmentProgramEnrollmentDraftProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentProgramEnrollmentDraftNotifier,
      IncomingTalentDevelopmentProgramEnrollmentDraft
    >((ref) {
      return IncomingTalentDevelopmentProgramEnrollmentDraftNotifier(
        ref.watch(talentAsOfDateProvider),
      );
    });

class IncomingTalentDevelopmentProgramEnrollmentDraftNotifier
    extends StateNotifier<IncomingTalentDevelopmentProgramEnrollmentDraft> {
  IncomingTalentDevelopmentProgramEnrollmentDraftNotifier(DateTime asOfDate)
    : super(IncomingTalentDevelopmentProgramEnrollmentDraft.empty(asOfDate));

  void initializeFromProgramPortfolio({
    required IncomingTalentDevelopmentProgram program,
    required IncomingTalentDevelopmentPortfolio portfolio,
  }) {
    state =
        IncomingTalentDevelopmentProgramEnrollmentDraft.fromProgramPortfolio(
          program: program,
          portfolio: portfolio,
          asOfDate: state.asOfDate,
        );
  }

  void setMentorName(String value) {
    state = state.copyWith(mentorName: value);
  }

  void setMilestone(String value) {
    state = state.copyWith(milestone: value);
  }

  void setEvidencePlan(String value) {
    state = state.copyWith(evidencePlan: value);
  }

  void setStatus(IncomingTalentDevelopmentProgramEnrollmentStatus value) {
    state = state.copyWith(status: value);
  }

  void setProgressScore(int value) {
    state = state.copyWith(progressScore: value);
  }

  void setEnrolledAt(DateTime value) {
    state = state.copyWith(enrolledAt: value);
  }

  void setNextReviewDate(DateTime value) {
    state = state.copyWith(nextReviewDate: value);
  }

  void setTargetCompletionDate(DateTime value) {
    state = state.copyWith(targetCompletionDate: value);
  }

  void clear() {
    state = IncomingTalentDevelopmentProgramEnrollmentDraft.empty(
      state.asOfDate,
    );
  }
}

final incomingTalentDevelopmentProgramEnrollmentsProvider =
    StateNotifierProvider<
      IncomingTalentDevelopmentProgramEnrollmentsNotifier,
      List<IncomingTalentDevelopmentProgramEnrollment>
    >((ref) {
      return IncomingTalentDevelopmentProgramEnrollmentsNotifier();
    });

class IncomingTalentDevelopmentProgramEnrollmentsNotifier
    extends StateNotifier<List<IncomingTalentDevelopmentProgramEnrollment>> {
  IncomingTalentDevelopmentProgramEnrollmentsNotifier() : super(const []);

  IncomingTalentDevelopmentProgramEnrollment submitDraft(
    IncomingTalentDevelopmentProgramEnrollmentDraft draft,
  ) {
    if (!draft.isReadyToSubmit) {
      throw StateError(draft.validationErrors.first);
    }
    if (state.any(
      (enrollment) =>
          !enrollment.isClosed &&
          enrollment.programId == draft.programId &&
          enrollment.portfolioId == draft.portfolioId,
    )) {
      throw StateError('Talent is already enrolled in this program');
    }
    if (state.any(
      (enrollment) =>
          !enrollment.isClosed && enrollment.portfolioId == draft.portfolioId,
    )) {
      throw StateError(
        'IDP portfolio already has an active program enrollment',
      );
    }

    final enrollment = draft.toEnrollment(
      id: _nextId(),
      createdAt: draft.asOfDate,
    );
    state = [enrollment, ...state];
    return enrollment;
  }

  void updateStatus({
    required String id,
    required IncomingTalentDevelopmentProgramEnrollmentStatus status,
  }) {
    state = [
      for (final enrollment in state)
        if (enrollment.id == id)
          _copyWithStatus(enrollment, status)
        else
          enrollment,
    ];
  }

  String _nextId() {
    final sequence = state.length + 1;
    return 'talent-program-enrollment-${sequence.toString().padLeft(3, '0')}';
  }

  IncomingTalentDevelopmentProgramEnrollment _copyWithStatus(
    IncomingTalentDevelopmentProgramEnrollment enrollment,
    IncomingTalentDevelopmentProgramEnrollmentStatus status,
  ) {
    return IncomingTalentDevelopmentProgramEnrollment(
      id: enrollment.id,
      programId: enrollment.programId,
      programTitle: enrollment.programTitle,
      portfolioId: enrollment.portfolioId,
      candidateId: enrollment.candidateId,
      candidateName: enrollment.candidateName,
      role: enrollment.role,
      department: enrollment.department,
      mentorName: enrollment.mentorName,
      milestone: enrollment.milestone,
      evidencePlan: enrollment.evidencePlan,
      status: status,
      progressScore: enrollment.progressScore,
      enrolledAt: enrollment.enrolledAt,
      nextReviewDate: enrollment.nextReviewDate,
      targetCompletionDate: enrollment.targetCompletionDate,
      sourcePortfolioStage: enrollment.sourcePortfolioStage,
      sourcePortfolioPriority: enrollment.sourcePortfolioPriority,
      createdAt: enrollment.createdAt,
    );
  }
}

final enrollmentReadyDevelopmentProgramsProvider =
    Provider<List<IncomingTalentDevelopmentProgram>>((ref) {
      final enrollments = ref.watch(
        incomingTalentDevelopmentProgramEnrollmentsProvider,
      );

      return ref
          .watch(activeIncomingTalentDevelopmentProgramsProvider)
          .where(
            (program) =>
                program.availableSeats(
                  _openEnrollmentCount(enrollments, program.id),
                ) >
                0,
          )
          .toList();
    });

final programReadyDevelopmentPortfoliosProvider =
    Provider<List<IncomingTalentDevelopmentPortfolio>>((ref) {
      final enrolledPortfolioIds =
          ref
              .watch(incomingTalentDevelopmentProgramEnrollmentsProvider)
              .where((enrollment) => !enrollment.isClosed)
              .map((enrollment) => enrollment.portfolioId)
              .toSet();

      return ref
          .watch(filteredIncomingTalentDevelopmentPortfoliosProvider)
          .where((portfolio) => !enrolledPortfolioIds.contains(portfolio.id))
          .toList();
    });

final filteredIncomingTalentDevelopmentProgramEnrollmentsProvider =
    Provider<List<IncomingTalentDevelopmentProgramEnrollment>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentDevelopmentProgramEnrollmentsProvider)
          .where(
            (enrollment) =>
                (selectedDepartment == talentAllDepartments ||
                    enrollment.department == selectedDepartment) &&
                (!attentionOnly || enrollment.needsAttention),
          )
          .toList();
    });

final incomingTalentDevelopmentProgramEnrollmentSummaryProvider =
    Provider<IncomingTalentDevelopmentProgramEnrollmentSummary>((ref) {
      return IncomingTalentDevelopmentProgramEnrollmentSummary.fromEnrollments(
        enrollments: ref.watch(
          filteredIncomingTalentDevelopmentProgramEnrollmentsProvider,
        ),
        asOfDate: ref.watch(talentAsOfDateProvider),
      );
    });

int _openEnrollmentCount(
  List<IncomingTalentDevelopmentProgramEnrollment> enrollments,
  String programId,
) {
  return enrollments
      .where(
        (enrollment) =>
            enrollment.programId == programId && !enrollment.isClosed,
      )
      .length;
}
