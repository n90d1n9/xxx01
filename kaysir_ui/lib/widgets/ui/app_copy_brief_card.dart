import 'package:flutter/material.dart';

import 'app_action_button.dart';
import 'app_status_pill.dart';
import 'app_surface.dart';

class AppCopyBriefCard extends StatelessWidget {
  const AppCopyBriefCard({
    required this.title,
    required this.text,
    required this.onCopy,
    this.icon = Icons.edit_note_outlined,
    this.copied = false,
    super.key,
  });

  final String title;
  final String text;
  final VoidCallback? onCopy;
  final IconData icon;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      backgroundColor: colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppStatusPill(
                    label: 'Copy ready',
                    icon: Icons.format_quote_rounded,
                    color: colorScheme.primary,
                    maxWidth: 122,
                  ),
                  AppActionButton(
                    label: copied ? 'Copied' : 'Copy',
                    icon:
                        copied
                            ? Icons.check_circle_outline
                            : Icons.copy_all_outlined,
                    compact: true,
                    variant: AppActionButtonVariant.secondary,
                    onPressed: onCopy,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
