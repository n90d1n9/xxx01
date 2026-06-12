// MODELS
// organization_models.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/legacy.dart';

// Base class for all organization entities
abstract class OrgEntity {
  final String id;
  final String name;
  final Color color;

  OrgEntity({String? id, required this.name, this.color = Colors.blue})
    : id = id ?? const Uuid().v4();

  OrgEntity copyWith({String? name, Color? color});
}

// Department model
class Department extends OrgEntity {
  final List<String> childrenIds; // Can contain Departments or Positions

  Department({
    super.id,
    required super.name,
    super.color,
    this.childrenIds = const [],
  });

  @override
  Department copyWith({String? name, Color? color, List<String>? childrenIds}) {
    return Department(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }
}

// Position model
class Position extends OrgEntity {
  final List<String> employeeIds;
  final String? parentDepartmentId;

  Position({
    super.id,
    required super.name,
    super.color,
    this.employeeIds = const [],
    this.parentDepartmentId,
  });

  @override
  Position copyWith({
    String? name,
    Color? color,
    List<String>? employeeIds,
    String? parentDepartmentId,
  }) {
    return Position(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      employeeIds: employeeIds ?? this.employeeIds,
      parentDepartmentId: parentDepartmentId ?? this.parentDepartmentId,
    );
  }
}

// Employee model
class Employee extends OrgEntity {
  final String email;
  final String? avatar;
  final String? positionId;

  Employee({
    super.id,
    required super.name,
    super.color,
    required this.email,
    this.avatar,
    this.positionId,
  });

  @override
  Employee copyWith({
    String? name,
    Color? color,
    String? email,
    String? avatar,
    String? positionId,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      positionId: positionId ?? this.positionId,
    );
  }
}

// Connection style for org chart lines
enum ConnectionStyle { straight, curved, orthogonal, stepped }

// Organization chart configuration
class OrgChartConfig {
  final double nodeSpacing;
  final double levelSpacing;
  final ConnectionStyle connectionStyle;
  final bool centerOnParent;
  final Color connectionColor;
  final double connectionThickness;

  const OrgChartConfig({
    this.nodeSpacing = 50.0,
    this.levelSpacing = 100.0,
    this.connectionStyle = ConnectionStyle.orthogonal,
    this.centerOnParent = true,
    this.connectionColor = Colors.grey,
    this.connectionThickness = 1.5,
  });

  OrgChartConfig copyWith({
    double? nodeSpacing,
    double? levelSpacing,
    ConnectionStyle? connectionStyle,
    bool? centerOnParent,
    Color? connectionColor,
    double? connectionThickness,
  }) {
    return OrgChartConfig(
      nodeSpacing: nodeSpacing ?? this.nodeSpacing,
      levelSpacing: levelSpacing ?? this.levelSpacing,
      connectionStyle: connectionStyle ?? this.connectionStyle,
      centerOnParent: centerOnParent ?? this.centerOnParent,
      connectionColor: connectionColor ?? this.connectionColor,
      connectionThickness: connectionThickness ?? this.connectionThickness,
    );
  }
}

// STATE MANAGEMENT
// org_state.dart

// State class for the org chart
class OrgChartState {
  final Map<String, Department> departments;
  final Map<String, Position> positions;
  final Map<String, Employee> employees;
  final String? rootDepartmentId;
  final OrgChartConfig config;
  final bool isEditing;

  const OrgChartState({
    this.departments = const {},
    this.positions = const {},
    this.employees = const {},
    this.rootDepartmentId,
    this.config = const OrgChartConfig(),
    this.isEditing = false,
  });

