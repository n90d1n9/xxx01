import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/models/order.dart';
import '../../order/states/current_order_provider.dart';
import '../experiences/pos_product_runtime_pack.dart';
import '../experiences/pos_product_runtime_pack_catalog.dart';
import '../experiences/pos_product_runtime_pack_controller.dart';
import '../experiences/pos_product_runtime_pack_switch_availability.dart';
import 'pos_runtime_pack_switch_action_handler.dart';
import 'pos_runtime_pack_option_tile.dart';
import 'pos_runtime_pack_switch_panel.dart';
import 'pos_switch_action_context_binding.dart';
import 'pos_switch_interaction.dart';
import 'pos_switch_popup_menu.dart';

class POSRuntimePackMenu extends ConsumerWidget {
  final bool showLabel;
  final double? viewportWidth;

  const POSRuntimePackMenu({
    super.key,
    this.showLabel = false,
    this.viewportWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(posProductRuntimePackSwitchControllerProvider);
    final currentPack = controller.currentPack;
    final currentOrder = ref.watch(currentOrderProvider);
    final resolvedViewportWidth =
        viewportWidth ?? MediaQuery.sizeOf(context).width;

    if (controller.isSingleOption) {
      return const SizedBox.shrink();
    }

    final icon = const Icon(Icons.apps_outlined);

    Future<void> openCompactSheet() async {
      final pack = await _showCompactSwitchSheet(
        context: context,
        controller: controller,
        currentOrder: currentOrder,
      );
      if (pack == null || !context.mounted) return;

      await handlePOSRuntimePackSwitchAction(
        actionContext: buildPOSSwitchActionContext(context: context, ref: ref),
        switchController: controller,
        pack: pack,
        currentOrder: currentOrder,
      );
    }

    return POSSwitchAdaptiveMenuButton<String>(
      tooltip: 'Runtime pack: ${currentPack.label}',
      icon: icon,
      label: showLabel ? Text(currentPack.label) : null,
      viewportWidth: resolvedViewportWidth,
      onCompactPressed: openCompactSheet,
      initialValue: currentPack.id,
      onSelected: (packId) async {
        await handlePOSRuntimePackSwitchAction(
          actionContext: buildPOSSwitchActionContext(
            context: context,
            ref: ref,
          ),
          switchController: controller,
          pack: controller.packFor(packId),
          currentOrder: currentOrder,
        );
      },
      itemBuilder: (context) => _buildEntries(controller, currentOrder),
    );
  }

  List<PopupMenuEntry<String>> _buildEntries(
    POSProductRuntimePackSwitchController controller,
    Order? currentOrder,
  ) {
    return buildPOSSwitchPopupMenuEntries<
      String,
      POSProductRuntimePackCatalogSection
    >(
      title: const Text('Runtime packs'),
      sections: controller.catalog.sections,
      sectionHeaderBuilder:
          (section) => POSRuntimePackSectionHeader(
            title: section.productLine,
            count: section.packCount,
          ),
      itemEntriesBuilder:
          (section) => section.packs.map((pack) {
            final plan = controller.planFor(pack);
            final availability =
                POSProductRuntimePackSwitchAvailability.evaluate(
                  plan: plan,
                  currentPack: controller.currentPack,
                  order: currentOrder,
                );
            return CheckedPopupMenuItem<String>(
              value: pack.id,
              checked: pack.id == controller.currentPack.id,
              child: POSRuntimePackOptionTile(
                pack: pack,
                plan: plan,
                availability: availability,
              ),
            );
          }),
    );
  }

  Future<POSProductRuntimePack?> _showCompactSwitchSheet({
    required BuildContext context,
    required POSProductRuntimePackSwitchController controller,
    required Order? currentOrder,
  }) {
    return showPOSSwitchCompactSheet<POSProductRuntimePack>(
      context: context,
      builder: (sheetContext) {
        return POSRuntimePackSwitchPanel(
          controller: controller,
          currentOrder: currentOrder,
          onPackSelected: (pack) => Navigator.of(sheetContext).pop(pack),
        );
      },
    );
  }
}
