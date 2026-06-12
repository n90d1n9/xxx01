import 'pull_request_review.dart';

class PullRequest {
  final String id;
  final String title;
  final String description;
  final String sourceBranch;
  final String targetBranch;
  final String author;
  final DateTime createdAt;
  final PullRequestStatus status;
  final List<String> reviewers;
  final List<PullRequestReview> reviews;
  final int changedFields;
  final int additions;
  final int deletions;

  const PullRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceBranch,
    required this.targetBranch,
    required this.author,
    required this.createdAt,
    required this.status,
    this.reviewers = const [],
    this.reviews = const [],
    required this.changedFields,
    required this.additions,
    required this.deletions,
  });
}
