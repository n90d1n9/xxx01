import 'package:flutter/material.dart';

import '../../order/models/order.dart';
import '../experiences/pos_product_runtime_pack.dart';
import '../experiences/pos_product_runtime_pack_controller.dart';
import '../experiences/pos_product_runtime_pack_switch_availability.dart';
import '../experiences/pos_product_runtime_pack_switch_availability_filter.dart';
import '../experiences/pos_product_runtime_pack_switch_preview.dart';
import 'pos_runtime_pack_option_tile.dart';
import 'pos_switch_filtered_panel.dart';
import 'pos_switch_option_surface.dart';

class POSRuntimePackSwitchPanel extends StatelessWidget {
  final POSProductRuntimePackSwitchController controller;
  final ValueChanged<POSProductRuntimePack> onPackSelected;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollController? scrollController;
  final bool enableSearch;
  final Order? currentOrder;

  const POSRuntimePackSwitchPanel({
    super.key,
    required this.controller,
    required this.onPackSelected,
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 16),
    this.shrinkWrap = false,
    this.scrollController,
    this.enableSearch = true,
    this.currentOrder,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchFilteredPanel<
      POSProductRuntimePackSwitchAvailabilityFilterStatus,
      POSProductRuntimePackSwitchAvailabilitySection
    >(
      title: 'Runtime packs',
      currentLabel: controller.currentPack.label,
      initialStatus: POSProductRuntimePackSwitchAvailabilityFilterStatus.all,
      statusValues: POSProductRuntimePackSwitchAvailabilityFilterStatus.values,
      statusLabelBuilder: (status) => status.label,
      searchHintText: 'Search runtime packs',
      filteredTitle: 'No matching runtime packs',
      emptyTitle: 'No runtime packs available',
      padding: padding,
      shrinkWrap: shrinkWrap,
      scrollController: scrollController,
      enableSearch: enableSearch,
      currentOrder: currentOrder,
      dataBuilder: (context, filterState) {
        final filter = POSProductRuntimePackSwitchAvailabilityFilter(
          query: filterState.query,
          status: filterState.status,
          order: currentOrder,
        );
        final counts = controller.availabilityCounts(
          query: filterState.query,
          order: currentOrder,
        );
        final result = controller.filterAvailability(filter);

        return POSSwitchFilteredPanelData(
          sections: result.sections,
          filterActive: filter.isActive,
          countForStatus: counts.countFor,
        );
      },
      headerBuilder:
          (context, section) => POSRuntimePackSectionHeader(
            title: section.productLine,
            count: section.packCount,
            constraints: const BoxConstraints(),
          ),
      childrenBuilder:
          (context, section) => [
            for (final availability in section.availabilities)
              _POSRuntimePackPanelOption(
                availability: availability,
                preview: POSProductRuntimePackSwitchPreview.evaluate(
                  availability: availability,
                  currentLayoutPreference: controller.currentLayoutPreference,
                ),
                onTap: () => onPackSelected(availability.plan.pack),
              ),
          ],
    );
  }
}

class _POSRuntimePackPanelOption extends StatelessWidget {
  final POSProductRuntimePackSwitchAvailability availability;
  final POSProductRuntimePackSwitchPreview preview;
  final VoidCallback onTap;

  const _POSRuntimePackPanelOption({
    required this.availability,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchOptionSurface(
      selected: availability.isCurrent,
      onTap: onTap,
      child: POSRuntimePackOptionTile(
        pack: availability.plan.pack,
        plan: availability.plan,
        availability: availability,
        preview: preview,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
