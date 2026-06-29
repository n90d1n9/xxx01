import 'package:flutter_riverpod/legacy.dart';

import '../form_designer/model/field_config.dart';
import 'model/form_branch.dart';
import 'model/form_commit.dart';
import 'model/pull_request.dart';
import 'model/pull_request_review.dart';
import 'state/version_control_state.dart';

class VersionControlManager extends StateNotifier<VersionControlState> {
  VersionControlManager() : super(VersionControlState());

  void createBranch(String name, String description) {
    final branch = FormBranch(
      id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      basedOn: state.currentBranch,
      createdAt: DateTime.now(),
      createdBy: 'current_user',
    );

    state = state.copyWith(branches: [...state.branches, branch]);
  }

  void switchBranch(String branchId) {
    state = state.copyWith(currentBranch: branchId);
  }

  void commit(String message, List<FieldConfig> fields) {
    final commit = FormCommit(
      id: 'commit_${DateTime.now().millisecondsSinceEpoch}',
      branchId: state.currentBranch,
      message: message,
      author: 'current_user',
      timestamp: DateTime.now(),
      fields: fields,
      parentCommitId: state.commits.isNotEmpty ? state.commits.last.id : null,
    );

    state = state.copyWith(commits: [...state.commits, commit]);
  }

  void createPullRequest(PullRequest pr) {
    state = state.copyWith(pullRequests: [...state.pullRequests, pr]);
  }

  void mergePullRequest(String prId) {
    final updatedPRs = state.pullRequests.map((pr) {
      if (pr.id == prId) {
        return PullRequest(
          id: pr.id,
          title: pr.title,
          description: pr.description,
          sourceBranch: pr.sourceBranch,
          targetBranch: pr.targetBranch,
          author: pr.author,
          createdAt: pr.createdAt,
          status: PullRequestStatus.merged,
          reviewers: pr.reviewers,
          reviews: pr.reviews,
          changedFields: pr.changedFields,
          additions: pr.additions,
          deletions: pr.deletions,
        );
      }
      return pr;
    }).toList();

    state = state.copyWith(pullRequests: updatedPRs);
  }
}


// Version Control Panel

