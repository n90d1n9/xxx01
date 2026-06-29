import 'git_commit.dart';

class GitBranch {
  final String name;
  final List<GitCommit> commits;
  final bool isActive;

  GitBranch({
    required this.name,
    this.commits = const [],
    this.isActive = false,
  });

  GitCommit? get head => commits.isNotEmpty ? commits.last : null;

  GitBranch copyWith({String? name, List<GitCommit>? commits, bool? isActive}) {
    return GitBranch(
      name: name ?? this.name,
      commits: commits ?? this.commits,
      isActive: isActive ?? this.isActive,
    );
  }
}
