import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace.dart';
import 'order_saved_workspace_action.dart';
import 'order_saved_workspace_details_action_bar.dart';
import 'order_saved_workspace_details_dialog.dart';
import 'order_saved_workspace_details_surface_frame.dart';
import 'order_saved_workspace_details_surface_presentation.dart';

export 'order_saved_workspace_details_surface_presentation.dart'
    show
        OrderSavedWorkspaceDetailsSurfaceKind,
        OrderSavedWorkspaceDetailsSurfacePresentation,
        orderSavedWorkspaceDetailsCompactBreakpoint,
        orderSavedWorkspaceDetailsMediumBreakpoint,
        orderSavedWorkspaceDetailsSurfaceForWidth;

Future<void> showOrderSavedWorkspaceDetailsSurface({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
  List<OrderSavedWorkspaceActionEntry> actionEntries = const [],
  OrderSavedWorkspaceDetailsActionSelected? onActionSelected,
}) {
  final surface = orderSavedWorkspaceDetailsSurfaceForWidth(
    MediaQuery.sizeOf(context).width,
  );

  return switch (surface) {
    OrderSavedWorkspaceDetailsSurfaceKind.dialog =>
      showOrderSavedWorkspaceDetailsDialog(
        context: context,
        workspace: workspace,
        actionEntries: actionEntries,
        onActionSelected: onActionSelected,
      ),
    OrderSavedWorkspaceDetailsSurfaceKind.bottomSheet =>
      showOrderSavedWorkspaceDetailsSheet(
        context: context,
        workspace: workspace,
        actionEntries: actionEntries,
        onActionSelected: onActionSelected,
      ),
    OrderSavedWorkspaceDetailsSurfaceKind.sideSheet =>
      showOrderSavedWorkspaceDetailsSideSheet(
        context: context,
        workspace: workspace,
        actionEntries: actionEntries,
        onActionSelected: onActionSelected,
      ),
  };
}

Future<void> showOrderSavedWorkspaceDetailsSheet({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
  List<OrderSavedWorkspaceActionEntry> actionEntries = const [],
  OrderSavedWorkspaceDetailsActionSelected? onActionSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder:
        (context) => OrderSavedWorkspaceDetailsSheet(
          workspace: workspace,
          actionEntries: actionEntries,
          onActionSelected: onActionSelected,
        ),
  );
}

Future<void> showOrderSavedWorkspaceDetailsSideSheet({
  required BuildContext context,
  required OrderSavedWorkspace workspace,
  List<OrderSavedWorkspaceActionEntry> actionEntries = const [],
  OrderSavedWorkspaceDetailsActionSelected? onActionSelected,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder:
        (context, animation, secondaryAnimation) =>
            OrderSavedWorkspaceDetailsSideSheet(
              workspace: workspace,
              actionEntries: actionEntries,
              onActionSelected: onActionSelected,
            ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return SlideTransition(position: offset, child: child);
    },
  );
}

class OrderSavedWorkspaceDetailsSideSheet extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected? onActionSelected;

  const OrderSavedWorkspaceDetailsSideSheet({
    super.key,
    required this.workspace,
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final surfacePresentation =
        OrderSavedWorkspaceDetailsSurfacePresentation.fromMediaQuery(
          mediaQuery,
        );

    return SafeArea(
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          key: const ValueKey('order_saved_workspace_details_side_sheet'),
          color: theme.colorScheme.surface,
          elevation: 18,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(POSUiTokens.radius * 2),
          ),
          child: SizedBox(
            width: surfacePresentation.sideSheetWidth,
            height: double.infinity,
            child: OrderSavedWorkspaceDetailsSurfaceFrame(
              workspace: workspace,
              padding: surfacePresentation.sideSheetPadding,
              contentMaxWidth: surfacePresentation.sideSheetContentMaxWidth,
              showDivider: true,
              actionEntries: actionEntries,
              onActionSelected: onActionSelected,
            ),
          ),
        ),
      ),
    );
  }
}

class OrderSavedWorkspaceDetailsSheet extends StatelessWidget {
  final OrderSavedWorkspace workspace;
  final List<OrderSavedWorkspaceActionEntry> actionEntries;
  final OrderSavedWorkspaceDetailsActionSelected? onActionSelected;

  const OrderSavedWorkspaceDetailsSheet({
    super.key,
    required this.workspace,
    this.actionEntries = const [],
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final surfacePresentation =
        OrderSavedWorkspaceDetailsSurfacePresentation.fromMediaQuery(
          mediaQuery,
        );

    return Padding(
      key: const ValueKey('order_saved_workspace_details_sheet'),
      padding: surfacePresentation.keyboardPadding,
      child: SizedBox(
        height: surfacePresentation.sheetHeight,
        child: OrderSavedWorkspaceDetailsSurfaceFrame(
          workspace: workspace,
          padding: surfacePresentation.sheetPadding,
          contentMaxWidth: surfacePresentation.sheetContentMaxWidth,
          showDragHandle: true,
          actionEntries: actionEntries,
          onActionSelected: onActionSelected,
        ),
      ),
    );
  }
}
