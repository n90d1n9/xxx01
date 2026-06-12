import 'package:flutter/services.dart';

/// Keeps survey number fields editable while blocking clearly invalid input.
class SurveyNumberInputFormatter extends TextInputFormatter {
  final bool allowDecimal;
  final bool allowNegative;

  const SurveyNumberInputFormatter({
    this.allowDecimal = true,
    this.allowNegative = true,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_canEditAsNumber(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }

  bool _canEditAsNumber(String value) {
    if (value.isEmpty) {
      return true;
    }

    if (allowNegative && value == '-') {
      return true;
    }

    if (allowDecimal && allowNegative && value == '-.') {
      return true;
    }

    final sign = allowNegative ? '-?' : '';
    if (allowDecimal) {
      return RegExp('^$sign(?:\\d+\\.?\\d*|\\.\\d*)\$').hasMatch(value);
    }

    return RegExp('^$sign\\d+\$').hasMatch(value);
  }
}
