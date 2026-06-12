import 'package:flutter/material.dart';

import '../../cashier/widgets/pos_ui.dart';

class PromotionCodeEntry extends StatelessWidget {
  final TextEditingController controller;
  final String? message;
  final bool isError;
  final VoidCallback onApplyCode;
  final ValueChanged<String>? onChanged;

  const PromotionCodeEntry({
    super.key,
    required this.controller,
    required this.onApplyCode,
    this.message,
    this.isError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
      border: Border.all(color: theme.dividerColor),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: onChanged,
                  onSubmitted: (_) => onApplyCode(),
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(POSUiTokens.radius),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(POSUiTokens.radius),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: POSUiTokens.gap),
              POSActionButton(
                icon: const Icon(Icons.arrow_forward),
                label: 'Apply',
                variant: POSActionButtonVariant.tonal,
                onPressed: onApplyCode,
              ),
            ],
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: POSUiTokens.gap),
            Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isError
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
