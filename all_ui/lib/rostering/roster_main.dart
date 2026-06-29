import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
class Employee {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> skills;
  final int hoursWorked;
  final int maxHours;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.skills,
    required this.hoursWorked,
    required this.maxHours,
  });
}

class Shift {
  final String id;
  final DateTime start;
  final DateTime end;
  final String role;
  final String? employeeId;
  final List<String> requiredSkills;

  Shift({
    required this.id,
    required this.start,
    required this.end,
    required this.role,
    this.employeeId,
    required this.requiredSkills,
  });

  Shift copyWith({
    String? id,
    DateTime? start,
    DateTime? end,
    String? role,
    String? employeeId,
    List<String>? requiredSkills,
  }) {
    return Shift(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      requiredSkills: requiredSkills ?? this.requiredSkills,
    );
  }
}

// State notifiers and providers
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final employeesProvider = StateProvider<List<Employee>>(
  (ref) => [
    Employee(
      id: '1',
      name: 'Emma Johnson',
      role: 'Manager',
      avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
      skills: ['Training', 'Customer Service', 'Inventory'],
      hoursWorked: 32,
      maxHours: 40,
    ),
    Employee(
      id: '2',
      name: 'Liam Williams',
      role: 'Barista',
      avatarUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
      skills: ['Coffee', 'Customer Service'],
      hoursWorked: 25,
      maxHours: 35,
    ),
    Employee(
      id: '3',
      name: 'Olivia Davis',
      role: 'Server',
      avatarUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
      skills: ['Food Service', 'Customer Service'],
      hoursWorked: 15,
      maxHours: 30,
    ),
    Employee(
      id: '4',
      name: 'Noah Martinez',
      role: 'Cook',
      avatarUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
      skills: ['Cooking', 'Food Prep'],
      hoursWorked: 28,
      maxHours: 40,
    ),
    Employee(
      id: '5',
      name: 'Sophia Thompson',
      role: 'Barista',
      avatarUrl: 'https://randomuser.me/api/portraits/women/5.jpg',
      skills: ['Coffee', 'Customer Service', 'Inventory'],
      hoursWorked: 18,
      maxHours: 25,
    ),
  ],
);

class ShiftNotifier extends StateNotifier<List<Shift>> {
  ShiftNotifier()
    : super([
        // Initialize with some sample shifts
        Shift(
          id: '1',
          start: DateTime.now().add(const Duration(hours: 9)),
          end: DateTime.now().add(const Duration(hours: 17)),
          role: 'Manager',
          employeeId: '1',
          requiredSkills: ['Training', 'Customer Service'],
        ),
        Shift(
          id: '2',
          start: DateTime.now().add(const Duration(hours: 8)),
          end: DateTime.now().add(const Duration(hours: 16)),
          role: 'Barista',
          employeeId: '2',
          requiredSkills: ['Coffee', 'Customer Service'],
        ),
        Shift(
          id: '3',
          start: DateTime.now().add(const Duration(hours: 10)),
          end: DateTime.now().add(const Duration(hours: 18)),
          role: 'Server',
          employeeId: '3',
          requiredSkills: ['Food Service', 'Customer Service'],
        ),
      ]);

  void addShift(Shift shift) {
    state = [...state, shift];
  }

  void updateShift(Shift shift) {
    state = [
      for (final s in state)
        if (s.id == shift.id) shift else s,
    ];
  }

  void removeShift(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void assignEmployee(String shiftId, String employeeId) {
    state = [
      for (final s in state)
        if (s.id == shiftId) s.copyWith(employeeId: employeeId) else s,
    ];
  }

  void unassignEmployee(String shiftId) {
    state = [
      for (final s in state)
        if (s.id == shiftId) s.copyWith(employeeId: null) else s,
    ];
  }

  List<Shift> getShiftsForDate(DateTime date) {
    return state.where((shift) {
      return shift.start.year == date.year &&
          shift.start.month == date.month &&
          shift.start.day == date.day;
    }).toList();
  }
}

final shiftsProvider = StateNotifierProvider<ShiftNotifier, List<Shift>>((ref) {
  return ShiftNotifier();
});

final shiftsForSelectedDateProvider = Provider<List<Shift>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final shifts = ref.watch(shiftsProvider);

  return shifts.where((shift) {
    return shift.start.year == selectedDate.year &&
        shift.start.month == selectedDate.month &&
        shift.start.day == selectedDate.day;
  }).toList();
});

final selectedEmployeeIdProvider = StateProvider<String?>((ref) => null);

