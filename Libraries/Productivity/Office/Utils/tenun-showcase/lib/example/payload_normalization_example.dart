import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart';

import 'payload_normalization_diagnostics.dart';
import 'payload_normalization_diff_panel.dart';
import 'payload_normalization_fixtures.dart';
import 'payload_normalization_json_panels.dart';

class PayloadNormalizationExample extends StatelessWidget {
  final String targetType;
  final bool autoNormalizePayload;
  final bool strictValidation;
  final bool dropUnsupportedSampling;
  final bool sanitizeTradingPayload;
  final bool highlightDiff;
  final int normalizeDefaultThreshold;
  final String normalizeDefaultMode;

  const PayloadNormalizationExample({
    super.key,
    required this.targetType,
    required this.autoNormalizePayload,
    required this.strictValidation,
    required this.dropUnsupportedSampling,
    required this.sanitizeTradingPayload,
    this.highlightDiff = true,
    required this.normalizeDefaultThreshold,
    required this.normalizeDefaultMode,
  });

  @override
  Widget build(BuildContext context) {
    final raw = buildPayloadNormalizationBrokenPayload(targetType);
    final mode = parsePayloadNormalizationMode(normalizeDefaultMode);
    final normalizationOptions = PayloadNormalizationOptions(
      dropUnsupportedSampling: dropUnsupportedSampling,
      defaultThreshold: normalizeDefaultThreshold,
      defaultMode: mode,
      sanitizeTradingPayload: sanitizeTradingPayload,
    );
    final normalizationReport = ChartConfigValidator.normalizePayloadWithReport(
      raw,
      options: normalizationOptions,
    );
    final normalized = normalizationReport.normalizedPayload;
    final rawValidation = ChartConfigValidator.validateJsonPayload(
      raw,
      deep: false,
    );
    final normalizedValidation = ChartConfigValidator.validateJsonPayload(
      normalized,
      deep: false,
    );
    final rawDoctor = ChartPayloadDoctor.inspect(
      raw,
      normalizationOptions: normalizationOptions,
    );
    final normalizedDoctor = ChartPayloadDoctor.inspect(
      normalized,
      normalizationOptions: normalizationOptions,
    );
    final effective = autoNormalizePayload ? normalized : raw;
    final effectiveValidation = autoNormalizePayload
        ? normalizedValidation
        : rawValidation;
    final effectiveDoctor = autoNormalizePayload ? normalizedDoctor : rawDoctor;
    final diffs = normalizationReport.diffs;
    final diffSummary = normalizationReport.summary;
    final diagnostics = buildPayloadNormalizationDiagnostics(
      targetType: targetType,
      autoNormalizePayload: autoNormalizePayload,
      strictValidation: strictValidation,
      dropUnsupportedSampling: dropUnsupportedSampling,
      sanitizeTradingPayload: sanitizeTradingPayload,
      normalizeDefaultThreshold: normalizeDefaultThreshold,
      normalizeDefaultMode: normalizeDefaultMode,
      effectivePayloadSource: autoNormalizePayload ? 'normalized' : 'raw',
      rawValidation: rawValidation,
      normalizedValidation: normalizedValidation,
      effectiveValidation: effectiveValidation,
      normalizationReport: normalizationReport,
      rawDoctor: rawDoctor,
      normalizedDoctor: normalizedDoctor,
      effectiveDoctor: effectiveDoctor,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target: $targetType | Normalize: $autoNormalizePayload | Strict: $strictValidation | '
            'Sanitize Trading: $sanitizeTradingPayload | Highlight Diff: $highlightDiff',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Raw errors: ${rawValidation.errors.length}, warnings: ${rawValidation.warnings.length} | '
            'Normalized errors: ${normalizedValidation.errors.length}, warnings: ${normalizedValidation.warnings.length}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Effective payload: ${autoNormalizePayload ? 'normalized' : 'raw'} '
            '| errors: ${effectiveValidation.errors.length}, warnings: ${effectiveValidation.warnings.length}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Doctor: raw ${rawDoctor.status.name}, normalized ${normalizedDoctor.status.name}, '
            'effective ${effectiveDoctor.status.name}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Raw mode/sampling: ${raw['dataMode']} / ${raw['sampling']}',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          Text(
            'Normalized mode/sampling: ${normalized['dataMode']} / ${normalized['sampling']}',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          Text(
            'Effective mode/sampling: ${effective['dataMode']} / ${effective['sampling']}',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          Text(
            'Changed paths after normalization: ${diffSummary.compactLabel}',
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              PayloadNormalizationCopyButton(
                label: 'Copy Raw JSON',
                payload: raw,
              ),
              PayloadNormalizationCopyButton(
                label: 'Copy Normalized JSON',
                payload: normalized,
              ),
              PayloadNormalizationCopyButton(
                label: 'Copy Effective JSON',
                payload: effective,
              ),
              PayloadNormalizationCopyButton(
                label: 'Copy Diagnostics JSON',
                payload: diagnostics,
              ),
              PayloadNormalizationCopyButton(
                label: 'Copy Doctor JSON',
                payload: effectiveDoctor.toJson(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 124,
            child: PayloadNormalizationDiffPanel(
              diffs: diffs,
              summary: diffSummary,
              highlightDiff: highlightDiff,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: PayloadNormalizationJsonPanels(
              raw: raw,
              normalized: normalized,
              diagnostics: diagnostics,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TenunChartFromJson(
              jsonConfig: raw,
              validatePayload: true,
              strictValidation: strictValidation,
              autoNormalizePayload: autoNormalizePayload,
              sanitizeTradingPayload: sanitizeTradingPayload,
              dropUnsupportedSampling: dropUnsupportedSampling,
              normalizeDefaultThreshold: normalizeDefaultThreshold,
              normalizeDefaultMode: mode,
              normalizationOptions: normalizationOptions,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
