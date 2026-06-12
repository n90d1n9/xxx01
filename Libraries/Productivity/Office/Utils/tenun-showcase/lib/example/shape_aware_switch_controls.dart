import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide Align, FontWeight;

class ShapeSwitchOptionsPreview extends StatelessWidget {
  final List<ChartSwitchOption> options;
  final int maxOptions;

  const ShapeSwitchOptionsPreview({
    super.key,
    required this.options,
    this.maxOptions = 4,
  });

  @override
  Widget build(BuildContext context) {
    final visibleOptions = options.take(maxOptions).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: visibleOptions.map((option) {
        final color = option.isCurrentType
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest;
        return Tooltip(
          message: option.reason,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 210),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#${option.rank} ${option.typeString}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 3),
                ShapeSwitchCapabilityChips(
                  capabilities: option.capabilities,
                  compact: true,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ShapeSwitchCapabilityChips extends StatelessWidget {
  final ChartCapabilities capabilities;
  final String? labelPrefix;
  final bool compact;

  const ShapeSwitchCapabilityChips({
    super.key,
    required this.capabilities,
    this.labelPrefix,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (labelPrefix != null) '$labelPrefix: ${capabilities.dataShape.name}',
      if (capabilities.supportsSampling) 'sample',
      if (capabilities.supportsZoom) 'zoom',
      if (capabilities.supportsDrilldown) 'drill',
      if (capabilities.supportsLegend) 'legend',
      if (capabilities.supportsTooltip) 'tip',
    ];
    if (labels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: labels
          .map(
            (label) => Chip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              labelPadding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
              label: Text(label, style: TextStyle(fontSize: compact ? 10 : 11)),
            ),
          )
          .toList(),
    );
  }
}

class ShapeSwitchCompatibilityBanner extends StatelessWidget {
  final ChartSwitchCompatibility compatibility;
  final bool forceCrossShape;

  const ShapeSwitchCompatibilityBanner({
    super.key,
    required this.compatibility,
    required this.forceCrossShape,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color background;
    final IconData icon;
    final String label;
    if (compatibility.isCompatible) {
      background = colors.secondaryContainer.withValues(alpha: 0.55);
      icon = Icons.check_circle_outline;
      label = 'Manual switch: compatible';
    } else if (compatibility.forceConversionAvailable) {
      background = colors.tertiaryContainer.withValues(alpha: 0.65);
      icon = Icons.warning_amber_outlined;
      label = forceCrossShape
          ? 'Manual switch: force conversion enabled'
          : 'Manual switch: force conversion required';
    } else {
      background = colors.errorContainer.withValues(alpha: 0.55);
      icon = Icons.block;
      label = 'Manual switch: not safe';
    }

    return _ShapeSwitchStatusBanner(
      background: background,
      icon: icon,
      message: '$label. ${compatibility.reason}',
    );
  }
}

class ShapeSwitchRenderSafetyBanner extends StatelessWidget {
  final ValidationResult? validation;
  final bool isRenderSafe;
  final String source;
  final String message;

  const ShapeSwitchRenderSafetyBanner({
    super.key,
    required this.validation,
    required this.isRenderSafe,
    required this.source,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasErrors = validation?.errors.isNotEmpty ?? false;
    final hasWarnings = validation?.warnings.isNotEmpty ?? false;
    final Color background;
    final IconData icon;
    final String label;

    if (isRenderSafe && hasWarnings) {
      background = colors.tertiaryContainer.withValues(alpha: 0.65);
      icon = Icons.report_problem_outlined;
      label = 'Payload validation: render-safe with warnings';
    } else if (isRenderSafe) {
      background = colors.secondaryContainer.withValues(alpha: 0.55);
      icon = Icons.verified_outlined;
      label = 'Payload validation: render-safe';
    } else if (hasErrors) {
      background = colors.errorContainer.withValues(alpha: 0.55);
      icon = Icons.error_outline;
      label = 'Payload validation: blocked';
    } else {
      background = colors.surfaceContainerHighest;
      icon = Icons.help_outline;
      label = 'Payload validation: not available';
    }

    final issueSummary = validation == null
        ? 'No validation report.'
        : '${validation!.errors.length} error(s), '
              '${validation!.warnings.length} warning(s).';
    final firstIssue = validation == null || validation!.issues.isEmpty
        ? null
        : validation!.issues.first;
    final firstIssueText = firstIssue == null ? '' : ' ${firstIssue.message}';

    return _ShapeSwitchStatusBanner(
      background: background,
      icon: icon,
      message: '$label ($source). $issueSummary $message$firstIssueText',
    );
  }
}

class _ShapeSwitchStatusBanner extends StatelessWidget {
  final Color background;
  final IconData icon;
  final String message;

  const _ShapeSwitchStatusBanner({
    required this.background,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
