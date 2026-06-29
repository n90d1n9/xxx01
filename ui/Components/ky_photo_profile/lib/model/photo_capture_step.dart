enum PhotoCaptureStep { instructions, positioning, capturing, review, complete }

enum PhotoQualityIssue {
  tooDark,
  tooBright,
  blurry,
  glassesGlare,
  faceNotCentered,
  faceTooSmall,
  faceTooLarge,
  eyesClosed,
  mouthOpen,
  headTilted,
  backgroundClutter,
}

enum PhotoComplianceStatus { compliant, nonCompliant, warning }