  OrgChartState copyWith({
    Map<String, Department>? departments,
    Map<String, Position>? positions,
    Map<String, Employee>? employees,
    String? rootDepartmentId,
    OrgChartConfig? config,
    bool? isEditing,
  }) {
    return OrgChartState(
      departments: departments ?? this.departments,
      positions: positions ?? this.positions,
      employees: employees ?? this.employees,
      rootDepartmentId: rootDepartmentId ?? this.rootDepartmentId,
      config: config ?? this.config,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

// Provider for org chart state
final orgChartProvider = StateNotifierProvider<OrgChartNotifier, OrgChartState>(
  (ref) {
    return OrgChartNotifier();
  },
);

// Notifier for org chart state
class OrgChartNotifier extends StateNotifier<OrgChartState> {
  OrgChartNotifier() : super(const OrgChartState());

  // Create a new department
  void addDepartment(Department department) {
    final departments = Map<String, Department>.from(state.departments);
    departments[department.id] = department;

    // If this is the first department, set it as root
    final rootDepartmentId = state.rootDepartmentId ?? department.id;

    state = state.copyWith(
      departments: departments,
      rootDepartmentId: rootDepartmentId,
    );
  }

  // Add a child to a department
  void addChildToDepartment(String departmentId, String childId) {
    final departments = Map<String, Department>.from(state.departments);
    final department = departments[departmentId];

    if (department != null) {
      final updatedChildrenIds = List<String>.from(department.childrenIds);
      if (!updatedChildrenIds.contains(childId)) {
        updatedChildrenIds.add(childId);
        departments[departmentId] = department.copyWith(
          childrenIds: updatedChildrenIds,
        );
        state = state.copyWith(departments: departments);
      }
    }
  }

  // Add a position
  void addPosition(Position position) {
    final positions = Map<String, Position>.from(state.positions);
    positions[position.id] = position;

    // If it has a parent department, update the department's children
    if (position.parentDepartmentId != null) {
      addChildToDepartment(position.parentDepartmentId!, position.id);
    }

    state = state.copyWith(positions: positions);
  }

  // Add an employee
  void addEmployee(Employee employee) {
    final employees = Map<String, Employee>.from(state.employees);
    employees[employee.id] = employee;

    // If it has a position, update the position's employees
    if (employee.positionId != null) {
      addEmployeeToPosition(employee.positionId!, employee.id);
    }

    state = state.copyWith(employees: employees);
  }

  // Add an employee to a position
  void addEmployeeToPosition(String positionId, String employeeId) {
    final positions = Map<String, Position>.from(state.positions);
    final position = positions[positionId];

    if (position != null) {
      final updatedEmployeeIds = List<String>.from(position.employeeIds);
      if (!updatedEmployeeIds.contains(employeeId)) {
        updatedEmployeeIds.add(employeeId);
        positions[positionId] = position.copyWith(
          employeeIds: updatedEmployeeIds,
        );
        state = state.copyWith(positions: positions);
      }
    }
  }

  // Update configuration
  void updateConfig(OrgChartConfig config) {
    state = state.copyWith(config: config);
  }

  // Toggle editing mode
  void toggleEditingMode() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  // Remove entity (cascading delete)
  void removeEntity(String id) {
    // Check in all collections
    if (state.departments.containsKey(id)) {
      _removeDepartment(id);
    } else if (state.positions.containsKey(id)) {
      _removePosition(id);
    } else if (state.employees.containsKey(id)) {
      _removeEmployee(id);
    }
  }

  // Remove a department and its children
  void _removeDepartment(String departmentId) {
    final department = state.departments[departmentId];
    if (department == null) return;

    // Remove all children
    for (final childId in department.childrenIds) {
      if (state.departments.containsKey(childId)) {
        _removeDepartment(childId);
      } else if (state.positions.containsKey(childId)) {
        _removePosition(childId);
      }
    }

    // Remove from parent department if it exists
    final updatedDepartments = Map<String, Department>.from(state.departments);
    updatedDepartments.remove(departmentId);

    // Update parent references
    for (final dep in updatedDepartments.values) {
      if (dep.childrenIds.contains(departmentId)) {
        final updatedChildrenIds = List<String>.from(dep.childrenIds)
          ..remove(departmentId);
        updatedDepartments[dep.id] = dep.copyWith(
          childrenIds: updatedChildrenIds,
        );
      }
    }

    // Check if we're removing the root
    String? rootDepartmentId = state.rootDepartmentId;
    if (rootDepartmentId == departmentId) {
      rootDepartmentId = updatedDepartments.isNotEmpty
          ? updatedDepartments.keys.first
          : null;
    }

    state = state.copyWith(
      departments: updatedDepartments,
      rootDepartmentId: rootDepartmentId,
    );
  }

  // Remove a position and its employees
  void _removePosition(String positionId) {
    final position = state.positions[positionId];
    if (position == null) return;

    // Remove all employees in this position
    for (final employeeId in position.employeeIds) {
      _removeEmployee(employeeId);
    }

    // Remove from parent department
    final updatedDepartments = Map<String, Department>.from(state.departments);
    if (position.parentDepartmentId != null) {
      final parentDept = updatedDepartments[position.parentDepartmentId];
      if (parentDept != null) {
        final updatedChildrenIds = List<String>.from(parentDept.childrenIds)
          ..remove(positionId);
        updatedDepartments[parentDept.id] = parentDept.copyWith(
          childrenIds: updatedChildrenIds,
        );
      }
    }

    // Remove the position
    final updatedPositions = Map<String, Position>.from(state.positions);
    updatedPositions.remove(positionId);

    state = state.copyWith(
      departments: updatedDepartments,
      positions: updatedPositions,
    );
  }

  // Remove an employee
  void _removeEmployee(String employeeId) {
    final employee = state.employees[employeeId];
    if (employee == null) return;

    // Remove from position
    final updatedPositions = Map<String, Position>.from(state.positions);
    if (employee.positionId != null) {
      final position = updatedPositions[employee.positionId];
      if (position != null) {
        final updatedEmployeeIds = List<String>.from(position.employeeIds)
          ..remove(employeeId);
        updatedPositions[position.id] = position.copyWith(
          employeeIds: updatedEmployeeIds,
        );
      }
    }

    // Remove the employee
    final updatedEmployees = Map<String, Employee>.from(state.employees);
    updatedEmployees.remove(employeeId);

    state = state.copyWith(
      positions: updatedPositions,
      employees: updatedEmployees,
    );
  }

  // Load sample data
  void loadSampleData() {
    // Create CEO department
    final ceoDept = Department(name: "Executive Office", color: Colors.indigo);

    // Create positions
    final ceoPosition = Position(
      name: "CEO",
      color: Colors.red,
      parentDepartmentId: ceoDept.id,
    );

    final ctoPosition = Position(
      name: "CTO",
      color: Colors.blue,
      parentDepartmentId: ceoDept.id,
    );

    final cfoPosition = Position(
      name: "CFO",
      color: Colors.green,
      parentDepartmentId: ceoDept.id,
    );

    // Create employees
    final ceoEmployee = Employee(
      name: "John Smith",
      email: "john@example.com",
      positionId: ceoPosition.id,
    );

    final ctoEmployee = Employee(
      name: "Jane Doe",
      email: "jane@example.com",
      positionId: ctoPosition.id,
    );

    final cfoEmployee = Employee(
      name: "Mike Johnson",
      email: "mike@example.com",
      positionId: cfoPosition.id,
    );

    // Create sub-departments
    final techDept = Department(name: "Technology", color: Colors.purple);

    final financeDept = Department(name: "Finance", color: Colors.green);

    // Create department positions
    final devManagerPosition = Position(
      name: "Development Manager",
      color: Colors.purple,
      parentDepartmentId: techDept.id,
    );

    final qaManagerPosition = Position(
      name: "QA Manager",
      color: Colors.purple,
      parentDepartmentId: techDept.id,
    );

    final accountingManagerPosition = Position(
      name: "Accounting Manager",
      color: Colors.green,
      parentDepartmentId: financeDept.id,
    );

    // Add departments to CEO department
    ceoDept.childrenIds.addAll([techDept.id, financeDept.id]);

    // Build the state
    state = OrgChartState(
      departments: {
        ceoDept.id: ceoDept,
        techDept.id: techDept,
        financeDept.id: financeDept,
      },
      positions: {
        ceoPosition.id: ceoPosition,
        ctoPosition.id: ctoPosition,
        cfoPosition.id: cfoPosition,
        devManagerPosition.id: devManagerPosition,
        qaManagerPosition.id: qaManagerPosition,
        accountingManagerPosition.id: accountingManagerPosition,
      },
      employees: {
        ceoEmployee.id: ceoEmployee,
        ctoEmployee.id: ctoEmployee,
        cfoEmployee.id: cfoEmployee,
      },
      rootDepartmentId: ceoDept.id,
    );
  }
}

// UI COMPONENTS
// main.dart

void main() {
  runApp(const ProviderScope(child: OrganizationChartApp()));
}

class OrganizationChartApp extends StatelessWidget {
  const OrganizationChartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organization Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,
      home: const OrganizationChartScreen(),
    );
  }
}

// Main screen
class OrganizationChartScreen extends ConsumerStatefulWidget {
  const OrganizationChartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OrganizationChartScreen> createState() =>
      _OrganizationChartScreenState();
}

class _OrganizationChartScreenState
    extends ConsumerState<OrganizationChartScreen> {
  @override
  void initState() {
    super.initState();
    // Load sample data when the app starts
    Future.microtask(
      () => ref.read(orgChartProvider.notifier).loadSampleData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orgChartProvider);
    final isEditing = state.isEditing;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Chart Builder'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.visibility : Icons.edit),
            onPressed: () =>
                ref.read(orgChartProvider.notifier).toggleEditingMode(),
            tooltip: isEditing ? 'View Mode' : 'Edit Mode',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showConfigDialog(context),
            tooltip: 'Chart Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Side panel for editing (hidden on small screens or in view mode)
          if (!isSmallScreen && isEditing)
            SizedBox(width: 300, child: EditorPanel()),

          // Main chart view
          Expanded(child: OrganizationChartView()),
        ],
      ),
      // Show bottom sheet editor on small screens
      floatingActionButton: isEditing
          ? FloatingActionButton(
              onPressed: () => _showAddEntityDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Add Entity',
            )
          : null,
      drawer: isSmallScreen && isEditing ? Drawer(child: EditorPanel()) : null,
    );
  }

  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChartConfigDialog(),
    );
  }

  void _showAddEntityDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddEntityDialog());
  }
}

