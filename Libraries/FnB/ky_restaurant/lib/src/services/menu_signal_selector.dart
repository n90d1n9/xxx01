import '../models/restaurant_models.dart';

/// Selects menu signals that should drive operational decisions.
class RestaurantMenuSignalSelector {
  const RestaurantMenuSignalSelector();

  RestaurantMenuSignal? topRisk(List<RestaurantMenuSignal> signals) {
    return _maxBy(signals, (signal) {
      return signal.soldOutRiskPercent * 1000 + signal.orders;
    });
  }

  RestaurantMenuSignal? highestMargin(List<RestaurantMenuSignal> signals) {
    return _maxBy(signals, (signal) {
      return signal.grossMarginPercent * 1000 + signal.orders;
    });
  }

  RestaurantMenuSignal? quickestPrep(List<RestaurantMenuSignal> signals) {
    return _minBy(signals, (signal) {
      return signal.prepMinutes * 1000 - signal.orders;
    });
  }
}

T? _maxBy<T>(List<T> values, int Function(T value) score) {
  if (values.isEmpty) return null;

  var best = values.first;
  var bestScore = score(best);
  for (final value in values.skip(1)) {
    final valueScore = score(value);
    if (valueScore > bestScore) {
      best = value;
      bestScore = valueScore;
    }
  }
  return best;
}

T? _minBy<T>(List<T> values, int Function(T value) score) {
  if (values.isEmpty) return null;

  var best = values.first;
  var bestScore = score(best);
  for (final value in values.skip(1)) {
    final valueScore = score(value);
    if (valueScore < bestScore) {
      best = value;
      bestScore = valueScore;
    }
  }
  return best;
}
