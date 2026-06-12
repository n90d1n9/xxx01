import 'pos_experience_manifest.dart';

class POSExperienceScreenFitDiagnostic {
  final double viewportWidth;
  final POSExperienceFormFactor formFactor;
  final List<POSExperienceFormFactor> supportedFormFactors;
  final bool supported;

  const POSExperienceScreenFitDiagnostic({
    required this.viewportWidth,
    required this.formFactor,
    required this.supportedFormFactors,
    required this.supported,
  });

  factory POSExperienceScreenFitDiagnostic.from({
    required double viewportWidth,
    required POSExperienceManifest manifest,
  }) {
    final formFactor = resolvePOSRuntimeFormFactor(viewportWidth);
    return POSExperienceScreenFitDiagnostic(
      viewportWidth: viewportWidth,
      formFactor: formFactor,
      supportedFormFactors: List.unmodifiable(manifest.supportedFormFactors),
      supported: manifest.supportsFormFactor(formFactor),
    );
  }

  String get statusLabel => supported ? 'Supported' : 'Unsupported';

  String get formFactorLabel => formFactor.label;

  String get message {
    if (supported) {
      return '$formFactorLabel screens are declared for this mode.';
    }

    return '$formFactorLabel screens are not declared for this mode. Supported: $supportedFormFactorLabel.';
  }

  String get supportedFormFactorLabel {
    if (supportedFormFactors.isEmpty) return 'none';
    return supportedFormFactors
        .map((formFactor) => formFactor.label)
        .join(', ');
  }
}

POSExperienceFormFactor resolvePOSRuntimeFormFactor(double viewportWidth) {
  if (viewportWidth < 720) return POSExperienceFormFactor.mobile;
  if (viewportWidth < 1120) return POSExperienceFormFactor.tablet;
  return POSExperienceFormFactor.desktop;
}
