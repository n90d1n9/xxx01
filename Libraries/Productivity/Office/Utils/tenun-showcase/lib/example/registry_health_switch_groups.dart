import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align;

class RegistryHealthSwitchGroupList extends StatelessWidget {
  const RegistryHealthSwitchGroupList({super.key, required this.groups});

  final List<ChartSwitchGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const Text('No runtime switch groups available.');
    }

    return Column(
      children: groups
          .map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.dataShape.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              '${group.count} switch targets',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _RegistryHealthSwitchTargetChips(group)),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RegistryHealthSwitchTargetChips extends StatelessWidget {
  const _RegistryHealthSwitchTargetChips(this.group);

  final ChartSwitchGroup group;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final chart in group.charts)
          Chip(
            label: Text(chart.typeString, style: const TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }
}
