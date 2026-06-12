import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/component.dart';
import '../provider/layout_data_binding_provider.dart';

class ComponentRenderer extends ConsumerWidget {
  final ComponentData component;
  final bool isPreview;

  const ComponentRenderer({
    super.key,
    required this.component,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!component.isVisible) return const SizedBox.shrink();
    final bindings = ref
        .watch(layoutDataBindingProvider)
        .maybeWhen(data: (values) => values, orElse: () => null);

    return Container(
      width: component.size.width,
      height: component.size.height,
      decoration: BoxDecoration(
        color: component.style.backgroundColor,
        borderRadius: component.style.borderRadius,
        border: component.style.border,
        boxShadow: component.style.shadows,
      ),
      padding: component.style.padding,
      child: _buildComponentContent(context, bindings),
    );
  }

  Widget _buildComponentContent(
    BuildContext context,
    LayoutDataBindingValues? bindings,
  ) {
    switch (component.type) {
      case ComponentType.buttonGrid:
        return _ProductButtonGrid(
          component: component,
          isPreview: isPreview,
          bindings: bindings,
        );
      case ComponentType.cartPanel:
        return _CartPanel(component: component, bindings: bindings);
      case ComponentType.numpad:
        return _Numpad(component: component);
      case ComponentType.functionPanel:
        return _FunctionPanel(component: component);
      case ComponentType.customButton:
        return _CustomButton(component: component, bindings: bindings);
      case ComponentType.textLabel:
        return _TextLabel(component: component, bindings: bindings);
      case ComponentType.imageHolder:
        return _ImageHolder(component: component, bindings: bindings);
      case ComponentType.separator:
        return _Separator(component: component, bindings: bindings);
    }
  }
}

class _ProductButtonGrid extends StatelessWidget {
  final ComponentData component;
  final bool isPreview;
  final LayoutDataBindingValues? bindings;

  const _ProductButtonGrid({
    required this.component,
    required this.isPreview,
    required this.bindings,
  });

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final columns = _intAttribute(
      attributes['columns'],
      fallback: 4,
      min: 2,
      max: 6,
    );
    final showPrice = _boolAttribute(attributes['showPrice'], fallback: true);
    final maxProducts = _intAttribute(
      attributes['maxProducts'],
      fallback: 0,
      min: 0,
      max: 48,
    );
    final allProducts =
        bindings?.products ?? LayoutDataBindingValues.fallback().products;
    final products =
        maxProducts <= 0 ? allProducts : allProducts.take(maxProducts).toList();

