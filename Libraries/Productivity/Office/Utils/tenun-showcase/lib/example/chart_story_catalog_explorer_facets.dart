import 'package:flutter/material.dart';

import 'chart_story_catalog_explorer_chips.dart';

class ChartCatalogFacetWrap extends StatefulWidget {
  const ChartCatalogFacetWrap({
    super.key,
    required this.title,
    required this.values,
    required this.valueCounts,
    required this.selectedValue,
    required this.onSelected,
    this.labelForValue,
    this.iconForValue,
    this.tooltipForValue,
  });

  final String title;
  final List<String> values;
  final Map<String, int> valueCounts;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final String Function(String value)? labelForValue;
  final IconData? Function(String value)? iconForValue;
  final String? Function(String value)? tooltipForValue;

  @override
  State<ChartCatalogFacetWrap> createState() => _ChartCatalogFacetWrapState();
}

class _ChartCatalogFacetWrapState extends State<ChartCatalogFacetWrap> {
  static const _collapsedValueLimit = 10;

  bool _isExpanded = false;

  bool get _canToggle => widget.values.length > _collapsedValueLimit;

  List<String> get _visibleValues {
    if (_isExpanded || !_canToggle) {
      return widget.values;
    }

    final visibleValues = <String>{};
    final selectedValue = widget.selectedValue;

    if (selectedValue != null && widget.values.contains(selectedValue)) {
      visibleValues.add(selectedValue);
    }

    for (final value in widget.values) {
      if (visibleValues.length >= _collapsedValueLimit) {
        break;
      }
      if ((widget.valueCounts[value] ?? 0) > 0) {
        visibleValues.add(value);
      }
    }

    for (final value in widget.values) {
      if (visibleValues.length >= _collapsedValueLimit) {
        break;
      }
      visibleValues.add(value);
    }

    return [
      for (final value in widget.values)
        if (visibleValues.contains(value)) value,
    ];
  }

  int get _hiddenCount {
    if (!_canToggle) {
      return 0;
    }

    return widget.values.length - _visibleValues.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleValues = _visibleValues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final value in visibleValues)
              ChartCatalogFacetChip(
                value: value,
                label: widget.labelForValue?.call(value) ?? value,
                count: widget.valueCounts[value] ?? 0,
                selected: value == widget.selectedValue,
                onSelected: widget.onSelected,
                avatarIcon: widget.iconForValue?.call(value),
                tooltip: widget.tooltipForValue?.call(value),
              ),
            if (_canToggle)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                label: Text(
                  _isExpanded ? 'Show fewer' : 'Show $_hiddenCount more',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
