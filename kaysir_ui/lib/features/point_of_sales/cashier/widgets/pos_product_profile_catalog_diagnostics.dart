import 'package:flutter/material.dart';

import '../experiences/pos_experience_diagnostics.dart';
import '../experiences/pos_product_profile.dart';
import 'pos_ui.dart';

class POSProductProfileCatalogDiagnosticsRows extends StatelessWidget {
  final POSExperienceDiagnostics diagnostics;

  const POSProductProfileCatalogDiagnosticsRows({
    super.key,
    required this.diagnostics,
  });

  @override
  Widget build(BuildContext context) {
    final report = diagnostics.productProfileValidationReport;
    if (report == null) {
      return const Text(
        'No product profile catalog validation report supplied.',
      );
    }
    final totalIssueCount = report.issues.length;

    return Column(
      children: [
        _CatalogDiagnosticRow(
          label: 'Profiles',
          value:
              '${report.profileCount} total, ${report.launchableCount} launchable',
        ),
        _CatalogDiagnosticRow(
          label: 'Blocked',
          value: '${report.blockedCount}',
        ),
        _CatalogDiagnosticRow(label: 'Status', value: report.statusLabel),
        _CatalogDiagnosticRow(
          label: 'Validation',
          value:
              totalIssueCount == 0
                  ? 'Product profile catalog contract valid.'
                  : '$totalIssueCount total validation issue${totalIssueCount == 1 ? '' : 's'} found.',
        ),
      ],
    );
  }
}

class POSProductProfileCatalogIssueList extends StatelessWidget {
  final List<POSProductProfileIssue> issues;

  const POSProductProfileCatalogIssueList({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          issues
              .map(
                (issue) => _CatalogDiagnosticRow(
                  label: _issueTypeLabel(issue.type),
                  value: issue.message,
                ),
              )
              .toList(),
    );
  }

  String _issueTypeLabel(POSProductProfileIssueType type) {
    switch (type) {
      case POSProductProfileIssueType.emptyCatalog:
        return 'Empty catalog';
      case POSProductProfileIssueType.blankProfileId:
        return 'Blank profile ID';
      case POSProductProfileIssueType.duplicateProfileId:
        return 'Duplicate profile';
      case POSProductProfileIssueType.duplicateModeId:
        return 'Duplicate mode';
      case POSProductProfileIssueType.blankProfileLabel:
        return 'Blank label';
      case POSProductProfileIssueType.blankProfileDescription:
        return 'Blank description';
      case POSProductProfileIssueType.blockedLaunch:
        return 'Launch blocked';
      case POSProductProfileIssueType.registryIssue:
        return 'Registry issue';
    }
  }
}

class _CatalogDiagnosticRow extends StatelessWidget {
  final String label;
  final String value;

  const _CatalogDiagnosticRow({required this.label, required this.value});

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
