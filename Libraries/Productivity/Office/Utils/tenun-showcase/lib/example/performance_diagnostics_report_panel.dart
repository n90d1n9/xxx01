import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenun/tenun_core.dart' hide Align, FontWeight;

import 'performance_diagnostics_utils.dart';
import 'performance_diagnostics_widgets.dart';

class PerformanceDiagnosticsReportPanel extends StatelessWidget {
  final bool running;
  final String? error;
  final AsyncChartProcessingReport? firstReport;
  final AsyncChartProcessingReport? lastReport;
  final ChartRuntimeDiagnostics? widgetRuntime;
  final ChartDataProcessingCacheStats? cacheStats;
  final int diagnosticOutputPoints;
  final List<PerformanceDiagnosticsHistoryEntry> history;

  const PerformanceDiagnosticsReportPanel({
    super.key,
    required this.running,
    required this.error,
    required this.firstReport,
    required this.lastReport,
    required this.widgetRuntime,
    required this.cacheStats,
    required this.diagnosticOutputPoints,
    this.history = const [],
  });

  @override
  Widget build(BuildContext context) {
    final first = firstReport;
    final last = lastReport;
    final cache = cacheStats ?? ChartDataProcessor.processingCacheStats;
    final historySummary = PerformanceDiagnosticsHistorySummary.tryFromEntries(
      history,
    );
    final historyAggregate =
        PerformanceDiagnosticsHistoryAggregate.tryFromEntries(history);
    final snapshot = PerformanceDiagnosticsSnapshot.tryCreate(
      firstReport: first,
      lastReport: last,
      widgetRuntime: widgetRuntime,
      cacheStats: cache,
      diagnosticOutputPoints: diagnosticOutputPoints,
      history: history,
    );
    final supportBundleValidation = snapshot?.validateSupportBundle();
    final supportBundlePreview = snapshot?.supportBundlePreview();

    return PerformanceDiagnosticsPanelCard(
      title: 'Runtime Diagnostics',
      subtitle: 'Processor metrics are generated outside paint/build.',
      child: ListView(
        key: const ValueKey('performance-diagnostics-list'),
        children: [
          if (running) ...[
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 10),
          ],
          if (error != null)
            PerformanceStatusBox(
              title: 'Diagnostics Error',
              message: error!,
              color: const Color(0xFFFFF1F2),
            ),
          _sectionTitle('Cache Stats'),
          _kv('Size', '${cache.size}/${cache.maxEntries}'),
          _kv(
            'Memory',
            '${_formatBytes(cache.currentBytes)} / '
                '${_formatBytes(cache.maxBytes)}',
          ),
          _kv('Hits / Misses', '${cache.hits} / ${cache.misses}'),
          _kv('Hit Rate', '${(cache.hitRate * 100).toStringAsFixed(1)}%'),
          _kv(
            'Extraction Cache',
            '${cache.extractionSize}/${cache.maxExtractionEntries} | '
                '${_formatBytes(cache.extractionCurrentBytes)} | '
                '${(cache.extractionHitRate * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
          if (first == null || last == null)
            const Text('Diagnostics pending...')
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricTile('Data Points', '${last.dataPointCount}'),
                _metricTile(
                  'Effective Points',
                  '${last.processingReport.effectiveDataPointCount}',
                ),
                _metricTile(
                  'Sample Input',
                  '${last.processingReport.sampleInputPointCount}',
                ),
                _metricTile('Output Points', '$diagnosticOutputPoints'),
                _metricTile(
                  'Downsampled',
                  last.processingReport.wasDownsampled ? 'yes' : 'no',
                ),
                _metricTile(
                  'Cache Health',
                  last.performanceSummary.overallCacheSeverity.name,
                ),
                _metricTile(
                  'Isolate Eligible',
                  last.isolateEligible ? 'yes' : 'no',
                ),
                _metricTile('Used Isolate', first.usedIsolate ? 'yes' : 'no'),
                _metricTile('Cache Hit', last.cacheHit ? 'yes' : 'no'),
                _metricTile(
                  'Path',
                  last.processingReport.path.name,
                  wide: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionTitle('Performance Summary'),
            _kv(
              'Overall Severity',
              last.performanceSummary.overallCacheSeverity.name,
            ),
            _kv(
              'Sampling Reduction',
              _percent(last.performanceSummary.samplingReductionRatio),
            ),
            _kv(
              'Result Cache Action',
              last.performanceSummary.cacheRecommendedAction.name,
            ),
            _kv(
              'Extraction Action',
              last.performanceSummary.extractionCacheRecommendedAction.name,
            ),
            _kv(
              'Isolate Mode',
              last.performanceSummary.usedIsolate == true ? 'isolate' : 'main',
            ),
            _kv(
              'End-to-End',
              _micros(
                last.performanceSummary.endToEndDuration ?? last.totalDuration,
              ),
            ),
            const SizedBox(height: 12),
            _sectionTitle('Snapshot Export'),
            _kv('Snapshot Ready', snapshot == null ? 'no' : 'yes'),
            _kv(
              'Snapshot Sections',
              snapshot == null ? 'pending' : '${snapshot.topLevelKeys.length}',
            ),
            _kv(
              'Snapshot History',
              snapshot == null ? 'pending' : '${snapshot.historyRunCount} runs',
            ),
            _kv(
              'Snapshot Runtime',
              snapshot?.hasRuntimeDiagnostics == true ? 'yes' : 'no',
            ),
            _kv(
              'Export Health',
              snapshot == null ? 'pending' : snapshot.exportSeverity().name,
            ),
            _kv(
              'Export Action',
              snapshot == null
                  ? 'pending'
                  : snapshot.exportRecommendation().name,
            ),
            _kv(
              'Export Hint',
              snapshot == null
                  ? 'pending'
                  : snapshot.exportRecommendationHint(),
            ),
            _kv(
              'Snapshot Fingerprint',
              snapshot == null ? 'pending' : snapshot.compactFingerprint(),
            ),
            _kv(
              'Support Bundle Fingerprint',
              snapshot == null
                  ? 'pending'
                  : snapshot.supportBundleFingerprint(),
            ),
            _kv(
              'Full Export Size',
              snapshot == null
                  ? 'pending'
                  : _formatBytes(snapshot.fullExportBytes),
            ),
            _kv(
              'Compact Export Size',
              snapshot == null
                  ? 'pending'
                  : _formatBytes(snapshot.compactExportBytes()),
            ),
            _kv(
              'Compact Reduction',
              snapshot == null
                  ? 'pending'
                  : _percent(snapshot.compactReductionRatio()),
            ),
            _kv(
              'Support Bundle Size',
              snapshot == null
                  ? 'pending'
                  : _formatBytes(snapshot.supportBundleBytes()),
            ),
            _kv(
              'Support Bundle Check',
              supportBundleValidation?.severity.name ?? 'pending',
            ),
            _kv(
              'Support Bundle Summary',
              supportBundleValidation?.summary ?? 'pending',
            ),
            _kv(
              'Support Bundle Preview',
              supportBundlePreview?.summary ?? 'pending',
            ),
            _kv(
              'Bundle Action',
              supportBundlePreview?.exportRecommendation ?? 'pending',
            ),
            _kv(
              'Bundle Points',
              supportBundlePreview == null
                  ? 'pending'
                  : '${supportBundlePreview.renderedDataPointCount ?? 0}/${supportBundlePreview.sourceDataPointCount ?? 0}',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: snapshot == null
                        ? null
                        : () => _copySnapshot(context, snapshot),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Snapshot JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: snapshot == null
                        ? null
                        : () => _copyCompactSnapshot(context, snapshot),
                    icon: const Icon(Icons.short_text, size: 16),
                    label: const Text('Copy Compact JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: snapshot == null
                        ? null
                        : () => _copySupportBundle(context, snapshot),
                    icon: const Icon(Icons.assignment_outlined, size: 16),
                    label: const Text('Copy Support Bundle'),
                  ),
                ],
              ),
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionTitle('Run Trend'),
              _kv('History Runs', '${historySummary!.runCount}'),
              _kv('Trend Health', historySummary.severity.name),
              _kv('Trend Action', historySummary.recommendation.name),
              _kv(
                'Data Delta',
                _historyDelta(
                  historySummary,
                  _signedInt(historySummary.dataPointDelta, suffix: 'pts'),
                ),
              ),
              _kv(
                'Sample Input Delta',
                _historyDelta(
                  historySummary,
                  _signedInt(
                    historySummary.sampleInputPointDelta,
                    suffix: 'pts',
                  ),
                ),
              ),
              _kv(
                'Output Delta',
                _historyDelta(
                  historySummary,
                  _signedInt(historySummary.outputPointDelta, suffix: 'pts'),
                ),
              ),
              _kv(
                'Reduction Delta',
                _historyDelta(
                  historySummary,
                  _signedPercent(historySummary.samplingReductionDelta),
                ),
              ),
              _kv(
                'Cache Hit Delta',
                _historyDelta(
                  historySummary,
                  _signedPercent(historySummary.cacheHitRateDelta),
                ),
              ),
              _kv(
                'Duration Delta',
                _historyDelta(
                  historySummary,
                  _signedMicros(historySummary.totalDurationDelta),
                ),
              ),
              _kv('Trend Hint', historySummary.recommendationHint),
              const SizedBox(height: 12),
              _sectionTitle('Run Aggregate'),
              _kv('Aggregate Health', historyAggregate!.severity.name),
              _kv('Aggregate Action', historyAggregate.recommendation.name),
              _kv('Avg Duration', _micros(historyAggregate.averageDuration)),
              _kv(
                'Duration Spread',
                '${_micros(historyAggregate.durationSpread)} '
                    '(${_percent(historyAggregate.durationSpreadRatio)})',
              ),
              _kv(
                'Fastest / Slowest',
                '#${historyAggregate.fastest.run} '
                    '${_micros(historyAggregate.fastest.totalDuration)} / '
                    '#${historyAggregate.slowest.run} '
                    '${_micros(historyAggregate.slowest.totalDuration)}',
              ),
              _kv(
                'Avg Output',
                '${_decimal(historyAggregate.averageOutputPointCount)} pts',
              ),
              _kv(
                'Avg Reduction',
                _percent(historyAggregate.averageSamplingReductionRatio),
              ),
              _kv(
                'Avg Cache Hit',
                _percent(historyAggregate.averageCacheHitRate),
              ),
              _kv(
                'Cache Hit Runs',
                '${historyAggregate.cacheHitRunCount}/${historyAggregate.runCount} '
                    '(${_percent(historyAggregate.cacheHitRunRatio)})',
              ),
              _kv(
                'Downsampled Runs',
                '${historyAggregate.downsampledRunCount}/${historyAggregate.runCount} '
                    '(${_percent(historyAggregate.downsampledRunRatio)})',
              ),
              _kv(
                'Isolate Runs',
                '${historyAggregate.isolateRunCount}/${historyAggregate.runCount} '
                    '(${_percent(historyAggregate.isolateRunRatio)})',
              ),
              _kv('Aggregate Hint', historyAggregate.recommendationHint),
              const SizedBox(height: 12),
              _sectionTitle('Run History'),
              const SizedBox(height: 4),
              for (final entry in history.take(5)) _historyRow(entry),
            ],
            const SizedBox(height: 12),
            _sectionTitle('Last Pass'),
            _kv('Total', _micros(last.totalDuration)),
            _kv('Processing', _micros(last.processingReport.totalDuration)),
            _kv('Sampling', _micros(last.processingReport.samplingDuration)),
            _kv('Stats', _micros(last.processingReport.statsDuration)),
            _kv(
              'Point Build',
              _micros(last.processingReport.pointBuildDuration),
            ),
            _kv(
              'Strategy',
              last.processingReport.samplingStrategy?.name ?? 'auto',
            ),
            _kv('Threshold', '${last.processingReport.renderThreshold}'),
            _kv(
              'Sample Input Points',
              '${last.processingReport.sampleInputPointCount}',
            ),
            _kv('Reduced Points', '${last.processingReport.reducedPointCount}'),
            _kv(
              'Output Ratio',
              _percent(last.processingReport.samplingOutputRatio),
            ),
            _kv(
              'Reduction Ratio',
              _percent(last.processingReport.samplingReductionRatio),
            ),
            _kv(
              'Result Cache Eligible',
              last.processingReport.cacheEligible ? 'yes' : 'no',
            ),
            _kv(
              'Result Cache Reason',
              last.processingReport.cacheAdmissionReason.name,
            ),
            _kv(
              'Result Cache Action',
              last.processingReport.cacheRecommendedAction.name,
            ),
            _kv(
              'Result Cache Severity',
              last.processingReport.cacheRecommendationSeverity.name,
            ),
            _kv('Result Cache Hint', last.processingReport.cacheAdmissionHint),
            _kv(
              'Extraction Cache Eligible',
              last.processingReport.extractionCacheEligible ? 'yes' : 'no',
            ),
            _kv(
              'Extraction Cache Reason',
              last.processingReport.extractionCacheAdmissionReason.name,
            ),
            _kv(
              'Extraction Cache Action',
              last.processingReport.extractionCacheRecommendedAction.name,
            ),
            _kv(
              'Extraction Cache Severity',
              last.processingReport.extractionCacheRecommendationSeverity.name,
            ),
            _kv(
              'Extraction Cache Hint',
              last.processingReport.extractionCacheAdmissionHint,
            ),
            _kv(
              'Policy Min Points',
              '${last.processingReport.cachePolicy.minPointCount} / '
                  '${last.processingReport.cachePolicy.minExtractionPointCount}',
            ),
            const SizedBox(height: 12),
            _sectionTitle('First Pass'),
            _kv('Used Isolate', first.usedIsolate ? 'yes' : 'no'),
            _kv('Path', first.processingReport.path.name),
            _kv('Cache Hit', first.cacheHit ? 'yes' : 'no'),
            _kv('Total', _micros(first.totalDuration)),
          ],
          const SizedBox(height: 12),
          _sectionTitle('Widget Runtime'),
          _kv(
            'Source / Rendered',
            widgetRuntime == null
                ? 'pending'
                : '${widgetRuntime!.sourceDataPointCount} / ${widgetRuntime!.renderedDataPointCount}',
          ),
          _kv(
            'Runtime Effective Points',
            widgetRuntime == null
                ? 'pending'
                : widgetRuntime!.effectiveDataPointCount?.toString() ??
                      'unavailable',
          ),
          _kv(
            'Runtime Sample Input',
            widgetRuntime == null
                ? 'pending'
                : widgetRuntime!.sampleInputPointCount?.toString() ??
                      'unavailable',
          ),
          _kv(
            'Processor / Runtime Output',
            widgetRuntime == null || last == null
                ? 'pending'
                : '${last.processingReport.outputPointCount} / ${widgetRuntime!.renderedDataPointCount}',
          ),
          _kv(
            'Runtime Severity',
            widgetRuntime?.performanceSummary.severity.name ?? 'pending',
          ),
          _kv(
            'Runtime Recommendation',
            widgetRuntime?.performanceSummary.recommendation.name ?? 'pending',
          ),
          _kv(
            'Runtime Action Required',
            widgetRuntime == null
                ? 'pending'
                : widgetRuntime!.performanceSummary.requiresAction
                ? 'yes'
                : 'no',
          ),
          _kv(
            'Runtime Hint',
            widgetRuntime?.performanceSummary.recommendationHint ?? 'pending',
          ),
          _kv(
            'Runtime Policy Source',
            widgetRuntime?.performancePolicySourceLabel ?? 'pending',
          ),
          _kv(
            'Large Data Threshold',
            widgetRuntime == null
                ? 'pending'
                : '${widgetRuntime!.performanceSummary.policy.normalizedLargeDatasetPointThreshold}',
          ),
          _kv(
            'Cache Pressure Limit',
            widgetRuntime == null
                ? 'pending'
                : _percent(
                    widgetRuntime!
                        .performanceSummary
                        .policy
                        .normalizedCachePressureWarningThreshold,
                  ),
          ),
          _kv(
            'Rendered Ratio',
            widgetRuntime == null
                ? 'pending'
                : _percent(
                    widgetRuntime!.performanceSummary.renderedOutputRatio,
                  ),
          ),
          _kv(
            'Runtime Reduction',
            widgetRuntime == null
                ? 'pending'
                : _percent(
                    widgetRuntime!.performanceSummary.renderedReductionRatio,
                  ),
          ),
          _kv(
            'Runtime Sampling Reduction',
            widgetRuntime == null
                ? 'pending'
                : widgetRuntime!.performanceSummary.samplingReductionRatio ==
                      null
                ? 'unavailable'
                : _percent(
                    widgetRuntime!.performanceSummary.samplingReductionRatio!,
                  ),
          ),
          _kv(
            'Config Sampled',
            widgetRuntime?.configSampledData == true ? 'yes' : 'no',
          ),
          _kv(
            'Processing Hit Rate',
            widgetRuntime == null
                ? 'pending'
                : _percent(
                    widgetRuntime!.performanceSummary.processingCacheHitRate,
                  ),
          ),
          _kv(
            'Extraction Hit Rate',
            widgetRuntime == null
                ? 'pending'
                : _percent(
                    widgetRuntime!.performanceSummary.extractionCacheHitRate,
                  ),
          ),
          _kv(
            'Build',
            widgetRuntime == null
                ? 'pending'
                : _micros(widgetRuntime!.totalBuildDuration),
          ),
          if (widgetRuntime?.renderCacheStats != null) ...[
            const SizedBox(height: 12),
            _sectionTitle('Render Object Cache'),
            _kv(
              'Colors',
              _formatObjectCache(widgetRuntime!.renderCacheStats!.colors),
            ),
            _kv(
              'Paints',
              _formatObjectCache(widgetRuntime!.renderCacheStats!.paints),
            ),
            _kv(
              'Text Painters',
              _formatObjectCache(widgetRuntime!.renderCacheStats!.textPainters),
            ),
            _kv(
              'Paths',
              _formatObjectCache(widgetRuntime!.renderCacheStats!.paths),
            ),
          ],
          if (widgetRuntime?.pictureCacheStats != null) ...[
            const SizedBox(height: 12),
            _sectionTitle('Picture Cache'),
            _kv('Size', '${widgetRuntime!.pictureCacheStats!.size}'),
            _kv(
              'Memory',
              _formatBytes(
                widgetRuntime!.pictureCacheStats!.currentMemoryBytes,
              ),
            ),
            _kv(
              'Hits / Misses',
              '${widgetRuntime!.pictureCacheStats!.hits} / '
                  '${widgetRuntime!.pictureCacheStats!.misses}',
            ),
            _kv('Evictions', '${widgetRuntime!.pictureCacheStats!.evictions}'),
          ],
          const SizedBox(height: 12),
          _sectionTitle('Cache Details'),
          _kv('Size', '${cache.size}/${cache.maxEntries}'),
          _kv(
            'Memory',
            '${_formatBytes(cache.currentBytes)} / '
                '${_formatBytes(cache.maxBytes)}',
          ),
          _kv('Largest Entry', _formatBytes(cache.largestEntryBytes)),
          _kv('Hits', '${cache.hits}'),
          _kv('Misses', '${cache.misses}'),
          _kv('Writes', '${cache.writes}'),
          _kv('Evictions', '${cache.evictions}'),
          _kv('Evicted Bytes', _formatBytes(cache.evictedBytes)),
          _kv('Skipped Writes', '${cache.skippedWrites}'),
          _kv('Hit Rate', '${(cache.hitRate * 100).toStringAsFixed(1)}%'),
          const SizedBox(height: 12),
          _sectionTitle('Extraction Cache Details'),
          _kv('Size', '${cache.extractionSize}/${cache.maxExtractionEntries}'),
          _kv(
            'Memory',
            '${_formatBytes(cache.extractionCurrentBytes)} / '
                '${_formatBytes(cache.maxExtractionBytes)}',
          ),
          _kv('Largest Entry', _formatBytes(cache.extractionLargestEntryBytes)),
          _kv('Hits', '${cache.extractionHits}'),
          _kv('Misses', '${cache.extractionMisses}'),
          _kv('Writes', '${cache.extractionWrites}'),
          _kv('Evictions', '${cache.extractionEvictions}'),
          _kv('Evicted Bytes', _formatBytes(cache.extractionEvictedBytes)),
          _kv('Skipped Writes', '${cache.extractionSkippedWrites}'),
          _kv(
            'Hit Rate',
            '${(cache.extractionHitRate * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, {bool wide = false}) {
    return PerformanceMetricTile(label: label, value: value, wide: wide);
  }

  Widget _sectionTitle(String text) => PerformanceSectionTitle(text);

  Widget _historyRow(PerformanceDiagnosticsHistoryEntry entry) {
    final sampling = _percent(entry.samplingReductionRatio);
    final cache = _percent(entry.cacheHitRate);
    final mode = entry.usedIsolate ? 'isolate' : 'main';
    final sampled = entry.wasDownsampled ? 'sampled' : 'full';
    return PerformanceKeyValueRow(
      label: '#${entry.run} ${entry.path}',
      value:
          '${entry.outputPointCount}/${entry.sampleInputPointCount} pts | '
          '$sampling reduction | cache $cache | $mode/$sampled | '
          '${_micros(entry.totalDuration)}',
    );
  }

  Widget _kv(String label, String value) {
    return PerformanceKeyValueRow(label: label, value: value);
  }

  Future<void> _copySnapshot(
    BuildContext context,
    PerformanceDiagnosticsSnapshot snapshot,
  ) async {
    await Clipboard.setData(ClipboardData(text: snapshot.toPrettyJson()));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Snapshot JSON copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copyCompactSnapshot(
    BuildContext context,
    PerformanceDiagnosticsSnapshot snapshot,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: snapshot.toPrettyCompactJson()),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Compact snapshot JSON copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copySupportBundle(
    BuildContext context,
    PerformanceDiagnosticsSnapshot snapshot,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: snapshot.toPrettySupportBundleJson()),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(
        content: Text('Support bundle JSON copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _micros(Duration duration) =>
      PerformanceDiagnosticsFormat.micros(duration);

  String _percent(double ratio) => PerformanceDiagnosticsFormat.percent(ratio);

  String _decimal(double value) => value.toStringAsFixed(1);

  String _signedInt(int value, {String suffix = ''}) {
    return PerformanceDiagnosticsFormat.signedInt(value, suffix: suffix);
  }

  String _signedPercent(double ratio) {
    return PerformanceDiagnosticsFormat.signedPercent(ratio);
  }

  String _signedMicros(Duration duration) {
    return PerformanceDiagnosticsFormat.signedMicros(duration);
  }

  String _historyDelta(
    PerformanceDiagnosticsHistorySummary summary,
    String value,
  ) {
    return summary.hasPrevious ? value : 'pending';
  }

  String _formatObjectCache(ChartObjectCacheStats stats) {
    return PerformanceDiagnosticsFormat.objectCache(stats);
  }

  String _formatBytes(int bytes) => PerformanceDiagnosticsFormat.bytes(bytes);
}
