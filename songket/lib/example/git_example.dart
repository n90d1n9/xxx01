import '../services/mermaid_parser.dart';

void main() {
  final gitGraphCode = '''
gitGraph
  commit id: "Initial commit"
  branch develop
  checkout develop
  commit id: "Add feature"
  checkout main
  commit id: "Update README"
  merge develop
  commit id: "Release v1.0"
''';

  final diagram = MermaidParser.parse(gitGraphCode);
  print('Git Graph commits: ${diagram.gitCommits.length}');

  for (final commit in diagram.gitCommits) {
    print(
      'Commit: ${commit.shortHash} - ${commit.displayMessage} - Branch: ${commit.branch}',
    );
    if (commit.isMerge) {
      print('  Merged: ${commit.mergedBranch}');
    }
  }
}
