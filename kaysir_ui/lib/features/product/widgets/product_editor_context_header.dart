import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../../../widgets/ui/app_surface.dart';
import '../models/management_pack.dart';
import '../models/product_editor_header_view_state.dart';
import '../models/product_form_save_action.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';

/// Compact workspace header for product editor mode, pack, and readiness.
class ProductEditorContextHeader extends StatelessWidget {
  const ProductEditorContextHeader({super.key, required this.viewState});

  final ProductEditorHeaderViewState viewState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readinessColor =
        viewState.isReady ? Colors.teal.shade700 : colorScheme.error;

    return AppSurface(
      elevated: true,
      backgroundColor: Color.alphaBlend(
        colorScheme.primary.withValues(alpha: 0.04),
        colorScheme.surface,
      ),
      borderColor: colorScheme.primary.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final titleBlock = _ProductEditorHeaderTitleBlock(
            viewState: viewState,
          );
          final statusStrip = _ProductEditorHeaderStatusStrip(
            viewState: viewState,
            readinessColor: readinessColor,
            alignment: compact ? WrapAlignment.start : WrapAlignment.end,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(height: 12),
                    statusStrip,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 16),
                    Flexible(child: statusStrip),
                  ],
                ),
              const SizedBox(height: 12),
              _ProductEditorHeaderMetricStrip(viewState: viewState),
            ],
          );
        },
      ),
    );
  }
}

@Preview(name: 'Product editor context header')
Widget productEditorContextHeaderPreview() {
  final overview = buildProductFormSectionOverview(
    pack: groceryFreshGoodsProductManagementPack,
    isEditing: false,
  );
  final progress = buildProductFormSectionProgressOverview(
    overview: overview,
    values: const {
      'name': 'Spinach',
      'sku': 'SP-001',
      'category': 'Fresh produce',
      'description': 'Leafy greens',
    },
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductEditorContextHeader(
          viewState: ProductEditorHeaderViewState.from(
            pack: groceryFreshGoodsProductManagementPack,
            saveSummary: buildProductFormSaveActionSummary(
              progress: progress,
              submitLabel: 'Add product',
              isEditing: false,
            ),
            isEditing: false,
          ),
        ),
      ),
    ),
  );
}

/// Title area for the product editor context header.
class _ProductEditorHeaderTitleBlock extends StatelessWidget {
  const _ProductEditorHeaderTitleBlock({required this.viewState});

  final ProductEditorHeaderViewState viewState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            viewState.isEditing
                ? Icons.edit_note_rounded
                : Icons.add_business_rounded,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewState.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                viewState.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Status chip strip for product editor mode, business model, and readiness.
class _ProductEditorHeaderStatusStrip extends StatelessWidget {
  const _ProductEditorHeaderStatusStrip({
    required this.viewState,
    required this.readinessColor,
    required this.alignment,
  });

  final ProductEditorHeaderViewState viewState;
  final Color readinessColor;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: alignment,
      runAlignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: viewState.modeLabel,
          color: colorScheme.primary,
          icon:
              viewState.isEditing
                  ? Icons.edit_rounded
                  : Icons.add_circle_outline_rounded,
          maxWidth: 132,
        ),
        AppStatusPill(
          label: viewState.businessModelLabel,
          color: colorScheme.secondary,
          icon: Icons.storefront_rounded,
          maxWidth: 190,
        ),
        AppStatusPill(
          label: viewState.readinessLabel,
          color: readinessColor,
          icon:
              viewState.isReady
                  ? Icons.task_alt_rounded
                  : Icons.pending_actions_rounded,
          maxWidth: 142,
        ),
        AppStatusPill(
          label: viewState.requiredReadinessLabel,
          color: colorScheme.tertiary,
          icon: Icons.rule_rounded,
          maxWidth: 168,
        ),
      ],
    );
  }
}

/// Dense metadata strip for the active product management pack.
class _ProductEditorHeaderMetricStrip extends StatelessWidget {
  const _ProductEditorHeaderMetricStrip({required this.viewState});

  final ProductEditorHeaderViewState viewState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _ProductEditorHeaderMetric(
          icon: Icons.extension_rounded,
          label: viewState.packLabel,
        ),
        _ProductEditorHeaderMetric(
          icon: Icons.account_tree_rounded,
          label: viewState.capabilityCountLabel,
        ),
        _ProductEditorHeaderMetric(
          icon: Icons.fact_check_rounded,
          label: viewState.packRequiredFieldCountLabel,
        ),
      ],
    );
  }
}

/// One compact icon and text metric inside the product editor header.
class _ProductEditorHeaderMetric extends StatelessWidget {
  const _ProductEditorHeaderMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
