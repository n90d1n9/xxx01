import 'package:flutter/material.dart';

import '../story/chart_story_contract.dart';
import '../story/chart_story_contract_docs.dart';
import 'showcase_source_panel.dart';

class ChartStoryContractPanel extends StatelessWidget {
  const ChartStoryContractPanel({
    super.key,
    required this.contract,
    required this.title,
    this.sourcePanelHeight = 160,
    this.sourcePanelMinWidth = 300,
  });

  final ChartStoryContract contract;
  final String title;
  final double sourcePanelHeight;
  final double sourcePanelMinWidth;

  @override
  Widget build(BuildContext context) {
    final sourceItems = _sourceItems;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contract.summary != null) ...[
            Text(
              contract.summary!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
          if (contract.useCases.isNotEmpty) ...[
            _ContractSectionLabel(label: 'Use cases'),
            _ContractChipWrap(values: contract.useCases),
            const SizedBox(height: 12),
          ],
          if (contract.tags.isNotEmpty) ...[
            _ContractSectionLabel(label: 'Tags'),
            _ContractChipWrap(values: contract.tags),
            const SizedBox(height: 12),
          ],
          if (contract.knobs.isNotEmpty) ...[
            _ContractSectionLabel(label: 'Knobs'),
            _KnobSpecList(knobs: contract.knobs),
            const SizedBox(height: 12),
          ],
          if (sourceItems.isNotEmpty)
            ShowcaseSourceTextPanelGroup(
              items: sourceItems,
              panelHeight: sourcePanelHeight,
              minPanelWidth: sourcePanelMinWidth,
            ),
        ],
      ),
    );
  }

  List<ShowcaseSourceTextItem> get _sourceItems {
    return [
      if (contract.sampleJson != null)
        ShowcaseSourceTextItem(
          title: 'Sample JSON',
          text: showcasePrettyJson(contract.sampleJson),
          copyLabel: '$title JSON',
        ),
      if (contract.hasSampleCode)
        ShowcaseSourceTextItem(
          title: 'Dart Code',
          text: contract.sampleCode!,
          copyLabel: '$title code',
        ),
      ShowcaseSourceTextItem(
        title: 'Docs Markdown',
        text: chartStoryContractMarkdown(title: title, contract: contract),
        copyLabel: '$title docs',
      ),
    ];
  }
}

class _ContractSectionLabel extends StatelessWidget {
  const _ContractSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ContractChipWrap extends StatelessWidget {
  const _ContractChipWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final value in values)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(value, style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
      ],
    );
  }
}

class _KnobSpecList extends StatelessWidget {
  const _KnobSpecList({required this.knobs});

  final List<ChartStoryKnobSpec> knobs;

  @override
  Widget build(BuildContext context) {
    final groupedKnobs = _groupKnobs(knobs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groupedKnobs.entries) ...[
          Text(group.key, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          _ContractChipWrap(
            values: [for (final knob in group.value) _knobSummaryLabel(knob)],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Map<String, List<ChartStoryKnobSpec>> _groupKnobs(
    List<ChartStoryKnobSpec> knobs,
  ) {
    final grouped = <String, List<ChartStoryKnobSpec>>{};

    for (final knob in knobs) {
      grouped.putIfAbsent(knob.group, () => []).add(knob);
    }

    return grouped;
  }

  String _knobSummaryLabel(ChartStoryKnobSpec knob) {
    final defaultValue = knob.defaultValue;
    if (defaultValue == null) {
      return knob.label;
    }

    return '${knob.label}: $defaultValue';
  }
}
