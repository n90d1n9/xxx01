class RegistryHealthApiConsistencyPanelOptions {
  const RegistryHealthApiConsistencyPanelOptions({
    this.rowLimit = 8,
    this.actionLimit = 6,
    this.concernLimit = 6,
    this.familyLimit = 4,
    this.primitiveLimit = 5,
    this.fieldLimit = 6,
    this.traceLimit = 8,
    this.sourceQueueLimit = 8,
    this.sourcePlanLimit = 6,
    this.sourceChecklistLimit = 6,
    this.sourceMilestoneLimit = 4,
    this.sourceReleaseGateLimit = 4,
    this.sourceVerificationLimit = 6,
    this.conformanceCaseLimit = 8,
    this.conformanceGateLimit = 4,
    this.conformanceVerificationLimit = 6,
    this.conformanceChecklistLimit = 6,
    this.conformanceEvidenceLimit = 6,
    this.releaseBriefLimit = 5,
    this.showScorecard = true,
    this.showScoreProjection = true,
    this.showReleaseBrief = true,
    this.showConformance = true,
    this.showConformanceGate = true,
    this.showConformanceVerification = true,
    this.showConformanceChecklist = true,
    this.showConformanceEvidence = true,
    this.showImplementationPlan = true,
    this.showTraceability = true,
    this.showSourceQueue = true,
    this.showSourcePlan = true,
    this.showSourceChecklist = true,
    this.showSourceMilestones = true,
    this.showSourceReleaseGates = true,
    this.showSourceVerification = true,
    this.showFamilyRemediation = true,
    this.showPrimitiveRemediation = true,
    this.showFieldRemediation = true,
    this.showConcernSummary = true,
    this.showAttentionTable = true,
    this.showActionPlan = true,
  }) : assert(rowLimit >= 0),
       assert(actionLimit >= 0),
       assert(concernLimit >= 0),
       assert(familyLimit >= 0),
       assert(primitiveLimit >= 0),
       assert(fieldLimit >= 0),
       assert(traceLimit >= 0),
       assert(sourceQueueLimit >= 0),
       assert(sourcePlanLimit >= 0),
       assert(sourceChecklistLimit >= 0),
       assert(sourceMilestoneLimit >= 0),
       assert(sourceReleaseGateLimit >= 0),
       assert(sourceVerificationLimit >= 0),
       assert(conformanceCaseLimit >= 0),
       assert(conformanceGateLimit >= 0),
       assert(conformanceVerificationLimit >= 0),
       assert(conformanceChecklistLimit >= 0),
       assert(conformanceEvidenceLimit >= 0),
       assert(releaseBriefLimit >= 0);

  static const compact = RegistryHealthApiConsistencyPanelOptions(
    rowLimit: 4,
    actionLimit: 3,
    concernLimit: 3,
    familyLimit: 3,
    primitiveLimit: 3,
    fieldLimit: 4,
    traceLimit: 4,
    sourceQueueLimit: 4,
    sourcePlanLimit: 3,
    sourceChecklistLimit: 3,
    sourceMilestoneLimit: 3,
    sourceReleaseGateLimit: 3,
    sourceVerificationLimit: 4,
    conformanceCaseLimit: 4,
    conformanceGateLimit: 3,
    conformanceVerificationLimit: 4,
    conformanceChecklistLimit: 3,
    conformanceEvidenceLimit: 3,
    releaseBriefLimit: 4,
    showConformance: false,
    showTraceability: false,
    showSourceQueue: false,
    showSourcePlan: false,
    showSourceChecklist: false,
    showSourceMilestones: false,
    showFamilyRemediation: false,
    showPrimitiveRemediation: false,
    showFieldRemediation: false,
    showAttentionTable: false,
  );

  static const release = RegistryHealthApiConsistencyPanelOptions(
    rowLimit: 0,
    actionLimit: 5,
    concernLimit: 0,
    sourceReleaseGateLimit: 4,
    sourceVerificationLimit: 5,
    conformanceGateLimit: 4,
    conformanceVerificationLimit: 5,
    conformanceEvidenceLimit: 5,
    releaseBriefLimit: 5,
    showConformance: false,
    showConformanceChecklist: false,
    showImplementationPlan: false,
    showTraceability: false,
    showSourceQueue: false,
    showSourcePlan: false,
    showSourceChecklist: false,
    showSourceMilestones: false,
    showFamilyRemediation: false,
    showPrimitiveRemediation: false,
    showFieldRemediation: false,
    showConcernSummary: false,
    showAttentionTable: false,
  );

  static const planning = RegistryHealthApiConsistencyPanelOptions(
    rowLimit: 8,
    actionLimit: 8,
    concernLimit: 8,
    familyLimit: 6,
    primitiveLimit: 6,
    fieldLimit: 8,
    traceLimit: 10,
    sourceQueueLimit: 10,
    sourcePlanLimit: 8,
    sourceChecklistLimit: 8,
    sourceMilestoneLimit: 5,
    showReleaseBrief: false,
    showConformance: false,
    showConformanceGate: false,
    showConformanceVerification: false,
    showConformanceChecklist: false,
    showConformanceEvidence: false,
  );

  final int rowLimit;
  final int actionLimit;
  final int concernLimit;
  final int familyLimit;
  final int primitiveLimit;
  final int fieldLimit;
  final int traceLimit;
  final int sourceQueueLimit;
  final int sourcePlanLimit;
  final int sourceChecklistLimit;
  final int sourceMilestoneLimit;
  final int sourceReleaseGateLimit;
  final int sourceVerificationLimit;
  final int conformanceCaseLimit;
  final int conformanceGateLimit;
  final int conformanceVerificationLimit;
  final int conformanceChecklistLimit;
  final int conformanceEvidenceLimit;
  final int releaseBriefLimit;
  final bool showScorecard;
  final bool showScoreProjection;
  final bool showReleaseBrief;
  final bool showConformance;
  final bool showConformanceGate;
  final bool showConformanceVerification;
  final bool showConformanceChecklist;
  final bool showConformanceEvidence;
  final bool showImplementationPlan;
  final bool showTraceability;
  final bool showSourceQueue;
  final bool showSourcePlan;
  final bool showSourceChecklist;
  final bool showSourceMilestones;
  final bool showSourceReleaseGates;
  final bool showSourceVerification;
  final bool showFamilyRemediation;
  final bool showPrimitiveRemediation;
  final bool showFieldRemediation;
  final bool showConcernSummary;
  final bool showAttentionTable;
  final bool showActionPlan;

  RegistryHealthApiConsistencyPanelOptions copyWith({
    int? rowLimit,
    int? actionLimit,
    int? concernLimit,
    int? familyLimit,
    int? primitiveLimit,
    int? fieldLimit,
    int? traceLimit,
    int? sourceQueueLimit,
    int? sourcePlanLimit,
    int? sourceChecklistLimit,
    int? sourceMilestoneLimit,
    int? sourceReleaseGateLimit,
    int? sourceVerificationLimit,
    int? conformanceCaseLimit,
    int? conformanceGateLimit,
    int? conformanceVerificationLimit,
    int? conformanceChecklistLimit,
    int? conformanceEvidenceLimit,
    int? releaseBriefLimit,
    bool? showScorecard,
    bool? showScoreProjection,
    bool? showReleaseBrief,
    bool? showConformance,
    bool? showConformanceGate,
    bool? showConformanceVerification,
    bool? showConformanceChecklist,
    bool? showConformanceEvidence,
    bool? showImplementationPlan,
    bool? showTraceability,
    bool? showSourceQueue,
    bool? showSourcePlan,
    bool? showSourceChecklist,
    bool? showSourceMilestones,
    bool? showSourceReleaseGates,
    bool? showSourceVerification,
    bool? showFamilyRemediation,
    bool? showPrimitiveRemediation,
    bool? showFieldRemediation,
    bool? showConcernSummary,
    bool? showAttentionTable,
    bool? showActionPlan,
  }) {
    return RegistryHealthApiConsistencyPanelOptions(
      rowLimit: rowLimit ?? this.rowLimit,
      actionLimit: actionLimit ?? this.actionLimit,
      concernLimit: concernLimit ?? this.concernLimit,
      familyLimit: familyLimit ?? this.familyLimit,
      primitiveLimit: primitiveLimit ?? this.primitiveLimit,
      fieldLimit: fieldLimit ?? this.fieldLimit,
      traceLimit: traceLimit ?? this.traceLimit,
      sourceQueueLimit: sourceQueueLimit ?? this.sourceQueueLimit,
      sourcePlanLimit: sourcePlanLimit ?? this.sourcePlanLimit,
      sourceChecklistLimit: sourceChecklistLimit ?? this.sourceChecklistLimit,
      sourceMilestoneLimit: sourceMilestoneLimit ?? this.sourceMilestoneLimit,
      sourceReleaseGateLimit:
          sourceReleaseGateLimit ?? this.sourceReleaseGateLimit,
      sourceVerificationLimit:
          sourceVerificationLimit ?? this.sourceVerificationLimit,
      conformanceCaseLimit: conformanceCaseLimit ?? this.conformanceCaseLimit,
      conformanceGateLimit: conformanceGateLimit ?? this.conformanceGateLimit,
      conformanceVerificationLimit:
          conformanceVerificationLimit ?? this.conformanceVerificationLimit,
      conformanceChecklistLimit:
          conformanceChecklistLimit ?? this.conformanceChecklistLimit,
      conformanceEvidenceLimit:
          conformanceEvidenceLimit ?? this.conformanceEvidenceLimit,
      releaseBriefLimit: releaseBriefLimit ?? this.releaseBriefLimit,
      showScorecard: showScorecard ?? this.showScorecard,
      showScoreProjection: showScoreProjection ?? this.showScoreProjection,
      showReleaseBrief: showReleaseBrief ?? this.showReleaseBrief,
      showConformance: showConformance ?? this.showConformance,
      showConformanceGate: showConformanceGate ?? this.showConformanceGate,
      showConformanceVerification:
          showConformanceVerification ?? this.showConformanceVerification,
      showConformanceChecklist:
          showConformanceChecklist ?? this.showConformanceChecklist,
      showConformanceEvidence:
          showConformanceEvidence ?? this.showConformanceEvidence,
      showImplementationPlan:
          showImplementationPlan ?? this.showImplementationPlan,
      showTraceability: showTraceability ?? this.showTraceability,
      showSourceQueue: showSourceQueue ?? this.showSourceQueue,
      showSourcePlan: showSourcePlan ?? this.showSourcePlan,
      showSourceChecklist: showSourceChecklist ?? this.showSourceChecklist,
      showSourceMilestones: showSourceMilestones ?? this.showSourceMilestones,
      showSourceReleaseGates:
          showSourceReleaseGates ?? this.showSourceReleaseGates,
      showSourceVerification:
          showSourceVerification ?? this.showSourceVerification,
      showFamilyRemediation:
          showFamilyRemediation ?? this.showFamilyRemediation,
      showPrimitiveRemediation:
          showPrimitiveRemediation ?? this.showPrimitiveRemediation,
      showFieldRemediation: showFieldRemediation ?? this.showFieldRemediation,
      showConcernSummary: showConcernSummary ?? this.showConcernSummary,
      showAttentionTable: showAttentionTable ?? this.showAttentionTable,
      showActionPlan: showActionPlan ?? this.showActionPlan,
    );
  }
}
