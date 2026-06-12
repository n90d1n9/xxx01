import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payable_cash_forecast.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/payable_cash_forecast_service.dart';

void main() {
  group('PayableCashForecastService', () {
    const service = PayableCashForecastService();
    final asOf = DateTime(2026, 5, 30, 18);

    test('summarizes open bills by cash timing buckets', () {
      final forecast = service.summarize(
        asOf: asOf,
        bills: [
          _bill(id: 'overdue', dueDate: DateTime(2026, 5, 20), amount: 100),
          _bill(id: 'today', dueDate: DateTime(2026, 5, 30), amount: 200),
          _bill(id: 'next-7', dueDate: DateTime(2026, 6, 5), amount: 300),
          _bill(id: '8-14', dueDate: DateTime(2026, 6, 12), amount: 400),
          _bill(id: '15-30', dueDate: DateTime(2026, 6, 25), amount: 500),
          _bill(id: 'later', dueDate: DateTime(2026, 7, 15), amount: 600),
        ],
      );

      expect(_amount(forecast, PayableCashForecastBucketIds.dueNow), 300);
      expect(_count(forecast, PayableCashForecastBucketIds.dueNow), 2);
      expect(_amount(forecast, PayableCashForecastBucketIds.next7Days), 300);
      expect(_amount(forecast, PayableCashForecastBucketIds.days8To14), 400);
      expect(_amount(forecast, PayableCashForecastBucketIds.days15To30), 500);
      expect(_amount(forecast, PayableCashForecastBucketIds.after30Days), 600);
      expect(forecast.next30Days, 1500);
      expect(forecast.totalOpen, 2100);
      expect(forecast.openBillCount, 6);
      expect(forecast.nextDueDate, DateTime(2026, 5, 20));
    });

    test('uses remaining balances and skips settled bills', () {
      final forecast = service.summarize(
        asOf: asOf,
        bills: [
          _bill(
            id: 'partial',
            dueDate: DateTime(2026, 6, 1),
            amount: 500,
            payments: [Payment(id: 'p1', invoiceId: 'partial', amount: 125)],
          ),
          _bill(
            id: 'settled',
            dueDate: DateTime(2026, 6, 2),
            amount: 250,
            status: InvoiceStatus.paid,
          ),
          Invoice(id: 'no-due-date', vendorId: 'vendor-1', amount: 75),
        ],
      );

      expect(_amount(forecast, PayableCashForecastBucketIds.next7Days), 375);
      expect(forecast.totalOpen, 375);
      expect(forecast.openBillCount, 1);
      expect(forecast.nextDueDate, DateTime(2026, 6, 1));
    });
  });
}

Invoice _bill({
  required String id,
  required DateTime dueDate,
  required double amount,
  InvoiceStatus status = InvoiceStatus.pending,
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    vendorId: 'vendor-1',
    invoiceNumber: 'BILL-$id',
    invoiceDate: DateTime(2026, 1, 1),
    dueDate: dueDate,
    amount: amount,
    status: status,
    payments: payments,
  );
}

double _amount(PayableCashForecast forecast, String bucketId) {
  return _bucket(forecast, bucketId).amount;
}

int _count(PayableCashForecast forecast, String bucketId) {
  return _bucket(forecast, bucketId).billCount;
}

PayableCashForecastBucket _bucket(
  PayableCashForecast forecast,
  String bucketId,
) {
  return forecast.buckets.singleWhere((bucket) => bucket.id == bucketId);
}
