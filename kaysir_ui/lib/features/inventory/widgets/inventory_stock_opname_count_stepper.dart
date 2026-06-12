import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import 'inventory_form_fields.dart';

/// Numeric count input with quick adjustment actions for stock opname rows.
///
/// The widget keeps text-entry behavior delegated to the shared inventory form
/// field while adding small increment/decrement controls around it. Parent row
/// widgets still own the controller so external line updates can stay
/// synchronized without duplicating draft state.
class InventoryStockOpnameCountStepper extends StatefulWidget {
  const InventoryStockOpnameCountStepper({
    super.key,
    required this.controller,
    required this.value,
    this.enabled = true,
    this.fieldKey,
    this.label = 'Actual count',
    this.minValue = 0,
    this.onChanged,
    this.productName,
    this.width = 238,
  });

  final TextEditingController controller;
  final int value;
  final bool enabled;
  final Key? fieldKey;
  final String label;
  final int minValue;
  final ValueChanged<String>? onChanged;
  final String? productName;
  final double width;

  @override
  State<InventoryStockOpnameCountStepper> createState() =>
      _InventoryStockOpnameCountStepperState();
}

/// Tracks controller text changes so count stepper actions stay correctly
/// enabled while the user is typing.
class _InventoryStockOpnameCountStepperState
    extends State<InventoryStockOpnameCountStepper> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant InventoryStockOpnameCountStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = _currentValue;
    final canChange = widget.enabled && widget.onChanged != null;
    final canDecrease = canChange && currentValue > widget.minValue;
    final productSuffix =
        widget.productName == null ? '' : ' for ${widget.productName}';

    return SizedBox(
      width: widget.width,
      child: Row(
        children: [
          AppIconActionButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease count$productSuffix',
            variant: AppIconActionButtonVariant.outlined,
            size: 36,
            iconSize: 18,
            onPressed: canDecrease ? () => _adjustBy(-1) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InventoryIntegerFormField(
              key: widget.fieldKey,
              controller: widget.controller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              isDense: true,
              label: widget.label,
              onChanged: canChange ? widget.onChanged : null,
            ),
          ),
          const SizedBox(width: 8),
          AppIconActionButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase count$productSuffix',
            variant: AppIconActionButtonVariant.outlined,
            size: 36,
            iconSize: 18,
            onPressed: canChange ? () => _adjustBy(1) : null,
          ),
        ],
      ),
    );
  }

  int get _currentValue {
    final parsed = int.tryParse(widget.controller.text.trim());
    return parsed ?? widget.value;
  }

  void _adjustBy(int delta) {
    final adjustedValue = _currentValue + delta;
    final nextValue =
        adjustedValue < widget.minValue ? widget.minValue : adjustedValue;
    final nextText = nextValue.toString();
    widget.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    widget.onChanged?.call(nextText);
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }
}

@Preview(name: 'Inventory stock opname count stepper')
Widget inventoryStockOpnameCountStepperPreview() {
  final controller = TextEditingController(text: '7');

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Center(
        child: InventoryStockOpnameCountStepper(
          controller: controller,
          value: 7,
          productName: 'Laptop',
          onChanged: (_) {},
        ),
      ),
    ),
  );
}
