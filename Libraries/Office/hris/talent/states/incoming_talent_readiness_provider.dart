import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recruitment/states/candidate_talent_handoff_checklist_provider.dart';
import '../../recruitment/states/candidate_talent_handoff_provider.dart';
import '../models/incoming_talent_readiness.dart';
import '../models/incoming_talent_readiness_summary.dart';
import 'incoming_talent_development_program_completion_provider.dart';
import 'incoming_talent_development_program_milestone_provider.dart';
import 'talent_provider.dart';

final incomingTalentReadinessWithDevelopmentEvidenceProvider =
    Provider<List<IncomingTalentReadiness>>((ref) {
      final checklistItems = ref.watch(
        candidateTalentHandoffChecklistItemsProvider,
      );
      final programMilestones = ref.watch(
        incomingTalentDevelopmentProgramMilestonesProvider,
      );
      final programCompletions = ref.watch(
        incomingTalentDevelopmentProgramCompletionsProvider,
      );
      final asOfDate = ref.watch(talentAsOfDateProvider);
      final readiness =
          ref
              .watch(candidateTalentHandoffsProvider)
              .map(
                (handoff) => IncomingTalentReadiness.fromHandoff(
                  handoff: handoff,
                  checklistItems: checklistItems,
                  asOfDate: asOfDate,
                  programMilestones: programMilestones,
                  programCompletions: programCompletions,
                ),
              )
              .toList()
            ..sort(_compareIncomingTalentReadiness);

      return readiness;
    });

final filteredIncomingTalentReadinessWithDevelopmentEvidenceProvider =
    Provider<List<IncomingTalentReadiness>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentReadinessWithDevelopmentEvidenceProvider)
          .where(
            (item) =>
                (selectedDepartment == talentAllDepartments ||
                    item.department == selectedDepartment) &&
                (!attentionOnly || item.needsAttention),
          )
          .toList();
    });

final incomingTalentReadinessWithDevelopmentEvidenceSummaryProvider =
    Provider<IncomingTalentReadinessSummary>((ref) {
      return IncomingTalentReadinessSummary.fromReadiness(
        ref.watch(
          filteredIncomingTalentReadinessWithDevelopmentEvidenceProvider,
        ),
      );
    });

int _compareIncomingTalentReadiness(
  IncomingTalentReadiness a,
  IncomingTalentReadiness b,
) {
  final statusCompare = _readinessStatusRank(
    a.status,
  ).compareTo(_readinessStatusRank(b.status));
  if (statusCompare != 0) return statusCompare;
  return a.targetStartDate.compareTo(b.targetStartDate);
}

int _readinessStatusRank(IncomingTalentReadinessStatus status) {
  return switch (status) {
    IncomingTalentReadinessStatus.blocked => 0,
    IncomingTalentReadinessStatus.attention => 1,
    IncomingTalentReadinessStatus.ready => 2,
  };
}
