import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/action.dart' as m;
import '../models/layout_spec.dart';
import '../models/view_state.dart';
import 'mix_panel.dart';
import 'quick_actions.dart';

class OperationsSection extends StatelessWidget {
  const OperationsSection({
    required this.workspace,
    required this.layoutSpec,
    required this.onActionSelected,
    this.onActionInvoked,
    super.key,
  });

  final ViewState workspace;
  final LayoutSpec layoutSpec;
  final ValueChanged<String> onActionSelected;
  final ValueChanged<m.Action>? onActionInvoked;

  @override
  Widget build(BuildContext context) {
    if (layoutSpec.usesSidePanel) {
      return Row(
        key: const ValueKey('operations_side_panel'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: MixPanel(insights: workspace.overview.orderInsights)),
          const SizedBox(width: POSUiTokens.gapLarge),
          SizedBox(
            width: layoutSpec.actionPanelWidth,
            child: QuickActions(
              actions: workspace.actions,
              onActionSelected: onActionSelected,
              onActionInvoked: onActionInvoked,
            ),
          ),
        ],
      );
    }

    return Column(
      key: const ValueKey('operations_stacked'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuickActions(
          actions: workspace.actions,
          onActionSelected: onActionSelected,
          onActionInvoked: onActionInvoked,
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        MixPanel(insights: workspace.overview.orderInsights),
      ],
    );
  }
}
