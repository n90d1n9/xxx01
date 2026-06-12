import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' hide FontWeight;

import 'performance_diagnostics_controls.dart';
import 'performance_diagnostics_report_panel.dart';
import 'performance_diagnostics_utils.dart';
import 'performance_diagnostics_widgets.dart';

class PerformanceDiagnosticsExample extends StatefulWidget {
  final int initialPoints;
  final bool initialUseIsolate;
  final bool initialWarmCache;

  const PerformanceDiagnosticsExample({
    super.key,
    this.initialPoints = 12000,
    this.initialUseIsolate = true,
    this.initialWarmCache = true,
  });

  @override
  State<PerformanceDiagnosticsExample> createState() =>
      _PerformanceDiagnosticsExampleState();
}

class _PerformanceDiagnosticsExampleState
    extends State<PerformanceDiagnosticsExample> {
  late final bool _prevCacheEnabled;
  late final int _prevCacheMaxEntries;
  late final int _prevCacheMaxBytes;
  late final int _prevCacheMinPointCount;
  late final bool _prevExtractionCacheEnabled;
  late final int _prevExtractionCacheMaxEntries;
  late final int _prevExtractionCacheMaxBytes;
  late final int _prevExtractionCacheMinPointCount;

  late int _points;
  late bool _useIsolate;
  late bool _warmCache;
  final AsyncChartProcessingController _processingController =
      AsyncChartProcessingController();

  ChartType _chartType = ChartType.line;
  ChartDataMode _dataMode = ChartDataMode.large;
  SamplingStrategy? _samplingStrategy = SamplingStrategy.minMax;

  bool _useCache = true;
  int _renderThreshold = 700;
  int _isolateThreshold = 8000;

  late List<double> _signal;

  bool _running = false;
  String? _error;
  AsyncChartProcessingReport? _firstReport;
  AsyncChartProcessingReport? _lastReport;
  ChartRuntimeDiagnostics? _widgetRuntime;
  ChartDataProcessingCacheStats? _cacheStats;
  int _diagnosticOutputPoints = 0;
  int _historyRun = 0;
  final List<PerformanceDiagnosticsHistoryEntry> _history = [];

  static const int _maxHistoryEntries = 6;

  @override
  void initState() {
    super.initState();
    _points = widget.initialPoints;
    _useIsolate = widget.initialUseIsolate;
    _warmCache = widget.initialWarmCache;

    _prevCacheEnabled = ChartDataProcessingCacheConfig.enabled;
    _prevCacheMaxEntries = ChartDataProcessingCacheConfig.maxEntries;
    _prevCacheMaxBytes = ChartDataProcessingCacheConfig.maxBytes;
    _prevCacheMinPointCount = ChartDataProcessingCacheConfig.minPointCount;
    _prevExtractionCacheEnabled =
        ChartDataProcessingCacheConfig.extractionCacheEnabled;
    _prevExtractionCacheMaxEntries =
        ChartDataProcessingCacheConfig.maxExtractionEntries;
    _prevExtractionCacheMaxBytes =
        ChartDataProcessingCacheConfig.maxExtractionBytes;
    _prevExtractionCacheMinPointCount =
        ChartDataProcessingCacheConfig.minExtractionPointCount;
    ChartDataProcessor.configureProcessingCache(
      enabled: true,
      maxEntries: 12,
      maxBytes: 16 * 1024 * 1024,
      minPointCount: 0,
      extractionCacheEnabled: true,
      maxExtractionEntries: 24,
      maxExtractionBytes: 16 * 1024 * 1024,
      minExtractionPointCount: 0,
    );
    ChartDataProcessor.clearProcessingCache();

    _rebuildSignal();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runDiagnostics());
  }

  @override
  void dispose() {
    _processingController.dispose();
    ChartDataProcessor.configureProcessingCache(
      enabled: _prevCacheEnabled,
      maxEntries: _prevCacheMaxEntries,
      maxBytes: _prevCacheMaxBytes,
      minPointCount: _prevCacheMinPointCount,
      extractionCacheEnabled: _prevExtractionCacheEnabled,
      maxExtractionEntries: _prevExtractionCacheMaxEntries,
      maxExtractionBytes: _prevExtractionCacheMaxBytes,
      minExtractionPointCount: _prevExtractionCacheMinPointCount,
    );
    ChartDataProcessor.clearProcessingCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chartPayload = _buildChartPayload();
    final renderedPoints = PerformanceDiagnosticsData.renderedPointCount(
      chartPayload,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxWidth < 620 || constraints.maxHeight < 700;

          if (compact) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._header,
                  _buildControls(renderedPoints),
                  const SizedBox(height: 10),
                  SizedBox(height: 320, child: _buildChart(chartPayload)),
                  const SizedBox(height: 10),
                  SizedBox(height: 430, child: _buildDiagnosticsPanel()),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._header,
              _buildControls(renderedPoints),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, panelConstraints) {
                    if (panelConstraints.maxWidth < 920) {
                      return Column(
                        children: [
                          Expanded(child: _buildChart(chartPayload)),
                          const SizedBox(height: 10),
                          Expanded(child: _buildDiagnosticsPanel()),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: _buildChart(chartPayload)),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: _buildDiagnosticsPanel()),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> get _header => const [
    Text(
      'Performance Diagnostics Lab',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
    SizedBox(height: 6),
    Text(
      'Inspect sampling, cache hits, isolate offloading, and processor timing for large datasets.',
      style: TextStyle(fontSize: 12, color: Colors.black87),
    ),
    SizedBox(height: 10),
  ];

  Widget _buildControls(int renderedPoints) {
    return PerformanceDiagnosticsControls(
      chartType: _chartType,
      dataMode: _dataMode,
      samplingStrategy: _samplingStrategy,
      useCache: _useCache,
      useIsolate: _useIsolate,
      warmCache: _warmCache,
      running: _running,
      points: _points,
      renderThreshold: _renderThreshold,
      isolateThreshold: _isolateThreshold,
      signalLength: _signal.length,
      renderedPoints: renderedPoints,
      diagnosticOutputPoints: _diagnosticOutputPoints,
      onChartTypeChanged: (value) {
        setState(() => _chartType = value);
      },
      onDataModeChanged: (value) {
        setState(() => _dataMode = value);
        _runDiagnostics();
      },
      onSamplingStrategyChanged: (value) {
        setState(() => _samplingStrategy = value);
        _runDiagnostics();
      },
      onUseCacheChanged: (value) {
        setState(() => _useCache = value);
        _runDiagnostics();
      },
      onUseIsolateChanged: (value) {
        setState(() => _useIsolate = value);
        _runDiagnostics();
      },
      onWarmCacheChanged: (value) {
        setState(() => _warmCache = value);
        _runDiagnostics();
      },
      onPointsChanged: (value) {
        setState(() {
          _points = value;
          _rebuildSignal();
        });
        _runDiagnostics();
      },
      onRenderThresholdChanged: (value) {
        setState(() => _renderThreshold = value);
        _runDiagnostics();
      },
      onIsolateThresholdChanged: (value) {
        setState(() => _isolateThreshold = value);
        _runDiagnostics();
      },
      onRunDiagnostics: _runDiagnostics,
      onClearCache: () {
        ChartDataProcessor.clearProcessingCache();
        setState(() => _cacheStats = ChartDataProcessor.processingCacheStats);
        _runDiagnostics();
      },
    );
  }

  Widget _buildChart(Map<String, dynamic> payload) {
    return PerformanceDiagnosticsPanelCard(
      title: 'Rendered Chart',
      subtitle: 'The same payload mode and sampling controls are applied here.',
      child: TenunChartFromJson(
        jsonConfig: payload,
        validatePayload: true,
        autoNormalizePayload: true,
        normalizationOptions: PayloadNormalizationOptions(
          defaultMode: _dataMode,
          defaultThreshold: _renderThreshold,
          dropUnsupportedSampling: true,
        ),
        onRuntimeDiagnostics: (diagnostics) {
          if (!mounted) return;
          if (_widgetRuntime?.stableSignature == diagnostics.stableSignature) {
            return;
          }
          setState(() => _widgetRuntime = diagnostics);
        },
      ),
    );
  }

  Widget _buildDiagnosticsPanel() {
    return PerformanceDiagnosticsReportPanel(
      running: _running,
      error: _error,
      firstReport: _firstReport,
      lastReport: _lastReport,
      widgetRuntime: _widgetRuntime,
      cacheStats: _cacheStats,
      diagnosticOutputPoints: _diagnosticOutputPoints,
      history: _history,
    );
  }

  Future<void> _runDiagnostics() async {
    final series = [
      Series(
        type: ChartType.line,
        name: 'Signal',
        data: List<dynamic>.from(_signal),
      ),
    ];

    setState(() {
      _running = true;
      _error = null;
    });

    try {
      final output = await _processingController.runLatest((_) async {
        final first = await AsyncChartProcessor.processAsyncWithReport(
          series,
          renderThreshold: _renderThreshold,
          samplingStrategy: _samplingStrategy,
          useCache: _useCache,
          useIsolate: _useIsolate,
          isolatePointThreshold: _isolateThreshold,
        );
        final last = _warmCache
            ? await AsyncChartProcessor.processAsyncWithReport(
                series,
                renderThreshold: _renderThreshold,
                samplingStrategy: _samplingStrategy,
                useCache: _useCache,
                useIsolate: _useIsolate,
                isolatePointThreshold: _isolateThreshold,
              )
            : first;
        return (first: first, last: last);
      });

      if (!mounted || output == null) return;
      setState(() {
        _firstReport = output.first.report;
        _lastReport = output.last.report;
        _diagnosticOutputPoints = ChartDataProcessor.outputPointCount(
          output.last.result.processed,
        );
        _cacheStats = ChartDataProcessor.processingCacheStats;
        _history.insert(
          0,
          PerformanceDiagnosticsHistoryEntry.fromReport(
            output.last.report,
            run: ++_historyRun,
          ),
        );
        if (_history.length > _maxHistoryEntries) {
          _history.removeRange(_maxHistoryEntries, _history.length);
        }
        _running = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _cacheStats = ChartDataProcessor.processingCacheStats;
        _running = false;
      });
    }
  }

  void _rebuildSignal() {
    _signal = PerformanceDiagnosticsData.buildSignal(_points);
  }

  Map<String, dynamic> _buildChartPayload() {
    return PerformanceDiagnosticsData.buildChartPayload(
      chartType: _chartType,
      dataMode: _dataMode,
      samplingStrategy: _samplingStrategy,
      renderThreshold: _renderThreshold,
      signal: _signal,
    );
  }
}