// Editor panel for managing entities
class EditorPanel extends ConsumerWidget {
  const EditorPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orgChartProvider);

    return Material(
      elevation: 4,
      child: Container(
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Organization Editor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showAddEntityDialog(context),
                    tooltip: 'Add Entity',
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Departments'),
                        Tab(text: 'Positions'),
                        Tab(text: 'Employees'),
                      ],
                      labelColor: Theme.of(context).primaryColor,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildEntityList(
                            context,
                            state.departments.values.toList(),
                            (entity) =>
                                _editDepartment(context, entity as Department),
                            ref,
                          ),
                          _buildEntityList(
                            context,
                            state.positions.values.toList(),
                            (entity) =>
                                _editPosition(context, entity as Position),
                            ref,
                          ),
                          _buildEntityList(
                            context,
                            state.employees.values.toList(),
                            (entity) =>
                                _editEmployee(context, entity as Employee),
                            ref,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityList(
    BuildContext context,
    List<OrgEntity> entities,
    Function(OrgEntity) onEdit,
    WidgetRef ref,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: entity.color,
              child: Text(
                entity.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(entity.name),
            subtitle: _getEntitySubtitle(entity),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => onEdit(entity),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _confirmDelete(context, entity, ref),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getEntitySubtitle(OrgEntity entity) {
    if (entity is Department) {
      return Text('${entity.childrenIds.length} children');
    } else if (entity is Position) {
      return Text('${entity.employeeIds.length} employees');
    } else if (entity is Employee) {
      return Text(entity.email);
    }
    return const SizedBox.shrink();
  }

  void _showAddEntityDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddEntityDialog());
  }

  void _editDepartment(BuildContext context, Department department) {
    // Implement department editing dialog
  }

  void _editPosition(BuildContext context, Position position) {
    // Implement position editing dialog
  }

  void _editEmployee(BuildContext context, Employee employee) {
    // Implement employee editing dialog
  }

  void _confirmDelete(BuildContext context, OrgEntity entity, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${entity.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(orgChartProvider.notifier).removeEntity(entity.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

// Dialog for adding entities
class AddEntityDialog extends ConsumerStatefulWidget {
  const AddEntityDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddEntityDialog> createState() => _AddEntityDialogState();
}

class _AddEntityDialogState extends ConsumerState<AddEntityDialog> {
  String _entityType = 'Department';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String? _selectedParentId;
  String? _selectedPositionId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add $_entityType'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Department',
                      label: Text('Department'),
                    ),
                    ButtonSegment(value: 'Position', label: Text('Position')),
                    ButtonSegment(value: 'Employee', label: Text('Employee')),
                  ],
                  selected: {_entityType},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _entityType = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_entityType == 'Employee') ...[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPositionDropdown(),
                ] else if (_entityType == 'Position') ...[
                  _buildDepartmentDropdown(),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Color: '),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveEntity, child: const Text('Save')),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    final departments = ref.watch(orgChartProvider).departments;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Parent Department',
        border: OutlineInputBorder(),
      ),
      value: _selectedParentId,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('None (Top Level)'),
        ),
        ...departments.values.map(
          (dept) =>
              DropdownMenuItem<String>(value: dept.id, child: Text(dept.name)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedParentId = value;
        });
      },
    );
  }

  Widget _buildPositionDropdown() {
    final positions = ref.watch(orgChartProvider).positions;

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Position',
        border: OutlineInputBorder(),
      ),
      value: _selectedPositionId,
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('None (Unassigned)'),
        ),
        ...positions.values.map(
          (pos) =>
              DropdownMenuItem<String>(value: pos.id, child: Text(pos.name)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPositionId = value;
        });
      },
    );
  }

  void _showColorPicker() {
    // Simple color picker implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.deepPurple,
                      Colors.indigo,
                      Colors.blue,
                      Colors.lightBlue,
                      Colors.cyan,
                      Colors.teal,
                      Colors.green,
                      Colors.lightGreen,
                      Colors.lime,
                      Colors.yellow,
                      Colors.amber,
                      Colors.orange,
                      Colors.deepOrange,
                      Colors.brown,
                      Colors.grey,
                      Colors.blueGrey,
                    ]
                    .map(
                      (color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveEntity() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(orgChartProvider.notifier);

      switch (_entityType) {
        case 'Department':
          final department = Department(
            name: _nameController.text,
            color: _selectedColor,
          );
          notifier.addDepartment(department);
          break;
        case 'Position':
          final position = Position(
            name: _nameController.text,
            color: _selectedColor,
            parentDepartmentId: _selectedParentId,
          );
          notifier.addPosition(position);
          break;
        case 'Employee':
          final employee = Employee(
            name: _nameController.text,
            color: _selectedColor,
            email: _emailController.text,
            positionId: _selectedPositionId,
          );
          notifier.addEmployee(employee);
          break;
      }

      Navigator.of(context).pop();
    }
  }
}

