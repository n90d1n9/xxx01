import '../models/customer.dart';

String customerInitials(String name) {
  final parts =
      name
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();
  if (parts.isEmpty) return '?';

  final first = parts.first[0].toUpperCase();
  if (parts.length == 1) return first;

  return '$first${parts.last[0].toUpperCase()}';
}

String customerContactLine(Customer customer) {
  final parts =
      [
        customer.phone.trim(),
        customer.email.trim(),
      ].where((part) => part.isNotEmpty).toList();

  return parts.isEmpty ? 'No contact details' : parts.join(' | ');
}

bool customerMatchesQuery(Customer customer, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  return customer.name.toLowerCase().contains(normalizedQuery) ||
      customer.phone.toLowerCase().contains(normalizedQuery) ||
      customer.email.toLowerCase().contains(normalizedQuery);
}

List<Customer> filterCustomersForPOS(List<Customer> customers, String query) {
  final filtered =
      customers
          .where((customer) => customerMatchesQuery(customer, query))
          .toList();
  filtered.sort((a, b) {
    final pointsCompare = b.loyaltyPoints.compareTo(a.loyaltyPoints);
    if (pointsCompare != 0) return pointsCompare;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return filtered;
}
