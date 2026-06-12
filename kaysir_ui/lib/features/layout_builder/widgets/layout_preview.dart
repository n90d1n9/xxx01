import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../provider/responsive_preview_provider.dart';
import '../provider/review_state.dart';
import 'layout_content.dart';

class LayoutPreview extends ConsumerWidget {
  const LayoutPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewState = ref.watch(responsivePreviewProvider);

    return Stack(
      children: [
        Center(
          child: DeviceFrame(
            mode: previewState.currentDevice,
            customSize: previewState.customSize,
          ),
        ),
        if (previewState.showBreakpoints) const BreakpointIndicators(),
      ],
    );
  }
}

class DeviceFrame extends StatelessWidget {
  final DeviceType mode;
  final Size? customSize;

  const DeviceFrame({super.key, required this.mode, this.customSize});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _getDeviceSize(mode, constraints);
        final radius = mode == DeviceType.mobile ? 24.0 : 10.0;

        return Container(
          width: size.width,
          height: size.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: const LayoutContent(),
        );
      },
    );
  }

  Size _getDeviceSize(DeviceType mode, BoxConstraints constraints) {
    final available = Size(
      constraints.maxWidth.isFinite ? constraints.maxWidth : 1200,
      constraints.maxHeight.isFinite ? constraints.maxHeight : 760,
    );

    switch (mode) {
      case DeviceType.mobile:
        return Size(390, available.height).clampTo(available);
      case DeviceType.tablet:
        return Size(768, available.height).clampTo(available);
      case DeviceType.desktop:
        return available;
      case DeviceType.custom:
        return (customSize ?? available).clampTo(available);
    }
  }
}

class BreakpointIndicators extends StatelessWidget {
  const BreakpointIndicators({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          _buildBreakpointLine(width: 390, label: 'Mobile', color: Colors.blue),
          _buildBreakpointLine(
            width: 768,
            label: 'Tablet',
            color: Colors.green,
          ),
          _buildBreakpointLine(
            width: 1024,
            label: 'Desktop',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakpointLine({
    required double width,
    required String label,
    required Color color,
  }) {
    return Positioned(
      left: width,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color.withValues(alpha: 0.45)),
          child: Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(label, style: TextStyle(color: color)),
            ),
          ),
        ),
      ),
    );
  }
}

extension on Size {
  Size clampTo(Size maxSize) {
    return Size(
      width.clamp(0, maxSize.width).toDouble(),
      height.clamp(0, maxSize.height).toDouble(),
    );
  }
}