// Dialog for chart configuration
class ChartConfigDialog extends ConsumerStatefulWidget {
  const ChartConfigDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<ChartConfigDialog> createState() => _ChartConfigDialogState();
}

class _ChartConfigDialogState extends ConsumerState<ChartConfigDialog> {
  late double _nodeSpacing;
  late double _levelSpacing;
  late ConnectionStyle _connectionStyle;
  late bool _centerOnParent;
  late Color _connectionColor;
  late double _connectionThickness;

  @override
  void initState() {
    super.initState();
    final config = ref.read(orgChartProvider).config;
    _nodeSpacing = config.nodeSpacing;
    _levelSpacing = config.levelSpacing;
    _connectionStyle = config.connectionStyle;
    _centerOnParent = config.centerOnParent;
    _connectionColor = config.connectionColor;
    _connectionThickness = config.connectionThickness;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chart Configuration'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Node Spacing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _nodeSpacing,
                min: 20,
                max: 150,
                divisions: 13,
                label: _nodeSpacing.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _nodeSpacing = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Level Spacing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _levelSpacing,
                min: 50,
                max: 200,
                divisions: 15,
                label: _levelSpacing.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _levelSpacing = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              const Text(
                'Connection Style',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<ConnectionStyle>(
                value: _connectionStyle,
                items: ConnectionStyle.values
                    .map(
                      (style) => DropdownMenuItem<ConnectionStyle>(
                        value: style,
                        child: Text(style.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _connectionStyle = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _centerOnParent,
                    onChanged: (value) {
                      setState(() {
                        _centerOnParent = value ?? false;
                      });
                    },
                  ),
                  const Text('Center Children on Parent'),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Text('Connection Color: '),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _connectionColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Connection Thickness',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _connectionThickness,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                label: _connectionThickness.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _connectionThickness = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final config = OrgChartConfig(
              nodeSpacing: _nodeSpacing,
              levelSpacing: _levelSpacing,
              connectionStyle: _connectionStyle,
              centerOnParent: _centerOnParent,
              connectionColor: _connectionColor,
              connectionThickness: _connectionThickness,
            );
            ref.read(orgChartProvider.notifier).updateConfig(config);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  void _showColorPicker() {
    // Simple color picker implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      Colors.black,
                      Colors.grey.shade800,
                      Colors.grey.shade600,
                      Colors.grey.shade400,
                      Colors.grey.shade200,
                      Colors.blue,
                      Colors.indigo,
                      Colors.purple,
                      Colors.pink,
                      Colors.red,
                      Colors.orange,
                      Colors.amber,
                      Colors.yellow,
                      Colors.lime,
                      Colors.green,
                      Colors.teal,
                      Colors.cyan,
                    ]
                    .map(
                      (color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _connectionColor = color;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// org_chart_view.dart

class OrganizationChartView extends ConsumerWidget {
  const OrganizationChartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orgChartProvider);

    if (state.rootDepartmentId == null) {
      return const Center(
        child: Text('No departments yet. Add a department to get started.'),
      );
    }

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 2.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: OrgChart(
            rootId: state.rootDepartmentId!,
            departments: state.departments,
            positions: state.positions,
            employees: state.employees,
            config: state.config,
            isEditing: state.isEditing,
          ),
        ),
      ),
    );
  }
}

class OrgChart extends ConsumerStatefulWidget {
  final String rootId;
  final Map<String, Department> departments;
  final Map<String, Position> positions;
  final Map<String, Employee> employees;
  final OrgChartConfig config;
  final bool isEditing;

  const OrgChart({
    Key? key,
    required this.rootId,
    required this.departments,
    required this.positions,
    required this.employees,
    required this.config,
    required this.isEditing,
  }) : super(key: key);

  @override
  ConsumerState<OrgChart> createState() => _OrgChartState();
}

class _OrgChartState extends ConsumerState<OrgChart> {
  // Map to store node positions
  final Map<String, Offset> _nodePositions = {};
  final Map<String, Size> _nodeSizes = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Clear positions for rebuild
        _nodePositions.clear();
        _nodeSizes.clear();

        return CustomPaint(
          painter: ConnectionsPainter(
            nodePositions: _nodePositions,
            nodeSizes: _nodeSizes,
            departments: widget.departments,
            positions: widget.positions,
            config: widget.config,
          ),
          child: _buildOrgChart(widget.rootId),
        );
      },
    );
  }

  Widget _buildOrgChart(String nodeId) {
    // Check if it's a department or position
    if (widget.departments.containsKey(nodeId)) {
      return _buildDepartmentNode(widget.departments[nodeId]!);
    } else if (widget.positions.containsKey(nodeId)) {
      return _buildPositionNode(widget.positions[nodeId]!);
    }

    // Fallback if ID is not found
    return const SizedBox.shrink();
  }

  Widget _buildDepartmentNode(Department department) {
    final children = department.childrenIds
        .map((id) => _buildOrgChart(id))
        .toList();

    return OrgChartNode(
      id: department.id,
      onPositionChanged: (id, position, size) {
        _nodePositions[id] = position;
        _nodeSizes[id] = size;
      },
      spacing: widget.config.nodeSpacing,
      levelSpacing: widget.config.levelSpacing,
      centerOnParent: widget.config.centerOnParent,
      content: DepartmentCard(
        department: department,
        isEditing: widget.isEditing,
      ),
      children: children,
    );
  }

  Widget _buildPositionNode(Position position) {
    // Get employees for this position
    final positionEmployees = position.employeeIds
        .map((id) => widget.employees[id])
        .where((e) => e != null)
        .cast<Employee>()
        .toList();

    return OrgChartNode(
      id: position.id,
      onPositionChanged: (id, position, size) {
        _nodePositions[id] = position;
        _nodeSizes[id] = size;
      },
      spacing: widget.config.nodeSpacing,
      levelSpacing: widget.config.levelSpacing,
      centerOnParent: widget.config.centerOnParent,
      content: PositionCard(
        position: position,
        employees: positionEmployees,
        isEditing: widget.isEditing,
      ),
      children: const [], // Positions don't have structural children
    );
  }
}