    return GridView.builder(
      physics:
          isPreview
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: showPrice ? 1.15 : 1.35,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return FilledButton.tonal(
          onPressed: isPreview ? null : () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (showPrice && product.price.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.price,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CartPanel extends StatelessWidget {
  final ComponentData component;
  final LayoutDataBindingValues? bindings;

  const _CartPanel({required this.component, required this.bindings});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final title = _stringAttribute(attributes['title'], fallback: 'Cart');
    final showTitle = _boolAttribute(attributes['showTitle'], fallback: true);
    final showSubtotal = _boolAttribute(
      attributes['showSubtotal'],
      fallback: true,
    );
    final showTax = _boolAttribute(attributes['showTax'], fallback: true);
    final compact = _boolAttribute(attributes['compact'], fallback: false);
    final cartItems =
        bindings?.cartItems ?? LayoutDataBindingValues.fallback().cartItems;
    final subtotal =
        bindings?.cartSubtotal ??
        LayoutDataBindingValues.fallback().cartSubtotal;
    final tax = bindings?.cartTax ?? LayoutDataBindingValues.fallback().cartTax;
    final total =
        bindings?.cartTotal ?? LayoutDataBindingValues.fallback().cartTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Divider(),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            compact
                                ? Theme.of(context).textTheme.bodySmall
                                : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.total,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          compact
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(),
        if (showSubtotal && subtotal.isNotEmpty)
          _CartSummaryRow(label: 'Subtotal', value: subtotal),
        if (showTax && tax.isNotEmpty)
          _CartSummaryRow(label: 'Tax', value: tax),
        Text(
          'Total: $total',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _CartSummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final ComponentData component;

  const _Numpad({required this.component});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final showDisplay = _boolAttribute(
      attributes['showDisplay'],
      fallback: true,
    );
    final displayValue = _stringAttribute(
      attributes['displayValue'],
      fallback: '0',
    );
    final showDecimal = _boolAttribute(
      attributes['showDecimal'],
      fallback: true,
    );
    final clearLabel = _stringAttribute(
      attributes['clearLabel'],
      fallback: 'C',
    );
    final buttonStyle = _buttonStyleAttribute(attributes['buttonStyle']);
    final labels = [
      '7',
      '8',
      '9',
      '4',
      '5',
      '6',
      '1',
      '2',
      '3',
      showDecimal ? '.' : '00',
      '0',
      clearLabel,
    ];

    return Column(
      children: [
        if (showDisplay) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: labels.length,
            itemBuilder: (context, index) {
              final label = labels[index];
              final isClear = label == clearLabel;

              return _ControlButton(
                label: label,
                style: buttonStyle,
                tone: isClear ? _ControlButtonTone.warning : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FunctionPanel extends StatelessWidget {
  final ComponentData component;

  const _FunctionPanel({required this.component});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final actions = _stringListAttribute(
      attributes['actions'],
      fallback: const ['Pay', 'Void', 'Discount', 'Print'],
    );
    final columns = _intAttribute(
      attributes['columns'],
      fallback: 1,
      min: 1,
      max: 2,
    );
    final buttonStyle = _buttonStyleAttribute(attributes['buttonStyle']);
    final compact = _boolAttribute(attributes['compact'], fallback: false);

    if (actions.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: compact ? 6 : 8,
        crossAxisSpacing: compact ? 6 : 8,
        childAspectRatio: columns == 1 ? (compact ? 5.2 : 4.3) : 2.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final label = actions[index];

        return _ControlButton(
          label: label,
          style: buttonStyle,
          tone: _actionTone(label),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final _ControlButtonStyle style;
  final _ControlButtonTone? tone;

  const _ControlButton({required this.label, required this.style, this.tone});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground =
        tone == _ControlButtonTone.warning ? colorScheme.error : null;
    final child = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    switch (style) {
      case _ControlButtonStyle.filled:
        return FilledButton(
          onPressed: () {},
          style:
              foreground == null
                  ? null
                  : FilledButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
          child: child,
        );
      case _ControlButtonStyle.tonal:
        return FilledButton.tonal(
          onPressed: () {},
          style:
              foreground == null
                  ? null
                  : FilledButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
          child: child,
        );
      case _ControlButtonStyle.outlined:
        return OutlinedButton(
          onPressed: () {},
          style:
              foreground == null
                  ? null
                  : OutlinedButton.styleFrom(foregroundColor: foreground),
          child: child,
        );
    }
  }
}

enum _ControlButtonStyle { outlined, tonal, filled }

enum _ControlButtonTone { warning }

class _CustomButton extends StatelessWidget {
  final ComponentData component;
  final LayoutDataBindingValues? bindings;

  const _CustomButton({required this.component, required this.bindings});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final label = _boundAttribute(
      attributes['label'],
      bindings,
      fallback: 'Action',
    );
    final textAlign = _textAlignAttribute(
      attributes['textAlign'],
      fallback: TextAlign.center,
    );
    final textColor = _colorAttribute(attributes['textColor']);
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: textColor,
      fontSize: _doubleAttribute(
        attributes['fontSize'],
        fallback: 14,
        min: 8,
        max: 48,
      ),
      fontWeight: _fontWeightAttribute(
        attributes['fontWeight'],
        fallback: FontWeight.w600,
      ),
    );

    return FilledButton(
      onPressed: () {},
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        maxLines: 2,
        style: textStyle,
      ),
    );
  }
}

class _TextLabel extends StatelessWidget {
  final ComponentData component;
  final LayoutDataBindingValues? bindings;

  const _TextLabel({required this.component, required this.bindings});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final text = _boundAttribute(
      attributes['text'],
      bindings,
      fallback: 'Label',
    );
    final textAlign = _textAlignAttribute(
      attributes['textAlign'],
      fallback: TextAlign.left,
    );
    final textColor = _colorAttribute(attributes['textColor']);
    final maxLines = _intAttribute(
      attributes['maxLines'],
      fallback: 1,
      min: 1,
      max: 6,
    );
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: textColor,
      fontSize: _doubleAttribute(
        attributes['fontSize'],
        fallback: 16,
        min: 8,
        max: 48,
      ),
      fontWeight: _fontWeightAttribute(
        attributes['fontWeight'],
        fallback: FontWeight.w500,
      ),
    );

    return Align(
      alignment: _alignmentForTextAlign(textAlign),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: textStyle,
      ),
    );
  }
}

String _boundAttribute(
  Object? value,
  LayoutDataBindingValues? bindings, {
  required String fallback,
}) {
  final template =
      value is String && value.trim().isNotEmpty ? value : fallback;
  return bindings?.resolve(template) ?? template;
}

String _stringAttribute(Object? value, {required String fallback}) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

List<String> _stringListAttribute(
  Object? value, {
  required List<String> fallback,
}) {
  if (value is List) {
    final items = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return items.isEmpty ? fallback : items;
  }

  if (value is String && value.trim().isNotEmpty) {
    final items = value
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return items.isEmpty ? fallback : items;
  }

  return fallback;
}

bool _boolAttribute(Object? value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}

int _intAttribute(
  Object? value, {
  required int fallback,
  required int min,
  required int max,
}) {
  final parsed =
      value is num ? value.round() : int.tryParse(value?.toString() ?? '');
  return (parsed ?? fallback).clamp(min, max);
}

double _doubleAttribute(
  Object? value, {
  required double fallback,
  required double min,
  required double max,
}) {
  final parsed =
      value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '');
  final next = parsed ?? fallback;
  if (next < min) return min;
  if (next > max) return max;
  return next;
}

FontWeight _fontWeightAttribute(Object? value, {required FontWeight fallback}) {
  final parsed =
      value is num ? value.round() : int.tryParse(value?.toString() ?? '');

  switch (parsed) {
    case 400:
      return FontWeight.w400;
    case 500:
      return FontWeight.w500;
    case 600:
      return FontWeight.w600;
    case 700:
      return FontWeight.w700;
  }

  return fallback;
}

Color? _colorAttribute(Object? value) {
  if (value is int) return Color(value);
  if (value is String && value.trim().isNotEmpty) {
    final normalized = value.trim().replaceAll('#', '');
    final parsed = int.tryParse(
      normalized.length == 6 ? 'FF$normalized' : normalized,
      radix: 16,
    );
    if (parsed != null) return Color(parsed);
  }

  return null;
}

TextAlign _textAlignAttribute(Object? value, {required TextAlign fallback}) {
  switch (value?.toString().trim().toLowerCase()) {
    case 'left':
      return TextAlign.left;
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
  }

  return fallback;
}

Alignment _alignmentForTextAlign(TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.center:
      return Alignment.center;
    case TextAlign.right:
    case TextAlign.end:
      return Alignment.centerRight;
    case TextAlign.left:
    case TextAlign.start:
    case TextAlign.justify:
      return Alignment.centerLeft;
  }
}

_SeparatorOrientation _separatorOrientationAttribute(Object? value) {
  return value?.toString().trim().toLowerCase() == 'vertical'
      ? _SeparatorOrientation.vertical
      : _SeparatorOrientation.horizontal;
}

_ControlButtonStyle _buttonStyleAttribute(Object? value) {
  switch (value?.toString().trim().toLowerCase()) {
    case 'filled':
      return _ControlButtonStyle.filled;
    case 'tonal':
      return _ControlButtonStyle.tonal;
    case 'outlined':
    default:
      return _ControlButtonStyle.outlined;
  }
}

_ControlButtonTone? _actionTone(String label) {
  final normalized = label.trim().toLowerCase();
  return normalized == 'void' ||
          normalized == 'cancel' ||
          normalized == 'delete' ||
          normalized == 'clear'
      ? _ControlButtonTone.warning
      : null;
}

class _Separator extends StatelessWidget {
  final ComponentData component;
  final LayoutDataBindingValues? bindings;

  const _Separator({required this.component, required this.bindings});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final orientation = _separatorOrientationAttribute(
      attributes['orientation'],
    );
    final thickness = _doubleAttribute(
      attributes['thickness'],
      fallback: 2,
      min: 1,
      max: 16,
    );
    final color =
        _colorAttribute(attributes['color']) ?? Theme.of(context).dividerColor;
    final dashed = _boolAttribute(attributes['dashed'], fallback: false);
    final inset = _doubleAttribute(
      attributes['inset'],
      fallback: 0,
      min: 0,
      max: 64,
    );
    final label =
        _boundAttribute(attributes['label'], bindings, fallback: '').trim();

    return orientation == _SeparatorOrientation.vertical
        ? _VerticalSeparator(
          color: color,
          dashed: dashed,
          inset: inset,
          label: label,
          thickness: thickness,
        )
        : _HorizontalSeparator(
          color: color,
          dashed: dashed,
          inset: inset,
          label: label,
          thickness: thickness,
        );
  }
}

class _HorizontalSeparator extends StatelessWidget {
  final Color color;
  final bool dashed;
  final double inset;
  final String label;
  final double thickness;

  const _HorizontalSeparator({
    required this.color,
    required this.dashed,
    required this.inset,
    required this.label,
    required this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: inset),
        child: SizedBox(
          height: thickness,
          child: CustomPaint(
            painter: _SeparatorLinePainter(
              color: color,
              dashed: dashed,
              orientation: _SeparatorOrientation.horizontal,
              thickness: thickness,
            ),
          ),
        ),
      ),
    );

    if (label.isEmpty) {
      return Center(child: Row(children: [line]));
    }

    return Center(
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _VerticalSeparator extends StatelessWidget {
  final Color color;
  final bool dashed;
  final double inset;
  final String label;
  final double thickness;

  const _VerticalSeparator({
    required this.color,
    required this.dashed,
    required this.inset,
    required this.label,
    required this.thickness,
  });

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: inset),
        child: SizedBox(
          width: thickness,
          child: CustomPaint(
            painter: _SeparatorLinePainter(
              color: color,
              dashed: dashed,
              orientation: _SeparatorOrientation.vertical,
              thickness: thickness,
            ),
          ),
        ),
      ),
    );

