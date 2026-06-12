import '../example/interaction_reliability_lab_example.dart';
import '../example/chart_export_lab_example.dart';
import '../example/json_render_safety_example.dart';
import '../example/large_data_sampling_example.dart';
import '../example/payload_doctor_example.dart';
import '../example/payload_normalization_example.dart';
import '../example/performance_diagnostics_example.dart';
import '../example/registry_health_example.dart';
import '../example/tenun_chart_json_force_type_example.dart';
import '../example/zoom_runtime_example.dart';
import 'chart_story_builders.dart';
import 'chart_tool_story_contracts.dart';
import 'json_render_safety_story_knobs.dart';
import 'payload_normalization_story_knobs.dart';
import 'registry_health_story_knobs.dart';

final chartToolStories = [
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Chart Export Lab',
    description:
        'Export a config-driven chart as CSV, XLSX, PNG, or JPEG through the unified ChartExporter API.',
    height: 640,
    child: const ChartExportLabExample(),
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/TenunChartJson ForceType Guardrails',
    description:
        'Custom blocked-switch fallback UI for safe TenunChartJson forceType previews.',
    height: 440,
    child: const TenunChartJsonForceTypeExample(),
  ),
  fixedHeightChartStory(
    name: 'Charts/Tools/JSON Render Safety',
    description:
        'Safe TenunChartFromJson render fallback presets for malformed or unregistered JSON payloads.',
    height: 700,
    contract: jsonRenderSafetyStoryContract,
    builder: (context) {
      final knobs = jsonRenderSafetyStoryKnobs(context);

      return JsonRenderSafetyExample(
        scenario: knobs.scenario,
        fallbackPreset: knobs.fallbackPreset,
        validatePayload: knobs.validatePayload,
        strictValidation: knobs.strictValidation,
        autoNormalizePayload: knobs.autoNormalizePayload,
        showPayloadSource: knobs.showPayloadSource,
      );
    },
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Zoom Legacy Charts',
    description:
        'Old line/area/bar rendered with new zoom controller, minimap and animation.',
    height: 460,
    child: const ZoomableLegacyChartsExample(),
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Drilldown Bar',
    description: 'Drill-down flow powered by ChartDrillDownController.',
    height: 460,
    child: const DrilldownLegacyBarExample(),
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Large Data Sampling Lab',
    description:
        'Runtime controls for sampling strategy, threshold, dataset size, and chart type.',
    height: 600,
    child: const LargeDataSamplingExample(),
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Interaction Reliability Lab',
    description:
        'Combined lab for synced zoom, drilldown, and large-data sampling behavior.',
    height: 860,
    child: const InteractionReliabilityLabExample(),
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Performance Diagnostics Lab',
    description:
        'Live cache/isolate/sampling timing diagnostics for large chart datasets.',
    height: 840,
    child: const PerformanceDiagnosticsExample(initialUseIsolate: false),
  ),
  fixedHeightChartChildStory(
    name: 'Charts/Tools/Payload Doctor',
    description:
        'Contract-aware JSON payload diagnosis with validation, normalization, and quick fixes.',
    height: 760,
    child: const PayloadDoctorExample(),
  ),
  fixedHeightChartStory(
    name: 'Charts/Tools/Payload Normalize Playground',
    description:
        'Toggle autoNormalizePayload/sanitizeTradingPayload to compare broken vs auto-fixed JSON behavior for line, pie, and trading payloads.',
    height: 560,
    builder: (context) {
      final knobs = payloadNormalizationStoryKnobs(context);
      return PayloadNormalizationExample(
        targetType: knobs.targetType,
        autoNormalizePayload: knobs.autoNormalizePayload,
        strictValidation: knobs.strictValidation,
        dropUnsupportedSampling: knobs.dropUnsupportedSampling,
        sanitizeTradingPayload: knobs.sanitizeTradingPayload,
        highlightDiff: knobs.highlightDiff,
        normalizeDefaultThreshold: knobs.normalizeDefaultThreshold,
        normalizeDefaultMode: knobs.normalizeDefaultMode,
      );
    },
  ),
  fixedHeightChartStory(
    name: 'Charts/Tools/Registry Health Matrix',
    description:
        'Developer-facing audit and capability matrix for registered chart bundles.',
    height: 900,
    contract: registryHealthMatrixStoryContract,
    builder: (context) {
      final knobs = registryHealthStoryKnobs(context);

      return _registryHealthExampleFromKnobs(knobs);
    },
  ),
  fixedHeightChartStory(
    name: 'Charts/Tools/Registry Health Split Review',
    description:
        'Focused core/pro package split and Pro readiness review for release planning.',
    height: 760,
    contract: registryHealthSplitReviewStoryContract,
    builder: (context) {
      final knobs = registryHealthStoryKnobs(
        context,
        initialSectionSet: 'split',
        initialDetailMode: 'compact',
        initialExportPreset: 'release',
        initialAuditIssueLimit: 4,
        initialSplitIssueLimit: 6,
        initialBacklogPreviewMode: 'compact',
        initialBacklogVisibleLimit: 3,
      );

      return _registryHealthExampleFromKnobs(knobs);
    },
  ),
];

RegistryHealthExample _registryHealthExampleFromKnobs(
  RegistryHealthStoryKnobs knobs,
) {
  return RegistryHealthExample(
    showcaseBacklogVisibleLimit: knobs.showcaseBacklogVisibleLimit,
    showcaseBacklogOptions: knobs.showcaseBacklogOptions,
    chartExampleMatrixOptions: knobs.chartExampleMatrixOptions,
    detailOptions: knobs.detailOptions,
    sectionOptions: knobs.sectionOptions,
    exportOptions: knobs.exportOptions,
  );
}
