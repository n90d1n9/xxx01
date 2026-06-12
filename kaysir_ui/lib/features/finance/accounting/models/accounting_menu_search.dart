import 'accounting_menu_catalog.dart';

enum AccountingMenuSearchScope { all, screens, shortcuts }

extension AccountingMenuSearchScopeLabel on AccountingMenuSearchScope {
  String get label {
    switch (this) {
      case AccountingMenuSearchScope.all:
        return 'All';
      case AccountingMenuSearchScope.screens:
        return 'Screens';
      case AccountingMenuSearchScope.shortcuts:
        return 'Shortcuts';
    }
  }

  String get queryValue {
    switch (this) {
      case AccountingMenuSearchScope.all:
        return 'all';
      case AccountingMenuSearchScope.screens:
        return 'screens';
      case AccountingMenuSearchScope.shortcuts:
        return 'shortcuts';
    }
  }
}

AccountingMenuSearchScope accountingMenuSearchScopeFromQuery(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'screen':
    case 'screens':
      return AccountingMenuSearchScope.screens;
    case 'shortcut':
    case 'shortcuts':
      return AccountingMenuSearchScope.shortcuts;
    case 'all':
    default:
      return AccountingMenuSearchScope.all;
  }
}

List<AccountingMenuSection> filterAccountingMenuSections(
  String query, {
  AccountingMenuSearchScope scope = AccountingMenuSearchScope.all,
  List<AccountingMenuSection> sections = accountingMenuSections,
}) {
  final terms = _searchTerms(query);
  if (terms.isEmpty && scope == AccountingMenuSearchScope.all) {
    return sections;
  }

  return [
    for (final section in sections)
      if (_matchesSection(section, terms))
        _sectionWithDestinations(section, _destinationsForScope(section, scope))
      else
        _filteredSection(section, terms, scope),
  ].where((section) => section.destinations.isNotEmpty).toList();
}

int accountingMenuDestinationCount(Iterable<AccountingMenuSection> sections) {
  return sections.fold<int>(
    0,
    (count, section) => count + section.destinations.length,
  );
}

AccountingMenuSection _filteredSection(
  AccountingMenuSection section,
  List<String> terms,
  AccountingMenuSearchScope scope,
) {
  return _sectionWithDestinations(
    section,
    _destinationsForScope(
      section,
      scope,
    ).where((destination) => _matchesDestination(destination, terms)).toList(),
  );
}

AccountingMenuSection _sectionWithDestinations(
  AccountingMenuSection section,
  List<AccountingMenuDestination> destinations,
) {
  return AccountingMenuSection(
    name: section.name,
    subtitle: section.subtitle,
    icon: section.icon,
    destinations: destinations,
  );
}

List<AccountingMenuDestination> _destinationsForScope(
  AccountingMenuSection section,
  AccountingMenuSearchScope scope,
) {
  switch (scope) {
    case AccountingMenuSearchScope.all:
      return section.destinations;
    case AccountingMenuSearchScope.screens:
      return section.screenDestinations.toList();
    case AccountingMenuSearchScope.shortcuts:
      return section.shortcutDestinations.toList();
  }
}

bool _matchesSection(AccountingMenuSection section, List<String> terms) {
  return terms.isNotEmpty &&
      _matches('${section.name} ${section.subtitle}', terms);
}

bool _matchesDestination(
  AccountingMenuDestination destination,
  List<String> terms,
) {
  return _matches(
    '${destination.name} ${destination.subtitle} ${destination.path}',
    terms,
  );
}

bool _matches(String value, List<String> terms) {
  final normalized = value.toLowerCase();
  return terms.every(normalized.contains);
}

List<String> _searchTerms(String query) {
  return query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList();
}