// Node layout component for the org chart
class OrgChartNode extends StatefulWidget {
  final String id;
  final Function(String, Offset, Size) onPositionChanged;
  final double spacing;
  final double levelSpacing;
  final bool centerOnParent;
  final Widget content;
  final List<Widget> children;

  const OrgChartNode({
    Key? key,
    required this.id,
    required this.onPositionChanged,
    required this.spacing,
    required this.levelSpacing,
    required this.centerOnParent,
    required this.content,
    required this.children,
  }) : super(key: key);

  @override
  State<OrgChartNode> createState() => _OrgChartNodeState();
}

class _OrgChartNodeState extends State<OrgChartNode> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  @override
  void didUpdateWidget(OrgChartNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  void _updatePosition() {
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      widget.onPositionChanged(widget.id, position, size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The node content
        Container(key: _key, child: widget.content),

        if (widget.children.isNotEmpty) ...[
          SizedBox(height: widget.levelSpacing),

          // Children layout
          widget.centerOnParent
              ? _buildCenteredChildren()
              : _buildFlowChildren(),
        ],
      ],
    );
  }

  Widget _buildCenteredChildren() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.children.length; i++) ...[
              if (i > 0) SizedBox(width: widget.spacing),
              widget.children[i],
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFlowChildren() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) SizedBox(width: widget.spacing),
          widget.children[i],
        ],
      ],
    );
  }
}

