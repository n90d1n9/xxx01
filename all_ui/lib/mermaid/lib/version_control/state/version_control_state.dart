import '../model/form_branch.dart';
import '../model/form_commit.dart';
import '../model/pull_request.dart';

class VersionControlState {
  final List<FormBranch> branches;
  final String currentBranch;
  final List<FormCommit> commits;
  final List<PullRequest> pullRequests;

  VersionControlState({
    this.branches = const [],
    this.currentBranch = 'main',
    this.commits = const [],
    this.pullRequests = const [],
  });

  VersionControlState copyWith({
    List<FormBranch>? branches,
    String? currentBranch,
    List<FormCommit>? commits,
    List<PullRequest>? pullRequests,
  }) {
    return VersionControlState(
      branches: branches ?? this.branches,
      currentBranch: currentBranch ?? this.currentBranch,
      commits: commits ?? this.commits,
      pullRequests: pullRequests ?? this.pullRequests,
    );
  }
}
