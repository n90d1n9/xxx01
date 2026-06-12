import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/management_pack.dart';
import '../models/management_pack_field_group.dart';
import '../models/management_pack_field_group_progress.dart';
import '../models/product_editor_section_navigator_view_state.dart';
import '../models/product_form_section.dart';
import '../models/product_form_section_progress.dart';

/// Readiness navigator for product editor sections and pack capabilities.
class ProductEditorSectionNavigator extends StatelessWidget {
  const ProductEditorSectionNavigator({
    super.key,
    required this.viewState,
    this.onSelectItem,
  });

  final ProductEditorSectionNavigatorViewState viewState;
  final ValueChanged<ProductEditorSectionNavigatorItem>? onSelectItem;

  @override
  Widget build(BuildContext context) {
    if (!viewState.hasItems) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final statusColor =
        viewState.isReady ? Colors.teal.shade700 : colorScheme.error;

    return AppContentPanel(
      title: 'Editor sections',
      subtitle: 'Product readiness by section and capability',
      leadingIcon: Icons.route_rounded,
      trailing: AppStatusPill(
        label: viewState.statusLabel,
        color: statusColor,
        icon:
            viewState.isReady
                ? Icons.task_alt_rounded
                : Icons.pending_actions_rounded,
        maxWidth: 180,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in viewState.items) ...[
            _ProductEditorSectionNavigatorRow(
              item: item,
              onSelect:
                  item.canLaunch && onSelectItem != null
                      ? () => onSelectItem!(item)
                      : null,
            ),
            if (item != viewState.items.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Product editor section navigator')
Widget productEditorSectionNavigatorPreview() {
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
      'barcode': '8990001',
      'expiry_date': '2026-07-01',
    },
  );
  final groupProgress = buildProductManagementPackFieldGroupProgressOverview(
    groups: buildProductManagementPackFieldGroups(
      groceryFreshGoodsProductManagementPack,
    ),
    values: const {'barcode': '8990001', 'expiry_date': '2026-07-01'},
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductEditorSectionNavigator(
          viewState: ProductEditorSectionNavigatorViewState.from(
            progress: progress,
            groupProgress: groupProgress,
          ),
          onSelectItem: (_) {},
        ),
      ),
    ),
  );
}

/// One section navigator row with progress and review affordance.
class _ProductEditorSectionNavigatorRow extends StatelessWidget {
  const _ProductEditorSectionNavigatorRow({
    required this.item,
    required this.onSelect,
  });

  final ProductEditorSectionNavigatorItem item;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final titleBlock = _ProductEditorSectionNavigatorTitle(
                item: item,
                color: color,
              );
              final actions = _ProductEditorSectionNavigatorActions(
                item: item,
                color: color,
                onSelect: onSelect,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleBlock, const SizedBox(height: 8), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (item.isReady) return Colors.teal.shade700;
    if (item.needsRequiredData) return colorScheme.error;

    return colorScheme.tertiary;
  }
}

/// Title, subtitle, and progress label for one navigator row.
class _ProductEditorSectionNavigatorTitle extends StatelessWidget {
  const _ProductEditorSectionNavigatorTitle({
    required this.item,
    required this.color,
  });

  final ProductEditorSectionNavigatorItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.progressLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData get _icon {
    return switch (item.kind) {
      ProductEditorSectionNavigatorItemKind.formSection =>
        Icons.view_agenda_rounded,
      ProductEditorSectionNavigatorItemKind.packGroup =>
        Icons.extension_rounded,
    };
  }
}

/// Status and review action controls for one navigator row.
class _ProductEditorSectionNavigatorActions extends StatelessWidget {
  const _ProductEditorSectionNavigatorActions({
    required this.item,
    required this.color,
    required this.onSelect,
  });

  final ProductEditorSectionNavigatorItem item;
  final Color color;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        AppStatusPill(
          label: item.statusLabel,
          color: color,
          icon: item.isReady ? Icons.task_alt_rounded : Icons.rule_rounded,
          maxWidth: 148,
        ),
        if (onSelect != null)
          TextButton.icon(
            onPressed: onSelect,
            icon: Icon(
              item.canReview
                  ? Icons.center_focus_strong_rounded
                  : Icons.open_in_new_rounded,
            ),
            label: Text(item.actionLabel),
          ),
      ],
    );
  }
}
