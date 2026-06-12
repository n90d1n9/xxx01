import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_empty_state.dart';
import '../../../../widgets/ui/app_status_pill.dart';
import '../models/omni_channel_activity_module_manifest.dart';
import '../models/omni_channel_activity_module_registry_diagnostics.dart';
import 'omni_channel_activity_registry_card.dart';

/// Reusable diagnostics section for registered activity business modules.
class OmniChannelActivityModuleRegistrySection extends StatelessWidget {
  final List<OmniChannelActivityModuleDiagnostic> modules;
  final List<OmniChannelActivityModuleRegistrationIssue> issues;

  const OmniChannelActivityModuleRegistrySection({
    super.key,
    required this.modules,
    this.issues = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        OmniChannelActivityRegistrySection(
          title: 'Business modules',
          icon: Icons.view_module_outlined,
          child:
              modules.isEmpty
                  ? const AppEmptyState(
                    icon: Icons.view_module_outlined,
                    title: 'No activity modules',
                    message:
                        'POS, ecommerce, marketplace, and channel modules will '
                        'appear here when registered.',
                  )
                  : Wrap(
                    key: const ValueKey('omni-channel-registry-modules'),
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final module in modules)
                        _ModuleRegistryTile(diagnostic: module),
                    ],
                  ),
        ),
        if (issues.isNotEmpty) ...[
          const SizedBox(height: 14),
          OmniChannelActivityRegistrySection(
            title: 'Module contract issues',
            icon: Icons.report_problem_outlined,
            child: Wrap(
              key: const ValueKey('omni-channel-registry-module-issues'),
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final issue in issues) _ModuleIssueTile(issue: issue),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Omni-channel module registry section')
Widget omniChannelActivityModuleRegistrySectionPreview() {
  final modules = [
    OmniChannelActivityModuleDiagnostic(
      manifest: OmniChannelActivityModuleManifest(
        id: 'point_of_sales',
        label: 'Point of sale',
        description: 'Cashier and counter channel activity.',
        activitySourceIds: const ['point_of_sales'],
        actionContributorIds: const ['point_of_sales'],
        triageDimensionKeys: const ['source', 'channel'],
        businessModelKeys: const ['point_of_sales', 'kiosk'],
        routePath: '/cashier',
      ),
      activityEventCount: 4,
      registeredActionContributorCount: 1,
      registeredTriageDimensionCount: 2,
    ),
    OmniChannelActivityModuleDiagnostic(
      manifest: OmniChannelActivityModuleManifest(
        id: 'marketplace',
        label: 'Marketplace',
        description: 'Marketplace order and fulfillment signals.',
        activitySourceIds: const ['marketplace'],
        actionContributorIds: const ['marketplace'],
        triageDimensionKeys: const ['source', 'channel'],
        businessModelKeys: const ['marketplace'],
      ),
      activityEventCount: 0,
      registeredActionContributorCount: 0,
      registeredTriageDimensionCount: 2,
      missingActionContributorIds: const ['marketplace'],
    ),
  ];

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: OmniChannelActivityModuleRegistrySection(
          modules: modules,
          issues: [
            OmniChannelActivityModuleRegistrationIssue(
              type:
                  OmniChannelActivityModuleRegistrationIssueType
                      .missingActionContributor,
              key: 'missing-action-marketplace',
              id: 'marketplace',
              labels: const ['Marketplace'],
              moduleCount: 1,
              missingKey: 'marketplace',
            ),
          ],
        ),
      ),
    ),
  );
}

/// Compact coverage tile for one business module manifest.
class _ModuleRegistryTile extends StatelessWidget {
  final OmniChannelActivityModuleDiagnostic diagnostic;

  const _ModuleRegistryTile({required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        diagnostic.isHealthy
            ? diagnostic.hasActivity
                ? colorScheme.primary
                : colorScheme.secondary
            : colorScheme.error;
    final description = diagnostic.description.trim();
    final subtitle =
        description.isEmpty ? diagnostic.businessModelLabel : description;

    return OmniChannelActivityRegistryTile(
      key: ValueKey('omni-channel-registry-module-${diagnostic.id}'),
      icon: Icons.view_module_outlined,
      color: color,
      title: diagnostic.label,
      subtitle: subtitle,
      subtitleMaxLines: 2,
      children: [
        AppStatusPill(
          label: diagnostic.statusLabel,
          color: color,
          icon:
              diagnostic.isHealthy
                  ? Icons.verified_outlined
                  : Icons.report_problem_outlined,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: _countLabel(diagnostic.activityEventCount, 'event'),
          color: colorScheme.secondary,
          icon: Icons.timeline_outlined,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: _countLabel(
            diagnostic.registeredActionContributorCount,
            'contributor',
          ),
          color: colorScheme.primary,
          icon: Icons.extension_outlined,
          maxWidth: 164,
        ),
        AppStatusPill(
          label: _countLabel(
            diagnostic.registeredTriageDimensionCount,
            'dimension',
          ),
          color: colorScheme.tertiary,
          icon: Icons.account_tree_outlined,
          maxWidth: 154,
        ),
      ],
    );
  }
}

/// Compact warning tile for one module manifest contract issue.
class _ModuleIssueTile extends StatelessWidget {
  final OmniChannelActivityModuleRegistrationIssue issue;

  const _ModuleIssueTile({required this.issue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OmniChannelActivityRegistryTile(
      key: ValueKey('omni-channel-registry-module-issue-${issue.key}'),
      icon: Icons.report_problem_outlined,
      color: colorScheme.error,
      title: issue.title,
      subtitle: issue.detail,
      subtitleMaxLines: 3,
      children: [
        AppStatusPill(
          label: issue.label,
          color: colorScheme.error,
          icon: Icons.view_module_outlined,
          maxWidth: 220,
        ),
      ],
    );
  }
}

String _countLabel(int count, String singular) {
  return '$count $singular${count == 1 ? '' : 's'}';
}
