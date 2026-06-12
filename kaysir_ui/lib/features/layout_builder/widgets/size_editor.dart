import 'package:flutter/material.dart';

import 'number_field.dart';

class SizeEditor extends StatelessWidget {
  static const _stackedBreakpoint = 260.0;

  final Size size;
  final Size minSize;
  final double step;
  final ValueChanged<Size> onSizeChanged;

  const SizeEditor({
    super.key,
    required this.size,
    this.minSize = const Size(1, 1),
    this.step = 1,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < _stackedBreakpoint;

        if (shouldStack) {
          return Column(
            children: [
              _widthField(),
              const SizedBox(height: 8),
              _heightField(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _widthField()),
            const SizedBox(width: 8),
            Expanded(child: _heightField()),
          ],
        );
      },
    );
  }

  Widget _widthField() {
    return NumberField(
      label: 'Width',
      value: size.width,
      min: minSize.width,
      step: step,
      onChanged: (value) {
        onSizeChanged(Size(value, size.height));
      },
    );
  }

  Widget _heightField() {
    return NumberField(
      label: 'Height',
      value: size.height,
      min: minSize.height,
      step: step,
      onChanged: (value) {
        onSizeChanged(Size(size.width, value));
      },
    );
  }
}
