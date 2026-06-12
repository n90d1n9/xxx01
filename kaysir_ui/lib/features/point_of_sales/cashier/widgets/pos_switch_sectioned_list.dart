import 'package:flutter/material.dart';

import 'pos_switch_panel_chrome.dart';

typedef POSSwitchSectionHeaderBuilder<T> =
    Widget Function(BuildContext context, T section);

typedef POSSwitchSectionChildrenBuilder<T> =
    Iterable<Widget> Function(BuildContext context, T section);

class POSSwitchSectionedList<T> extends StatelessWidget {
  final Iterable<T> sections;
  final bool filterActive;
  final String filteredTitle;
  final String emptyTitle;
  final POSSwitchSectionHeaderBuilder<T> headerBuilder;
  final POSSwitchSectionChildrenBuilder<T> childrenBuilder;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final EdgeInsetsGeometry sectionHeaderPadding;

  const POSSwitchSectionedList({
    super.key,
    required this.sections,
    required this.filterActive,
    required this.filteredTitle,
    required this.emptyTitle,
    required this.headerBuilder,
    required this.childrenBuilder,
    this.scrollController,
    this.shrinkWrap = false,
    this.sectionHeaderPadding = const EdgeInsets.fromLTRB(2, 12, 2, 8),
  });

  @override
  Widget build(BuildContext context) {
    final sectionList = sections.toList(growable: false);

    return ListView(
      controller: scrollController,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      children: [
        if (sectionList.isEmpty)
          POSSwitchPanelEmptyState(
            filterActive: filterActive,
            filteredTitle: filteredTitle,
            emptyTitle: emptyTitle,
          )
        else
          for (final section in sectionList) ...[
            Padding(
              padding: sectionHeaderPadding,
              child: headerBuilder(context, section),
            ),
            ...childrenBuilder(context, section),
          ],
      ],
    );
  }
}
