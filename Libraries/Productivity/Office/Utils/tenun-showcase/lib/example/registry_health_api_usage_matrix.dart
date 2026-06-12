import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

class RegistryHealthApiUsageMatrix extends StatelessWidget {
  const RegistryHealthApiUsageMatrix({super.key, required this.capabilities});

  final List<ChartCapabilities> capabilities;

  @override
  Widget build(BuildContext context) {
    final rows = registryHealthApiUsageRows(capabilities);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 46,
              dataRowMaxHeight: 64,
              columns: const [
                DataColumn(label: Text('Contract')),
                DataColumn(label: Text('Family')),
                DataColumn(label: Text('Charts')),
                DataColumn(label: Text('Shapes')),
                DataColumn(label: Text('Examples')),
              ],
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row.contractName)),
                        DataCell(Text(row.familyName)),
                        DataCell(Text(row.chartCount.toString())),
                        DataCell(_RegistryHealthApiUsageChips(row.shapes)),
                        DataCell(_RegistryHealthApiUsageChips(row.examples)),
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

class RegistryHealthApiUsageRow {
  final String contractName;
  final String familyName;
  final int familyIndex;
  final int chartCount;
  final List<String> shapes;
  final List<String> examples;

  const RegistryHealthApiUsageRow({
    required this.contractName,
    required this.familyName,
    required this.familyIndex,
    required this.chartCount,
    required this.shapes,
    required this.examples,
  });
}

List<RegistryHealthApiUsageRow> registryHealthApiUsageRows(
  Iterable<ChartCapabilities> capabilities, {
  int exampleLimit = 6,
}) {
  final grouped = <String, List<ChartCapabilities>>{};
  for (final capability in capabilities) {
    grouped
        .putIfAbsent(capability.apiContract.name, () => <ChartCapabilities>[])
        .add(capability);
  }

  final rows = <RegistryHealthApiUsageRow>[];
  for (final entry in grouped.entries) {
    final items = entry.value.toList()
      ..sort((a, b) => a.typeString.compareTo(b.typeString));
    final contract = items.first.apiContract;
    rows.add(
      RegistryHealthApiUsageRow(
        contractName: contract.name,
        familyName: contract.family.name,
        familyIndex: contract.family.index,
        chartCount: items.length,
        shapes: registryHealthApiUsageShapes(items),
        examples: registryHealthApiUsageExamples(
          items,
          visibleLimit: exampleLimit,
        ),
      ),
    );
  }

  return rows..sort((a, b) {
    final family = a.familyIndex.compareTo(b.familyIndex);
    if (family != 0) return family;
    return a.contractName.compareTo(b.contractName);
  });
}

List<String> registryHealthApiUsageShapes(
  Iterable<ChartCapabilities> capabilities,
) {
  final shapes = {for (final item in capabilities) item.dataShape.name}.toList()
    ..sort();
  return shapes;
}

List<String> registryHealthApiUsageExamples(
  Iterable<ChartCapabilities> capabilities, {
  int visibleLimit = 6,
}) {
  final labels = [for (final item in capabilities) item.typeString]..sort();
  if (labels.length <= visibleLimit) return labels;

  final remaining = labels.length - visibleLimit;
  return [...labels.take(visibleLimit), '+$remaining'];
}

class _RegistryHealthApiUsageChips extends StatelessWidget {
  const _RegistryHealthApiUsageChips(this.labels);

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
