import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'json_render_safety_telemetry.dart';
import 'showcase_source_panel.dart';

class JsonRenderSafetyObservationPanel extends StatelessWidget {
  const JsonRenderSafetyObservationPanel({
    super.key,
    required this.telemetrySnapshot,
    this.renderError,
    this.validationResult,
  });

  final JsonRenderSafetyTelemetrySnapshot telemetrySnapshot;
  final Object? renderError;
  final ValidationResult? validationResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validation = validationResult;
    final error = renderError;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sensors_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Observed callbacks',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ObservationChip(
                  label: error == null
                      ? 'render.none'
                      : 'render.${error.runtimeType}',
                ),
                _ObservationChip(
                  label: validation == null
                      ? 'validation.none'
                      : 'validation.${validation.isValid ? 'valid' : 'invalid'}',
                ),
                if (validation != null)
                  _ObservationChip(label: 'errors.${validation.errors.length}'),
                if (validation != null)
                  _ObservationChip(
                    label: 'warnings.${validation.warnings.length}',
                  ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                error.toString(),
                style: theme.textTheme.bodySmall,
              ),
            ] else if (validation != null && !validation.isValid) ...[
              const SizedBox(height: 8),
              Text(
                validation.errors.isEmpty
                    ? 'Validation blocked rendering.'
                    : validation.errors.first.message,
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 10),
            ShowcaseSourceTextPanelGroup(
              panelHeight: 142,
              minPanelWidth: 280,
              items: [
                ShowcaseSourceTextItem(
                  title: 'Telemetry JSON',
                  text: showcasePrettyJson(telemetrySnapshot.toJson()),
                  copyLabel: 'JSON render safety telemetry',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservationChip extends StatelessWidget {
  const _ObservationChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
