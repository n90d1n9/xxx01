import 'package:flutter/material.dart';

import '../experiences/pos_experience_manifest.dart';
import '../experiences/pos_mode_switch_availability.dart';
import '../experiences/pos_mode_switch_controller.dart';
import '../experiences/pos_mode_switch_impact.dart';
import '../experiences/pos_mode_switch_order_guard.dart';
import '../experiences/pos_mode_switch_policy.dart';
import '../experiences/pos_mode_switch_preview.dart';
import '../states/pos_layout_provider.dart';
import 'pos_mode_switch_impact_summary.dart';
import 'pos_mode_switch_preview_summary.dart';
import 'pos_switch_section_header.dart';
import 'pos_ui.dart';

class POSModeSwitchSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final BoxConstraints constraints;

  const POSModeSwitchSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.constraints = const BoxConstraints(minWidth: 320),
  });

  @override
  Widget build(BuildContext context) {
    return POSSwitchSectionHeader(
      title: title,
      countLabel: '$count mode${count == 1 ? '' : 's'}',
      constraints: constraints,
    );
  }
}

class POSModeSwitchOptionTile extends StatelessWidget {
  final POSModeSwitchOption option;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final bool showSelectedIndicator;
  final POSModeSwitchAvailability? availability;
  final POSModeSwitchImpact? impact;
  final POSModeSwitchOrderDecision? orderDecision;
  final POSModeSwitchPreview? preview;

  const POSModeSwitchOptionTile({
    super.key,
    required this.option,
    this.constraints = const BoxConstraints(minWidth: 320, maxWidth: 360),
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.showSelectedIndicator = false,
    this.availability,
    this.impact,
    this.orderDecision,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final experience = option.experience;
    final manifest = experience.manifest;
    final resolvedOrderDecision = availability?.orderDecision ?? orderDecision;
    final resolvedPreview = preview;

    return ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    experience.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: POSUiTokens.gap),
                POSReleaseStageChip(stage: manifest.releaseStage),
                if (showSelectedIndicator && option.selected) ...[
                  const SizedBox(width: POSUiTokens.gap),
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              manifest.archetypeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                POSModeMetaChip(
                  icon: Icons.view_quilt_outlined,
                  label: experience.preferredLayout.label,
                ),
                POSModeMetaChip(
                  icon: Icons.devices_outlined,
                  label: _formFactorSummary(manifest.supportedFormFactors),
                ),
                if (resolvedPreview == null)
                  POSModeSwitchDecisionChip(decision: option.decision),
                if (resolvedPreview == null &&
                    (resolvedOrderDecision?.hasActiveOrder ?? false))
                  POSModeSwitchOrderDecisionChip(
                    decision: resolvedOrderDecision!,
                  ),
              ],
            ),
            if (resolvedPreview != null) ...[
              const SizedBox(height: 5),
              POSModeSwitchPreviewSummary(preview: resolvedPreview),
            ] else if (impact != null && impact!.hasChanges) ...[
              const SizedBox(height: 5),
              POSModeSwitchImpactSummary(impact: impact!),
            ],
          ],
        ),
      ),
    );
  }

  String _formFactorSummary(List<POSExperienceFormFactor> formFactors) {
    if (formFactors.isEmpty) return 'No screens';
    if (formFactors.length == 1) return formFactors.first.label;

    return formFactors.map((formFactor) => formFactor.label).join(', ');
  }
}

class POSModeSwitchDecisionChip extends StatelessWidget {
  final POSModeSwitchDecision decision;

  const POSModeSwitchDecisionChip({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background =
        decision.isBlocked
            ? colorScheme.errorContainer
            : decision.needsConfirmation
            ? colorScheme.tertiaryContainer
            : colorScheme.secondaryContainer;
    final foreground =
        decision.isBlocked
            ? colorScheme.onErrorContainer
            : decision.needsConfirmation
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSecondaryContainer;
    final border =
        decision.isBlocked
            ? colorScheme.error.withValues(alpha: 0.22)
            : decision.needsConfirmation
            ? colorScheme.tertiary.withValues(alpha: 0.24)
            : colorScheme.secondary.withValues(alpha: 0.22);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 13, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              decision.statusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    if (decision.isBlocked) return Icons.block;
    if (decision.needsConfirmation) return Icons.info_outline;
    return Icons.check_circle_outline;
  }
}

class POSModeSwitchOrderDecisionChip extends StatelessWidget {
  final POSModeSwitchOrderDecision decision;

  const POSModeSwitchOrderDecisionChip({super.key, required this.decision});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background =
        decision.isBlocked
            ? colorScheme.errorContainer
            : decision.needsConfirmation
            ? colorScheme.tertiaryContainer
            : colorScheme.secondaryContainer;
    final foreground =
        decision.isBlocked
            ? colorScheme.onErrorContainer
            : decision.needsConfirmation
            ? colorScheme.onTertiaryContainer
            : colorScheme.onSecondaryContainer;
    final border =
        decision.isBlocked
            ? colorScheme.error.withValues(alpha: 0.22)
            : decision.needsConfirmation
            ? colorScheme.tertiary.withValues(alpha: 0.24)
            : colorScheme.secondary.withValues(alpha: 0.22);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 13, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              decision.statusLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    if (decision.isBlocked) return Icons.lock_outline;
    if (decision.needsConfirmation) return Icons.receipt_long_outlined;
    return Icons.check_circle_outline;
  }
}

class POSReleaseStageChip extends StatelessWidget {
  final POSExperienceReleaseStage stage;

  const POSReleaseStageChip({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(theme.colorScheme);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        stage.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  _StageColors _colors(ColorScheme colorScheme) {
    switch (stage) {
      case POSExperienceReleaseStage.stable:
        return _StageColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
          border: colorScheme.secondary.withValues(alpha: 0.22),
        );
      case POSExperienceReleaseStage.preview:
        return _StageColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withValues(alpha: 0.24),
        );
      case POSExperienceReleaseStage.experimental:
        return _StageColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withValues(alpha: 0.22),
        );
    }
  }
}

class POSModeMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const POSModeMetaChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _StageColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
