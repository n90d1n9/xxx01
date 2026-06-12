import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/registry_diagnostics.dart';
import 'empty_state.dart';
import 'registry_issue_row.dart';
import 'registry_source_pill.dart';

class RegistrySourcePills extends StatelessWidget {
  const RegistrySourcePills({required this.sourceSummaries, super.key});

  final List<RegistrySourceSummary> sourceSummaries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children: sourceSummaries
          .map((summary) => RegistrySourcePill(summary: summary))
          .toList(growable: false),
    );
  }
}

class RegistryIssueList extends StatelessWidget {
  const RegistryIssueList({required this.diagnostics, super.key});

  final RegistryDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) {
    if (!diagnostics.hasIssues) {
      return const EmptyState(message: 'No registry issues found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: diagnostics.issues
          .map((issue) => RegistryIssueRow(issue: issue))
          .toList(growable: false),
    );
  }
}
