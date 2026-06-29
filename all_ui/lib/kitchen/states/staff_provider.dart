import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/staff.dart';

class StaffNotifier extends StateNotifier<List<Staff>> {
  StaffNotifier()
    : super([
        // Some initial dummy data
        Staff(
          id: '1',
          name: 'Jane Smith',
          role: StaffRole.chef,
          contact: '+1234567890',
          joiningDate: DateTime(2022, 1, 15),
          notes: 'Head chef',
        ),
        Staff(
          id: '2',
          name: 'Mike Johnson',
          role: StaffRole.kitchenHelper,
          contact: '+1987654321',
          joiningDate: DateTime(2022, 5, 10),
        ),
      ]);

  void addStaff(Staff staff) {
    state = [...state, staff];
  }

  void updateStaff(Staff updatedStaff) {
    state =
        state
            .map((staff) => staff.id == updatedStaff.id ? updatedStaff : staff)
            .toList();
  }

  void deleteStaff(String id) {
    state = state.where((staff) => staff.id != id).toList();
  }

  List<Staff> getStaffByRole(StaffRole role) {
    return state.where((staff) => staff.role == role).toList();
  }
}

final staffProvider = StateNotifierProvider<StaffNotifier, List<Staff>>(
  (ref) => StaffNotifier(),
);
