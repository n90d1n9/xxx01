import 'chart_story_contract.dart';

final jsonRenderSafetyStoryContract = ChartStoryContract(
  section: 'Tools',
  family: 'JSON Safety',
  variant: 'Render Fallback',
  summary:
      'Interactive JSON safety story for render fallback presets, validation mode, and malformed payload previews.',
  tags: const ['json', 'diagnostics', 'fallback', 'validation', 'tools'],
  useCases: const [
    'Reviewing API-fed chart payloads before release',
    'Debugging unregistered custom chart bundles',
    'Choosing fallback verbosity for production dashboards',
  ],
  knobs: const [
    ChartStoryKnobSpec.options(
      key: 'scenario',
      label: 'Scenario',
      options: [
        'unknownType',
        'unregisteredCustomType',
        'invalidSamplingPolicy',
      ],
    ),
    ChartStoryKnobSpec.options(
      key: 'fallbackPreset',
      label: 'Fallback Preset',
      options: ['defaults', 'compact', 'quiet', 'production'],
    ),
    ChartStoryKnobSpec.boolean(
      key: 'validatePayload',
      label: 'Validate Payload',
    ),
    ChartStoryKnobSpec.boolean(
      key: 'strictValidation',
      label: 'Strict Validation',
    ),
    ChartStoryKnobSpec.boolean(
      key: 'autoNormalizePayload',
      label: 'Auto Normalize Payload',
    ),
    ChartStoryKnobSpec.boolean(
      key: 'showPayloadSource',
      label: 'Show Payload Source',
      defaultValue: true,
    ),
  ],
  sampleJson: const {
    'type': 'linee',
    'title': {'text': 'Weekly activation'},
    'series': [
      {
        'name': 'Activated',
        'data': [42, 48, 53, 61],
      },
    ],
  },
  sampleCode: '''
TenunChartFromJson(
  jsonConfig: chartPayload,
  diagnosticFallbackOptions: TenunDiagnosticFallbackOptions.defaults,
  onRenderError: (error, stackTrace) {
    // Capture or report render-time JSON failures.
  },
  onValidationResult: (result) {
    // Capture payload validation state when validation is enabled.
  },
)
''',
);

final registryHealthMatrixStoryContract = ChartStoryContract(
  section: 'Tools',
  family: 'Registry Health',
  variant: 'Matrix',
  summary:
      'Developer-facing audit matrix for chart registry readiness, sample coverage, contracts, runtime safety, and package split review.',
  tags: const ['registry', 'health', 'audit', 'contracts', 'release', 'tools'],
  useCases: const [
    'Auditing chart bundle readiness before release',
    'Finding missing sample, contract, and runtime coverage',
    'Preparing core and Pro package split handoff reports',
  ],
  knobs: registryHealthStoryKnobSpecs(),
  sampleJson: const {
    'tool': 'registryHealth',
    'preset': 'full',
    'sections': [
      'showcaseCoverage',
      'sampleDiagnostics',
      'exampleMatrix',
      'contractMatrices',
      'packageBoundary',
      'proReadiness',
    ],
    'packageSplit': {'corePackage': 'tenun', 'proPackage': 'tenun_pro'},
  },
  sampleCode: '''
final knobs = registryHealthStoryKnobs(context);

RegistryHealthExample(
  showcaseBacklogVisibleLimit: knobs.showcaseBacklogVisibleLimit,
  showcaseBacklogOptions: knobs.showcaseBacklogOptions,
  chartExampleMatrixOptions: knobs.chartExampleMatrixOptions,
  detailOptions: knobs.detailOptions,
  sectionOptions: knobs.sectionOptions,
  exportOptions: knobs.exportOptions,
)
''',
);

