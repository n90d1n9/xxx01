import 'package:flutter/material.dart';

import '../story/chart_story_contract.dart';
import '../story/chart_story_groups.dart';
import 'chart_story_contract_panel.dart';
import 'chart_story_contract_starter_panel.dart';

class ChartCatalogStoryContractDisclosure extends StatefulWidget {
  const ChartCatalogStoryContractDisclosure({
    super.key,
    required this.contract,
    required this.title,
  });

  final ChartStoryContract contract;
  final String title;

  @override
  State<ChartCatalogStoryContractDisclosure> createState() =>
      _ChartCatalogStoryContractDisclosureState();
}

class _ChartCatalogStoryContractDisclosureState
    extends State<ChartCatalogStoryContractDisclosure> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.schema_outlined,
              size: 18,
            ),
            label: Text(
              'Story contract',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (_isExpanded)
          ChartStoryContractPanel(
            contract: widget.contract,
            title: widget.title,
          ),
      ],
    );
  }
}

class ChartCatalogStoryContractStarterDisclosure extends StatefulWidget {
  const ChartCatalogStoryContractStarterDisclosure({
    super.key,
    required this.entry,
  });

  final ChartStoryEntry entry;

  @override
  State<ChartCatalogStoryContractStarterDisclosure> createState() =>
      _ChartCatalogStoryContractStarterDisclosureState();
}

class _ChartCatalogStoryContractStarterDisclosureState
    extends State<ChartCatalogStoryContractStarterDisclosure> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.article_outlined,
              size: 18,
            ),
            label: Text(
              'Starter contract',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (_isExpanded) ChartStoryContractStarterPanel(entry: widget.entry),
      ],
    );
  }
}
