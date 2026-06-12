class OrderWorkspaceBreadcrumb {
  final String id;
  final String label;
  final String location;
  final bool isCurrent;

  const OrderWorkspaceBreadcrumb({
    required this.id,
    required this.label,
    this.location = '',
    this.isCurrent = false,
  });

  bool get canOpen {
    return !isCurrent && location.trim().isNotEmpty;
  }
}
