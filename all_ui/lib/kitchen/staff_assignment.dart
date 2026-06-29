import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
class Branch {
  final String id;
  final String name;
  final String address;

  Branch({required this.id, required this.name, required this.address});
}

class Staff {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String email;
  final String phone;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.email,
    required this.phone,
  });
}

class StaffAssignment {
  final String id;
  final Staff staff;
  final Branch branch;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // Active, Pending, Completed

  StaffAssignment({
    required this.id,
    required this.staff,
    required this.branch,
    required this.startDate,
    this.endDate,
    required this.status,
  });
}

// Sample data
final List<Branch> sampleBranches = [
  Branch(id: '1', name: 'Downtown Branch', address: '123 Main Street'),
  Branch(id: '2', name: 'Westside Branch', address: '456 West Avenue'),
  Branch(id: '3', name: 'Eastside Branch', address: '789 East Boulevard'),
];

final List<Staff> sampleStaff = [
  Staff(
    id: '1',
    name: 'Alex Johnson',
    role: 'Manager',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    email: 'alex@example.com',
    phone: '555-1234',
  ),
  Staff(
    id: '2',
    name: 'Sarah Williams',
    role: 'Senior Associate',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    email: 'sarah@example.com',
    phone: '555-5678',
  ),
  Staff(
    id: '3',
    name: 'Michael Brown',
    role: 'Associate',
    avatarUrl: 'https://i.pravatar.cc/150?img=8',
    email: 'michael@example.com',
    phone: '555-9012',
  ),
  Staff(
    id: '4',
    name: 'Emily Davis',
    role: 'Junior Associate',
    avatarUrl: 'https://i.pravatar.cc/150?img=9',
    email: 'emily@example.com',
    phone: '555-3456',
  ),
];

final List<StaffAssignment> sampleAssignments = [
  StaffAssignment(
    id: '1',
    staff: sampleStaff[0],
    branch: sampleBranches[0],
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    status: 'Active',
  ),
  StaffAssignment(
    id: '2',
    staff: sampleStaff[1],
    branch: sampleBranches[1],
    startDate: DateTime.now().subtract(const Duration(days: 15)),
    status: 'Active',
  ),
  StaffAssignment(
    id: '3',
    staff: sampleStaff[2],
    branch: sampleBranches[2],
    startDate: DateTime.now().subtract(const Duration(days: 60)),
    endDate: DateTime.now().add(const Duration(days: 30)),
    status: 'Pending',
  ),
  StaffAssignment(
    id: '4',
    staff: sampleStaff[3],
    branch: sampleBranches[0],
    startDate: DateTime.now().subtract(const Duration(days: 90)),
    endDate: DateTime.now().subtract(const Duration(days: 30)),
    status: 'Completed',
  ),
];

// Providers
final branchesProvider = Provider<List<Branch>>((ref) => sampleBranches);
final staffProvider = Provider<List<Staff>>((ref) => sampleStaff);

final staffAssignmentsProvider =
    StateNotifierProvider<StaffAssignmentNotifier, List<StaffAssignment>>(
      (ref) => StaffAssignmentNotifier(sampleAssignments),
    );

final selectedBranchFilterProvider = StateProvider<String?>((ref) => null);
final statusFilterProvider = StateProvider<String?>((ref) => null);

