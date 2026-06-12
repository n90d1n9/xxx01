import 'package:flutter/material.dart';

import '../story/chart_story_contract_starter.dart';
import '../story/chart_story_groups.dart';
import 'showcase_source_panel.dart';

class ChartStoryContractStarterPanel extends StatelessWidget {
  const ChartStoryContractStarterPanel({
    super.key,
    required this.entry,
    this.sourcePanelHeight = 180,
    this.sourcePanelMinWidth = 320,
  });

  final ChartStoryEntry entry;
  final double sourcePanelHeight;
  final double sourcePanelMinWidth;

  @override
  Widget build(BuildContext context) {
    final starter = chartStoryContractStarterForEntry(entry);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Use this starter as the contract scaffold for this story, then replace the placeholder use case, knobs, JSON, and code with chart-specific content.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ShowcaseSourceTextPanelGroup(
            panelHeight: sourcePanelHeight,
            minPanelWidth: sourcePanelMinWidth,
            items: [
              ShowcaseSourceTextItem(
                title: 'Contract starter',
                text: starter.code,
                copyLabel: '${entry.leaf ?? entry.name} contract starter',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartStoryContractStarterBundlePanel extends StatelessWidget {
  const ChartStoryContractStarterBundlePanel({
    super.key,
    required this.entries,
    this.limit = 6,
    this.sourcePanelHeight = 220,
    this.sourcePanelMinWidth = 360,
  });

  final List<ChartStoryEntry> entries;
  final int limit;
  final double sourcePanelHeight;
  final double sourcePanelMinWidth;

  @override
  Widget build(BuildContext context) {
    final bundle = chartStoryContractStarterBundleForEntries(
      entries,
      limit: limit,
    );
    if (bundle.isEmpty) {
      return const SizedBox.shrink();
    }

    final hiddenText = bundle.hiddenCount == 0
        ? ''
        : ' ${bundle.hiddenCount} additional starter contracts are hidden.';

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Copy the next ${bundle.count} contract starter scaffolds for batch migration.$hiddenText',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ShowcaseSourceTextPanelGroup(
            panelHeight: sourcePanelHeight,
            minPanelWidth: sourcePanelMinWidth,
            items: [
              ShowcaseSourceTextItem(
                title: 'Starter bundle',
                text: bundle.code,
                copyLabel: 'contract starter bundle',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
