import 'registry_health_api_conformance_evidence.dart';
import 'registry_health_api_conformance_gate.dart';
import 'registry_health_api_consistency_release_brief.dart';
import 'registry_health_api_consistency_score_projection.dart';
import 'registry_health_api_consistency_source_release_gates.dart';
import 'registry_health_api_consistency_source_verification.dart';

RegistryHealthApiConsistencyReleaseBriefReport
registryHealthApiConsistencyReleaseBriefReport({
  required RegistryHealthApiConsistencyScoreProjection scoreProjection,
  required RegistryHealthApiConformanceGateReport conformanceGate,
  required RegistryHealthApiConsistencySourceReleaseGatesReport
  sourceReleaseGates,
  required RegistryHealthApiConsistencySourceVerificationReport
  sourceVerification,
  required RegistryHealthApiConformanceEvidenceReport conformanceEvidence,
}) {
  final items = <RegistryHealthApiConsistencyReleaseBriefItem>[
    _scoreRecoveryBriefItem(scoreProjection),
    _conformanceGateBriefItem(conformanceGate),
    _sourceReleaseGateBriefItem(sourceReleaseGates),
    _sourceVerificationBriefItem(sourceVerification),
    _evidenceBriefItem(conformanceEvidence),
  ];

  return RegistryHealthApiConsistencyReleaseBriefReport(
    items: List<RegistryHealthApiConsistencyReleaseBriefItem>.unmodifiable(
      items,
    ),
    currentScorePercent: scoreProjection.scorecard.scorePercent,
    projectedScorePercent: scoreProjection.projectedScorePercent,
  );
}

RegistryHealthApiConsistencyReleaseBriefItem _scoreRecoveryBriefItem(
  RegistryHealthApiConsistencyScoreProjection projection,
) {
  final status = _scoreRecoveryStatus(projection);
  final stepCount = projection.steps.length;
  final scoreLift =
      projection.projectedScorePercent - projection.scorecard.scorePercent;
  return RegistryHealthApiConsistencyReleaseBriefItem(
    kind: RegistryHealthApiConsistencyReleaseBriefKind.scoreRecovery,
    status: status,
    summaryLabel:
        'Projects API consistency score from ${projection.scorecard.scorePercent}% to ${projection.projectedScorePercent}%.',
    detailLabel: projection.statusLabel,
    metrics: List<String>.unmodifiable([
      _releaseBriefCount(stepCount, 'phase', 'phases'),
      '${_releaseBriefSignedNumber(scoreLift)} pts',
    ]),
  );
}

RegistryHealthApiConsistencyReleaseBriefItem _conformanceGateBriefItem(
  RegistryHealthApiConformanceGateReport report,
) {
  final topGate = report.topGate;
  return RegistryHealthApiConsistencyReleaseBriefItem(
    kind: RegistryHealthApiConsistencyReleaseBriefKind.conformanceGates,
    status: report.status,
    summaryLabel:
        '${_releaseBriefCount(report.gateCount, 'conformance gate', 'conformance gates')}, '
        '${_releaseBriefCount(report.requiredCheckCount, 'required check', 'required checks')}.',
    detailLabel: topGate == null
        ? 'No conformance gate attention.'
        : '${topGate.gateLabel}: ${topGate.summaryLabel}',
    metrics: List<String>.unmodifiable([
      _releaseBriefCount(report.gateCount, 'gate', 'gates'),
      _releaseBriefCount(report.requiredCheckCount, 'check', 'checks'),
    ]),
  );
}

RegistryHealthApiConsistencyReleaseBriefItem _sourceReleaseGateBriefItem(
  RegistryHealthApiConsistencySourceReleaseGatesReport report,
) {
  final topGate = report.topGate;
  return RegistryHealthApiConsistencyReleaseBriefItem(
    kind: RegistryHealthApiConsistencyReleaseBriefKind.sourceReleaseGates,
    status: _sourceReleaseGateStatus(report),
    summaryLabel:
        '${_releaseBriefCount(report.gateCount, 'source release gate', 'source release gates')}, '
        '${_releaseBriefCount(report.requiredCheckCount, 'required check', 'required checks')}.',
    detailLabel: topGate == null
        ? 'No source release gate attention.'
        : '${topGate.gateLabel}: ${topGate.validationLabel}',
    metrics: List<String>.unmodifiable([
      _releaseBriefCount(report.gateCount, 'gate', 'gates'),
      _releaseBriefCount(report.requiredCheckCount, 'check', 'checks'),
    ]),
  );
}

