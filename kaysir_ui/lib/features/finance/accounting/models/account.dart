enum AccountType { asset, liability, equity, revenue, expense }

class Account {
  final String id;
  final String name;
  final String code;
  final AccountType type;

  Account({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });
}
