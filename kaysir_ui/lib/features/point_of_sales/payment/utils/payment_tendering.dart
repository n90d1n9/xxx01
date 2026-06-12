import 'dart:math' as math;

const List<double> kPOSTenderDenominations = [
  10000,
  20000,
  50000,
  100000,
  200000,
  500000,
];

class TenderSuggestion {
  final String label;
  final double amount;
  final bool isExact;

  const TenderSuggestion({
    required this.label,
    required this.amount,
    this.isExact = false,
  });
}

class PaymentTenderEvaluation {
  final double amount;
  final double remainingAmount;
  final String method;
  final bool isValid;
  final String? message;

  const PaymentTenderEvaluation({
    required this.amount,
    required this.remainingAmount,
    required this.method,
    required this.isValid,
    this.message,
  });

  bool get isCash => isCashPaymentMethod(method);

  double get changeDue =>
      amount > remainingAmount ? _money(amount - remainingAmount) : 0;

  double get shortfall =>
      remainingAmount > amount ? _money(remainingAmount - amount) : 0;

  bool get completesOrder => isValid && shortfall == 0;
}

List<TenderSuggestion> resolveTenderSuggestions(
  double remainingAmount, {
  bool includeCashRounds = true,
  List<double> denominations = kPOSTenderDenominations,
}) {
  return resolveTenderSuggestionsForMethod(
    remainingAmount,
    method: includeCashRounds ? 'Cash' : 'Exact',
    includeCashRounds: includeCashRounds,
    denominations: denominations,
  );
}

List<TenderSuggestion> resolveTenderSuggestionsForMethod(
  double remainingAmount, {
  required String method,
  bool includeCashRounds = true,
  List<double> denominations = kPOSTenderDenominations,
}) {
  final remaining = _money(remainingAmount);
  if (remaining <= 0) return const [];

  final suggestions = <TenderSuggestion>[];
  final seen = <int>{};

  void add(String label, double amount, {bool isExact = false}) {
    final normalized = _money(amount);
    if (normalized <= 0) return;

    final key = (normalized * 100).round();
    if (!seen.add(key)) return;

    suggestions.add(
      TenderSuggestion(label: label, amount: normalized, isExact: isExact),
    );
  }

  add('Exact', remaining, isExact: true);
  if (!includeCashRounds || !isCashPaymentMethod(method)) return suggestions;

  for (final denomination in denominations) {
    if (denomination >= remaining) {
      add(_compactAmountLabel(denomination), denomination);
    }
    if (suggestions.length >= 5) return suggestions;
  }

  add(
    _compactAmountLabel(_roundUpTo(remaining, 100000)),
    _roundUpTo(remaining, 100000),
  );
  add(
    _compactAmountLabel(_roundUpTo(remaining, 500000)),
    _roundUpTo(remaining, 500000),
  );

  return suggestions.take(5).toList();
}

PaymentTenderEvaluation evaluatePaymentTender({
  required double amount,
  required double remainingAmount,
  required String method,
}) {
  final normalizedAmount = _money(amount);
  final normalizedRemaining = _money(remainingAmount);
  final isCash = isCashPaymentMethod(method);

  if (!normalizedAmount.isFinite || normalizedAmount <= 0) {
    return PaymentTenderEvaluation(
      amount: normalizedAmount,
      remainingAmount: normalizedRemaining,
      method: method,
      isValid: false,
      message: 'Enter a payment amount.',
    );
  }

  if (normalizedRemaining <= 0) {
    return PaymentTenderEvaluation(
      amount: normalizedAmount,
      remainingAmount: normalizedRemaining,
      method: method,
      isValid: false,
      message: 'This order is already paid.',
    );
  }

  final changeDue = normalizedAmount - normalizedRemaining;
  if (!isCash && changeDue > 0.009) {
    return PaymentTenderEvaluation(
      amount: normalizedAmount,
      remainingAmount: normalizedRemaining,
      method: method,
      isValid: false,
      message: 'Non-cash payments cannot exceed the remaining balance.',
    );
  }

  return PaymentTenderEvaluation(
    amount: normalizedAmount,
    remainingAmount: normalizedRemaining,
    method: method,
    isValid: true,
  );
}

String formatPaymentAmountInput(double amount) {
  final normalized = _money(amount);
  if (normalized % 1 == 0) return normalized.round().toString();
  return normalized.toStringAsFixed(2);
}

bool isCashPaymentMethod(String method) {
  return method.trim().toLowerCase() == 'cash';
}

double _roundUpTo(double amount, double increment) {
  if (increment <= 0) return _money(amount);
  return _money((amount / increment).ceil() * increment);
}

String _compactAmountLabel(double amount) {
  final normalized = _money(amount);
  if (normalized >= 1000000) {
    final millions = normalized / 1000000;
    return '${_trimDecimal(millions)}m';
  }
  if (normalized >= 1000) {
    final thousands = normalized / 1000;
    return '${_trimDecimal(thousands)}k';
  }
  return _trimDecimal(normalized);
}

String _trimDecimal(double value) {
  final normalized = _money(value);
  if (normalized % 1 == 0) return normalized.round().toString();
  return normalized.toStringAsFixed(1);
}

double _money(double value) {
  if (!value.isFinite) return math.max(value, 0);
  return (value * 100).round() / 100;
}
