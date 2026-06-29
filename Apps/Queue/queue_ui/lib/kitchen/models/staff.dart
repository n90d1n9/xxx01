enum StaffRole { chef, kitchenHelper, delivery, manager }

class Staff {
  final String id;
  final String name;
  final StaffRole role;
  final String contact;
  final DateTime joiningDate;
  final String? notes;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.contact,
    required this.joiningDate,
    this.notes,
  });
}
