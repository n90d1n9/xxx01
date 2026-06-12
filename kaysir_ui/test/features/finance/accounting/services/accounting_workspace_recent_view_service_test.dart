import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_saved_view.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_recent_view.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_recent_view_service.dart';

void main() {
  test('records recent workspace views with newest-first dedupe', () {
    const service = AccountingWorkspaceRecentViewService(maxItems: 3);
    final statutory = AccountingWorkspaceRecentView.fromSavedView(
      accountingMenuSavedViews.singleWhere(
        (view) => view.id == 'spt-statutory',
      ),
    );
    final reconciliation = AccountingWorkspaceRecentView.fromSearch(
      query: 'reconciliation',
      scope: AccountingMenuSearchScope.screens,
    );

    var views = service.record(const [], statutory);
    views = service.record(views, reconciliation);
    views = service.record(views, statutory);

    expect(views.map((view) => view.id), [statutory.id, reconciliation.id]);
  });

  test('skips default workspace view and caps list length', () {
    const service = AccountingWorkspaceRecentViewService(maxItems: 2);

    var views = service.record(
      const [],
      AccountingWorkspaceRecentView.fromSearch(
        query: '',
        scope: AccountingMenuSearchScope.all,
      ),
    );

    expect(views, isEmpty);

    views = service.record(
      views,
      AccountingWorkspaceRecentView.fromSearch(
        query: 'evidence',
        scope: AccountingMenuSearchScope.all,
      ),
    );
    views = service.record(
      views,
      AccountingWorkspaceRecentView.fromSearch(
        query: 'close',
        scope: AccountingMenuSearchScope.screens,
      ),
    );
    views = service.record(
      views,
      AccountingWorkspaceRecentView.fromSearch(
        query: 'spt',
        scope: AccountingMenuSearchScope.shortcuts,
      ),
    );

    expect(views.length, 2);
    expect(views.map((view) => view.id), ['shortcuts:spt', 'screens:close']);
  });
}