final filteredAssignmentsProvider = Provider<List<StaffAssignment>>((ref) {
  final assignments = ref.watch(staffAssignmentsProvider);
  final selectedBranchId = ref.watch(selectedBranchFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  return assignments.where((assignment) {
    bool matchesBranch =
        selectedBranchId == null || assignment.branch.id == selectedBranchId;
    bool matchesStatus =
        statusFilter == null || assignment.status == statusFilter;
    return matchesBranch && matchesStatus;
  }).toList();
});

// Notifier for Staff Assignments
class StaffAssignmentNotifier extends StateNotifier<List<StaffAssignment>> {
  StaffAssignmentNotifier(List<StaffAssignment> initialAssignments)
    : super(initialAssignments);

  void addAssignment(StaffAssignment assignment) {
    state = [...state, assignment];
  }

  void updateAssignment(StaffAssignment updatedAssignment) {
    state = [
      for (final assignment in state)
        if (assignment.id == updatedAssignment.id)
          updatedAssignment
        else
          assignment,
    ];
  }

  void removeAssignment(String id) {
    state = state.where((assignment) => assignment.id != id).toList();
  }
}

// Main Screen
class StaffAssignmentsScreen extends ConsumerWidget {
  const StaffAssignmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(filteredAssignmentsProvider);
    final branches = ref.watch(branchesProvider);
    final selectedBranchId = ref.watch(selectedBranchFilterProvider);
    final statusFilter = ref.watch(statusFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Staff Assignments'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context, ref, branches);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (selectedBranchId != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          'Branch: ${branches.firstWhere((b) => b.id == selectedBranchId).name}',
                        ),
                        onSelected: (_) {
                          ref
                              .read(selectedBranchFilterProvider.notifier)
                              .state = null;
                        },
                        avatar: const Icon(Icons.close, size: 16),
                        backgroundColor: Colors.indigo[100],
                        selectedColor: Colors.indigo[100],
                        selected: true,
                      ),
                    ),
                  if (statusFilter != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('Status: $statusFilter'),
                        onSelected: (_) {
                          ref.read(statusFilterProvider.notifier).state = null;
                        },
                        avatar: const Icon(Icons.close, size: 16),
                        backgroundColor: Colors.indigo[100],
                        selectedColor: Colors.indigo[100],
                        selected: true,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Stats summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildStatCard(
                  context,
                  'Active',
                  assignments
                      .where((a) => a.status == 'Active')
                      .length
                      .toString(),
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Pending',
                  assignments
                      .where((a) => a.status == 'Pending')
                      .length
                      .toString(),
                  Colors.amber,
                ),
                _buildStatCard(
                  context,
                  'Completed',
                  assignments
                      .where((a) => a.status == 'Completed')
                      .length
                      .toString(),
                  Colors.blue,
                ),
              ],
            ),
          ),

          // Assignments list
          Expanded(
            child:
                assignments.isEmpty
                    ? const Center(
                      child: Text(
                        'No assignments found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        return _buildAssignmentCard(context, ref, assignment);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAssignmentDialog(context, ref);
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    WidgetRef ref,
    StaffAssignment assignment,
  ) {
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');
    Color statusColor;
    IconData statusIcon;

    switch (assignment.status) {
      case 'Active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Pending':
        statusColor = Colors.amber;
        statusIcon = Icons.access_time;
        break;
      case 'Completed':
        statusColor = Colors.blue;
        statusIcon = Icons.task_alt;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.circle;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showAssignmentDetails(context, ref, assignment);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(assignment.staff.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.staff.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          assignment.staff.role,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          assignment.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    assignment.branch.name,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    assignment.endDate == null
                        ? 'From ${dateFormat.format(assignment.startDate)}'
                        : '${dateFormat.format(assignment.startDate)} - ${dateFormat.format(assignment.endDate!)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<Branch> branches,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Assignments',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Branch',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All Branches'),
                        selected:
                            ref.read(selectedBranchFilterProvider) == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                .read(selectedBranchFilterProvider.notifier)
                                .state = null;
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.indigo[100],
                      ),
                      ...branches.map((branch) {
                        return FilterChip(
                          label: Text(branch.name),
                          selected:
                              ref.read(selectedBranchFilterProvider) ==
                              branch.id,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(selectedBranchFilterProvider.notifier)
                                  .state = branch.id;
                            } else if (ref.read(selectedBranchFilterProvider) ==
                                branch.id) {
                              ref
                                  .read(selectedBranchFilterProvider.notifier)
                                  .state = null;
                            }
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.indigo[100],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All Statuses'),
                        selected: ref.read(statusFilterProvider) == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(statusFilterProvider.notifier).state =
                                null;
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.indigo[100],
                      ),
                      ...['Active', 'Pending', 'Completed'].map((status) {
                        return FilterChip(
                          label: Text(status),
                          selected: ref.read(statusFilterProvider) == status,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(statusFilterProvider.notifier).state =
                                  status;
                            } else if (ref.read(statusFilterProvider) ==
                                status) {
                              ref.read(statusFilterProvider.notifier).state =
                                  null;
                            }
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor:
                              status == 'Active'
                                  ? Colors.green[100]
                                  : status == 'Pending'
                                  ? Colors.amber[100]
                                  : Colors.blue[100],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAssignmentDetails(
    BuildContext context,
    WidgetRef ref,
    StaffAssignment assignment,
  ) {
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(assignment.staff.avatarUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      assignment.staff.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      assignment.staff.role,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailItem(
                        'Status',
                        assignment.status,
                        assignment.status == 'Active'
                            ? Colors.green
                            : assignment.status == 'Pending'
                            ? Colors.amber
                            : Colors.blue,
                      ),
                      _detailItem(
                        'Branch',
                        assignment.branch.name,
                        Colors.indigo,
                      ),
                      _detailItem(
                        'Branch Address',
                        assignment.branch.address,
                        Colors.indigo,
                      ),
                      _detailItem(
                        'Start Date',
                        dateFormat.format(assignment.startDate),
                        Colors.indigo,
                      ),
                      if (assignment.endDate != null)
                        _detailItem(
                          'End Date',
                          dateFormat.format(assignment.endDate!),
                          Colors.indigo,
                        ),
                      _detailItem(
                        'Email',
                        assignment.staff.email,
                        Colors.indigo,
                      ),
                      _detailItem(
                        'Phone',
                        assignment.staff.phone,
                        Colors.indigo,
                      ),

                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditAssignmentDialog(
                                  context,
                                  ref,
                                  assignment,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(color: Colors.indigo),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.indigo),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Assignment'),
                                      content: const Text(
                                        'Are you sure you want to delete this assignment?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref
                                                .read(
                                                  staffAssignmentsProvider
                                                      .notifier,
                                                )
                                                .removeAssignment(
                                                  assignment.id,
                                                );
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            Navigator.pop(
                                              context,
                                            ); // Close bottom sheet
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  label == 'Status' ? FontWeight.bold : FontWeight.normal,
              color: label == 'Status' ? color : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  void _showAddAssignmentDialog(BuildContext context, WidgetRef ref) {
    final staff = ref.read(staffProvider);
    final branches = ref.read(branchesProvider);

    // Form values
    Staff? selectedStaff;
    Branch? selectedBranch;
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    String status = 'Active';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Assignment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Staff>(
                      decoration: const InputDecoration(
                        labelText: 'Staff Member',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStaff,
                      items:
                          staff.map((Staff staff) {
                            return DropdownMenuItem<Staff>(
                              value: staff,
                              child: Text(staff.name),
                            );
                          }).toList(),
                      onChanged: (Staff? value) {
                        setState(() {
                          selectedStaff = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Branch>(
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedBranch,
                      items:
                          branches.map((Branch branch) {
                            return DropdownMenuItem<Branch>(
                              value: branch,
                              child: Text(branch.name),
                            );
                          }).toList(),
                      onChanged: (Branch? value) {
                        setState(() {
                          selectedBranch = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                        );
                        if (picked != null && picked != startDate) {
                          setState(() {
                            startDate = picked;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('MMM d, yyyy').format(startDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              endDate ??
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Date (Optional)',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (endDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        endDate = null;
                                      });
                                    },
                                  ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                endDate != null
                                    ? DateFormat('MMM d, yyyy').format(endDate!)
                                    : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: status,
                      items:
                          ['Active', 'Pending', 'Completed'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStaff != null && selectedBranch != null) {
                      final newAssignment = StaffAssignment(
                        id:
                            (ref.read(staffAssignmentsProvider).length + 1)
                                .toString(),
                        staff: selectedStaff!,
                        branch: selectedBranch!,
                        startDate: startDate,
                        endDate: endDate,
                        status: status,
                      );
                      ref
                          .read(staffAssignmentsProvider.notifier)
                          .addAssignment(newAssignment);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
    StaffAssignment assignment,
  ) {
    final staff = ref.read(staffProvider);
    final branches = ref.read(branchesProvider);

    // Form values
    Staff? selectedStaff = assignment.staff;
    Branch? selectedBranch = assignment.branch;
    DateTime startDate = assignment.startDate;
    DateTime? endDate = assignment.endDate;
    String status = assignment.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Assignment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Staff>(
                      decoration: const InputDecoration(
                        labelText: 'Staff Member',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedStaff,
                      items:
                          staff.map((Staff staff) {
                            return DropdownMenuItem<Staff>(
                              value: staff,
                              child: Text(staff.name),
                            );
                          }).toList(),
                      onChanged: (Staff? value) {
                        setState(() {
                          selectedStaff = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Branch>(
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedBranch,
                      items:
                          branches.map((Branch branch) {
                            return DropdownMenuItem<Branch>(
                              value: branch,
                              child: Text(branch.name),
                            );
                          }).toList(),
                      onChanged: (Branch? value) {
                        setState(() {
                          selectedBranch = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                        );
                        if (picked != null && picked != startDate) {
                          setState(() {
                            startDate = picked;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('MMM d, yyyy').format(startDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate:
                              endDate ??
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2025),
                        );
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'End Date (Optional)',
                            border: const OutlineInputBorder(),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (endDate != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        endDate = null;
                                      });
                                    },
                                  ),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                          controller: TextEditingController(
                            text:
                                endDate != null
                                    ? DateFormat('MMM d, yyyy').format(endDate!)
                                    : '',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: status,
                      items:
                          ['Active', 'Pending', 'Completed'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            status = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStaff != null && selectedBranch != null) {
                      final updatedAssignment = StaffAssignment(
                        id: assignment.id,
                        staff: selectedStaff!,
                        branch: selectedBranch!,
                        startDate: startDate,
                        endDate: endDate,
                        status: status,
                      );
                      ref
                          .read(staffAssignmentsProvider.notifier)
                          .updateAssignment(updatedAssignment);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Main entry point for the app
void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Staff Management',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const StaffAssignmentsScreen(),
      ),
    ),
  );
}
