import 'package:flutter/material.dart';

import '../../order/models/order.dart';
import '../experiences/pos_mode_switch_availability.dart';
import '../experiences/pos_mode_switch_availability_filter.dart';
import '../experiences/pos_mode_switch_controller.dart';
import '../experiences/pos_mode_switch_filter.dart';
import '../experiences/pos_mode_switch_preview.dart';
import 'pos_mode_switch_option_tile.dart';
import 'pos_switch_filtered_panel.dart';
import 'pos_switch_option_surface.dart';

class POSModeSwitchPanel extends StatelessWidget {
  final POSModeSwitchState state;
  final ValueChanged<POSModeSwitchOption> onOptionSelected;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool enableSearch;
  final Order? currentOrder;

  const POSModeSwitchPanel({
    super.key,
    required this.state,
    required this.onOptionSelected,
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 16),
    this.shrinkWrap = false,
    this.scrollController,
    this.enableSearch = true,
    this.currentOrder,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchFilteredPanel<
      POSModeSwitchFilterStatus,
      POSModeSwitchAvailabilitySection
    >(
      title: 'POS modes',
      currentLabel: state.currentExperience.label,
      initialStatus: POSModeSwitchFilterStatus.all,
      statusValues: POSModeSwitchFilterStatus.values,
      statusLabelBuilder: (status) => status.label,
      searchHintText: 'Search modes',
      filteredTitle: 'No matching modes',
      emptyTitle: 'No modes available',
      padding: padding,
      shrinkWrap: shrinkWrap,
      scrollController: scrollController,
      enableSearch: enableSearch,
      currentOrder: currentOrder,
      dataBuilder: (context, filterState) {
        final filter = POSModeSwitchAvailabilityFilter(
          query: filterState.query,
          status: filterState.status,
          order: currentOrder,
          currentExperience: state.currentExperience,
        );
        final counts = POSModeSwitchAvailabilityCounts.fromState(
          state,
          query: filterState.query,
          order: currentOrder,
          currentExperience: state.currentExperience,
        );
        final result = filter.apply(state);

        return POSSwitchFilteredPanelData(
          sections: result.sections,
          filterActive: filter.isActive,
          countForStatus: counts.countFor,
        );
      },
      headerBuilder:
          (context, section) => POSModeSwitchSectionHeader(
            title: section.productLine,
            count: section.optionCount,
            constraints: const BoxConstraints(),
          ),
      childrenBuilder:
          (context, section) => [
            for (final availability in section.availabilities)
              _POSModeSwitchPanelOption(
                availability: availability,
                preview: POSModeSwitchPreview.evaluate(
                  availability: availability,
                  currentExperience: state.currentExperience,
                ),
                onTap: () => onOptionSelected(availability.option),
              ),
          ],
    );
  }
}

class _POSModeSwitchPanelOption extends StatelessWidget {
  final POSModeSwitchAvailability availability;
  final POSModeSwitchPreview preview;
  final VoidCallback onTap;

  const _POSModeSwitchPanelOption({
    required this.availability,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final option = availability.option;

    return POSSwitchOptionSurface(
      selected: option.selected,
      onTap: onTap,
      child: POSModeSwitchOptionTile(
        option: option,
        availability: availability,
        preview: preview,
        showSelectedIndicator: true,
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
