import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/customer_lookup.dart';

void main() {
  test('customerInitials handles one or multiple name parts', () {
    expect(customerInitials('Jane Smith'), 'JS');
    expect(customerInitials('Ada'), 'A');
    expect(customerInitials('  '), '?');
  });

  test('customerContactLine joins available contact details', () {
    expect(
      customerContactLine(
        Customer(
          id: '1',
          name: 'Jane',
          phone: '0812',
          email: 'jane@example.com',
          loyaltyPoints: 120,
        ),
      ),
      '0812 | jane@example.com',
    );
  });

  test('customerMatchesQuery checks name, phone, and email', () {
    final customer = Customer(
      id: '1',
      name: 'Jane Smith',
      phone: '0812',
      email: 'jane@example.com',
      loyaltyPoints: 120,
    );

    expect(customerMatchesQuery(customer, 'smith'), isTrue);
    expect(customerMatchesQuery(customer, '0812'), isTrue);
    expect(customerMatchesQuery(customer, 'EXAMPLE'), isTrue);
    expect(customerMatchesQuery(customer, 'missing'), isFalse);
  });

  test('filterCustomersForPOS sorts by loyalty points then name', () {
    final customers = [
      _customer(id: 'low', name: 'Zed', points: 10),
      _customer(id: 'a', name: 'Ana', points: 50),
      _customer(id: 'b', name: 'Bima', points: 50),
    ];

    final filtered = filterCustomersForPOS(customers, '');

    expect(filtered.map((customer) => customer.id), ['a', 'b', 'low']);
  });
}

Customer _customer({
  required String id,
  required String name,
  required int points,
}) {
  return Customer(
    id: id,
    name: name,
    phone: '',
    email: '',
    loyaltyPoints: points,
  );
}