// Main screen
class RosteringScreen extends ConsumerWidget {
  const RosteringScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final shifts = ref.watch(shiftsForSelectedDateProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Staff Rostering',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.analytics_outlined,
              color: Color(0xFF2D3142),
            ),
            onPressed: () {
              // Show analytics
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF2D3142)),
            onPressed: () {
              // Show settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(context, ref),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildShiftsList(context, ref, shifts),
                ),
                Expanded(flex: 2, child: _buildEmployeesList(context, ref)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4F5D75),
        child: const Icon(Icons.add),
        onPressed: () => _showAddShiftDialog(context, ref),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: () {
                        ref
                            .read(selectedDateProvider.notifier)
                            .state = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day - 1,
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Today'),
                      onPressed: () {
                        ref.read(selectedDateProvider.notifier).state =
                            DateTime.now();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: () {
                        ref
                            .read(selectedDateProvider.notifier)
                            .state = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day + 1,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index - 7));
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = date;
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF4F5D75) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF4F5D75)
                                : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isSelected
                                    ? Colors.white
                                    : DateTime.now().day == date.day
                                    ? const Color(0xFFEF8354)
                                    : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsList(
    BuildContext context,
    WidgetRef ref,
    List<Shift> shifts,
  ) {
    final employees = ref.watch(employeesProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shifts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                  onPressed: () {
                    // Show filter options
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child:
                shifts.isEmpty
                    ? const Center(
                      child: Text(
                        'No shifts scheduled for this day',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: shifts.length,
                      itemBuilder: (context, index) {
                        final shift = shifts[index];
                        final assignedEmployee = employees.firstWhere(
                          (e) => e.id == shift.employeeId,
                          orElse:
                              () => Employee(
                                id: '',
                                name: 'Unassigned',
                                role: '',
                                avatarUrl: '',
                                skills: [],
                                hoursWorked: 0,
                                maxHours: 0,
                              ),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: _getColorForRole(shift.role),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shift.role,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${DateFormat('h:mm a').format(shift.start)} - ${DateFormat('h:mm a').format(shift.end)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children:
                                            shift.requiredSkills.map((skill) {
                                              return Chip(
                                                label: Text(
                                                  skill,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                padding: EdgeInsets.zero,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                backgroundColor:
                                                    Colors.grey[100],
                                                labelPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    shift.employeeId != null
                                        ? Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                assignedEmployee.avatarUrl,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              assignedEmployee.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      shiftsProvider.notifier,
                                                    )
                                                    .unassignEmployee(shift.id);
                                              },
                                            ),
                                          ],
                                        )
                                        : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF4F5D75,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                          ),
                                          child: const Text('Assign'),
                                          onPressed: () {
                                            ref
                                                .read(
                                                  selectedEmployeeIdProvider
                                                      .notifier,
                                                )
                                                .state = null;
                                            _showAssignEmployeeDialog(
                                              context,
                                              ref,
                                              shift,
                                            );
                                          },
                                        ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _showEditShiftDialog(
                                              context,
                                              ref,
                                              shift,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(shiftsProvider.notifier)
                                                .removeShift(shift.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Staff',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: () {
                    // Add employee
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final progress = employee.hoursWorked / employee.maxHours;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(employee.avatarUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.role,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[200],
                                      color:
                                          progress > 0.9
                                              ? Colors.red[400]
                                              : progress > 0.7
                                              ? Colors.orange[400]
                                              : Colors.green[400],
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${employee.hoursWorked}/${employee.maxHours}h',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          // Show employee details
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddShiftDialog(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedDateProvider);

    // Create form controllers
    final startTimeController = TextEditingController(text: '09:00');
    final endTimeController = TextEditingController(text: '17:00');
    final roleController = TextEditingController();
    final List<String> selectedSkills = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Shift'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Required Skills:'),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            'Customer Service',
                            'Coffee',
                            'Food Prep',
                            'Cooking',
                            'Training',
                            'Inventory',
                            'Food Service',
                          ].map((skill) {
                            final isSelected = selectedSkills.contains(skill);
                            return FilterChip(
                              label: Text(skill),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedSkills.add(skill);
                                  } else {
                                    selectedSkills.remove(skill);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F5D75),
                  ),
                  child: const Text('Add Shift'),
                  onPressed: () {
                    // Parse times
                    final startTimeParts = startTimeController.text.split(':');
                    final endTimeParts = endTimeController.text.split(':');

                    final startTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      int.parse(startTimeParts[0]),
                      int.parse(startTimeParts[1]),
                    );

                    final endTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      int.parse(endTimeParts[0]),
                      int.parse(endTimeParts[1]),
                    );

                    final newShift = Shift(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      start: startTime,
                      end: endTime,
                      role: roleController.text,
                      requiredSkills: selectedSkills,
                    );

                    ref.read(shiftsProvider.notifier).addShift(newShift);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditShiftDialog(BuildContext context, WidgetRef ref, Shift shift) {
    // Create form controllers
    final startTimeController = TextEditingController(
      text: DateFormat('HH:mm').format(shift.start),
    );
    final endTimeController = TextEditingController(
      text: DateFormat('HH:mm').format(shift.end),
    );
    final roleController = TextEditingController(text: shift.role);
    final List<String> selectedSkills = [...shift.requiredSkills];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Shift'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Required Skills:'),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            'Customer Service',
                            'Coffee',
                            'Food Prep',
                            'Cooking',
                            'Training',
                            'Inventory',
                            'Food Service',
                          ].map((skill) {
                            final isSelected = selectedSkills.contains(skill);
                            return FilterChip(
                              label: Text(skill),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedSkills.add(skill);
                                  } else {
                                    selectedSkills.remove(skill);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F5D75),
                  ),
                  child: const Text('Save Changes'),
                  onPressed: () {
                    // Parse times
                    final startTimeParts = startTimeController.text.split(':');
                    final endTimeParts = endTimeController.text.split(':');

                    final startTime = DateTime(
                      shift.start.year,
                      shift.start.month,
                      shift.start.day,
                      int.parse(startTimeParts[0]),
                      int.parse(startTimeParts[1]),
                    );

                    final endTime = DateTime(
                      shift.end.year,
                      shift.end.month,
                      shift.end.day,
                      int.parse(endTimeParts[0]),
                      int.parse(endTimeParts[1]),
                    );

                    final updatedShift = Shift(
                      id: shift.id,
                      start: startTime,
                      end: endTime,
                      role: roleController.text,
                      employeeId: shift.employeeId,
                      requiredSkills: selectedSkills,
                    );

                    ref.read(shiftsProvider.notifier).updateShift(updatedShift);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignEmployeeDialog(
    BuildContext context,
    WidgetRef ref,
    Shift shift,
  ) {
    final employees = ref.read(employeesProvider);

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final selectedEmployeeId = ref.watch(selectedEmployeeIdProvider);

            return AlertDialog(
              title: const Text('Assign Employee to Shift'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shift: ${shift.role}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${DateFormat('MMM d, h:mm a').format(shift.start)} - ${DateFormat('h:mm a').format(shift.end)}',
                    ),
                    const SizedBox(height: 8),
                    const Text('Required Skills:'),
                    Wrap(
                      spacing: 8,
                      children:
                          shift.requiredSkills.map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor: Colors.grey[200],
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select an employee:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index];
                          final hasAllSkills = shift.requiredSkills.every(
                            (skill) => employee.skills.contains(skill),
                          );

                          return RadioListTile<String>(
                            title: Text(
                              employee.name,
                              style: TextStyle(
                                fontWeight:
                                    selectedEmployeeId == employee.id
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(employee.role),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value:
                                      employee.hoursWorked / employee.maxHours,
                                  backgroundColor: Colors.grey[200],
                                  color:
                                      employee.hoursWorked / employee.maxHours >
                                              0.9
                                          ? Colors.red[400]
                                          : employee.hoursWorked /
                                                  employee.maxHours >
                                              0.7
                                          ? Colors.orange[400]
                                          : Colors.green[400],
                                  minHeight: 4,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${employee.hoursWorked}/${employee.maxHours} hours',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (!hasAllSkills)
                                  const Text(
                                    'Missing some required skills',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            secondary: CircleAvatar(
                              backgroundImage: NetworkImage(employee.avatarUrl),
                            ),
                            value: employee.id,
                            groupValue: selectedEmployeeId,
                            onChanged: (value) {
                              ref
                                  .read(selectedEmployeeIdProvider.notifier)
                                  .state = value;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F5D75),
                  ),
                  child: const Text('Assign'),
                  onPressed:
                      selectedEmployeeId == null
                          ? null
                          : () {
                            ref
                                .read(shiftsProvider.notifier)
                                .assignEmployee(shift.id, selectedEmployeeId);
                            Navigator.of(context).pop();
                          },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return const Color(0xFF9381FF);
      case 'barista':
        return const Color(0xFFEF8354);
      case 'server':
        return const Color(0xFF4CB944);
      case 'cook':
        return const Color(0xFFFFDB58);
      default:
        return const Color(0xFF4F5D75);
    }
  }
}

// Main app widget
class RosteringApp extends StatelessWidget {
  const RosteringApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Staff Rostering',
        theme: ThemeData(
          primaryColor: const Color(0xFF4F5D75),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F5D75),
            secondary: const Color(0xFFEF8354),
          ),
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Color(0xFF2D3142)),
            titleTextStyle: TextStyle(
              color: Color(0xFF2D3142),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const RosteringScreen(),
      ),
    );
  }
}

void main() {
  runApp(const RosteringApp());
}
