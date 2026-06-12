import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'json_render_safety_models.dart';
import 'json_render_safety_observation_panel.dart';
import 'json_render_safety_telemetry.dart';
import 'showcase_source_panel.dart';

class JsonRenderSafetyExample extends StatefulWidget {
  const JsonRenderSafetyExample({
    super.key,
    this.scenario = JsonRenderSafetyScenario.unknownType,
    this.fallbackPreset = JsonRenderSafetyFallbackPreset.defaults,
    this.validatePayload = false,
    this.strictValidation = false,
    this.autoNormalizePayload = false,
    this.showPayloadSource = true,
  });

  final JsonRenderSafetyScenario scenario;
  final JsonRenderSafetyFallbackPreset fallbackPreset;
  final bool validatePayload;
  final bool strictValidation;
  final bool autoNormalizePayload;
  final bool showPayloadSource;

  @override
  State<JsonRenderSafetyExample> createState() =>
      _JsonRenderSafetyExampleState();
}

class _JsonRenderSafetyExampleState extends State<JsonRenderSafetyExample> {
  Object? _renderError;
  ValidationResult? _validationResult;

  @override
  void didUpdateWidget(covariant JsonRenderSafetyExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldResetObservation(oldWidget)) {
      _renderError = null;
      _validationResult = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final definition = jsonRenderSafetyScenarioDefinition(widget.scenario);
    final effectiveStrictValidation =
        widget.validatePayload && widget.strictValidation;
    final fallbackOptions = _fallbackOptions(widget.fallbackPreset);
    final telemetrySnapshot = JsonRenderSafetyTelemetrySnapshot(
      scenario: widget.scenario,
      fallbackPreset: widget.fallbackPreset,
      payload: definition.payload,
      validatePayload: widget.validatePayload,
      strictValidation: effectiveStrictValidation,
      autoNormalizePayload: widget.autoNormalizePayload,
      renderError: _renderError,
      validationResult: _validationResult,
    );
    final chart = TenunChartFromJson(
      jsonConfig: definition.payload,
      validatePayload: widget.validatePayload,
      strictValidation: effectiveStrictValidation,
      autoNormalizePayload: widget.autoNormalizePayload,
      diagnosticFallbackOptions: fallbackOptions,
      onRenderError: _handleRenderError,
      onValidationResult: _handleValidationResult,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final preview = _RenderSafetyPreviewCard(
            title: definition.label,
            summary: definition.summary,
            scenario: widget.scenario,
            fallbackPreset: widget.fallbackPreset,
            validatePayload: widget.validatePayload,
            strictValidation: effectiveStrictValidation,
            autoNormalizePayload: widget.autoNormalizePayload,
            renderError: _renderError,
            validationResult: _validationResult,
            telemetrySnapshot: telemetrySnapshot,
            child: chart,
          );
          final source = _RenderSafetySourceCard(
            definition: definition,
            fallbackPreset: widget.fallbackPreset,
            validatePayload: widget.validatePayload,
            strictValidation: effectiveStrictValidation,
            autoNormalizePayload: widget.autoNormalizePayload,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JSON render safety',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (compact)
                Column(
                  children: [
                    preview,
                    if (widget.showPayloadSource) ...[
                      const SizedBox(height: 12),
                      source,
                    ],
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: preview),
                    if (widget.showPayloadSource) ...[
                      const SizedBox(width: 12),
                      Expanded(flex: 4, child: source),
                    ],
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  bool _shouldResetObservation(JsonRenderSafetyExample oldWidget) {
    return oldWidget.scenario != widget.scenario ||
        oldWidget.fallbackPreset != widget.fallbackPreset ||
        oldWidget.validatePayload != widget.validatePayload ||
        oldWidget.strictValidation != widget.strictValidation ||
        oldWidget.autoNormalizePayload != widget.autoNormalizePayload;
  }

  void _handleRenderError(Object error, StackTrace stackTrace) {
    if (_renderError.runtimeType == error.runtimeType &&
        _renderError?.toString() == error.toString()) {
      return;
    }

    setState(() {
      _renderError = error;
    });
  }

  void _handleValidationResult(ValidationResult result) {
    if (_validationSignature(_validationResult) ==
        _validationSignature(result)) {
      return;
    }

    setState(() {
      _validationResult = result;
    });
  }

  String _validationSignature(ValidationResult? result) {
    if (result == null) return 'none';
    return [
      result.type.name,
      result.isValid,
      result.errors.length,
      result.warnings.length,
      result.issues.map((issue) => issue.toString()).join('|'),
    ].join(':');
  }
}

class _RenderSafetyPreviewCard extends StatelessWidget {
  const _RenderSafetyPreviewCard({
    required this.title,
    required this.summary,
    required this.scenario,
    required this.fallbackPreset,
    required this.validatePayload,
    required this.strictValidation,
    required this.autoNormalizePayload,
    this.renderError,
    this.validationResult,
    required this.telemetrySnapshot,
    required this.child,
  });

  final String title;
  final String summary;
  final JsonRenderSafetyScenario scenario;
  final JsonRenderSafetyFallbackPreset fallbackPreset;
  final bool validatePayload;
  final bool strictValidation;
  final bool autoNormalizePayload;
  final Object? renderError;
  final ValidationResult? validationResult;
  final JsonRenderSafetyTelemetrySnapshot telemetrySnapshot;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(summary, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SafetyChip(label: _scenarioToken(scenario)),
                _SafetyChip(label: 'fallback.${fallbackPreset.name}'),
                _SafetyChip(label: 'validate.$validatePayload'),
                _SafetyChip(label: 'strict.$strictValidation'),
                _SafetyChip(label: 'normalize.$autoNormalizePayload'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(height: 320, width: double.infinity, child: child),
            const SizedBox(height: 12),
            JsonRenderSafetyObservationPanel(
              telemetrySnapshot: telemetrySnapshot,
              renderError: renderError,
              validationResult: validationResult,
            ),
          ],
        ),
      ),
    );
  }
}

class _RenderSafetySourceCard extends StatelessWidget {
  const _RenderSafetySourceCard({
    required this.definition,
    required this.fallbackPreset,
    required this.validatePayload,
    required this.strictValidation,
    required this.autoNormalizePayload,
  });

