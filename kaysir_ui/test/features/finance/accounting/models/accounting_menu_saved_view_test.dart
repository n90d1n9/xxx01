import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';

void main() {
  test('builds shareable paths for saved accounting workspace views', () {
    final ledgerReview = accountingMenuSavedViews.singleWhere(
      (view) => view.id == 'ledger-review',
    );
    final releaseShortcuts = accountingMenuSavedViews.singleWhere(
      (view) => view.id == 'release-shortcuts',
    );
    final statutory = accountingMenuSavedViews.singleWhere(
      (view) => view.id == 'spt-statutory',
    );
    final evidence = accountingMenuSavedViews.singleWhere(
      (view) => view.id == 'evidence',
    );

    expect(ledgerReview.path, '/accounting?q=ledger&scope=screens');
    expect(releaseShortcuts.path, '/accounting?scope=shortcuts');
    expect(statutory.path, '/accounting?q=spt&scope=shortcuts');
    expect(evidence.path, '/accounting?q=evidence');
  });

  test('matches the selected saved view by query and scope', () {
    final statutory = accountingMenuSavedViews.singleWhere(
      (view) => view.id == 'spt-statutory',
    );

    expect(
      statutory.isSelected(
        query: ' SPT ',
        scope: AccountingMenuSearchScope.shortcuts,
      ),
      isTrue,
    );
    expect(
      statutory.isSelected(query: 'spt', scope: AccountingMenuSearchScope.all),
      isFalse,
    );
  });
}
