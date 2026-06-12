import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'review_state.dart';

final responsivePreviewProvider =
    StateNotifierProvider<ResponsivePreviewNotifier, ResponsivePreviewState>((
      ref,
    ) {
      return ResponsivePreviewNotifier();
    });

const _previewDeviceCycle = [
  DeviceType.desktop,
  DeviceType.tablet,
  DeviceType.mobile,
];

class ResponsivePreviewNotifier extends StateNotifier<ResponsivePreviewState> {
  ResponsivePreviewNotifier() : super(ResponsivePreviewState.desktop);

  void setDevice(DeviceType device) {
    state = ResponsivePreviewState(
      currentDevice: device,
      isPreviewMode: state.isPreviewMode,
      showBreakpoints: state.showBreakpoints,
      customSize: device == DeviceType.custom ? state.customSize : null,
    );
  }

  void setPreviewMode(ResponsivePreviewState mode) {
    state = mode;
  }

  void togglePreviewMode() {
    state = state.copyWith(isPreviewMode: !state.isPreviewMode);
  }

  void toggleBreakpoints() {
    state = state.copyWith(showBreakpoints: !state.showBreakpoints);
  }

  void cycleDevice({bool reverse = false}) {
    final currentIndex = _previewDeviceCycle.indexOf(state.currentDevice);
    if (currentIndex == -1) {
      setDevice(reverse ? _previewDeviceCycle.last : _previewDeviceCycle.first);
      return;
    }

    final offset = reverse ? -1 : 1;
    final nextIndex =
        (currentIndex + offset + _previewDeviceCycle.length) %
        _previewDeviceCycle.length;
    setDevice(_previewDeviceCycle[nextIndex]);
  }

  void setCustomBreakpoint(double width, double height) {
    state = state.copyWith(
      currentDevice: DeviceType.custom,
      customSize: Size(width, height),
    );
  }

  void rotateCustomSize() {
    rotateCurrentSize();
  }

  void rotateCurrentSize() {
    final size = Size(state.width, state.height);
    state = state.copyWith(
      currentDevice: DeviceType.custom,
      customSize: Size(size.height, size.width),
    );
  }
}
