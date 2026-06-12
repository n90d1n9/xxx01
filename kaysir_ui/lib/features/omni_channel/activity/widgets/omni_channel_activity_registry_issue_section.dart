import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity_registry_issue.dart';
import 'omni_channel_activity_registry_card.dart';

/// Warning section for action contributor registration contract issues.
class OmniChannelActivityRegistryIssueSection extends StatelessWidget {
  final List<OmniChannelActivityActionContributorRegistrationIssue> issues;

  const OmniChannelActivityRegistryIssueSection({
    super.key,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OmniChannelActivityRegistrySection(
      title: 'Contributor registration issues',
      icon: Icons.report_problem_outlined,
      iconColor: colorScheme.error,
      child: Wrap(
        key: const ValueKey('omni-channel-registry-registration-issues'),
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final issue in issues) _RegistryIssueTile(issue: issue),
        ],
      ),
    );
  }
}

@Preview(name: 'Omni-channel registry issue section')
Widget omniChannelActivityRegistryIssueSectionPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityRegistryIssueSection(
          issues: [
            OmniChannelActivityActionContributorRegistrationIssue(
              type:
                  OmniChannelActivityActionContributorRegistrationIssueType
                      .duplicateId,
              key: 'duplicate-id-commerce',
              id: 'commerce',
              labels: const ['Commerce actions', 'Marketplace actions'],
              contributorCount: 2,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Compact warning tile for one contributor registration issue.
class _RegistryIssueTile extends StatelessWidget {
  final OmniChannelActivityActionContributorRegistrationIssue issue;

  const _RegistryIssueTile({required this.issue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OmniChannelActivityRegistryTile(
      key: ValueKey('omni-channel-registry-registration-issue-${issue.key}'),
      icon: Icons.report_problem_outlined,
      color: colorScheme.error,
      title: issue.title,
      subtitle: issue.detail,
      subtitleMaxLines: 2,
      backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.18),
      borderColor: colorScheme.error.withValues(alpha: 0.36),
      children: [
        AppStatusPill(
          label: _countLabel(issue.contributorCount, 'contributor'),
          color: colorScheme.error,
          icon: Icons.extension_outlined,
          maxWidth: 164,
        ),
      ],
    );
  }
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
