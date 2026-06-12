import '../../recruitment/models/candidate_talent_handoff_checklist_models.dart';
import '../../recruitment/models/candidate_talent_handoff_models.dart';
import 'incoming_talent_development_program_completion.dart';
import 'incoming_talent_development_program_milestone.dart';

enum IncomingTalentReadinessStatus {
  ready('Ready'),
  attention('Attention'),
  blocked('Blocked');

  final String label;

  const IncomingTalentReadinessStatus(this.label);
}

class IncomingTalentReadiness {
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String managerName;
  final String ownerName;
  final CandidateTalentHandoffType handoffType;
  final IncomingTalentReadinessStatus status;
  final int readinessScore;
  final int requiredChecklistCount;
  final int completedRequiredChecklistCount;
  final int openRequiredChecklistCount;
  final int blockedRequiredChecklistCount;
  final int missingRequiredChecklistCount;
  final int acceptedProgramMilestoneCount;
  final int roleReadyProgramCompletionCount;
  final int programCompletionExtensionCount;
  final DateTime targetStartDate;
  final DateTime firstCheckpointDate;
  final int daysToStart;
  final String talentFocus;
  final String nextAction;

  const IncomingTalentReadiness({
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.managerName,
    required this.ownerName,
    required this.handoffType,
    required this.status,
    required this.readinessScore,
    required this.requiredChecklistCount,
    required this.completedRequiredChecklistCount,
    required this.openRequiredChecklistCount,
    required this.blockedRequiredChecklistCount,
    required this.missingRequiredChecklistCount,
    required this.acceptedProgramMilestoneCount,
    required this.roleReadyProgramCompletionCount,
    required this.programCompletionExtensionCount,
    required this.targetStartDate,
    required this.firstCheckpointDate,
    required this.daysToStart,
    required this.talentFocus,
    required this.nextAction,
  });

  factory IncomingTalentReadiness.fromHandoff({
    required CandidateTalentHandoff handoff,
    required List<CandidateTalentHandoffChecklistItem> checklistItems,
    required DateTime asOfDate,
    List<IncomingTalentDevelopmentProgramMilestone> programMilestones =
        const [],
    List<IncomingTalentDevelopmentProgramCompletion> programCompletions =
        const [],
  }) {
    final coverage = CandidateTalentHandoffChecklistCoverage.fromHandoff(
      handoff: handoff,
      items: checklistItems,
    );
    final candidateMilestones =
        programMilestones
            .where((milestone) => milestone.candidateId == handoff.candidateId)
            .toList();
    final candidateCompletions =
        programCompletions
            .where(
              (completion) => completion.candidateId == handoff.candidateId,
            )
            .toList();
    final acceptedProgramMilestoneCount =
        candidateMilestones
            .where(
              (milestone) =>
                  milestone.status ==
                  IncomingTalentDevelopmentProgramMilestoneStatus.accepted,
            )
            .length;
    final roleReadyProgramCompletionCount =
        candidateCompletions
            .where((completion) => completion.isRoleReady)
            .length;
    final programCompletionExtensionCount =
        candidateCompletions
            .where(
              (completion) =>
                  completion.decision ==
                  IncomingTalentDevelopmentProgramCompletionDecision
                      .extendProgram,
            )
            .length;
    final handoffItems =
        checklistItems.where((item) => item.handoffId == handoff.id).toList();
    final completedRequired = _countRequiredCategoriesWithStatus(
      categories: coverage.requiredCategories,
      items: handoffItems,
      status: CandidateTalentHandoffChecklistStatus.completed,
    );
    final blockedRequired = _countRequiredCategoriesWithStatus(
      categories: coverage.requiredCategories,
      items: handoffItems,
      status: CandidateTalentHandoffChecklistStatus.blocked,
    );
    final openRequired = _countOpenRequiredCategories(
      categories: coverage.requiredCategories,
      items: handoffItems,
    );
    final daysToStart = _daysBetween(asOfDate, handoff.targetStartDate);
    final missingRequired = coverage.missingCategories.length;
    final status = _readinessStatus(
      handoff: handoff,
      missingRequired: missingRequired,
      openRequired: openRequired,
      blockedRequired: blockedRequired,
      programCompletionExtensionCount: programCompletionExtensionCount,
    );

    return IncomingTalentReadiness(
      handoffId: handoff.id,
      candidateId: handoff.candidateId,
      candidateName: handoff.candidateName,
      role: handoff.role,
      department: handoff.department,
      managerName: handoff.receivingManagerName,
      ownerName: handoff.ownerName,
      handoffType: handoff.type,
      status: status,
      readinessScore: handoff.readinessScore,
      requiredChecklistCount: coverage.requiredCategories.length,
      completedRequiredChecklistCount: completedRequired,
      openRequiredChecklistCount: openRequired,
      blockedRequiredChecklistCount: blockedRequired,
      missingRequiredChecklistCount: missingRequired,
      acceptedProgramMilestoneCount: acceptedProgramMilestoneCount,
      roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      targetStartDate: handoff.targetStartDate,
      firstCheckpointDate: handoff.firstCheckpointDate,
      daysToStart: daysToStart,
      talentFocus: handoff.talentFocus,
      nextAction: _readinessNextAction(
        handoff: handoff,
        missingRequired: missingRequired,
        openRequired: openRequired,
        blockedRequired: blockedRequired,
        daysToStart: daysToStart,
        programCompletionExtensionCount: programCompletionExtensionCount,
        roleReadyProgramCompletionCount: roleReadyProgramCompletionCount,
      ),
    );
  }

