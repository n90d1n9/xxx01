import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/product_workspace_setup_action.dart';
import 'workspace_preview_fixtures.dart';

/// Inline setup prompt shown when a product workspace route needs preparation.
class ProductWorkspaceSetupNotice extends StatelessWidget {
  const ProductWorkspaceSetupNotice({
    super.key,
    required this.prompt,
    required this.onActionPressed,
  });

  final ProductWorkspaceSetupPrompt prompt;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.construction_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppStatusPill(
                            label: prompt.statusLabel,
                            color:
                                prompt.isInactive
                                    ? colorScheme.error
                                    : colorScheme.primary,
                            maxWidth: 112,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prompt.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.82,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final action = AppActionButton(
              label: prompt.actionLabel,
              icon: Icons.arrow_forward_rounded,
              variant: AppActionButtonVariant.secondary,
              compact: true,
              onPressed: onActionPressed,
            );

            if (constraints.maxWidth < 680) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: action),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                const SizedBox(width: 12),
                action,
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Product workspace setup notice')
Widget workspaceSetupNoticePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ProductWorkspaceSetupNotice(
          prompt: previewProductWorkspaceSetupPrompt,
          onActionPressed: () {},
        ),
      ),
    ),
  );
}
