import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_catalog.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';

void main() {
  test('parses search scope from route query', () {
    expect(
      accountingMenuSearchScopeFromQuery('screens'),
      AccountingMenuSearchScope.screens,
    );
    expect(
      accountingMenuSearchScopeFromQuery('screen'),
      AccountingMenuSearchScope.screens,
    );
    expect(
      accountingMenuSearchScopeFromQuery('shortcuts'),
      AccountingMenuSearchScope.shortcuts,
    );
    expect(
      accountingMenuSearchScopeFromQuery('shortcut'),
      AccountingMenuSearchScope.shortcuts,
    );
    expect(
      accountingMenuSearchScopeFromQuery('unknown'),
      AccountingMenuSearchScope.all,
    );
    expect(
      accountingMenuSearchScopeFromQuery(null),
      AccountingMenuSearchScope.all,
    );
  });

  test('builds accounting workspace search paths', () {
    expect(
      AccountingPath.workspaceWithSearch(query: 'spt', scope: 'shortcuts'),
      '/accounting?q=spt&scope=shortcuts',
    );
    expect(
      AccountingPath.workspaceWithSearch(role: 'tax'),
      AccountingPath.workspaceTax,
    );
    expect(
      AccountingPath.workspaceWithSearch(
        query: 'evidence',
        scope: 'all',
        role: 'auditor',
        queue: 'blocked',
        owner: 'Audit liaison',
        work: 'auditor-evidence-gaps',
        detail: 'request',
      ),
      '/accounting?q=evidence&scope=all&role=auditor&queue=blocked'
      '&owner=Audit+liaison&work=auditor-evidence-gaps&detail=request',
    );
    expect(
      AccountingPath.workspaceWithSearch(query: '  filing  '),
      '/accounting?q=filing',
    );
    expect(AccountingPath.workspaceWithSearch(), AccountingPath.workspace);
  });

  test('returns all accounting sections for an empty query', () {
    final sections = filterAccountingMenuSections('');

    expect(sections, accountingMenuSections);
    expect(
      accountingMenuDestinationCount(sections),
      accountingMenuSections.fold<int>(
        0,
        (count, section) => count + section.destinations.length,
      ),
    );
  });

  test('filters destinations by screen or shortcut metadata', () {
    final sections = filterAccountingMenuSections('evidence');
    final destinations = sections.expand((section) => section.destinations);

    expect(
      sections.map((section) => section.name),
      containsAll(['Close & Ledger', 'Reconciliation', 'Financial Reporting']),
    );
    expect(
      destinations.map((destination) => destination.name),
      containsAll(['Financial Notes', 'Release Evidence']),
    );
    expect(
      destinations.map((destination) => destination.name),
      isNot(contains('Balance Sheet')),
    );
  });

  test('filters destinations by screen scope', () {
    final sections = filterAccountingMenuSections(
      '',
      scope: AccountingMenuSearchScope.screens,
    );
    final destinations = sections.expand((section) => section.destinations);

    expect(
      destinations.every((destination) => destination.registerRoute),
      isTrue,
    );
    expect(
      destinations.map((destination) => destination.name),
      isNot(contains('Release Filing')),
    );
  });

  test('filters destinations by shortcut scope', () {
    final sections = filterAccountingMenuSections(
      '',
      scope: AccountingMenuSearchScope.shortcuts,
    );
    final destinations = sections.expand((section) => section.destinations);

    expect(
      sections.map((section) => section.name),
      contains('Financial Reporting'),
    );
    expect(
      destinations.every((destination) => !destination.registerRoute),
      isTrue,
    );
    expect(destinations.map((destination) => destination.name), [
      'Management Checklist',
      'Management Approval',
      'Management Reconciliation',
      'Management Export Evidence',
      'Management Audit',
      'Release Sign-off',
      'Release Evidence',
      'Release Distribution',
      'Release Archive',
      'Release Retention',
      'Release Filing',
    ]);
  });

  test('keeps an entire section when the section name matches', () {
    final sections = filterAccountingMenuSections('reconciliation');
    final reconciliation = sections.singleWhere(
      (section) => section.name == 'Reconciliation',
    );

    expect(reconciliation.destinations.length, 3);
  });

  test('returns no sections when nothing matches', () {
    expect(filterAccountingMenuSections('missing workspace'), isEmpty);
  });
}
