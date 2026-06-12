import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

class RegistryHealthCapabilityMatrix extends StatelessWidget {
  const RegistryHealthCapabilityMatrix({super.key, required this.capabilities});

  final List<ChartCapabilities> capabilities;

  @override
  Widget build(BuildContext context) {
    final rows = sortedRegistryHealthCapabilities(capabilities);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 48,
              columns: const [
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Shape')),
                DataColumn(label: Text('API')),
                DataColumn(label: Text('Features')),
              ],
              rows: rows
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.typeString)),
                        DataCell(Text(item.dataShape.name)),
                        DataCell(Text(registryHealthCapabilityApiLabel(item))),
                        DataCell(_RegistryHealthFeatureChips(item)),
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

List<ChartCapabilities> sortedRegistryHealthCapabilities(
  Iterable<ChartCapabilities> capabilities,
) {
  return capabilities.toList()..sort((a, b) {
    final shape = a.dataShape.name.compareTo(b.dataShape.name);
    if (shape != 0) return shape;
    return a.typeString.compareTo(b.typeString);
  });
}

List<String> registryHealthCapabilityFeatureLabels(
  ChartCapabilities capabilities,
) {
  return [
    if (capabilities.supportsSampling) 'sample',
    if (capabilities.supportsZoom) 'zoom',
    if (capabilities.supportsDrilldown) 'drill',
    if (capabilities.supportsLegend) 'legend',
    if (capabilities.supportsTooltip) 'tip',
  ];
}

String registryHealthCapabilityApiLabel(ChartCapabilities capabilities) {
  return capabilities.apiContract.name;
}

class _RegistryHealthFeatureChips extends StatelessWidget {
  const _RegistryHealthFeatureChips(this.capabilities);

  final ChartCapabilities capabilities;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: registryHealthCapabilityFeatureLabels(capabilities)
          .map(
            (feature) => Chip(
              label: Text(feature, style: const TextStyle(fontSize: 10)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            ),
          )
          .toList(),
    );
  }
}
