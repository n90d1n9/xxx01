import 'package:flutter/material.dart';

import '../experiences/pos_switch_action_result.dart';
import '../experiences/pos_switch_action_text.dart';
import 'pos_switch_preview_pill.dart';

class POSSwitchActionPresentation {
  final String feedbackMessage;
  final String historyMessage;
  final String supportSummary;
  final String? operatorGuidance;
  final IconData kindIcon;
  final IconData outcomeIcon;
  final POSSwitchPreviewTone outcomeTone;
  final bool showCloseIcon;

  const POSSwitchActionPresentation({
    required this.feedbackMessage,
    required this.historyMessage,
    required this.supportSummary,
    required this.kindIcon,
    required this.outcomeIcon,
    required this.outcomeTone,
    required this.showCloseIcon,
    this.operatorGuidance,
  });

  factory POSSwitchActionPresentation.fromResult(POSSwitchActionResult result) {
    final text = POSSwitchActionText.fromResult(result);

    return POSSwitchActionPresentation(
      feedbackMessage: text.feedbackMessage,
      historyMessage: text.historyMessage,
      supportSummary: text.supportSummary,
      operatorGuidance: text.operatorGuidance,
      kindIcon: kindIconFor(result.kind),
      outcomeIcon: outcomeIconFor(result.outcome),
      outcomeTone: outcomeToneFor(result.outcome),
      showCloseIcon: result.outcome != POSSwitchActionOutcome.applied,
    );
  }

  POSSwitchActionPalette badgePalette(ColorScheme colorScheme) {
    switch (outcomeTone) {
      case POSSwitchPreviewTone.positive:
        return POSSwitchActionPalette(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
        );
      case POSSwitchPreviewTone.warning:
        return POSSwitchActionPalette(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
        );
      case POSSwitchPreviewTone.danger:
        return POSSwitchActionPalette(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
        );
      case POSSwitchPreviewTone.neutral:
        return POSSwitchActionPalette(
          background: colorScheme.surfaceContainerHighest,
          foreground: colorScheme.onSurfaceVariant,
        );
    }
  }

  POSSwitchActionPalette snackBarPalette(ColorScheme colorScheme) {
    switch (outcomeTone) {
      case POSSwitchPreviewTone.positive:
        return POSSwitchActionPalette(
          background: colorScheme.primary,
          foreground: colorScheme.onPrimary,
        );
      case POSSwitchPreviewTone.warning:
        return POSSwitchActionPalette(
          background: colorScheme.tertiary,
          foreground: colorScheme.onTertiary,
        );
      case POSSwitchPreviewTone.danger:
        return POSSwitchActionPalette(
          background: colorScheme.error,
          foreground: colorScheme.onError,
        );
      case POSSwitchPreviewTone.neutral:
        return POSSwitchActionPalette(
          background: colorScheme.inverseSurface,
          foreground: colorScheme.onInverseSurface,
        );
    }
  }

  static IconData kindIconFor(POSSwitchActionKind kind) {
    switch (kind) {
      case POSSwitchActionKind.mode:
        return Icons.dashboard_customize_outlined;
      case POSSwitchActionKind.runtimePack:
        return Icons.apps_outlined;
      case POSSwitchActionKind.commerceChannel:
        return Icons.storefront_outlined;
    }
  }

  static IconData outcomeIconFor(POSSwitchActionOutcome outcome) {
    switch (outcome) {
      case POSSwitchActionOutcome.applied:
        return Icons.check_circle_outline;
      case POSSwitchActionOutcome.blocked:
        return Icons.block_outlined;
      case POSSwitchActionOutcome.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static POSSwitchPreviewTone outcomeToneFor(POSSwitchActionOutcome outcome) {
    switch (outcome) {
      case POSSwitchActionOutcome.applied:
        return POSSwitchPreviewTone.positive;
      case POSSwitchActionOutcome.blocked:
        return POSSwitchPreviewTone.danger;
      case POSSwitchActionOutcome.cancelled:
        return POSSwitchPreviewTone.warning;
    }
  }
}

class POSSwitchActionPalette {
  final Color background;
  final Color foreground;

  const POSSwitchActionPalette({
    required this.background,
    required this.foreground,
  });
}
