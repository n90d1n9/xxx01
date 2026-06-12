import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/product_editor_form_layout.dart';

/// Slot-based responsive layout shell for product editor workspaces.
class ProductEditorWorkspaceLayout extends StatelessWidget {
  const ProductEditorWorkspaceLayout({
    super.key,
    required this.layout,
    required this.header,
    required this.primaryContent,
    required this.sideRail,
    required this.compactGuidance,
    required this.compactSaveAction,
    this.sectionSpacing = 16,
    this.compactSaveActionSpacing = 32,
  });

  final ProductEditorFormLayout layout;
  final Widget header;
  final Widget primaryContent;
  final Widget sideRail;
  final Widget compactGuidance;
  final Widget compactSaveAction;
  final double sectionSpacing;
  final double compactSaveActionSpacing;

  @override
  Widget build(BuildContext context) {
    if (layout.isSplit) return _buildSplitLayout();

    return _buildStackedLayout();
  }

  Widget _buildStackedLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        SizedBox(height: sectionSpacing),
        compactGuidance,
        SizedBox(height: sectionSpacing),
        primaryContent,
        SizedBox(height: compactSaveActionSpacing),
        compactSaveAction,
      ],
    );
  }

  Widget _buildSplitLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        SizedBox(height: sectionSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: primaryContent),
            SizedBox(width: layout.gap),
            SizedBox(width: layout.sideRailWidth, child: sideRail),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Product editor workspace layout')
Widget productEditorWorkspaceLayoutPreview() {
  final layout = ProductEditorFormLayout.forWidth(1280);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductEditorWorkspaceLayout(
          layout: layout,
          header: const _PreviewPanel(label: 'Workspace header', height: 92),
          primaryContent: const _PreviewPanel(
            label: 'Editable product fields',
            height: 420,
          ),
          sideRail: const _PreviewPanel(label: 'Guidance rail', height: 360),
          compactGuidance: const _PreviewPanel(
            label: 'Compact guidance',
            height: 160,
          ),
          compactSaveAction: const _PreviewPanel(
            label: 'Compact save action',
            height: 120,
          ),
        ),
      ),
    ),
  );
}

/// Preview-only surface used to show product editor layout slots.
class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