// Department card UI
class DepartmentCard extends ConsumerWidget {
  final Department department;
  final bool isEditing;

  const DepartmentCard({
    Key? key,
    required this.department,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      color: department.color.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: department.color, width: 2),
      ),
      child: InkWell(
        onTap: isEditing ? () => _showEditDialog(context, ref) : null,
        child: Container(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 180),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                department.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${department.childrenIds.length} ${department.childrenIds.length == 1 ? 'item' : 'items'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // Implement edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Department'),
        content: Text('Editing functionality to be implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Position card UI
class PositionCard extends ConsumerWidget {
  final Position position;
  final List<Employee> employees;
  final bool isEditing;

  const PositionCard({
    Key? key,
    required this.position,
    required this.employees,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: position.color, width: 2),
      ),
      child: InkWell(
        onTap: isEditing ? () => _showEditDialog(context, ref) : null,
        child: Container(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 160),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: position.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                position.name,
                style: TextStyle(
                  color: position.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (employees.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...employees.map((employee) => _buildEmployeeItem(employee)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeItem(Employee employee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: employee.color,
            child: Text(
              employee.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              employee.name,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // Implement edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Position'),
        content: Text('Editing functionality to be implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for drawing connections between nodes
class ConnectionsPainter extends CustomPainter {
  final Map<String, Offset> nodePositions;
  final Map<String, Size> nodeSizes;
  final Map<String, Department> departments;
  final Map<String, Position> positions;
  final OrgChartConfig config;

  ConnectionsPainter({
    required this.nodePositions,
    required this.nodeSizes,
    required this.departments,
    required this.positions,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = config.connectionColor
      ..strokeWidth = config.connectionThickness
      ..style = PaintingStyle.stroke;

    // Draw connections for each department
    for (final department in departments.values) {
      _drawDepartmentConnections(canvas, department, paint);
    }
  }

  void _drawDepartmentConnections(
    Canvas canvas,
    Department department,
    Paint paint,
  ) {
    final parentId = department.id;
    final parentPos = nodePositions[parentId];
    final parentSize = nodeSizes[parentId];

    if (parentPos == null || parentSize == null) return;

    final parentBottom = Offset(
      parentPos.dx + (parentSize.width / 2),
      parentPos.dy + parentSize.height,
    );

    for (final childId in department.childrenIds) {
      final childPos = nodePositions[childId];
      final childSize = nodeSizes[childId];

      if (childPos == null || childSize == null) continue;

      final childTop = Offset(childPos.dx + (childSize.width / 2), childPos.dy);

      _drawConnection(canvas, parentBottom, childTop, paint);
    }
  }

  void _drawConnection(Canvas canvas, Offset start, Offset end, Paint paint) {
    switch (config.connectionStyle) {
      case ConnectionStyle.straight:
        canvas.drawLine(start, end, paint);
        break;

      case ConnectionStyle.curved:
        final path = Path();
        path.moveTo(start.dx, start.dy);

        final midY = start.dy + (end.dy - start.dy) / 2;
        path.cubicTo(start.dx, midY, end.dx, midY, end.dx, end.dy);

        canvas.drawPath(path, paint);
        break;

      case ConnectionStyle.orthogonal:
        final path = Path();
        path.moveTo(start.dx, start.dy);
        final midY = start.dy + (end.dy - start.dy) / 2;

        path.lineTo(start.dx, midY);
        path.lineTo(end.dx, midY);
        path.lineTo(end.dx, end.dy);

        canvas.drawPath(path, paint);
        break;

      case ConnectionStyle.stepped:
        final path = Path();
        path.moveTo(start.dx, start.dy);

        path.lineTo(start.dx, start.dy + 10);
        path.lineTo(end.dx, end.dy - 10);
        path.lineTo(end.dx, end.dy);

        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) {
    return nodePositions != oldDelegate.nodePositions ||
        nodeSizes != oldDelegate.nodeSizes ||
        departments != oldDelegate.departments ||
        positions != oldDelegate.positions ||
        config != oldDelegate.config;
  }
}

// Add export functionality
class ExportUtility {
  // Export to JSON
  static String exportToJson(OrgChartState state) {
    final Map<String, dynamic> data = {
      'departments': state.departments.map(
        (key, value) => MapEntry(key, {
          'id': value.id,
          'name': value.name,
          'color': value.color.value,
          'childrenIds': value.childrenIds,
        }),
      ),
      'positions': state.positions.map(
        (key, value) => MapEntry(key, {
          'id': value.id,
          'name': value.name,
          'color': value.color.value,
          'employeeIds': value.employeeIds,
          'parentDepartmentId': value.parentDepartmentId,
        }),
      ),
      'employees': state.employees.map(
        (key, value) => MapEntry(key, {
          'id': value.id,
          'name': value.name,
          'color': value.color.value,
          'email': value.email,
          'avatar': value.avatar,
          'positionId': value.positionId,
        }),
      ),
      'rootDepartmentId': state.rootDepartmentId,
      'config': {
        'nodeSpacing': state.config.nodeSpacing,
        'levelSpacing': state.config.levelSpacing,
        'connectionStyle': state.config.connectionStyle.toString(),
        'centerOnParent': state.config.centerOnParent,
        'connectionColor': state.config.connectionColor.value,
        'connectionThickness': state.config.connectionThickness,
      },
    };

    return jsonEncode(data);
  }

  // Import from JSON
  static OrgChartState importFromJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final departments = (data['departments'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        Department(
          id: value['id'] as String,
          name: value['name'] as String,
          color: Color(value['color'] as int),
          childrenIds: List<String>.from(value['childrenIds'] as List),
        ),
      ),
    );

    final positions = (data['positions'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        Position(
          id: value['id'] as String,
          name: value['name'] as String,
          color: Color(value['color'] as int),
          employeeIds: List<String>.from(value['employeeIds'] as List),
          parentDepartmentId: value['parentDepartmentId'] as String?,
        ),
      ),
    );

    final employees = (data['employees'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        Employee(
          id: value['id'] as String,
          name: value['name'] as String,
          color: Color(value['color'] as int),
          email: value['email'] as String,
          avatar: value['avatar'] as String?,
          positionId: value['positionId'] as String?,
        ),
      ),
    );

    final configData = data['config'] as Map<String, dynamic>;
    final connectionStyleStr = configData['connectionStyle'] as String;
    final connectionStyle = ConnectionStyle.values.firstWhere(
      (e) => e.toString() == connectionStyleStr,
      orElse: () => ConnectionStyle.orthogonal,
    );

    final config = OrgChartConfig(
      nodeSpacing: configData['nodeSpacing'] as double,
      levelSpacing: configData['levelSpacing'] as double,
      connectionStyle: connectionStyle,
      centerOnParent: configData['centerOnParent'] as bool,
      connectionColor: Color(configData['connectionColor'] as int),
      connectionThickness: configData['connectionThickness'] as double,
    );

    return OrgChartState(
      departments: departments,
      positions: positions,
      employees: employees,
      rootDepartmentId: data['rootDepartmentId'] as String?,
      config: config,
    );
  }

  // Generate a simple SVG representation of the org chart
  static String exportToSvg(OrgChartState state) {
    // Implementation for SVG export would go here
    // This would be a more complex implementation involving
    // positioning calculations and SVG generation
    return "SVG export not implemented yet";
  }
}

// Add additional imports needed for JSON export/import
