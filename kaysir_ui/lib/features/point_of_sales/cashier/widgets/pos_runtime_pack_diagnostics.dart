import 'package:flutter/material.dart';

import '../experiences/pos_experience_diagnostics.dart';
import '../experiences/pos_product_runtime_pack.dart';
import 'pos_ui.dart';

class POSRuntimePackDiagnosticsRows extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const POSRuntimePackDiagnosticsRows({super.key, required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final resolution = diagnostics.runtimePackResolution;
    if (resolution == null) {
      return const Text('No POS runtime pack supplied.');
    }

    return Column(
      children: [
        _RuntimePackDiagnosticRow(
          label: 'Pack',
          value: diagnostics.runtimePackLabel,
        ),
        _RuntimePackDiagnosticRow(
          label: 'Pack ID',
          value: diagnostics.runtimePackId,
        ),
        _RuntimePackDiagnosticRow(
          label: 'Product line',
          value: diagnostics.runtimePackProductLine,
        ),
        _RuntimePackDiagnosticRow(
          label: 'Use',
          value: diagnostics.runtimePackDescription,
        ),
        _RuntimePackDiagnosticRow(
          label: 'Validation',
          value:
              diagnostics.runtimePackIssueCount == 0
                  ? 'Runtime pack wiring valid.'
                  : '${diagnostics.runtimePackIssueCount} runtime pack issue${diagnostics.runtimePackIssueCount == 1 ? '' : 's'} found.',
        ),
        if (resolution.usedFallback)
          _RuntimePackDiagnosticRow(
            label: 'Default pack',
            value:
                resolution.fallbackReason ?? 'Default runtime pack is active.',
          ),
      ],
    );
  }
}

class POSRuntimePackIssueList extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const POSRuntimePackIssueList({super.key, required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (diagnostics.runtimePackUsedFallback)
          _RuntimePackDiagnosticRow(
            label: 'Default pack',
            value:
                diagnostics.runtimePackFallbackReason ??
                'Default runtime pack is active.',
          ),
        ...diagnostics.runtimePackRegistryIssues.map(
          (issue) => _RuntimePackDiagnosticRow(
            label: _registryIssueTypeLabel(issue.type),
            value: issue.message,
          ),
        ),
        ...diagnostics.runtimePackIssues.map(
          (issue) => _RuntimePackDiagnosticRow(
            label: _packIssueTypeLabel(issue.type),
            value: issue.message,
          ),
        ),
      ],
    );
  }

  String _registryIssueTypeLabel(POSProductRuntimePackRegistryIssueType type) {
    switch (type) {
      case POSProductRuntimePackRegistryIssueType.emptyRegistry:
        return 'Empty packs';
      case POSProductRuntimePackRegistryIssueType.duplicatePackId:
        return 'Duplicate pack';
      case POSProductRuntimePackRegistryIssueType.missingDefaultPack:
        return 'Missing default';
      case POSProductRuntimePackRegistryIssueType.packIssue:
        return 'Pack issue';
    }
  }

  String _packIssueTypeLabel(POSProductRuntimePackIssueType type) {
    switch (type) {
      case POSProductRuntimePackIssueType.blankPackId:
        return 'Blank pack ID';
      case POSProductRuntimePackIssueType.blankPackLabel:
        return 'Blank label';
      case POSProductRuntimePackIssueType.blankPackDescription:
        return 'Blank description';
      case POSProductRuntimePackIssueType.productProfileCatalogIssue:
        return 'Product catalog';
      case POSProductRuntimePackIssueType.commerceChannelRegistryIssue:
        return 'Channel registry';
      case POSProductRuntimePackIssueType.commerceChannelBehaviorIssue:
        return 'Channel behaviors';
      case POSProductRuntimePackIssueType.layoutStrategyIssue:
        return 'Layout strategy';
      case POSProductRuntimePackIssueType.layoutRendererIssue:
        return 'Layout renderer';
      case POSProductRuntimePackIssueType.touchLayoutProfileIssue:
        return 'Touch layout';
      case POSProductRuntimePackIssueType.commandActionIssue:
        return 'Command registry';
      case POSProductRuntimePackIssueType.shortcutIssue:
        return 'Shortcut registry';
    }
  }
}

class _RuntimePackDiagnosticRow extends StatelessWidget {
  final String label;
  final String value;

  const _RuntimePackDiagnosticRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
