import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../form_designer/states/form_field_provider.dart';
import '../model/form_commit.dart';
import '../model/pull_request.dart';
import '../model/pull_request_review.dart';
import '../state/version_control_provider.dart';
import '../state/version_control_state.dart';

class VersionControlPanel extends ConsumerWidget {
  const VersionControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vcState = ref.watch(versionControlProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_tree, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Version Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.near_me, size: 14, color: Colors.purple),
                      const SizedBox(width: 6),
                      Text(
                        vcState.currentBranch,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TabBar(
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.purple,
              tabs: const [
                Tab(text: 'Branches'),
                Tab(text: 'Commits'),
                Tab(text: 'Pull Requests'),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                children: [
                  _BranchesTab(state: vcState),
                  _CommitsTab(commits: vcState.commits),
                  _PullRequestsTab(pullRequests: vcState.pullRequests),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchesTab extends ConsumerWidget {
  final VersionControlState state;

  const _BranchesTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle, size: 18),
          label: const Text('Create Branch'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          onPressed: () => _showCreateBranchDialog(context, ref),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            children: [
              _BranchCard(
                name: 'main',
                description: 'Main production branch',
                isCurrent: state.currentBranch == 'main',
                isProtected: true,
                onSwitch: () => ref
                    .read(versionControlProvider.notifier)
                    .switchBranch('main'),
              ),
              ...state.branches.map(
                (branch) => _BranchCard(
                  name: branch.name,
                  description: branch.description,
                  isCurrent: state.currentBranch == branch.id,
                  isProtected: branch.isProtected,
                  onSwitch: () => ref
                      .read(versionControlProvider.notifier)
                      .switchBranch(branch.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateBranchDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Create New Branch',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Branch Name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(versionControlProvider.notifier)
                  .createBranch(nameController.text, descController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final String name;
  final String description;
  final bool isCurrent;
  final bool isProtected;
  final VoidCallback onSwitch;

  const _BranchCard({
    required this.name,
    required this.description,
    required this.isCurrent,
    required this.isProtected,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? Colors.purple.withOpacity(0.2)
            : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? Colors.purple : Colors.white24,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.near_me,
                color: isCurrent ? Colors.purple : Colors.white54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isCurrent ? Colors.purple : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isProtected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield, size: 12, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Protected',
                        style: TextStyle(color: Colors.orange, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (!isCurrent) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync_alt, size: 16),
              label: const Text('Switch to this branch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onPressed: onSwitch,
            ),
          ],
        ],
      ),
    );
  }
}

class _CommitsTab extends ConsumerWidget {
  final List<FormCommit> commits;

  const _CommitsTab({required this.commits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (commits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.commit, size: 60, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No commits yet',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create First Commit'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () => _showCommitDialog(context, ref),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.commit, size: 18),
          label: const Text('New Commit'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          onPressed: () => _showCommitDialog(context, ref),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: commits.length,
            itemBuilder: (context, index) {
              final commit = commits[commits.length - 1 - index];
              return _CommitCard(commit: commit, isLatest: index == 0);
            },
          ),
        ),
      ],
    );
  }

  void _showCommitDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Create Commit',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Commit Message',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: 'Describe your changes...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final fields = ref.read(formFieldsProvider);
              ref
                  .read(versionControlProvider.notifier)
                  .commit(controller.text, fields);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Commit created successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Commit'),
          ),
        ],
      ),
    );
  }
}

class _CommitCard extends StatelessWidget {
  final FormCommit commit;
  final bool isLatest;

  const _CommitCard({required this.commit, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLatest ? Colors.purple : Colors.white24,
          width: isLatest ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.commit, color: Colors.purple, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commit.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          commit.author,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: Colors.white54)),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(commit.timestamp),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HEAD',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CommitStat(
                icon: Icons.description,
                label: '${commit.fields.length} fields',
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              Text(
                commit.id.substring(0, 8),
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

class _CommitStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CommitStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _PullRequestsTab extends ConsumerWidget {
  final List<PullRequest> pullRequests;

  const _PullRequestsTab({required this.pullRequests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openPRs = pullRequests
        .where((pr) => pr.status == PullRequestStatus.open)
        .toList();
    final closedPRs = pullRequests
        .where((pr) => pr.status != PullRequestStatus.open)
        .toList();

    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.merge_type, size: 18),
          label: const Text('Create Pull Request'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          onPressed: () => _showCreatePRDialog(context, ref),
        ),
        const SizedBox(height: 16),

        if (pullRequests.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.merge_type, size: 60, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'No pull requests',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              children: [
                if (openPRs.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'OPEN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...openPRs.map((pr) => _PullRequestCard(pr: pr)),
                ],
                if (closedPRs.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'CLOSED',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...closedPRs.map((pr) => _PullRequestCard(pr: pr)),
                ],
              ],
            ),
          ),
      ],
    );
  }

  void _showCreatePRDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        title: const Text(
          'Create Pull Request',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Pull request creation dialog - Select source/target branches and add details',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _PullRequestCard extends ConsumerWidget {
  final PullRequest pr;

  const _PullRequestCard({required this.pr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getStatusColor(pr.status).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(pr.status),
                color: _getStatusColor(pr.status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pr.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pr.description,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${pr.sourceBranch} → ${pr.targetBranch}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _PRStat(
                icon: Icons.edit,
                label: '${pr.changedFields}',
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _PRStat(
                icon: Icons.add,
                label: '+${pr.additions}',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _PRStat(
                icon: Icons.remove,
                label: '-${pr.deletions}',
                color: Colors.red,
              ),
              const Spacer(),
              if (pr.status == PullRequestStatus.open)
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(versionControlProvider.notifier)
                        .mergePullRequest(pr.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Pull request merged')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Merge', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PullRequestStatus status) {
    switch (status) {
      case PullRequestStatus.open:
        return Colors.green;
      case PullRequestStatus.approved:
        return Colors.blue;
      case PullRequestStatus.changesRequested:
        return Colors.orange;
      case PullRequestStatus.merged:
        return Colors.purple;
      case PullRequestStatus.closed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PullRequestStatus status) {
    switch (status) {
      case PullRequestStatus.open:
        return Icons.merge_type;
      case PullRequestStatus.approved:
        return Icons.check_circle;
      case PullRequestStatus.changesRequested:
        return Icons.change_circle;
      case PullRequestStatus.merged:
        return Icons.done_all;
      case PullRequestStatus.closed:
        return Icons.cancel;
    }
  }
}

class _PRStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PRStat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
