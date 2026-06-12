import 'package:flutter/material.dart';

import 'pos_filter_search_field.dart';
import 'pos_switch_status_filter_bar.dart';
import 'pos_ui.dart';

class POSSwitchFilterControls<T> extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHintText;
  final ValueChanged<String> onSearchChanged;
  final T selectedStatus;
  final List<POSSwitchStatusFilterOption<T>> statusOptions;
  final ValueChanged<T> onStatusSelected;

  const POSSwitchFilterControls({
    super.key,
    required this.searchController,
    required this.searchHintText,
    required this.onSearchChanged,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        POSFilterSearchField(
          controller: searchController,
          hintText: searchHintText,
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: POSUiTokens.gap),
        POSSwitchStatusFilterBar<T>(
          selectedValue: selectedStatus,
          options: statusOptions,
          onSelected: onStatusSelected,
        ),
        const SizedBox(height: POSUiTokens.gap),
      ],
    );
  }
}
