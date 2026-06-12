import 'package:tenun/tenun_core.dart';

Map<String, dynamic> buildPayloadNormalizationDiagnostics({
  required String targetType,
  required bool autoNormalizePayload,
  required bool strictValidation,
  required bool dropUnsupportedSampling,
  required bool sanitizeTradingPayload,
  required int normalizeDefaultThreshold,
  required String normalizeDefaultMode,
  required String effectivePayloadSource,
  required ValidationResult rawValidation,
  required ValidationResult normalizedValidation,
  required ValidationResult effectiveValidation,
  required PayloadNormalizationResult normalizationReport,
  required ChartPayloadDoctorReport rawDoctor,
  required ChartPayloadDoctorReport normalizedDoctor,
  required ChartPayloadDoctorReport effectiveDoctor,
}) {
  return {
    'targetType': targetType,
    'effectivePayloadSource': effectivePayloadSource,
    'options': {
      'autoNormalizePayload': autoNormalizePayload,
      'strictValidation': strictValidation,
      'dropUnsupportedSampling': dropUnsupportedSampling,
      'sanitizeTradingPayload': sanitizeTradingPayload,
      'normalizeDefaultThreshold': normalizeDefaultThreshold,
      'normalizeDefaultMode': normalizeDefaultMode,
    },
    'validation': {
      'raw': rawValidation.toJson(),
      'normalized': normalizedValidation.toJson(),
      'effective': effectiveValidation.toJson(),
    },
    'doctor': {
      'raw': rawDoctor.toJson(),
      'normalized': normalizedDoctor.toJson(),
      'effective': effectiveDoctor.toJson(),
    },
    'normalization': normalizationReport.toJson(),
  };
}
