import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component.dart';
import '../provider/review_state.dart';
import 'component_renderer.dart';

class ResponsiveComponentWrapper extends ConsumerWidget {
  final ComponentData component;
  final DeviceType previewMode;

  const ResponsiveComponentWrapper({
    super.key,
    required this.component,
    required this.previewMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsiveProperties =
        component.responsiveProperties[previewMode.name];

    if (responsiveProperties?.isVisible == false || !component.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: responsiveProperties?.position?.dx ?? component.position.dx,
      top: responsiveProperties?.position?.dy ?? component.position.dy,
      child: SizedBox(
        width: responsiveProperties?.size?.width ?? component.size.width,
        height: responsiveProperties?.size?.height ?? component.size.height,
        child: ComponentRenderer(component: component, isPreview: true),
      ),
    );
  }
}
