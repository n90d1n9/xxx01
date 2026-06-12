import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/chart_of_accounts_validator.dart';

void main() {
  test('accepts a complete base chart of accounts', () {
    final result = const ChartOfAccountsValidator().validate(_baseChart());

    expect(result.isValid, isTrue);
    expect(result.issues, isEmpty);
  });

  test('flags duplicate codes and missing required posting accounts', () {
    final result = const ChartOfAccountsValidator().validate([
      _account(id: 'cash', code: '1000', type: AccountingAccountType.asset),
      _account(id: 'bank', code: '1000', type: AccountingAccountType.asset),
    ]);

    expect(result.isValid, isFalse);
    expect(
      result.issues.map((issue) => issue.message),
      contains('Account code 1000 is already used.'),
    );
    expect(
      result.issues.map((issue) => issue.message),
      contains('Required posting account 1100 is missing.'),
    );
  });

  test('flags invalid parent hierarchy and parent posting warnings', () {
    final result = const ChartOfAccountsValidator(
      requiredPostingCodes: [],
    ).validate([
      _account(
        id: 'asset-parent',
        code: '1000',
        type: AccountingAccountType.asset,
      ),
      _account(
        id: 'child',
        code: '1001',
        type: AccountingAccountType.liability,
        parentId: 'asset-parent',
      ),
      _account(
        id: 'missing-parent',
        code: '1002',
        type: AccountingAccountType.asset,
        parentId: 'does-not-exist',
      ),
    ]);

    expect(result.isValid, isFalse);
    expect(
      result.issues.map((issue) => issue.message),
      contains('Child account type must match parent account type.'),
    );
    expect(
      result.issues.map((issue) => issue.message),
      contains('Parent account is missing.'),
    );
    expect(
      result.issues.map((issue) => issue.message),
      contains('Parent account should not allow direct posting.'),
    );
  });
}

List<AccountingAccount> _baseChart() {
  return [
    _account(id: 'cash', code: '1000', type: AccountingAccountType.asset),
    _account(id: 'ar', code: '1100', type: AccountingAccountType.asset),
    _account(id: 'ap', code: '2000', type: AccountingAccountType.liability),
    _account(id: 'equity', code: '3000', type: AccountingAccountType.equity),
    _account(id: 'revenue', code: '4000', type: AccountingAccountType.revenue),
    _account(id: 'expense', code: '5000', type: AccountingAccountType.expense),
  ];
}

AccountingAccount _account({
  required String id,
  required String code,
  required AccountingAccountType type,
  String? parentId,
}) {
  return AccountingAccount(
    id: id,
    code: code,
    name: '$code account',
    type: type,
    parentId: parentId,
  );
}
