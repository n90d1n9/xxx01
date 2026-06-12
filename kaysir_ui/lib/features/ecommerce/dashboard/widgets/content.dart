import 'package:flutter/material.dart';

import '../models/action.dart' as m;
import '../models/layout_spec.dart';
import '../models/section_order.dart';
import '../models/view_state.dart';
import 'sections.dart';

class Content extends StatelessWidget {
  final ViewState workspace;
  final VoidCallback onOpenCheckout;
  final VoidCallback onOpenOrders;
  final ValueChanged<String> onDestinationSelected;
  final ValueChanged<String> onActionSelected;
  final ValueChanged<m.Action>? onActionInvoked;
  final LayoutSpecBuilder? layoutSpecBuilder;
  final SectionOrder sectionOrder;
  final Map<SectionSlot, GlobalKey>? sectionFocusKeys;

  const Content({
    super.key,
    required this.workspace,
    required this.onOpenCheckout,
    required this.onOpenOrders,
    required this.onDestinationSelected,
    required this.onActionSelected,
    this.onActionInvoked,
    this.layoutSpecBuilder,
    this.sectionOrder = SectionOrder.defaultOrder,
    this.sectionFocusKeys,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutSpec = (layoutSpecBuilder ?? LayoutSpec.fromWidth)(
          constraints.maxWidth,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(layoutSpec.contentPadding),
          child: SectionDeck(
            workspace: workspace,
            layoutSpec: layoutSpec,
            sectionOrder: sectionOrder,
            onOpenCheckout: onOpenCheckout,
            onOpenOrders: onOpenOrders,
            onDestinationSelected: onDestinationSelected,
            onActionSelected: onActionSelected,
            onActionInvoked: onActionInvoked,
            sectionFocusKeys: sectionFocusKeys,
          ),
        );
      },
    );
  }
}
