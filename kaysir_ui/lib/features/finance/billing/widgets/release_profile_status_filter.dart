import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'release_profile_contract.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_contract_status_visuals.dart';
import 'standard_release_workspace_profiles.dart';

/// Selectable status filter for release workspace profile contract lists.
class BillingReleaseProfileStatusFilter extends StatelessWidget {
  final BillingReleaseWorkspaceProfileContractStatusSummary summary;
  final BillingReleaseProfileStatusFilterOption selectedOption;
  final ValueChanged<BillingReleaseProfileStatusFilterOption> onOptionSelected;
  final bool showZeroStatuses;

  const BillingReleaseProfileStatusFilter({
    super.key,
    required this.summary,
    required this.selectedOption,
    required this.onOptionSelected,
    this.showZeroStatuses = false,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final options = billingReleaseProfileStatusFilterOptions(
      summary,
      showZeroStatuses: showZeroStatuses,
    );
    final selected = selectedOption.resolveFor(
      summary,
      showZeroStatuses: showZeroStatuses,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile status',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<BillingReleaseProfileStatusFilterOption>(
            showSelectedIcon: false,
            segments: [
              for (final option in options)
                ButtonSegment(
                  value: option,
                  icon: Icon(_optionIcon(option)),
                  label: Text(option.labelFor(summary)),
                  tooltip: option.tooltipFor(summary),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              onOptionSelected(selection.first);
            },
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Release profile status filter')
Widget releaseProfileStatusFilterPreview() {
  final coverage = BillingReleaseWorkspaceProfileContractCoverage(
    contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BillingReleaseProfileStatusFilter(
          summary: coverage.statusSummary,
          selectedOption: BillingReleaseProfileStatusFilterOption.all,
          onOptionSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Filter options exposed by the release profile status segmented control.
enum BillingReleaseProfileStatusFilterOption {
  all,
  tailored,
  constrained,
  extended,
  standard,
}

/// Maps filter options to profile contract statuses and list predicates.
extension BillingReleaseProfileStatusFilterOptionMapping
    on BillingReleaseProfileStatusFilterOption {
  BillingReleaseWorkspaceProfileContractStatus? get contractStatus {
    return switch (this) {
      BillingReleaseProfileStatusFilterOption.all => null,
      BillingReleaseProfileStatusFilterOption.tailored =>
        BillingReleaseWorkspaceProfileContractStatus.tailored,
      BillingReleaseProfileStatusFilterOption.constrained =>
        BillingReleaseWorkspaceProfileContractStatus.constrained,
      BillingReleaseProfileStatusFilterOption.extended =>
        BillingReleaseWorkspaceProfileContractStatus.extended,
      BillingReleaseProfileStatusFilterOption.standard =>
        BillingReleaseWorkspaceProfileContractStatus.standard,
    };
  }

  Set<BillingReleaseWorkspaceProfileContractStatus>? get includedStatuses {
    final status = contractStatus;
    if (status == null) return null;

    return {status};
  }

  String get emptyLabel {
    final status = contractStatus;
    if (status == null) return 'No release workspace profiles are registered.';

    return 'No ${status.label.toLowerCase()} release profiles.';
  }

  bool isAvailableFor(
    BillingReleaseWorkspaceProfileContractStatusSummary summary, {
    bool showZeroStatuses = false,
  }) {
    final status = contractStatus;
    if (status == null) return true;

    return showZeroStatuses || summary.countFor(status) > 0;
  }

  BillingReleaseProfileStatusFilterOption resolveFor(
    BillingReleaseWorkspaceProfileContractStatusSummary summary, {
    bool showZeroStatuses = false,
  }) {
    if (isAvailableFor(summary, showZeroStatuses: showZeroStatuses)) {
      return this;
    }

    return BillingReleaseProfileStatusFilterOption.all;
  }

  String labelFor(BillingReleaseWorkspaceProfileContractStatusSummary summary) {
    if (this == BillingReleaseProfileStatusFilterOption.all) {
      return 'All ${summary.totalCount}';
    }

    final status = contractStatus!;
    return '${status.label} ${summary.countFor(status)}';
  }

  String tooltipFor(
    BillingReleaseWorkspaceProfileContractStatusSummary summary,
  ) {
    if (this == BillingReleaseProfileStatusFilterOption.all) {
      return 'Show all ${summary.totalCount} release workspace profiles';
    }

    final status = contractStatus!;
    return 'Show ${summary.countFor(status)} ${status.label.toLowerCase()} '
        'release workspace profiles';
  }
}

const _statusOptions = [
  BillingReleaseProfileStatusFilterOption.tailored,
  BillingReleaseProfileStatusFilterOption.constrained,
  BillingReleaseProfileStatusFilterOption.extended,
  BillingReleaseProfileStatusFilterOption.standard,
];

/// Returns status filter options available for a profile contract summary.
List<BillingReleaseProfileStatusFilterOption>
billingReleaseProfileStatusFilterOptions(
  BillingReleaseWorkspaceProfileContractStatusSummary summary, {
  bool showZeroStatuses = false,
}) {
  return [
    BillingReleaseProfileStatusFilterOption.all,
    for (final option in _statusOptions)
      if (option.isAvailableFor(summary, showZeroStatuses: showZeroStatuses))
        option,
  ];
}

IconData _optionIcon(BillingReleaseProfileStatusFilterOption option) {
  final status = option.contractStatus;
  if (status == null) return Icons.filter_list_outlined;

  return BillingReleaseWorkspaceProfileContractStatusVisuals.fromStatus(
    status,
  ).icon;
}
