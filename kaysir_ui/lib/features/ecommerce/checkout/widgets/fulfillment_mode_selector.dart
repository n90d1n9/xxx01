import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/fulfillment.dart';

class FulfillmentModeSelector extends StatelessWidget {
  final POSFulfillmentMode selectedMode;
  final List<FulfillmentSelection> options;
  final ValueChanged<POSFulfillmentMode> onModeSelected;

  const FulfillmentModeSelector({
    super.key,
    required this.selectedMode,
    required this.options,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          options.map((option) {
            final selected = option.mode == selectedMode;
            return KeyedSubtree(
              key: ValueKey('fulfillment_${option.modeKey}'),
              child: POSChoicePill(
                label: option.modeLabel,
                selected: selected,
                onSelected: (_) => onModeSelected(option.mode),
              ),
            );
          }).toList(),
    );
  }
}
