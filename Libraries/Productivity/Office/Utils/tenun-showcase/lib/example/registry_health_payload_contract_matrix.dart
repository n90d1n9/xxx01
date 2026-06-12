import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

class RegistryHealthPayloadContractMatrix extends StatelessWidget {
  const RegistryHealthPayloadContractMatrix({
    super.key,
    required this.contracts,
  });

  final List<ChartPayloadContract> contracts;

  @override
  Widget build(BuildContext context) {
    final rows = sortedRegistryHealthPayloadContracts(contracts);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 56,
              columns: const [
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Shape')),
                DataColumn(label: Text('Strategy')),
                DataColumn(label: Text('Shortcut Fields')),
                DataColumn(label: Text('Flags')),
              ],
              rows: rows
                  .map(
                    (contract) => DataRow(
                      cells: [
                        DataCell(Text(contract.typeString)),
                        DataCell(Text(contract.dataShape.name)),
                        DataCell(Text(contract.seriesStrategy.name)),
                        DataCell(
                          Text(registryHealthPayloadFieldsLabel(contract)),
                        ),
                        DataCell(_RegistryHealthPayloadFlags(contract)),
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

List<ChartPayloadContract> sortedRegistryHealthPayloadContracts(
  Iterable<ChartPayloadContract> contracts,
) {
  return contracts.toList()..sort((a, b) {
    final shape = a.dataShape.name.compareTo(b.dataShape.name);
    if (shape != 0) return shape;
    return a.typeString.compareTo(b.typeString);
  });
}

String registryHealthPayloadFieldsLabel(ChartPayloadContract contract) {
  switch (contract.seriesStrategy) {
    case ChartPayloadSeriesStrategy.dataFields:
      return contract.dataFieldPriority.isEmpty
          ? '-'
          : contract.dataFieldPriority.join(' | ');
    case ChartPayloadSeriesStrategy.namedCollection:
      return contract.namedCollectionField ?? '-';
    case ChartPayloadSeriesStrategy.nodeLink:
      return 'nodes + links';
    case ChartPayloadSeriesStrategy.calendarDateValues:
      return 'data | dateValues';
    case ChartPayloadSeriesStrategy.ringSlices:
      return 'rings[].slices';
    case ChartPayloadSeriesStrategy.partitionPie:
      return 'mainSlices + subSlices';
  }
}

bool registryHealthHasSpecialShortcutFields(ChartPayloadContract contract) {
  if (contract.seriesStrategy != ChartPayloadSeriesStrategy.dataFields) {
    return true;
  }
  return contract.dataFieldPriority.length > 1 ||
      (contract.dataFieldPriority.isNotEmpty &&
          contract.dataFieldPriority.first != 'data');
}

List<String> registryHealthPayloadFlagLabels(ChartPayloadContract contract) {
  return [
    if (contract.requiresSeries) 'series' else 'optional',
    if (contract.usesExternalDataModel) 'external model',
    if (registryHealthHasSpecialShortcutFields(contract)) 'shortcut',
  ];
}

class _RegistryHealthPayloadFlags extends StatelessWidget {
  const _RegistryHealthPayloadFlags(this.contract);

  final ChartPayloadContract contract;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: registryHealthPayloadFlagLabels(contract)
          .map(
            (flag) => Chip(
              label: Text(flag, style: const TextStyle(fontSize: 10)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            ),
          )
          .toList(),
    );
  }
}
