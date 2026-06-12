import 'git_branch.dart';
import 'git_commit.dart';

class GitGraph {
  final List<GitBranch> branches;
  final List<GitCommit> commits;
  final String currentBranch;

  GitGraph({
    required this.branches,
    required this.commits,
    required this.currentBranch,
  });

  GitBranch? getBranch(String name) {
    return branches.firstWhere((branch) => branch.name == name);
  }

  List<GitCommit> getCommitsOnBranch(String branchName) {
    return commits.where((commit) => commit.branch == branchName).toList();
  }
}
