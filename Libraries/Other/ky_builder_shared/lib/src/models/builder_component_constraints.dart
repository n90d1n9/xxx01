enum BuilderComponentAnchorMode { free, start, center, end, stretch }

extension BuilderComponentAnchorModeX on BuilderComponentAnchorMode {
  String get key {
    return switch (this) {
      BuilderComponentAnchorMode.free => 'free',
      BuilderComponentAnchorMode.start => 'start',
      BuilderComponentAnchorMode.center => 'center',
      BuilderComponentAnchorMode.end => 'end',
      BuilderComponentAnchorMode.stretch => 'stretch',
    };
  }

  String get label {
    return switch (this) {
      BuilderComponentAnchorMode.free => 'Free',
      BuilderComponentAnchorMode.start => 'Start',
      BuilderComponentAnchorMode.center => 'Center',
      BuilderComponentAnchorMode.end => 'End',
      BuilderComponentAnchorMode.stretch => 'Stretch',
    };
  }

  static BuilderComponentAnchorMode fromKey(String? key) {
    return BuilderComponentAnchorMode.values.firstWhere(
      (mode) => mode.key == key || mode.name == key,
      orElse: () => BuilderComponentAnchorMode.free,
    );
  }
}

class BuilderComponentConstraints {
  final BuilderComponentAnchorMode horizontalAnchor;
  final BuilderComponentAnchorMode verticalAnchor;
  final bool maintainAspectRatio;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;

  const BuilderComponentConstraints({
    this.horizontalAnchor = BuilderComponentAnchorMode.free,
    this.verticalAnchor = BuilderComponentAnchorMode.free,
    this.maintainAspectRatio = false,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  bool get hasCustomRules {
    return horizontalAnchor != BuilderComponentAnchorMode.free ||
        verticalAnchor != BuilderComponentAnchorMode.free ||
        maintainAspectRatio ||
        minWidth != null ||
        minHeight != null ||
        maxWidth != null ||
        maxHeight != null;
  }

  BuilderComponentConstraints copyWith({
    BuilderComponentAnchorMode? horizontalAnchor,
    BuilderComponentAnchorMode? verticalAnchor,
    bool? maintainAspectRatio,
    double? minWidth,
    double? minHeight,
    double? maxWidth,
    double? maxHeight,
  }) {
    return BuilderComponentConstraints(
      horizontalAnchor: horizontalAnchor ?? this.horizontalAnchor,
      verticalAnchor: verticalAnchor ?? this.verticalAnchor,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horizontalAnchor': horizontalAnchor.key,
      'verticalAnchor': verticalAnchor.key,
      'maintainAspectRatio': maintainAspectRatio,
      'minWidth': minWidth,
      'minHeight': minHeight,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
    };
  }

  factory BuilderComponentConstraints.fromJson(Map<String, dynamic> json) {
    return BuilderComponentConstraints(
      horizontalAnchor: BuilderComponentAnchorModeX.fromKey(
        json['horizontalAnchor'] as String?,
      ),
      verticalAnchor: BuilderComponentAnchorModeX.fromKey(
        json['verticalAnchor'] as String?,
      ),
      maintainAspectRatio: json['maintainAspectRatio'] as bool? ?? false,
      minWidth: _positiveDoubleOrNull(json['minWidth']),
      minHeight: _positiveDoubleOrNull(json['minHeight']),
      maxWidth: _positiveDoubleOrNull(json['maxWidth']),
      maxHeight: _positiveDoubleOrNull(json['maxHeight']),
    );
  }

  static double? _positiveDoubleOrNull(Object? value) {
    final parsed = switch (value) {
      num() => value.toDouble(),
      String() => double.tryParse(value),
      _ => null,
    };
    if (parsed == null || parsed <= 0 || !parsed.isFinite) return null;
    return parsed;
  }
}
