import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';

class SurveyEvidenceCaptureRequest {
  final SurveyEvidenceRequirement requirement;
  final String? collectorId;
  final String? collectorName;
  final String captureSource;
  final Map<String, dynamic> metadata;

  const SurveyEvidenceCaptureRequest({
    required this.requirement,
    this.collectorId,
    this.collectorName,
    this.captureSource = 'device_adapter',
    this.metadata = const {},
  });

  SurveyEvidenceCaptureRequest copyWith({
    SurveyEvidenceRequirement? requirement,
    String? collectorId,
    String? collectorName,
    String? captureSource,
    Map<String, dynamic>? metadata,
  }) {
    return SurveyEvidenceCaptureRequest(
      requirement: requirement ?? this.requirement,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      captureSource: captureSource ?? this.captureSource,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> get evidenceMetadata {
    return {...metadata, 'captureSource': captureSource};
  }
}

abstract class SurveyEvidenceCaptureAdapter {
  const SurveyEvidenceCaptureAdapter();

  String get id;

  String get label;

  bool supports(SurveyEvidenceRequirement requirement);

  Future<SurveyEvidence?> capture(SurveyEvidenceCaptureRequest request);
}

class SurveyEvidenceCaptureRegistry {
  final List<SurveyEvidenceCaptureAdapter> adapters;

  const SurveyEvidenceCaptureRegistry({this.adapters = const []});

  bool get hasAdapters => adapters.isNotEmpty;

  SurveyEvidenceCaptureAdapter? adapterFor(
    SurveyEvidenceRequirement requirement,
  ) {
    for (final adapter in adapters) {
      if (adapter.supports(requirement)) {
        return adapter;
      }
    }

    return null;
  }

  Future<SurveyEvidence?> capture(SurveyEvidenceCaptureRequest request) {
    final adapter = adapterFor(request.requirement);
    if (adapter == null) {
      return Future.value();
    }

    return adapter.capture(request);
  }
}

class SurveyEvidenceKindCaptureAdapter extends SurveyEvidenceCaptureAdapter {
  final SurveyEvidenceKind kind;
  final Future<SurveyEvidence?> Function(SurveyEvidenceCaptureRequest request)
  onCapture;
  @override
  final String id;
  @override
  final String label;

  const SurveyEvidenceKindCaptureAdapter({
    required this.kind,
    required this.onCapture,
    required this.id,
    required this.label,
  });

  @override
  bool supports(SurveyEvidenceRequirement requirement) {
    return requirement.kind == kind;
  }

  @override
  Future<SurveyEvidence?> capture(SurveyEvidenceCaptureRequest request) {
    return onCapture(request);
  }
}
