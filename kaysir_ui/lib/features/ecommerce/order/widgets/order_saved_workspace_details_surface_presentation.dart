import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';

const double orderSavedWorkspaceDetailsCompactBreakpoint = 720;
const double orderSavedWorkspaceDetailsMediumBreakpoint = 1120;

enum OrderSavedWorkspaceDetailsSurfaceKind { dialog, sideSheet, bottomSheet }

OrderSavedWorkspaceDetailsSurfaceKind orderSavedWorkspaceDetailsSurfaceForWidth(
  double width,
) {
  if (width < orderSavedWorkspaceDetailsCompactBreakpoint) {
    return OrderSavedWorkspaceDetailsSurfaceKind.bottomSheet;
  }

  if (width < orderSavedWorkspaceDetailsMediumBreakpoint) {
    return OrderSavedWorkspaceDetailsSurfaceKind.sideSheet;
  }

  return OrderSavedWorkspaceDetailsSurfaceKind.dialog;
}

class OrderSavedWorkspaceDetailsSurfacePresentation {
  static const double sheetHeightFactor = 0.86;
  static const double dialogContentMaxWidth = 460;
  static const double sheetHandleWidth = 42;
  static const double sheetHandleHeight = 4;
  static const double sideSheetMinWidth = 440;
  static const double sideSheetMaxWidth = 560;
  static const double sideSheetWidthFactor = 0.48;

  final Size viewportSize;
  final EdgeInsets viewInsets;

  const OrderSavedWorkspaceDetailsSurfacePresentation({
    required this.viewportSize,
    this.viewInsets = EdgeInsets.zero,
  });

  factory OrderSavedWorkspaceDetailsSurfacePresentation.fromMediaQuery(
    MediaQueryData mediaQuery,
  ) {
    return OrderSavedWorkspaceDetailsSurfacePresentation(
      viewportSize: mediaQuery.size,
      viewInsets: mediaQuery.viewInsets,
    );
  }

  OrderSavedWorkspaceDetailsSurfaceKind get kind {
    return orderSavedWorkspaceDetailsSurfaceForWidth(viewportSize.width);
  }

  EdgeInsets get keyboardPadding {
    return EdgeInsets.only(bottom: viewInsets.bottom);
  }

  EdgeInsets get sheetPadding {
    return const EdgeInsets.fromLTRB(
      POSUiTokens.gapLarge,
      POSUiTokens.gap,
      POSUiTokens.gapLarge,
      POSUiTokens.gapLarge,
    );
  }

  double get sheetHeight => viewportSize.height * sheetHeightFactor;

  double get sheetContentMaxWidth => double.infinity;

  EdgeInsets get sideSheetPadding {
    return const EdgeInsets.all(POSUiTokens.gapLarge);
  }

  double get sideSheetWidth {
    return (viewportSize.width * sideSheetWidthFactor)
        .clamp(sideSheetMinWidth, sideSheetMaxWidth)
        .toDouble();
  }

  double get sideSheetContentMaxWidth => double.infinity;
}
