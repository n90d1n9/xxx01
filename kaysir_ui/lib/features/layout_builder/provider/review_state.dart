import 'dart:ui';

class ResponsivePreviewState {
  final DeviceType currentDevice;
  final bool isPreviewMode;
  final bool showBreakpoints;
  final Size? customSize;

  static const ResponsivePreviewState desktop = ResponsivePreviewState(
    currentDevice: DeviceType.desktop,
  );

  static const ResponsivePreviewState tablet = ResponsivePreviewState(
    currentDevice: DeviceType.tablet,
  );

  static const ResponsivePreviewState mobile = ResponsivePreviewState(
    currentDevice: DeviceType.mobile,
  );

  const ResponsivePreviewState({
    required this.currentDevice,
    this.isPreviewMode = false,
    this.showBreakpoints = true,
    this.customSize,
  });

  factory ResponsivePreviewState.custom({
    required double width,
    required double height,
  }) {
    return ResponsivePreviewState(
      currentDevice: DeviceType.custom,
      customSize: Size(width, height),
    );
  }

  double get width {
    if (customSize != null) return customSize!.width;

    switch (currentDevice) {
      case DeviceType.mobile:
        return 390;
      case DeviceType.tablet:
        return 768;
      case DeviceType.desktop:
        return 1200;
      case DeviceType.custom:
        return 1024;
    }
  }

  double get height {
    if (customSize != null) return customSize!.height;

    switch (currentDevice) {
      case DeviceType.mobile:
        return 844;
      case DeviceType.tablet:
        return 1024;
      case DeviceType.desktop:
        return 760;
      case DeviceType.custom:
        return 720;
    }
  }

  ResponsivePreviewState copyWith({
    DeviceType? currentDevice,
    bool? isPreviewMode,
    bool? showBreakpoints,
    Size? customSize,
  }) {
    return ResponsivePreviewState(
      currentDevice: currentDevice ?? this.currentDevice,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      showBreakpoints: showBreakpoints ?? this.showBreakpoints,
      customSize: customSize ?? this.customSize,
    );
  }
}

enum DeviceType { mobile, tablet, desktop, custom }