  int get pendingRequiredChecklistCount {
    return missingRequiredChecklistCount + openRequiredChecklistCount;
  }

  int get developmentEvidenceCount {
    return acceptedProgramMilestoneCount + roleReadyProgramCompletionCount;
  }

  double get checklistCompletionRatio {
    if (requiredChecklistCount == 0) return 1;
    return completedRequiredChecklistCount / requiredChecklistCount;
  }

  bool get needsAttention =>
      status != IncomingTalentReadinessStatus.ready ||
      programCompletionExtensionCount > 0;
}

int _countRequiredCategoriesWithStatus({
  required Set<CandidateTalentHandoffChecklistCategory> categories,
  required List<CandidateTalentHandoffChecklistItem> items,
  required CandidateTalentHandoffChecklistStatus status,
}) {
  return categories
      .where(
        (category) => items.any(
          (item) => item.category == category && item.status == status,
        ),
      )
      .length;
}

int _countOpenRequiredCategories({
  required Set<CandidateTalentHandoffChecklistCategory> categories,
  required List<CandidateTalentHandoffChecklistItem> items,
}) {
  return categories.where((category) {
    final categoryItems = items.where((item) => item.category == category);
    if (categoryItems.isEmpty) return false;
    if (categoryItems.any(
      (item) => item.status == CandidateTalentHandoffChecklistStatus.blocked,
    )) {
      return false;
    }
    return !categoryItems.any(
      (item) => item.status == CandidateTalentHandoffChecklistStatus.completed,
    );
  }).length;
}

IncomingTalentReadinessStatus _readinessStatus({
  required CandidateTalentHandoff handoff,
  required int missingRequired,
  required int openRequired,
  required int blockedRequired,
  required int programCompletionExtensionCount,
}) {
  if (handoff.status == CandidateTalentHandoffStatus.blocked ||
      handoff.risk == CandidateTalentHandoffRisk.high ||
      blockedRequired > 0) {
    return IncomingTalentReadinessStatus.blocked;
  }
  if (handoff.status == CandidateTalentHandoffStatus.watch ||
      handoff.risk == CandidateTalentHandoffRisk.medium ||
      programCompletionExtensionCount > 0 ||
      missingRequired > 0 ||
      openRequired > 0 ||
      handoff.readinessScore < 80) {
    return IncomingTalentReadinessStatus.attention;
  }
  return IncomingTalentReadinessStatus.ready;
}

String _readinessNextAction({
  required CandidateTalentHandoff handoff,
  required int missingRequired,
  required int openRequired,
  required int blockedRequired,
  required int daysToStart,
  required int programCompletionExtensionCount,
  required int roleReadyProgramCompletionCount,
}) {
  if (blockedRequired > 0) {
    return 'Unblock $blockedRequired required checklist tasks before start.';
  }
  if (handoff.status == CandidateTalentHandoffStatus.blocked ||
      handoff.risk == CandidateTalentHandoffRisk.high) {
    return 'Escalate blocked handoff before start.';
  }
  if (missingRequired > 0) {
    return 'Generate $missingRequired missing required checklist tasks.';
  }
  if (openRequired > 0) {
    return 'Close $openRequired required checklist tasks before start.';
  }
  if (programCompletionExtensionCount > 0) {
    final decisionLabel =
        programCompletionExtensionCount == 1 ? 'decision' : 'decisions';
    return 'Resolve $programCompletionExtensionCount program extension '
        '$decisionLabel before release.';
  }
  if (handoff.status == CandidateTalentHandoffStatus.watch ||
      handoff.risk == CandidateTalentHandoffRisk.medium ||
      handoff.readinessScore < 80) {
    return 'Review manager alignment before release.';
  }
  if (roleReadyProgramCompletionCount > 0) {
    final credentialLabel =
        roleReadyProgramCompletionCount == 1 ? 'credential' : 'credentials';
    return 'Apply $roleReadyProgramCompletionCount role-ready '
        '$credentialLabel to talent setup.';
  }
  if (daysToStart <= 3) return 'Confirm first checkpoint and manager kickoff.';
  return 'Release to learning and mentorship setup.';
}

int _daysBetween(DateTime start, DateTime end) {
  final startDate = DateTime(start.year, start.month, start.day);
  final endDate = DateTime(end.year, end.month, end.day);
  return endDate.difference(startDate).inDays;
}
