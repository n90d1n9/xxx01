import 'package:flutter/foundation.dart';

/// Manages a panel value that can be controlled externally or stored locally.
class RestaurantControlledPanelValue<T> {
  RestaurantControlledPanelValue(T initialValue) : _localValue = initialValue;

  T _localValue;

  T resolve(T? controlledValue) => controlledValue ?? _localValue;

  bool syncInitial({required T previousInitialValue, required T initialValue}) {
    if (previousInitialValue == initialValue ||
        _localValue != previousInitialValue) {
      return false;
    }

    _localValue = initialValue;
    return true;
  }

  bool select({
    required T value,
    required T? controlledValue,
    ValueChanged<T>? onChanged,
    VoidCallback? onLocalChanged,
  }) {
    if (value == resolve(controlledValue)) return false;

    onChanged?.call(value);
    if (controlledValue == null) {
      _localValue = value;
      onLocalChanged?.call();
    }
    return true;
  }
}
