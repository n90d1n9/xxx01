enum POSExperienceReleaseStage { stable, preview, experimental }

enum POSExperienceFormFactor { mobile, tablet, desktop, kiosk }

class POSExperienceManifest {
  final String productLine;
  final String archetypeKey;
  final String archetypeLabel;
  final POSExperienceReleaseStage releaseStage;
  final List<POSExperienceFormFactor> supportedFormFactors;
  final List<String> traits;
  final List<String> dataTraits;

  const POSExperienceManifest({
    this.productLine = 'Kaysir POS',
    this.archetypeKey = 'general_commerce',
    this.archetypeLabel = 'General commerce',
    this.releaseStage = POSExperienceReleaseStage.stable,
    this.supportedFormFactors = const [
      POSExperienceFormFactor.desktop,
      POSExperienceFormFactor.tablet,
      POSExperienceFormFactor.mobile,
    ],
    this.traits = const [],
    this.dataTraits = const [],
  });

  bool supportsFormFactor(POSExperienceFormFactor formFactor) {
    return supportedFormFactors.contains(formFactor);
  }

  POSExperienceManifest copyWith({
    String? productLine,
    String? archetypeKey,
    String? archetypeLabel,
    POSExperienceReleaseStage? releaseStage,
    List<POSExperienceFormFactor>? supportedFormFactors,
    List<String>? traits,
    List<String>? dataTraits,
  }) {
    return POSExperienceManifest(
      productLine: productLine ?? this.productLine,
      archetypeKey: archetypeKey ?? this.archetypeKey,
      archetypeLabel: archetypeLabel ?? this.archetypeLabel,
      releaseStage: releaseStage ?? this.releaseStage,
      supportedFormFactors: supportedFormFactors ?? this.supportedFormFactors,
      traits: traits ?? this.traits,
      dataTraits: dataTraits ?? this.dataTraits,
    );
  }
}

extension POSExperienceReleaseStageLabel on POSExperienceReleaseStage {
  String get label {
    switch (this) {
      case POSExperienceReleaseStage.stable:
        return 'Stable';
      case POSExperienceReleaseStage.preview:
        return 'Preview';
      case POSExperienceReleaseStage.experimental:
        return 'Experimental';
    }
  }
}

extension POSExperienceFormFactorLabel on POSExperienceFormFactor {
  String get label {
    switch (this) {
      case POSExperienceFormFactor.mobile:
        return 'Mobile';
      case POSExperienceFormFactor.tablet:
        return 'Tablet';
      case POSExperienceFormFactor.desktop:
        return 'Desktop';
      case POSExperienceFormFactor.kiosk:
        return 'Kiosk';
    }
  }
}
