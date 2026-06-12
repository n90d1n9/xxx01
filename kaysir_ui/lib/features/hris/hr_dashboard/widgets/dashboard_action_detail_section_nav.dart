import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

class DashboardActionDetailSectionNav extends StatelessWidget {
  final List<DashboardActionDetailSectionLink> sections;

  const DashboardActionDetailSectionNav({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return HrisListSurface(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var index = 0; index < sections.length; index += 1)
            _DashboardActionDetailSectionChip(
              section: sections[index],
              order: index.toDouble(),
            ),
        ],
      ),
    );
  }
}

class _DashboardActionDetailSectionChip extends StatelessWidget {
  final DashboardActionDetailSectionLink section;
  final double order;

  const _DashboardActionDetailSectionChip({
    required this.section,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final sectionName = section.label.toLowerCase();

    return FocusTraversalOrder(
      order: NumericFocusOrder(order),
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        focusable: true,
        selected: section.selected,
        sortKey: OrdinalSortKey(order),
        label: '${section.label} section',
        value: section.selected ? 'Current section' : null,
        onTapHint: 'Jump to $sectionName section',
        onTap: section.onSelected,
        child: Tooltip(
          message: 'Jump to $sectionName',
          child: ChoiceChip(
            avatar: Icon(section.icon, size: 17),
            label: Text(section.label),
            selected: section.selected,
            onSelected: (_) => section.onSelected(),
          ),
        ),
      ),
    );
  }
}

class DashboardActionDetailSectionLink {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  const DashboardActionDetailSectionLink({
    required this.label,
    required this.icon,
    this.selected = false,
    required this.onSelected,
  });
}
