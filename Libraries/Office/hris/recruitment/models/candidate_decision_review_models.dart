import 'candidate_decision_models.dart';

enum CandidateDecisionOutcome {
  advance('Advance'),
  advanceWithConditions('Advance with conditions'),
  offerReady('Offer ready'),
  hold('Hold'),
  reject('Reject');

  final String label;

  const CandidateDecisionOutcome(this.label);
}

class CandidateDecisionReview {
  final String id;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final CandidateDecisionOutcome outcome;
  final CandidateDecisionRecommendation recommendation;
  final String ownerName;
  final DateTime dueDate;
  final String nextStep;
  final String notes;
  final int blockerCount;
  final DateTime createdAt;

  const CandidateDecisionReview({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.outcome,
    required this.recommendation,
    required this.ownerName,
    required this.dueDate,
    required this.nextStep,
    required this.notes,
    required this.blockerCount,
    required this.createdAt,
  });

  bool get blocksHandoff {
    return outcome == CandidateDecisionOutcome.hold ||
        outcome == CandidateDecisionOutcome.reject;
  }
}
