enum PullRequestStatus { open, approved, changesRequested, merged, closed }

enum ReviewDecision { approve, requestChanges, comment }

class PullRequestReview {
  final String id;
  final String reviewer;
  final ReviewDecision decision;
  final String? comment;
  final DateTime timestamp;

  const PullRequestReview({
    required this.id,
    required this.reviewer,
    required this.decision,
    this.comment,
    required this.timestamp,
  });
}