RegistryHealthApiConsistencyReleaseBriefItem _sourceVerificationBriefItem(
  RegistryHealthApiConsistencySourceVerificationReport report,
) {
  final topVerification = report.topVerification;
  return RegistryHealthApiConsistencyReleaseBriefItem(
    kind: RegistryHealthApiConsistencyReleaseBriefKind.sourceVerification,
    status: _sourceVerificationStatus(report),
    summaryLabel:
        '${_releaseBriefCount(report.verificationCount, 'source verification', 'source verifications')} '
        'cover ${_releaseBriefCount(report.gateCoverageCount, 'gate link', 'gate links')}.',
    detailLabel: topVerification == null
        ? 'No source verification attention.'
        : '${topVerification.kindLabel}: ${topVerification.checkLabel}',
    metrics: List<String>.unmodifiable([
      _releaseBriefCount(report.verificationCount, 'check', 'checks'),
      _releaseBriefCount(report.gateCoverageCount, 'gate link', 'gate links'),
    ]),
  );
}

RegistryHealthApiConsistencyReleaseBriefItem _evidenceBriefItem(
  RegistryHealthApiConformanceEvidenceReport report,
) {
  final topEvidence = report.topEvidence;
  return RegistryHealthApiConsistencyReleaseBriefItem(
    kind: RegistryHealthApiConsistencyReleaseBriefKind.evidenceHandoff,
    status: _evidenceStatus(report),
    summaryLabel:
        '${_releaseBriefCount(report.evidenceCount, 'evidence group', 'evidence groups')} '
        'cover ${_releaseBriefCount(report.stepCount, 'step', 'steps')}.',
    detailLabel: topEvidence == null
        ? 'No evidence handoff attention.'
        : '${topEvidence.evidenceLabel}: ${topEvidence.summaryLabel}',
    metrics: List<String>.unmodifiable([
      _releaseBriefCount(report.evidenceCount, 'group', 'groups'),
      _releaseBriefCount(report.stepCount, 'step', 'steps'),
    ]),
  );
}

RegistryHealthApiConformanceGateStatus _scoreRecoveryStatus(
  RegistryHealthApiConsistencyScoreProjection projection,
) {
  if (projection.projectedRequiredGapCount > 0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  if (projection.projectedAdvisoryGapCount > 0 ||
      projection.projectedScorePercent < 95) {
    return RegistryHealthApiConformanceGateStatus.review;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

RegistryHealthApiConformanceGateStatus _sourceReleaseGateStatus(
  RegistryHealthApiConsistencySourceReleaseGatesReport report,
) {
  if (report.blockedGateCount > 0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  if (report.reviewGateCount > 0) {
    return RegistryHealthApiConformanceGateStatus.review;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

RegistryHealthApiConformanceGateStatus _sourceVerificationStatus(
  RegistryHealthApiConsistencySourceVerificationReport report,
) {
  if (report.blockedVerificationCount > 0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  if (report.reviewVerificationCount > 0) {
    return RegistryHealthApiConformanceGateStatus.review;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

RegistryHealthApiConformanceGateStatus _evidenceStatus(
  RegistryHealthApiConformanceEvidenceReport report,
) {
  if (report.blockedEvidenceCount > 0) {
    return RegistryHealthApiConformanceGateStatus.blocked;
  }
  if (report.reviewEvidenceCount > 0) {
    return RegistryHealthApiConformanceGateStatus.review;
  }
  return RegistryHealthApiConformanceGateStatus.ready;
}

String _releaseBriefCount(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';

String _releaseBriefSignedNumber(int value) {
  if (value == 0) return '0';
  return value > 0 ? '+$value' : '$value';
}
