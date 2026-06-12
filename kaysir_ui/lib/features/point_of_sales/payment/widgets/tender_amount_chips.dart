import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';
import '../utils/payment_tendering.dart';

class TenderAmountChips extends StatelessWidget {
  final List<TenderSuggestion> suggestions;
  final double selectedAmount;
  final ValueChanged<double> onSelected;

  const TenderAmountChips({
    super.key,
    required this.suggestions,
    required this.selectedAmount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: POSUiTokens.gap,
      runSpacing: POSUiTokens.gap,
      children:
          suggestions.map((suggestion) {
            final selected =
                (suggestion.amount - selectedAmount).abs() <= 0.009;

            return POSChoicePill(
              label: suggestion.label,
              selected: selected,
              onSelected: (_) => onSelected(suggestion.amount),
            );
          }).toList(),
    );
  }
}
