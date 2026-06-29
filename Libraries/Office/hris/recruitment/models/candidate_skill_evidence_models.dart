import 'candidate_skill_fit_models.dart';

class CandidateSkillEvidenceDraft {
  final String candidateId;
  final String candidateName;
  final String skill;
  final String currentLevelText;
  final String evidence;

  const CandidateSkillEvidenceDraft({
    required this.candidateId,
    required this.candidateName,
    required this.skill,
    required this.currentLevelText,
    required this.evidence,
  });

  factory CandidateSkillEvidenceDraft.empty() {
    return const CandidateSkillEvidenceDraft(
      candidateId: '',
      candidateName: '',
      skill: '',
      currentLevelText: '',
      evidence: '',
    );
  }

  factory CandidateSkillEvidenceDraft.fromSignal({
    required CandidateSkillFitProfile profile,
    required CandidateSkillFitSignal signal,
  }) {
    return CandidateSkillEvidenceDraft(
      candidateId: profile.candidateId,
      candidateName: profile.candidateName,
      skill: signal.skill,
      currentLevelText: '${signal.currentLevel}',
      evidence:
          signal.evidence == 'No evidence captured yet' ? '' : signal.evidence,
    );
  }

  CandidateSkillEvidenceDraft copyWith({
    String? candidateId,
    String? candidateName,
    String? skill,
    String? currentLevelText,
    String? evidence,
  }) {
    return CandidateSkillEvidenceDraft(
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      skill: skill ?? this.skill,
      currentLevelText: currentLevelText ?? this.currentLevelText,
      evidence: evidence ?? this.evidence,
    );
  }

  int? get currentLevel => int.tryParse(currentLevelText.trim());

  List<String> get validationErrors {
    return [
      if (validateCandidate(candidateId) case final error?) error,
      if (validateSkill(skill) case final error?) error,
      if (validateLevel(currentLevelText) case final error?) error,
      if (validateEvidence(evidence) case final error?) error,
    ];
  }

  bool get isReady => validationErrors.isEmpty;

  CandidateSkillEvidence toEvidence() {
    if (!isReady) {
      throw StateError('Complete candidate scorecard evidence before saving.');
    }
    return CandidateSkillEvidence(
      candidateId: candidateId,
      skill: skill.trim(),
      currentLevel: currentLevel!,
      evidence: evidence.trim(),
    );
  }

  static String? validateCandidate(String? value) {
    return value == null || value.trim().isEmpty ? 'Select a candidate' : null;
  }

  static String? validateSkill(String? value) {
    return value == null || value.trim().isEmpty ? 'Select a skill' : null;
  }

  static String? validateLevel(String? value) {
    final level = int.tryParse(value?.trim() ?? '');
    if (level == null || level < 0 || level > 5) {
      return 'Select a level from 0 to 5';
    }
    return null;
  }

  static String? validateEvidence(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.length < 12) {
      return 'Add evidence with at least 12 characters';
    }
    return null;
  }
}
