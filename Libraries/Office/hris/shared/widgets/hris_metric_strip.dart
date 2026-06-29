import 'package:flutter/material.dart';

import '../theme/hris_theme.dart';

class HrisMetricStripItem {
  final String label;
  final String value;

  const HrisMetricStripItem({required this.label, required this.value});
}

class HrisMetricStrip extends StatelessWidget {
  final List<HrisMetricStripItem> items;

  const HrisMetricStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          items
              .map(
                (item) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: item == items.last ? 0 : 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: HrisColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: HrisColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: HrisColors.muted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.value,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