  final JsonRenderSafetyScenarioDefinition definition;
  final JsonRenderSafetyFallbackPreset fallbackPreset;
  final bool validatePayload;
  final bool strictValidation;
  final bool autoNormalizePayload;

  @override
  Widget build(BuildContext context) {
    return ShowcaseSourceTextPanelGroup(
      panelHeight: 234,
      minPanelWidth: 320,
      items: [
        ShowcaseSourceTextItem(
          title: 'Payload',
          text: showcasePrettyJson(definition.payload),
          copyLabel: 'JSON render safety payload',
        ),
        ShowcaseSourceTextItem(
          title: 'Dart',
          text: _sampleCode(
            fallbackPreset: fallbackPreset,
            validatePayload: validatePayload,
            strictValidation: strictValidation,
            autoNormalizePayload: autoNormalizePayload,
          ),
          copyLabel: 'JSON render safety code',
        ),
      ],
    );
  }
}

class _SafetyChip extends StatelessWidget {
  const _SafetyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
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

TenunDiagnosticFallbackOptions _fallbackOptions(
  JsonRenderSafetyFallbackPreset preset,
) {
  return switch (preset) {
    JsonRenderSafetyFallbackPreset.defaults =>
      TenunDiagnosticFallbackOptions.defaults,
    JsonRenderSafetyFallbackPreset.compact =>
      TenunDiagnosticFallbackOptions.compact,
    JsonRenderSafetyFallbackPreset.quiet =>
      TenunDiagnosticFallbackOptions.quiet,
    JsonRenderSafetyFallbackPreset.production =>
      TenunDiagnosticFallbackOptions.production,
  };
}

String _sampleCode({
  required JsonRenderSafetyFallbackPreset fallbackPreset,
  required bool validatePayload,
  required bool strictValidation,
  required bool autoNormalizePayload,
}) {
  return '''
TenunChartFromJson(
  jsonConfig: chartPayload,
  validatePayload: $validatePayload,
  strictValidation: $strictValidation,
  autoNormalizePayload: $autoNormalizePayload,
  diagnosticFallbackOptions: ${_fallbackPresetExpression(fallbackPreset)},
  onRenderError: (error, stackTrace) {
    // Capture or report render-time JSON failures.
  },
  onValidationResult: (result) {
    // Capture payload validation state when validation is enabled.
  },
)
'''
      .trim();
}

String _fallbackPresetExpression(JsonRenderSafetyFallbackPreset preset) {
  return switch (preset) {
    JsonRenderSafetyFallbackPreset.defaults =>
      'TenunDiagnosticFallbackOptions.defaults',
    JsonRenderSafetyFallbackPreset.compact =>
      'TenunDiagnosticFallbackOptions.compact',
    JsonRenderSafetyFallbackPreset.quiet =>
      'TenunDiagnosticFallbackOptions.quiet',
    JsonRenderSafetyFallbackPreset.production =>
      'TenunDiagnosticFallbackOptions.production',
  };
}

String _scenarioToken(JsonRenderSafetyScenario scenario) {
  return switch (scenario) {
    JsonRenderSafetyScenario.unknownType => 'scenario.unknown-type',
    JsonRenderSafetyScenario.unregisteredCustomType =>
      'scenario.unregistered-custom',
    JsonRenderSafetyScenario.invalidSamplingPolicy =>
      'scenario.invalid-sampling',
  };
}