final registryHealthSplitReviewStoryContract = ChartStoryContract(
  section: 'Tools',
  family: 'Registry Health',
  variant: 'Split Review',
  summary:
      'Focused core/pro package split and commercial Pro readiness review for financial and enterprise chart planning.',
  tags: const [
    'registry',
    'package-split',
    'pro',
    'commercial',
    'enterprise',
    'release',
  ],
  useCases: const [
    'Reviewing core versus Pro chart package boundaries',
    'Checking commercial Pro readiness before enterprise chart rollout',
    'Planning financial, analytics, and export features for tenun_pro',
  ],
  knobs: registryHealthStoryKnobSpecs(
    healthSections: 'Split Review',
    matrixView: 'Full',
    showMatrixTable: true,
    detailDensity: 'Compact',
    exportPreset: 'Release',
    auditIssues: 4,
    splitIssues: 6,
    backlogPreview: 'Compact',
    backlogItems: 3,
  ),
  sampleJson: const {
    'tool': 'registryHealthSplitReview',
    'preset': 'release',
    'sections': ['readiness', 'packageBoundary', 'proReadiness'],
    'thresholds': {
      'auditIssueLimit': 4,
      'splitIssueLimit': 6,
      'backlogVisibleLimit': 3,
    },
    'packageSplit': {
      'corePackage': 'tenun',
      'proPackage': 'tenun_pro',
      'commercialFocus': ['financial', 'enterprise', 'advanced analytics'],
    },
  },
  sampleCode: '''
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

RegistryHealthExample(
  showcaseBacklogVisibleLimit: knobs.showcaseBacklogVisibleLimit,
  showcaseBacklogOptions: knobs.showcaseBacklogOptions,
  chartExampleMatrixOptions: knobs.chartExampleMatrixOptions,
  detailOptions: knobs.detailOptions,
  sectionOptions: knobs.sectionOptions,
  exportOptions: knobs.exportOptions,
)
''',
);

List<ChartStoryKnobSpec> registryHealthStoryKnobSpecs({
  String healthSections = 'Full',
  String matrixView = 'Full',
  bool showMatrixTable = true,
  String detailDensity = 'Full',
  String exportPreset = 'Full',
  int auditIssues = 8,
  int splitIssues = 8,
  String backlogPreview = 'Full',
  int backlogItems = 6,
}) {
  return [
    ChartStoryKnobSpec.options(
      key: 'healthSections',
      label: 'Health Sections',
      group: 'Scope',
      defaultValue: healthSections,
      options: const [
        'Full',
        'Overview',
        'Samples',
        'Contracts',
        'Split Review',
      ],
    ),
    const ChartStoryKnobSpec.boolean(
      key: 'showPackageBoundary',
      label: 'Show Package Boundary',
      group: 'Scope',
      defaultValue: true,
    ),
    const ChartStoryKnobSpec.boolean(
      key: 'showProReadiness',
      label: 'Show Pro Readiness',
      group: 'Scope',
      defaultValue: true,
    ),
    ChartStoryKnobSpec.options(
      key: 'matrixView',
      label: 'Matrix View',
      group: 'Matrix',
      defaultValue: matrixView,
      options: const ['Full', 'Compact', 'Summary', 'Actions'],
    ),
    ChartStoryKnobSpec.boolean(
      key: 'showMatrixTable',
      label: 'Show Matrix Table',
      group: 'Matrix',
      defaultValue: showMatrixTable,
    ),
    ChartStoryKnobSpec.options(
      key: 'detailDensity',
      label: 'Detail Density',
      group: 'Detail',
      defaultValue: detailDensity,
      options: const ['Full', 'Compact'],
    ),
    ChartStoryKnobSpec.options(
      key: 'exportPreset',
      label: 'Export Preset',
      group: 'Export',
      defaultValue: exportPreset,
      options: const ['Full', 'Compact', 'Release', 'Planning'],
    ),
    ChartStoryKnobSpec.sliderInt(
      key: 'auditIssues',
      label: 'Audit Issues',
      group: 'Detail',
      min: 0,
      max: 16,
      divisions: 16,
      defaultValue: auditIssues,
    ),
    ChartStoryKnobSpec.sliderInt(
      key: 'splitIssues',
      label: 'Split Issues',
      group: 'Detail',
      min: 0,
      max: 16,
      divisions: 16,
      defaultValue: splitIssues,
    ),
    ChartStoryKnobSpec.options(
      key: 'backlogPreview',
      label: 'Backlog Preview',
      group: 'Backlog',
      defaultValue: backlogPreview,
      options: const ['Full', 'Compact', 'JSON Only', 'No Source'],
    ),
    ChartStoryKnobSpec.sliderInt(
      key: 'backlogItems',
      label: 'Backlog Items',
      group: 'Backlog',
      min: 1,
      max: 12,
      divisions: 11,
      defaultValue: backlogItems,
    ),
  ];
}
