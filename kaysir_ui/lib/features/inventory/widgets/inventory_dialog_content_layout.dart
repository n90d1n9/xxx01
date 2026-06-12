import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'inventory_dialog_surface.dart';

/// Reusable inventory dialog shell for flows whose body owns its own form
/// fields, validation, and actions.
class InventoryDialogContentLayout extends StatelessWidget {
  const InventoryDialogContentLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
    this.subtitle,
    this.onClose,
    this.closeTooltip = 'Close dialog',
    this.maxWidth = 640,
    this.maxHeight,
    this.padding = const EdgeInsets.all(20),
    this.scrollable = true,
    this.showCloseButton = true,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 2,
    this.bodySpacing = 18,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onClose;
  final String closeTooltip;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool showCloseButton;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final double bodySpacing;

  @override
  Widget build(BuildContext context) {
    return InventoryDialogSurface(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      padding: padding,
      scrollable: scrollable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InventoryDialogHeader(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            closeTooltip: closeTooltip,
            showCloseButton: showCloseButton,
            titleMaxLines: titleMaxLines,
            subtitleMaxLines: subtitleMaxLines,
            onClose: onClose,
          ),
          SizedBox(height: bodySpacing),
          child,
        ],
      ),
    );
  }
}

@Preview(name: 'Inventory dialog content layout')
Widget inventoryDialogContentLayoutPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryDialogContentLayout(
          eyebrow: 'Warehouse Transfer',
          title: 'Transfer Laptop',
          subtitle: 'LT-001 | From Main Warehouse - Jakarta',
          closeTooltip: 'Close stock transfer',
          onClose: () {},
          child: const Text('Transfer form body'),
        ),
      ),
    ),
  );
}
