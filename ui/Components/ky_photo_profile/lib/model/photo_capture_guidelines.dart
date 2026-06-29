class PhotoCaptureGuidelines {
  final double minFaceSize; // as percentage of frame height
  final double maxFaceSize;
  final double optimalFaceSize;
  final double maxHeadTilt;
  final bool requireEyesOpen;
  final bool requireMouthClosed;
  final bool requireNeutralExpression;
  final bool requirePlainBackground;
  final bool noGlasses;
  final bool noHat;

  const PhotoCaptureGuidelines({
    this.minFaceSize = 0.3,
    this.maxFaceSize = 0.6,
    this.optimalFaceSize = 0.45,
    this.maxHeadTilt = 15,
    this.requireEyesOpen = true,
    this.requireMouthClosed = true,
    this.requireNeutralExpression = true,
    this.requirePlainBackground = true,
    this.noGlasses = false,
    this.noHat = true,
  });

  // Indonesian KTP photo guidelines
  static const PhotoCaptureGuidelines ktpGuidelines = PhotoCaptureGuidelines(
    minFaceSize: 0.4,
    maxFaceSize: 0.6,
    optimalFaceSize: 0.5,
    maxHeadTilt: 5,
    requireEyesOpen: true,
    requireMouthClosed: true,
    requireNeutralExpression: true,
    requirePlainBackground: true,
    noGlasses: true,
    noHat: true,
  );

  // Passport photo guidelines
  static const PhotoCaptureGuidelines passportGuidelines =
      PhotoCaptureGuidelines(
        minFaceSize: 0.5,
        maxFaceSize: 0.7,
        optimalFaceSize: 0.6,
        maxHeadTilt: 5,
        requireEyesOpen: true,
        requireMouthClosed: true,
        requireNeutralExpression: true,
        requirePlainBackground: true,
        noGlasses: false, // Allowed with no glare
        noHat: true,
      );
}
