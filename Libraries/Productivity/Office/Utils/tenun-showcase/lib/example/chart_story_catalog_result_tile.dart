import 'package:flutter/material.dart';

import '../story/chart_story_contract_coverage.dart';
import '../story/chart_story_groups.dart';
import 'chart_story_catalog_result_disclosures.dart';
import 'chart_story_catalog_result_metadata.dart';

class ChartCatalogResultTile extends StatelessWidget {
  const ChartCatalogResultTile({super.key, required this.entry});

  final ChartStoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final contract = entry.contract;
    final missingParts = chartStoryContractMissingParts(entry);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.auto_graph),
            title: Text(entry.leaf ?? entry.name),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.breadcrumb}\n${entry.story.description}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ChartCatalogEntryMetadataWrap(entry: entry),
                ],
              ),
            ),
            trailing: Text(
              entry.groupLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (contract != null)
            ChartCatalogStoryContractDisclosure(
              contract: contract,
              title: entry.leaf ?? entry.name,
            ),
          if (missingParts.isNotEmpty)
            ChartCatalogStoryContractStarterDisclosure(entry: entry),
        ],
      ),
    );
  }
}
