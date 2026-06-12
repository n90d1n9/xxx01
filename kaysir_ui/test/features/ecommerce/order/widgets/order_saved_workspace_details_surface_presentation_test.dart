import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_surface.dart';

void main() {
  test('details surface presentation computes compact sheet layout', () {
    const presentation = OrderSavedWorkspaceDetailsSurfacePresentation(
      viewportSize: Size(480, 800),
      viewInsets: EdgeInsets.only(bottom: 24),
    );

    expect(
      presentation.kind,
      OrderSavedWorkspaceDetailsSurfaceKind.bottomSheet,
    );
    expect(presentation.keyboardPadding, const EdgeInsets.only(bottom: 24));
    expect(
      presentation.sheetHeight,
      800 * OrderSavedWorkspaceDetailsSurfacePresentation.sheetHeightFactor,
    );
    expect(presentation.sheetContentMaxWidth, double.infinity);
    expect(OrderSavedWorkspaceDetailsSurfacePresentation.sheetHandleWidth, 42);
    expect(OrderSavedWorkspaceDetailsSurfacePresentation.sheetHandleHeight, 4);
  });

  test('details surface presentation computes medium side sheet layout', () {
    const presentation = OrderSavedWorkspaceDetailsSurfacePresentation(
      viewportSize: Size(900, 768),
    );

    expect(presentation.kind, OrderSavedWorkspaceDetailsSurfaceKind.sideSheet);
    expect(
      presentation.sideSheetWidth,
      OrderSavedWorkspaceDetailsSurfacePresentation.sideSheetMinWidth,
    );
    expect(presentation.sideSheetContentMaxWidth, double.infinity);
  });

  test('details surface presentation keeps wide layouts on dialog surface', () {
    const presentation = OrderSavedWorkspaceDetailsSurfacePresentation(
      viewportSize: Size(1280, 768),
    );

    expect(presentation.kind, OrderSavedWorkspaceDetailsSurfaceKind.dialog);
    expect(presentation.keyboardPadding, EdgeInsets.zero);
    expect(
      OrderSavedWorkspaceDetailsSurfacePresentation.dialogContentMaxWidth,
      460,
    );
  });

  test('details surface presentation can be created from media query data', () {
    final presentation =
        OrderSavedWorkspaceDetailsSurfacePresentation.fromMediaQuery(
          const MediaQueryData(
            size: Size(600, 900),
            viewInsets: EdgeInsets.only(bottom: 12),
          ),
        );

    expect(presentation.viewportSize, const Size(600, 900));
    expect(presentation.viewInsets, const EdgeInsets.only(bottom: 12));
    expect(
      presentation.kind,
      OrderSavedWorkspaceDetailsSurfaceKind.bottomSheet,
    );
  });
}
