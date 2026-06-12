import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

class RegistryHealthApiContractMatrix extends StatelessWidget {
  const RegistryHealthApiContractMatrix({super.key, required this.contracts});

  final List<ChartApiContract> contracts;

  @override
  Widget build(BuildContext context) {
    final rows = sortedRegistryHealthApiContracts(contracts);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 72,
              columns: const [
                DataColumn(label: Text('Contract')),
                DataColumn(label: Text('Family')),
                DataColumn(label: Text('Fields')),
                DataColumn(label: Text('Recommended')),
                DataColumn(label: Text('Categories')),
              ],
              rows: rows
                  .map(
                    (contract) => DataRow(
                      cells: [
                        DataCell(Text(contract.name)),
                        DataCell(Text(contract.family.name)),
                        DataCell(
                          Text(contract.supportedFields.length.toString()),
                        ),
                        DataCell(
                          _RegistryHealthApiChips(
                            registryHealthApiRecommendedLabels(contract),
                          ),
                        ),
                        DataCell(
                          _RegistryHealthApiChips(
                            registryHealthApiCategoryLabels(contract),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

List<ChartApiContract> sortedRegistryHealthApiContracts(
  Iterable<ChartApiContract> contracts,
) {
  return contracts.toList()..sort((a, b) {
    final family = a.family.index.compareTo(b.family.index);
    if (family != 0) return family;
    return a.name.compareTo(b.name);
  });
}

List<String> registryHealthApiCategoryLabels(ChartApiContract contract) {
  final counts = registryHealthApiCategoryCounts(contract);
  return [
    for (final category in ChartApiFieldCategory.values)
      if ((counts[category] ?? 0) > 0)
        '${_registryHealthApiCategoryLabel(category)} ${counts[category]}',
  ];
}

Map<ChartApiFieldCategory, int> registryHealthApiCategoryCounts(
  ChartApiContract contract,
) {
  final counts = <ChartApiFieldCategory, int>{};
  for (final spec in contract.supportedSpecs) {
    counts.update(spec.category, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts;
}

bool registryHealthApiSupportsCategory(
  ChartApiContract contract,
  ChartApiFieldCategory category,
) {
  return registryHealthApiCategoryCounts(contract).containsKey(category);
}

List<String> registryHealthApiRecommendedLabels(
  ChartApiContract contract, {
  int visibleLimit = 4,
}) {
  if (contract.recommendedFields.length <= visibleLimit) {
    return contract.recommendedFields;
  }

  final remaining = contract.recommendedFields.length - visibleLimit;
  return [...contract.recommendedFields.take(visibleLimit), '+$remaining'];
}

String _registryHealthApiCategoryLabel(ChartApiFieldCategory category) {
  switch (category) {
    case ChartApiFieldCategory.structure:
      return 'structure';
    case ChartApiFieldCategory.display:
      return 'display';
    case ChartApiFieldCategory.interaction:
      return 'interaction';
    case ChartApiFieldCategory.accessibility:
      return 'a11y';
    case ChartApiFieldCategory.animation:
      return 'motion';
    case ChartApiFieldCategory.formatting:
      return 'format';
    case ChartApiFieldCategory.layout:
      return 'layout';
    case ChartApiFieldCategory.runtime:
      return 'runtime';
  }
}

class _RegistryHealthApiChips extends StatelessWidget {
  const _RegistryHealthApiChips(this.labels);

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const Text('-');

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: labels
          .map(
            (label) => Chip(
              label: Text(label, style: const TextStyle(fontSize: 10)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            ),
          )
          .toList(),
    );
  }
}
