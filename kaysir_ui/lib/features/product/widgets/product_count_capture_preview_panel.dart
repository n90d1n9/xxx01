import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../utils/product_count_capture_view.dart';

class ProductCountCapturePreviewPanel extends StatelessWidget {
  const ProductCountCapturePreviewPanel({super.key, required this.preview});

  final ProductCountCaptureDraftPreview preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _previewColor(context, preview.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.38,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final header = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(_previewIcon(preview.status), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Count preview',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _previewMessage(preview),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final facts = _PreviewFacts(preview: preview, color: color);

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [header, const SizedBox(height: 12), facts],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: header),
                const SizedBox(width: 12),
                facts,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PreviewFacts extends StatelessWidget {
  const _PreviewFacts({required this.preview, required this.color});

  final ProductCountCaptureDraftPreview preview;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        AppStatusPill(label: preview.statusLabel, color: color),
        AppStatusPill(
          label: 'System ${preview.systemStockLabel}',
          color: colorScheme.primary,
        ),
        AppStatusPill(
          label: 'Actual ${preview.actualStockLabel}',
          color: colorScheme.secondary,
        ),
        AppStatusPill(label: 'Diff ${preview.varianceLabel}', color: color),
      ],
    );
  }
}

String _previewMessage(ProductCountCaptureDraftPreview preview) {
  switch (preview.status) {
    case ProductCountCapturePreviewStatus.missingTarget:
      return 'Choose a product to preview stock variance.';
    case ProductCountCapturePreviewStatus.missingQuantity:
      return 'Enter the physical quantity to preview the variance.';
    case ProductCountCapturePreviewStatus.matched:
      return 'Physical stock matches the system stock.';
    case ProductCountCapturePreviewStatus.variance:
      return 'Physical stock differs from the system stock.';
  }
}

Color _previewColor(
  BuildContext context,
  ProductCountCapturePreviewStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case ProductCountCapturePreviewStatus.missingTarget:
      return colorScheme.outline;
    case ProductCountCapturePreviewStatus.missingQuantity:
      return Colors.orange;
    case ProductCountCapturePreviewStatus.matched:
      return Colors.green;
    case ProductCountCapturePreviewStatus.variance:
      return colorScheme.error;
  }
}

IconData _previewIcon(ProductCountCapturePreviewStatus status) {
  switch (status) {
    case ProductCountCapturePreviewStatus.missingTarget:
      return Icons.inventory_2_outlined;
    case ProductCountCapturePreviewStatus.missingQuantity:
      return Icons.edit_note_rounded;
    case ProductCountCapturePreviewStatus.matched:
      return Icons.check_circle_rounded;
    case ProductCountCapturePreviewStatus.variance:
      return Icons.rule_rounded;
  }
}
