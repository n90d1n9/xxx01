import 'package:flutter/material.dart';

import '../../order/models/order.dart';
import 'pos_switch_filter_controls.dart';
import 'pos_switch_filter_host.dart';
import 'pos_switch_filter_state.dart';
import 'pos_switch_order_context_banner.dart';
import 'pos_switch_panel_scaffold.dart';
import 'pos_switch_sectioned_list.dart';
import 'pos_switch_status_filter_bar.dart';

typedef POSSwitchFilteredPanelDataBuilder<TStatus, TSection> =
    POSSwitchFilteredPanelData<TStatus, TSection> Function(
      BuildContext context,
      POSSwitchFilterState<TStatus> filterState,
    );

class POSSwitchFilteredPanelData<TStatus, TSection> {
  final Iterable<TSection> sections;
  final bool filterActive;
  final int Function(TStatus status) countForStatus;

  const POSSwitchFilteredPanelData({
    required this.sections,
    required this.filterActive,
    required this.countForStatus,
  });
}

class POSSwitchFilteredPanel<TStatus, TSection> extends StatelessWidget {
  final String title;
  final String currentLabel;
  final TStatus initialStatus;
  final String initialQuery;
  final Iterable<TStatus> statusValues;
  final String Function(TStatus status) statusLabelBuilder;
  final String searchHintText;
  final String filteredTitle;
  final String emptyTitle;
  final POSSwitchFilteredPanelDataBuilder<TStatus, TSection> dataBuilder;
  final POSSwitchSectionHeaderBuilder<TSection> headerBuilder;
  final POSSwitchSectionChildrenBuilder<TSection> childrenBuilder;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool enableSearch;
  final Order? currentOrder;

  const POSSwitchFilteredPanel({
    super.key,
    required this.title,
    required this.currentLabel,
    required this.initialStatus,
    required this.statusValues,
    required this.statusLabelBuilder,
    required this.searchHintText,
    required this.filteredTitle,
    required this.emptyTitle,
    required this.dataBuilder,
    required this.headerBuilder,
    required this.childrenBuilder,
    this.initialQuery = '',
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 16),
    this.shrinkWrap = false,
    this.scrollController,
    this.enableSearch = true,
    this.currentOrder,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchFilterHost<TStatus>(
      initialStatus: initialStatus,
      initialQuery: initialQuery,
      builder: (context, filterState) {
        final data = dataBuilder(context, filterState);

        return POSSwitchPanelScaffold(
          title: title,
          currentLabel: currentLabel,
          padding: padding,
          shrinkWrap: shrinkWrap,
          contextBanner: _orderContextBanner(),
          filters:
              enableSearch
                  ? POSSwitchFilterControls<TStatus>(
                    searchController: filterState.searchController,
                    searchHintText: searchHintText,
                    onSearchChanged: filterState.setQuery,
                    selectedStatus: filterState.status,
                    statusOptions: POSSwitchStatusFilterOption.fromValues(
                      statusValues,
                      labelBuilder: statusLabelBuilder,
                      countBuilder: data.countForStatus,
                    ),
                    onStatusSelected: filterState.setStatus,
                  )
                  : null,
          body: POSSwitchSectionedList<TSection>(
            sections: data.sections,
            filterActive: data.filterActive,
            filteredTitle: filteredTitle,
            emptyTitle: emptyTitle,
            shrinkWrap: shrinkWrap,
            scrollController: scrollController,
            headerBuilder: headerBuilder,
            childrenBuilder: childrenBuilder,
          ),
        );
      },
    );
  }

  Widget? _orderContextBanner() {
    final order = currentOrder;
    if (order == null || order.items.isEmpty) return null;

    return POSSwitchOrderContextBanner(order: order);
  }
}
