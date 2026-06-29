import '../models/diagram_type.dart';
import '../models/git_commit.dart';
import '../models/mermaid_diagram.dart';
import 'base_parser.dart';

class GitGraphParser implements DiagramParser {
  @override
  bool canParse(List<String> lines) {
    if (lines.isEmpty) return false;
    final firstLine = lines[0].toLowerCase();
    return firstLine.contains('git');
  }

  @override
  MermaidDiagram parse(List<String> lines, String code) {
    final commits = <GitCommit>[];
    final branches = <String, String>{};
    String currentBranch = 'main';
    var commitCount = 0;

    branches['main'] = 'initial';

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (_parseBranch(line, branches, commits) != null) {
        currentBranch = _parseBranch(line, branches, commits)!;
        continue;
      }

      if (_parseCommit(line, commits, currentBranch, commitCount)) {
        commitCount++;
        branches[currentBranch] = commits.last.id;
        continue;
      }

      if (_parseMerge(line, commits, currentBranch, branches, commitCount)) {
        commitCount++;
        branches[currentBranch] = commits.last.id;
        continue;
      }
    }

    return MermaidDiagram(
      type: DiagramType.gitGraph,
      gitCommits: commits,
      rawCode: code,
    );
  }

  String? _parseBranch(
    String line,
    Map<String, String> branches,
    List<GitCommit> commits,
  ) {
    if (line.startsWith('branch ')) {
      final branchName = line.substring(7).trim();
      branches[branchName] = commits.isNotEmpty ? commits.last.id : 'initial';
      return branchName;
    }
    return null;
  }

  bool _parseCommit(
    String line,
    List<GitCommit> commits,
    String branch,
    int commitCount,
  ) {
    if (line.startsWith('commit ')) {
      final commitId = 'commit_$commitCount';
      final message = line.substring(7).trim().replaceAll('"', '');

      commits.add(
        GitCommit(
          id: commitId,
          message: message,
          branch: branch,
          timestamp: DateTime.now().subtract(Duration(days: commitCount)),
        ),
      );
      return true;
    }
    return false;
  }

  bool _parseMerge(
    String line,
    List<GitCommit> commits,
    String currentBranch,
    Map<String, String> branches,
    int commitCount,
  ) {
    if (line.startsWith('merge ')) {
      final branchName = line.substring(6).trim();
      final mergeCommitId = 'merge_$commitCount';

      commits.add(
        GitCommit(
          id: mergeCommitId,
          message: 'Merge $branchName into $currentBranch',
          branch: currentBranch,
          timestamp: DateTime.now().subtract(Duration(days: commitCount)),
          isMerge: true,
          mergedBranch: branchName,
        ),
      );
      return true;
    }
    return false;
  }
}
