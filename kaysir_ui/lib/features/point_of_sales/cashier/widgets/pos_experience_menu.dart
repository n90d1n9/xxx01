import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/models/order.dart';
import '../../order/states/current_order_provider.dart';
import '../experiences/pos_mode_switch_availability.dart';
import '../experiences/pos_mode_switch_controller.dart';
import '../experiences/pos_mode_switch_preview.dart';
import 'pos_mode_switch_option_tile.dart';
import 'pos_mode_switch_panel.dart';
import 'pos_mode_switch_action_handler.dart';
import 'pos_switch_action_context_binding.dart';
import 'pos_switch_interaction.dart';
import 'pos_switch_popup_menu.dart';

class POSExperienceMenu extends ConsumerWidget {
  final double? viewportWidth;

  const POSExperienceMenu({super.key, this.viewportWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedViewportWidth =
        viewportWidth ?? MediaQuery.sizeOf(context).width;
    final switchController = ref.watch(
      posModeSwitchControllerProvider(resolvedViewportWidth),
    );
    final switchState = switchController.state;
    final currentExperience = switchState.currentExperience;
    final currentOrder = ref.watch(currentOrderProvider);

    if (switchState.isSingleOption) {
      return const SizedBox.shrink();
    }

    Future<void> openCompactSheet() async {
      final option = await _showCompactSwitchSheet(
        context: context,
        state: switchState,
        currentOrder: currentOrder,
      );
      if (option == null || !context.mounted) return;

      await handlePOSModeSwitchAction(
        actionContext: buildPOSSwitchActionContext(context: context, ref: ref),
        switchController: switchController,
        option: option,
        currentOrder: currentOrder,
      );
    }

    return POSSwitchAdaptiveMenuButton<String>(
      tooltip: 'POS mode: ${currentExperience.label}',
      icon: const Icon(Icons.dashboard_customize_outlined),
      viewportWidth: resolvedViewportWidth,
      onCompactPressed: openCompactSheet,
      initialValue: currentExperience.id,
      onSelected: (experienceId) async {
        final option = switchController.optionFor(experienceId);
        await handlePOSModeSwitchAction(
          actionContext: buildPOSSwitchActionContext(
            context: context,
            ref: ref,
          ),
          switchController: switchController,
          option: option,
          currentOrder: currentOrder,
        );
      },
      itemBuilder:
          (context) =>
              _buildEntries(state: switchState, currentOrder: currentOrder),
    );
  }

  List<PopupMenuEntry<String>> _buildEntries({
    required POSModeSwitchState state,
    required Order? currentOrder,
  }) {
    return buildPOSSwitchPopupMenuEntries<String, POSModeSwitchSection>(
      sections: state.sections,
      sectionHeaderBuilder:
          (section) => POSModeSwitchSectionHeader(
            title: section.productLine,
            count: section.optionCount,
          ),
      itemEntriesBuilder:
          (section) => section.options.map((option) {
            final availability = POSModeSwitchAvailability.evaluate(
              option: option,
              order: currentOrder,
            );

            return CheckedPopupMenuItem<String>(
              value: option.id,
              checked: option.selected,
              child: POSModeSwitchOptionTile(
                option: option,
                availability: availability,
                preview: POSModeSwitchPreview.evaluate(
                  availability: availability,
                  currentExperience: state.currentExperience,
                ),
              ),
            );
          }),
    );
  }

  Future<POSModeSwitchOption?> _showCompactSwitchSheet({
    required BuildContext context,
    required POSModeSwitchState state,
    required Order? currentOrder,
  }) {
    return showPOSSwitchCompactSheet<POSModeSwitchOption>(
      context: context,
      builder: (sheetContext) {
        return POSModeSwitchPanel(
          state: state,
          currentOrder: currentOrder,
          onOptionSelected: (option) => Navigator.of(sheetContext).pop(option),
        );
      },
    );
  }
}
