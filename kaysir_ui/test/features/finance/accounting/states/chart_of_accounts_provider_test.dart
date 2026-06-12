import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/states/accounting_core_provider.dart';
import 'package:kaysir/features/finance/accounting/states/chart_of_accounts_provider.dart';

void main() {
  test('seeds editable CoA state and feeds accounting chart provider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final chart = container.read(chartOfAccountsProvider);
    final postingChart = container.read(accountingChartProvider);

    expect(chart.map((account) => account.code), containsAll(['1000', '1100']));
    expect(postingChart, same(chart));
    expect(chart.first.currencyCode, 'IDR');
  });

  test('adds and deactivates accounts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(chartOfAccountsProvider.notifier)
        .addAccount(
          const AccountingAccount(
            id: 'custom-6100',
            code: '6100',
            name: 'Cloud subscription expense',
            type: AccountingAccountType.expense,
          ),
        );

    expect(
      container.read(chartOfAccountsProvider).map((account) => account.code),
      contains('6100'),
    );

    container
        .read(chartOfAccountsProvider.notifier)
        .deactivateAccount('custom-6100');

    final account = container
        .read(chartOfAccountsProvider)
        .singleWhere((account) => account.id == 'custom-6100');

    expect(account.isActive, isFalse);
  });
}
