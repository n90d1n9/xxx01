import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

class RegistryHealthShowcaseGapMatrix extends StatelessWidget {
  const RegistryHealthShowcaseGapMatrix({
    super.key,
    required this.entries,
    this.visibleLimit = 12,
  });

  final List<ChartFamilyManifestEntry> entries;
  final int visibleLimit;

  @override
  Widget build(BuildContext context) {
    final rows = registryHealthShowcaseGapRows(entries);
    final visibleRows = rows.take(visibleLimit).toList(growable: false);
    final hiddenCount = rows.length - visibleRows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowHeight: 34,
                  dataRowMinHeight: 42,
                  dataRowMaxHeight: 58,
                  columns: const [
                    DataColumn(label: Text('Chart')),
                    DataColumn(label: Text('Shape')),
                    DataColumn(label: Text('Bundle')),
                    DataColumn(label: Text('API')),
                    DataColumn(label: Text('Capabilities')),
                  ],
                  rows: [
                    for (final row in visibleRows)
                      DataRow(
                        cells: [
                          DataCell(Text(row.typeString)),
                          DataCell(Text(row.shapeName)),
                          DataCell(Text(row.bundleName)),
                          DataCell(Text(row.apiContractName)),
                          DataCell(_GapCapabilityChips(row.capabilities)),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '+$hiddenCount more missing chart families',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class RegistryHealthShowcaseGapRow {
  final String typeString;
  final String shapeName;
  final String bundleName;
  final String apiContractName;
  final List<String> capabilities;

  const RegistryHealthShowcaseGapRow({
    required this.typeString,
    required this.shapeName,
    required this.bundleName,
    required this.apiContractName,
    required this.capabilities,
  });
}

List<RegistryHealthShowcaseGapRow> registryHealthShowcaseGapRows(
  Iterable<ChartFamilyManifestEntry> entries,
) {
  final rows = [
    for (final entry in entries)
      RegistryHealthShowcaseGapRow(
        typeString: entry.showcaseExampleKey,
        shapeName: entry.dataShape.name,
        bundleName: entry.primaryBundleName,
        apiContractName: entry.apiContract.name,
        capabilities: registryHealthShowcaseGapCapabilityLabels(entry),
      ),
  ];

  return rows..sort((a, b) {
    final bundle = a.bundleName.compareTo(b.bundleName);
    if (bundle != 0) return bundle;
    final shape = a.shapeName.compareTo(b.shapeName);
    if (shape != 0) return shape;
    return a.typeString.compareTo(b.typeString);
  });
}

List<String> registryHealthShowcaseGapCapabilityLabels(
  ChartFamilyManifestEntry entry,
) {
  return [
    if (entry.supportsSampling) 'sample',
    if (entry.supportsZoom) 'zoom',
    if (entry.supportsDrilldown) 'drill',
    if (entry.supportsLegend) 'legend',
    if (entry.supportsTooltip) 'tip',
    if (entry.supportsRuntimeSwitching) 'switch',
  ];
}

class _GapCapabilityChips extends StatelessWidget {
  const _GapCapabilityChips(this.labels);

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const Text('-');

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final label in labels)
          Chip(
            label: Text(label, style: const TextStyle(fontSize: 10)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          ),
      ],
    );
  }
}
