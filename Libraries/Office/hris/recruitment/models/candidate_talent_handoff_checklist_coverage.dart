import 'candidate_talent_handoff_checklist_item.dart';
import 'candidate_talent_handoff_checklist_template.dart';
import 'candidate_talent_handoff_models.dart';

class CandidateTalentHandoffChecklistCoverage {
  final String handoffId;
  final String candidateId;
  final String candidateName;
  final String templateLabel;
  final Set<CandidateTalentHandoffChecklistCategory> requiredCategories;
  final Set<CandidateTalentHandoffChecklistCategory> coveredCategories;

  const CandidateTalentHandoffChecklistCoverage({
    required this.handoffId,
    required this.candidateId,
    required this.candidateName,
    required this.templateLabel,
    required this.requiredCategories,
    required this.coveredCategories,
  });

  factory CandidateTalentHandoffChecklistCoverage.fromHandoff({
    required CandidateTalentHandoff handoff,
    required List<CandidateTalentHandoffChecklistItem> items,
  }) {
    final template = CandidateTalentHandoffChecklistTemplate.forHandoff(
      handoff,
    );
    final handoffItems = items.where((item) => item.handoffId == handoff.id);

    return CandidateTalentHandoffChecklistCoverage(
      handoffId: handoff.id,
      candidateId: handoff.candidateId,
      candidateName: handoff.candidateName,
      templateLabel: template.label,
      requiredCategories:
          template.tasks
              .where((task) => task.requiredBeforeStart)
              .map((task) => task.category)
              .toSet(),
      coveredCategories: handoffItems.map((item) => item.category).toSet(),
    );
  }

  List<CandidateTalentHandoffChecklistCategory> get missingCategories {
    return requiredCategories
        .where((category) => !coveredCategories.contains(category))
        .toList();
  }

  bool get isComplete => missingCategories.isEmpty;

  double get coverageRatio {
    if (requiredCategories.isEmpty) return 1;
    return (requiredCategories.length - missingCategories.length) /
        requiredCategories.length;
  }

  String get nextAction {
    if (isComplete) return 'Checklist coverage complete.';
    return 'Generate ${missingCategories.length} missing checklist tasks.';
  }
}
