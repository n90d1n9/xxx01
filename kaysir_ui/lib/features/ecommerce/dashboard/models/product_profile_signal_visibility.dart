class ProductProfileSignalVisibility {
  final bool businessMotion;
  final bool launchComplexity;
  final bool footprint;

  const ProductProfileSignalVisibility({
    this.businessMotion = false,
    this.launchComplexity = false,
    this.footprint = false,
  });

  static const none = ProductProfileSignalVisibility();

  static const compact = ProductProfileSignalVisibility(businessMotion: true);

  static const decision = ProductProfileSignalVisibility(
    businessMotion: true,
    launchComplexity: true,
  );

  static const detailed = ProductProfileSignalVisibility(
    businessMotion: true,
    launchComplexity: true,
    footprint: true,
  );

  bool get hasDecisionSignals => businessMotion || launchComplexity;

  bool get hasFootprint => footprint;

  bool get hasAny => hasDecisionSignals || hasFootprint;

  ProductProfileSignalVisibility copyWith({
    bool? businessMotion,
    bool? launchComplexity,
    bool? footprint,
  }) {
    return ProductProfileSignalVisibility(
      businessMotion: businessMotion ?? this.businessMotion,
      launchComplexity: launchComplexity ?? this.launchComplexity,
      footprint: footprint ?? this.footprint,
    );
  }
}