    if (label.isEmpty) {
      return Center(child: Column(children: [line]));
    }

    return Center(
      child: Column(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _SeparatorLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  final _SeparatorOrientation orientation;
  final double thickness;

  const _SeparatorLinePainter({
    required this.color,
    required this.dashed,
    required this.orientation,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = thickness;
    final isHorizontal = orientation == _SeparatorOrientation.horizontal;
    final start =
        isHorizontal ? Offset(0, size.height / 2) : Offset(size.width / 2, 0);
    final end =
        isHorizontal
            ? Offset(size.width, size.height / 2)
            : Offset(size.width / 2, size.height);

    if (!dashed) {
      canvas.drawLine(start, end, paint);
      return;
    }

    const dash = 8.0;
    const gap = 5.0;
    final length = isHorizontal ? size.width : size.height;
    var cursor = 0.0;

    while (cursor < length) {
      final next = (cursor + dash).clamp(0, length).toDouble();
      final dashStart =
          isHorizontal ? Offset(cursor, start.dy) : Offset(start.dx, cursor);
      final dashEnd =
          isHorizontal ? Offset(next, start.dy) : Offset(start.dx, next);
      canvas.drawLine(dashStart, dashEnd, paint);
      cursor += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _SeparatorLinePainter oldDelegate) {
    return color != oldDelegate.color ||
        dashed != oldDelegate.dashed ||
        orientation != oldDelegate.orientation ||
        thickness != oldDelegate.thickness;
  }
}

enum _SeparatorOrientation { horizontal, vertical }

class _ImageHolder extends StatelessWidget {
  final ComponentData component;
  final LayoutDataBindingValues? bindings;

  const _ImageHolder({required this.component, required this.bindings});

  @override
  Widget build(BuildContext context) {
    final attributes = component.properties.attributes;
    final source =
        _boundAttribute(attributes['source'], bindings, fallback: '').trim();
    final fit = _boxFitAttribute(attributes['fit']);
    final alignment = _imageAlignmentAttribute(attributes['alignment']);
    final showPlaceholder = _boolAttribute(
      attributes['showPlaceholder'],
      fallback: true,
    );
    final radius = component.style.borderRadius.topLeft.x;

    if (source.isEmpty) {
      return showPlaceholder
          ? _ImagePlaceholder(borderRadius: radius)
          : const SizedBox.shrink();
    }

    final image =
        _isNetworkImage(source)
            ? Image.network(
              source,
              fit: fit,
              alignment: alignment,
              width: double.infinity,
              height: double.infinity,
              errorBuilder:
                  (_, _, _) =>
                      showPlaceholder
                          ? _ImagePlaceholder(borderRadius: radius)
                          : const SizedBox.shrink(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return showPlaceholder
                    ? _ImagePlaceholder(borderRadius: radius, isLoading: true)
                    : const SizedBox.shrink();
              },
            )
            : Image.asset(
              source,
              fit: fit,
              alignment: alignment,
              width: double.infinity,
              height: double.infinity,
              errorBuilder:
                  (_, _, _) =>
                      showPlaceholder
                          ? _ImagePlaceholder(borderRadius: radius)
                          : const SizedBox.shrink(),
            );

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final double borderRadius;
  final bool isLoading;

  const _ImagePlaceholder({required this.borderRadius, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child:
            isLoading
                ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: colorScheme.onSurfaceVariant,
                ),
      ),
    );
  }
}

bool _isNetworkImage(String source) {
  final lower = source.toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

BoxFit _boxFitAttribute(Object? value) {
  switch (value?.toString().trim().toLowerCase()) {
    case 'contain':
      return BoxFit.contain;
    case 'fill':
      return BoxFit.fill;
    case 'fit_width':
      return BoxFit.fitWidth;
    case 'fit_height':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    case 'cover':
    default:
      return BoxFit.cover;
  }
}

Alignment _imageAlignmentAttribute(Object? value) {
  switch (value?.toString().trim().toLowerCase()) {
    case 'top':
      return Alignment.topCenter;
    case 'bottom':
      return Alignment.bottomCenter;
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    case 'center':
    default:
      return Alignment.center;
  }
}
