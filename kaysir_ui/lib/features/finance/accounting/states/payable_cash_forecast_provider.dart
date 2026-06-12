import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/payable_cash_forecast.dart';
import '../services/payable_cash_forecast_service.dart';
import 'invoice_provider.dart';

final payableCashForecastServiceProvider = Provider<PayableCashForecastService>(
  (ref) {
    return const PayableCashForecastService();
  },
);

final payableCashForecastProvider = Provider<PayableCashForecast>((ref) {
  final bills = ref.watch(allPayableInvoicesProvider);
  final service = ref.watch(payableCashForecastServiceProvider);

  return service.summarize(bills: bills, asOf: DateTime.now());
});
