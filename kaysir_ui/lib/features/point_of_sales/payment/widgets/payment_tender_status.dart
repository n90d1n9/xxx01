import 'package:flutter/material.dart';

import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../utils/payment_tendering.dart';

class PaymentTenderStatus extends StatelessWidget {
  final PaymentTenderEvaluation evaluation;

  const PaymentTenderStatus({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _TenderStatusVisual.resolve(theme, evaluation);

    return POSSurface(
      color: status.backgroundColor,
      border: Border.all(color: status.borderColor),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          POSIconBadge(
            icon: status.icon,
            size: 32,
            iconSize: 18,
            backgroundColor: status.iconBackgroundColor,
            foregroundColor: status.foregroundColor,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: status.foregroundColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (status.message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    status.message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: status.foregroundColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (status.amount != null)
            Text(
              formatPOSCurrency(status.amount!),
              style: theme.textTheme.titleMedium?.copyWith(
                color: status.foregroundColor,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class _TenderStatusVisual {
  final IconData icon;
  final String title;
  final String? message;
  final double? amount;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;

  const _TenderStatusVisual({
    required this.icon,
    required this.title,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    this.message,
    this.amount,
  });

  static _TenderStatusVisual resolve(
    ThemeData theme,
    PaymentTenderEvaluation evaluation,
  ) {
    if (!evaluation.isValid) {
      return _TenderStatusVisual(
        icon: Icons.error_outline,
        title: evaluation.message ?? 'Payment needs attention',
        foregroundColor: theme.colorScheme.error,
        backgroundColor: theme.colorScheme.errorContainer.withValues(
          alpha: 0.26,
        ),
        borderColor: theme.colorScheme.error.withValues(alpha: 0.24),
        iconBackgroundColor: theme.colorScheme.errorContainer,
      );
    }

    if (evaluation.changeDue > 0) {
      return _TenderStatusVisual(
        icon: Icons.payments_outlined,
        title: 'Change due',
        message: 'Return this amount after recording the cash tender.',
        amount: evaluation.changeDue,
        foregroundColor: theme.colorScheme.tertiary,
        backgroundColor: theme.colorScheme.tertiaryContainer.withValues(
          alpha: 0.30,
        ),
        borderColor: theme.colorScheme.tertiary.withValues(alpha: 0.20),
        iconBackgroundColor: theme.colorScheme.tertiaryContainer,
      );
    }

    if (evaluation.shortfall > 0) {
      return _TenderStatusVisual(
        icon: Icons.timelapse_outlined,
        title: 'Remaining after payment',
        message: 'The order can continue with another payment.',
        amount: evaluation.shortfall,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        backgroundColor: theme.colorScheme.secondaryContainer.withValues(
          alpha: 0.32,
        ),
        borderColor: theme.colorScheme.secondary.withValues(alpha: 0.20),
        iconBackgroundColor: theme.colorScheme.secondaryContainer,
      );
    }

    return _TenderStatusVisual(
      icon: Icons.check_circle_outline,
      title: 'Exact payment',
      message: 'This payment will clear the remaining balance.',
      foregroundColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.30,
      ),
      borderColor: theme.colorScheme.primary.withValues(alpha: 0.22),
      iconBackgroundColor: theme.colorScheme.primaryContainer,
    );
  }
}
