class Vendor {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final double totalOutstanding;
  Vendor({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.totalOutstanding = 0,
  });
}
