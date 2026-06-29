final vendorsProvider = StateNotifierProvider<VendorNotifier, List<Vendor>>((
  ref,
) {
  return VendorNotifier();
});

class VendorNotifier extends StateNotifier<List<Vendor>> {
  VendorNotifier()
    : super([
        Vendor(
          id: 'V001',
          name: 'Tech Solutions Inc.',
          email: 'accounts@techsolutions.com',
          totalOutstanding: 4300.00,
        ),
        Vendor(
          id: 'V002',
          name: 'Office Supplies Co.',
          email: 'billing@officesupplies.com',
          totalOutstanding: 750.50,
        ),
        Vendor(
          id: 'V003',
          name: 'Marketing Agency',
          email: 'finance@marketingagency.com',
          totalOutstanding: 4200.00,
        ),
        Vendor(
          id: 'V004',
          name: 'Cloud Services Ltd.',
          email: 'payments@cloudservices.com',
          totalOutstanding: 1200.00,
        ),
      ]);

  void addVendor(Vendor vendor) {
    state = [...state, vendor];
  }
}
