import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatefulWidget {
  static const _compactBreakpoint = 156.0;

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double? min;
  final double? max;
  final double step;

  const NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
  }) : assert(step > 0),
       assert(min == null || max == null || min <= max);

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatNumber(_boundedValue(widget.value)),
    );
    _focusNode = FocusNode(debugLabel: '${widget.label} number field')
      ..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus) {
      _syncControllerText(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < NumberField._compactBreakpoint;

        if (isCompact) {
          return _NumberTextField(
            label: widget.label,
            controller: _controller,
            focusNode: _focusNode,
            errorText: _errorText,
            onChanged: _handleTextChanged,
            onEditingComplete: _commitText,
            showInlineLabel: true,
          );
        }

        return Row(
          children: [
            Flexible(
              flex: 2,
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _NumberTextField(
                label: widget.label,
                controller: _controller,
                focusNode: _focusNode,
                errorText: _errorText,
                onChanged: _handleTextChanged,
                onEditingComplete: _commitText,
                onStep: _stepValue,
                showSteppers: true,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _setError(null);
      return;
    }
    _commitText();
  }

  void _syncControllerText(double value) {
    final nextText = _formatNumber(_boundedValue(value));
    if (_controller.text == nextText) return;

    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  void _handleTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      _setError(value.trim().isEmpty ? 'Required' : 'Enter a number');
      return;
    }

    final boundedValue = _boundedValue(parsed);
    _setError(_rangeErrorFor(parsed, boundedValue));
    widget.onChanged(boundedValue);
  }

  void _commitText() {
    final parsed = double.tryParse(_controller.text);
    if (parsed == null) {
      _setError(null);
      _syncControllerText(widget.value);
      return;
    }

    final boundedValue = _boundedValue(parsed);
    _setError(null);
    _syncControllerText(boundedValue);
    widget.onChanged(boundedValue);
  }

  void _stepValue(int direction) {
    final currentValue = double.tryParse(_controller.text) ?? widget.value;
    final nextValue = _boundedValue(currentValue + widget.step * direction);
    _setError(null);
    _syncControllerText(nextValue);
    widget.onChanged(nextValue);
  }

  double _boundedValue(double value) {
    var nextValue = value;
    final min = widget.min;
    final max = widget.max;

    if (min != null && nextValue < min) nextValue = min;
    if (max != null && nextValue > max) nextValue = max;
    return nextValue;
  }

  String? _rangeErrorFor(double rawValue, double boundedValue) {
    if ((rawValue - boundedValue).abs() < 0.001) return null;

    final min = widget.min;
    final max = widget.max;
    if (min != null && rawValue < min) return 'Min ${_formatNumber(min)}';
    if (max != null && rawValue > max) return 'Max ${_formatNumber(max)}';
    return null;
  }

  void _setError(String? errorText) {
    if (_errorText == errorText) return;
    setState(() {
      _errorText = errorText;
    });
  }
}

class _NumberTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final ValueChanged<int>? onStep;
  final bool showInlineLabel;
  final bool showSteppers;

  const _NumberTextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onChanged,
    required this.onEditingComplete,
    this.onStep,
    this.showInlineLabel = false,
    this.showSteppers = false,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textAlign: TextAlign.end,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: (_) => onEditingComplete(),
      decoration: InputDecoration(
        isDense: true,
        labelText: showInlineLabel ? label : null,
        errorText: errorText,
        errorMaxLines: 1,
        errorStyle: const TextStyle(fontSize: 10),
        suffixIcon:
            showSteppers
                ? _NumberStepper(
                  onDecrease: () => onStep?.call(-1),
                  onIncrease: () => onStep?.call(1),
                )
                : null,
        suffixIconConstraints:
            showSteppers
                ? const BoxConstraints.tightFor(width: 32, height: 44)
                : null,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );

    if (!showSteppers || onStep == null) return field;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp):
            () => onStep?.call(1),
        const SingleActivator(LogicalKeyboardKey.arrowDown):
            () => onStep?.call(-1),
      },
      child: field,
    );
  }
}

class _NumberStepper extends StatelessWidget {
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _NumberStepper({required this.onIncrease, required this.onDecrease});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Tooltip(
          message: 'Increase',
          child: InkResponse(
            radius: 14,
            onTap: onIncrease,
            child: Icon(
              Icons.keyboard_arrow_up,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Tooltip(
          message: 'Decrease',
          child: InkResponse(
            radius: 14,
            onTap: onDecrease,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (!value.isFinite) return '0';
  if ((value - value.round()).abs() < 0.001) {
    return value.round().toString();
  }

  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
