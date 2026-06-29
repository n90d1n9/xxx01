enum EasingType {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  easeInCubic,
  easeOutCubic,
  easeInOutCubic,
  hold;

  double apply(double t) {
    switch (this) {
      case EasingType.linear:
        return t;
      case EasingType.easeIn:
        return t * t;
      case EasingType.easeOut:
        return t * (2 - t);
      case EasingType.easeInOut:
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
      case EasingType.easeInCubic:
        return t * t * t;
      case EasingType.easeOutCubic:
        final t1 = t - 1;
        return t1 * t1 * t1 + 1;
      case EasingType.easeInOutCubic:
        return t < 0.5
            ? 4 * t * t * t
            : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1;
      case EasingType.hold:
        return 0;
    }
  }
}
