import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graphview/GraphView.dart';

// Models
class Position {
  final String id;
  final String title;
  final double salary;

  Position({required this.id, required this.title, required this.salary});
}

class Employee {
  final String id;
  final String name;
  final String imageUrl;
  final String positionId;
  final String departmentId;

  Employee({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.positionId,
    required this.departmentId,
  });
}

class Department {
  final String id;
  final String name;
  final String? parentDepartmentId;
  final Color color;

  Department({
    required this.id,
    required this.name,
    this.parentDepartmentId,
    required this.color,
  });
}

// State Management
class OrgChartProvider extends ChangeNotifier {
  List<Department> _departments = [];
  List<Employee> _employees = [];
  List<Position> _positions = [];

  // Editing mode
  bool _isEditMode = false;
  String? _selectedItemId;

  // Getters
  List<Department> get departments => _departments;
  List<Employee> get employees => _employees;
  List<Position> get positions => _positions;
  bool get isEditMode => _isEditMode;
  String? get selectedItemId => _selectedItemId;

  // Sample data initialization
  void initSampleData() {
    // Add departments
    _departments = [
      Department(id: 'd1', name: 'Executive', color: Colors.blue.shade700),
      Department(
        id: 'd2',
        name: 'Engineering',
        parentDepartmentId: 'd1',
        color: Colors.green.shade600,
      ),
      Department(
        id: 'd3',
        name: 'Marketing',
        parentDepartmentId: 'd1',
        color: Colors.purple.shade600,
      ),
      Department(
        id: 'd4',
        name: 'Frontend',
        parentDepartmentId: 'd2',
        color: Colors.teal.shade600,
      ),
      Department(
        id: 'd5',
        name: 'Backend',
        parentDepartmentId: 'd2',
        color: Colors.indigo.shade600,
      ),
    ];

    // Add positions
    _positions = [
      Position(id: 'p1', title: 'CEO', salary: 200000),
      Position(id: 'p2', title: 'CTO', salary: 180000),
      Position(id: 'p3', title: 'CMO', salary: 170000),
      Position(id: 'p4', title: 'Senior Developer', salary: 120000),
      Position(id: 'p5', title: 'Designer', salary: 90000),
    ];

    // Add employees
    _employees = [
      Employee(
        id: 'e1',
        name: 'Jane Smith',
        imageUrl: 'assets/avatar1.png',
        positionId: 'p1',
        departmentId: 'd1',
      ),
      Employee(
        id: 'e2',
        name: 'John Doe',
        imageUrl: 'assets/avatar2.png',
        positionId: 'p2',
        departmentId: 'd2',
      ),
      Employee(
        id: 'e3',
        name: 'Alice Johnson',
        imageUrl: 'assets/avatar3.png',
        positionId: 'p3',
        departmentId: 'd3',
      ),
      Employee(
        id: 'e4',
        name: 'Bob Williams',
        imageUrl: 'assets/avatar4.png',
        positionId: 'p4',
        departmentId: 'd4',
      ),
      Employee(
        id: 'e5',
        name: 'Carol Brown',
        imageUrl: 'assets/avatar5.png',
        positionId: 'p4',
        departmentId: 'd5',
      ),
    ];

    notifyListeners();
  }

  // CRUD Operations
  void addDepartment(Department department) {
    _departments.add(department);
    notifyListeners();
  }

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void addPosition(Position position) {
    _positions.add(position);
    notifyListeners();
  }

  void updateDepartment(Department department) {
    final index = _departments.indexWhere((d) => d.id == department.id);
    if (index != -1) {
      _departments[index] = department;
      notifyListeners();
    }
  }

  void updateEmployee(Employee employee) {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      _employees[index] = employee;
      notifyListeners();
    }
  }

  void updatePosition(Position position) {
    final index = _positions.indexWhere((p) => p.id == position.id);
    if (index != -1) {
      _positions[index] = position;
      notifyListeners();
    }
  }

  void deleteDepartment(String id) {
    _departments.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void deletePosition(String id) {
    _positions.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Mode and selection
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  void selectItem(String id) {
    _selectedItemId = id;
    notifyListeners();
  }

  // Helper methods
  Department? getDepartmentById(String id) {
    try {
      return _departments.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Employee? getEmployeeById(String id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Position? getPositionById(String id) {
    try {
      return _positions.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Department> getChildDepartments(String parentId) {
    return _departments.where((d) => d.parentDepartmentId == parentId).toList();
  }

  List<Employee> getEmployeesByDepartment(String departmentId) {
    return _employees.where((e) => e.departmentId == departmentId).toList();
  }
}

// UI Components
class OrgChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrgChartProvider()..initSampleData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Organization Chart Builder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: OrgChartScreen(),
      ),
    );
  }
}
// Replace the OrgChartScreen widget with this fixed version

class OrgChartScreen extends StatefulWidget {
  @override
  _OrgChartScreenState createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen>
    with SingleTickerProviderStateMixin {
  bool _showSidebar = true;
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Update selected tab index when tab changes
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrgChartProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Organization Chart Builder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(provider.isEditMode ? Icons.visibility : Icons.edit),
            tooltip: provider.isEditMode ? 'View Mode' : 'Edit Mode',
            onPressed: provider.toggleEditMode,
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              // Show search dialog
              showSearch(context: context, delegate: OrgChartSearch(provider));
            },
          ),
          if (isSmallScreen)
            IconButton(
              icon: Icon(_showSidebar ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _showSidebar = !_showSidebar;
                });
              },
            ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          if (_showSidebar && !isSmallScreen)
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Organization Elements',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController, // Add the controller here
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    tabs: [
                      Tab(text: 'Departments'),
                      Tab(text: 'Employees'),
                      Tab(text: 'Positions'),
                    ],
                    onTap: (index) {
                      setState(() {
                        // No need to update a separate index variable anymore
                      });
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController, // Add the controller here too
                      children: [
                        // Departments list
                        ListView.builder(
                          itemCount: provider.departments.length,
                          itemBuilder: (context, index) {
                            final department = provider.departments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: department.color,
                                child: Text(
                                  department.name.substring(0, 1),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(department.name),
                              subtitle:
                                  department.parentDepartmentId != null
                                      ? Text(
                                        'Parent: ${provider.getDepartmentById(department.parentDepartmentId!)?.name ?? "None"}',
                                      )
                                      : Text('Top Level'),
                              selected:
                                  provider.selectedItemId == department.id,
                              onTap: () => provider.selectItem(department.id),
                              trailing:
                                  provider.isEditMode
                                      ? PopupMenuButton(
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                child: Text('Edit'),
                                                value: 'edit',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Delete'),
                                                value: 'delete',
                                              ),
                                            ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            // Show edit dialog
                                          } else if (value == 'delete') {
                                            provider.deleteDepartment(
                                              department.id,
                                            );
                                          }
                                        },
                                      )
                                      : null,
                            );
                          },
                        ),

                        // Employees list
                        ListView.builder(
                          itemCount: provider.employees.length,
                          itemBuilder: (context, index) {
                            final employee = provider.employees[index];
                            final position = provider.getPositionById(
                              employee.positionId,
                            );
                            final department = provider.getDepartmentById(
                              employee.departmentId,
                            );

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(employee.imageUrl),
                              ),
                              title: Text(employee.name),
                              subtitle: Text(
                                '${position?.title ?? "Unknown"} - ${department?.name ?? "Unknown"}',
                              ),
                              selected: provider.selectedItemId == employee.id,
                              onTap: () => provider.selectItem(employee.id),
                              trailing:
                                  provider.isEditMode
                                      ? PopupMenuButton(
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                child: Text('Edit'),
                                                value: 'edit',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Delete'),
                                                value: 'delete',
                                              ),
                                            ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            // Show edit dialog
                                          } else if (value == 'delete') {
                                            provider.deleteEmployee(
                                              employee.id,
                                            );
                                          }
                                        },
                                      )
                                      : null,
                            );
                          },
                        ),

                        // Positions list
                        ListView.builder(
                          itemCount: provider.positions.length,
                          itemBuilder: (context, index) {
                            final position = provider.positions[index];

                            return ListTile(
                              leading: Icon(Icons.work),
                              title: Text(position.title),
                              subtitle: Text(
                                '\$${position.salary.toStringAsFixed(0)}',
                              ),
                              selected: provider.selectedItemId == position.id,
                              onTap: () => provider.selectItem(position.id),
                              trailing:
                                  provider.isEditMode
                                      ? PopupMenuButton(
                                        itemBuilder:
                                            (context) => [
                                              PopupMenuItem(
                                                child: Text('Edit'),
                                                value: 'edit',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Delete'),
                                                value: 'delete',
                                              ),
                                            ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            // Show edit dialog
                                          } else if (value == 'delete') {
                                            provider.deletePosition(
                                              position.id,
                                            );
                                          }
                                        },
                                      )
                                      : null,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Add buttons
                  if (provider.isEditMode)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text(
                          _tabController.index == 0
                              ? 'Add Department'
                              : _tabController.index == 1
                              ? 'Add Employee'
                              : 'Add Position',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: Size(double.infinity, 48),
                        ),
                        onPressed: () {
                          // Show add dialog based on selected tab
                          if (_tabController.index == 0) {
                            _showDepartmentDialog(context);
                          } else if (_tabController.index == 1) {
                            _showEmployeeDialog(context);
                          } else {
                            _showPositionDialog(context);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Rest of the build method remains the same...

          // Drawer for mobile
          if (isSmallScreen)
            Drawer(
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Center(
                      child: Text(
                        'Org Chart Elements',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.corporate_fare),
                    title: Text('Departments'),
                    selected: _selectedTabIndex == 0,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                        _showSidebar = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Employees'),
                    selected: _selectedTabIndex == 1,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                        _showSidebar = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.work),
                    title: Text('Positions'),
                    selected: _selectedTabIndex == 2,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 2;
                        _showSidebar = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                  if (provider.isEditMode)
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Add New'),
                      onTap: () {
                        Navigator.pop(context);
                        if (_selectedTabIndex == 0) {
                          _showDepartmentDialog(context);
                        } else if (_selectedTabIndex == 1) {
                          _showEmployeeDialog(context);
                        } else {
                          _showPositionDialog(context);
                        }
                      },
                    ),
                ],
              ),
            ),

          // Main content area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chart header
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organization Chart',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${provider.departments.length} Departments, ${provider.employees.length} Employees',
                              ),
                              Spacer(),
                              ToggleButtons(
                                children: [
                                  Tooltip(
                                    message: 'Tree View',
                                    child: Icon(Icons.account_tree),
                                  ),
                                  Tooltip(
                                    message: 'Grid View',
                                    child: Icon(Icons.grid_view),
                                  ),
                                ],
                                isSelected: [true, false],
                                onPressed: (index) {
                                  // Toggle view type
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Chart visualization
                  Expanded(child: OrganizationChartView(provider)),
                ],
              ),
            ),
          ),
        ],
      ),
      // FAB for mobile
      floatingActionButton:
          isSmallScreen && provider.isEditMode
              ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () {
                  if (_selectedTabIndex == 0) {
                    _showDepartmentDialog(context);
                  } else if (_selectedTabIndex == 1) {
                    _showEmployeeDialog(context);
                  } else {
                    _showPositionDialog(context);
                  }
                },
              )
              : null,
    );
  }

  void _showDepartmentDialog(BuildContext context) {
    final provider = Provider.of<OrgChartProvider>(context, listen: false);
    final nameController = TextEditingController();
    String? parentId;
    Color color = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Department'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Department Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      decoration: InputDecoration(
                        labelText: 'Parent Department',
                        border: OutlineInputBorder(),
                      ),
                      value: parentId,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('None (Top Level)'),
                        ),
                        ...provider.departments.map(
                          (dept) => DropdownMenuItem<String?>(
                            value: dept.id,
                            child: Text(dept.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          parentId = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Department Color:'),
                        SizedBox(width: 16),
                        CircleAvatar(backgroundColor: color, radius: 16),
                        SizedBox(width: 8),
                        TextButton(
                          child: Text('Change'),
                          onPressed: () {
                            // Show color picker
                            setState(() {
                              // In a real app, this would open a color picker
                              // For simplicity, we'll just cycle through some colors
                              final colors = [
                                Color(0xFF2196F3), // blue
                                Color(0xFFF44336), // red
                                Color(0xFF4CAF50), // green
                                Color(0xFF9C27B0), // purple
                                Color(0xFFFF9800), // orange
                                Color(0xFF009688), // teal
                              ];

                              final currentIndex = colors.indexOf(color);
                              color =
                                  colors[(currentIndex + 1) % colors.length];
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      provider.addDepartment(
                        Department(
                          id: 'd${provider.departments.length + 1}',
                          name: nameController.text,
                          parentDepartmentId: parentId,
                          color: color,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEmployeeDialog(BuildContext context) {
    final provider = Provider.of<OrgChartProvider>(context, listen: false);
    final nameController = TextEditingController();
    String? departmentId;
    String? positionId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Employee'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Employee Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      value: departmentId,
                      items:
                          provider.departments
                              .map(
                                (dept) => DropdownMenuItem<String?>(
                                  value: dept.id,
                                  child: Text(dept.name),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          departmentId = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      decoration: InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(),
                      ),
                      value: positionId,
                      items:
                          provider.positions
                              .map(
                                (pos) => DropdownMenuItem<String?>(
                                  value: pos.id,
                                  child: Text(pos.title),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          positionId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        departmentId != null &&
                        positionId != null) {
                      provider.addEmployee(
                        Employee(
                          id: 'e${provider.employees.length + 1}',
                          name: nameController.text,
                          imageUrl:
                              'assets/avatar${(provider.employees.length % 5) + 1}.png',
                          departmentId: departmentId!,
                          positionId: positionId!,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPositionDialog(BuildContext context) {
    final provider = Provider.of<OrgChartProvider>(context, listen: false);
    final titleController = TextEditingController();
    final salaryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Position'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Position Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: salaryController,
                  decoration: InputDecoration(
                    labelText: 'Salary',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    salaryController.text.isNotEmpty) {
                  provider.addPosition(
                    Position(
                      id: 'p${provider.positions.length + 1}',
                      title: titleController.text,
                      salary: double.tryParse(salaryController.text) ?? 0,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class OrganizationChartView extends StatelessWidget {
  final OrgChartProvider provider;

  OrganizationChartView(this.provider);

  @override
  Widget build(BuildContext context) {
    // Build the graph nodes and edges
    final Graph graph = Graph();
    final builder = SugiyamaConfiguration();

    // Add nodes for departments
    final Map<String, Node> departmentNodes = {};
    for (final department in provider.departments) {
      final node = Node.Id(department.id);
      graph.addNode(node);
      departmentNodes[department.id] = node;

      // Add edge if there's a parent
      if (department.parentDepartmentId != null &&
          departmentNodes.containsKey(department.parentDepartmentId)) {
        graph.addEdge(departmentNodes[department.parentDepartmentId]!, node);
      }
    }

    builder.nodeSeparation = 100;
    builder.levelSeparation = 100;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(100),
          minScale: 0.1,
          maxScale: 2.0,
          child: GraphView(
            graph: graph,
            algorithm: SugiyamaAlgorithm(builder),
            paint:
                Paint()
                  ..color = Colors.grey.shade400
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
            builder: (Node node) {
              // Get department from node
              final departmentId = node.key!.value as String;
              final department = provider.getDepartmentById(departmentId);

              if (department == null) {
                return Container();
              }

              // Get employees for this department
              final employees = provider.getEmployeesByDepartment(departmentId);

              return Card(
                color: department.color.withValues(alpha: 0.2),
                elevation: 4,
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: department.color, width: 2),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  constraints: BoxConstraints(minWidth: 200, maxWidth: 280),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Department header
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: department.color,
                            child: Text(
                              department.name.substring(0, 1),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              department.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24),

                      // Employee cards inside department
                      if (employees.isNotEmpty) ...[
                        Text(
                          '${employees.length} Employee${employees.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...employees.map((employee) {
                          final position = provider.getPositionById(
                            employee.positionId,
                          );
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(employee.imageUrl),
                                radius: 16,
                              ),
                              title: Text(
                                employee.name,
                                style: TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                position?.title ?? 'Unknown Position',
                                style: TextStyle(fontSize: 12),
                              ),
                              dense: true,
                              onTap: () => provider.selectItem(employee.id),
                            ),
                          );
                        }).toList(),
                      ] else
                        Text(
                          'No employees',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      // Add employee button when in edit mode
                      if (provider.isEditMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.person_add, size: 16),
                            label: Text('Add Employee'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 36),
                              foregroundColor: department.color,
                              side: BorderSide(color: department.color),
                            ),
                            onPressed: () {
                              // Pre-select this department when adding an employee
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OrgChartSearch extends SearchDelegate {
  final OrgChartProvider provider;

  OrgChartSearch(this.provider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    final departments =
        provider.departments
            .where(
              (dept) => dept.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    final employees =
        provider.employees
            .where(
              (emp) => emp.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    final positions =
        provider.positions
            .where(
              (pos) => pos.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    if (query.isEmpty) {
      return Center(
        child: Text('Search for departments, employees, or positions'),
      );
    }

    if (departments.isEmpty && employees.isEmpty && positions.isEmpty) {
      return Center(child: Text('No results found for "$query"'));
    }

    return ListView(
      children: [
        if (departments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Departments',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...departments.map(
            (department) => ListTile(
              leading: CircleAvatar(
                backgroundColor: department.color,
                child: Text(
                  department.name.substring(0, 1),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(department.name),
              onTap: () {
                provider.selectItem(department.id);
                // Close search
              },
            ),
          ),
        ],

        if (employees.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Employees',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...employees.map((employee) {
            final position = provider.getPositionById(employee.positionId);
            final department = provider.getDepartmentById(
              employee.departmentId,
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(employee.imageUrl),
              ),
              title: Text(employee.name),
              subtitle: Text(
                '${position?.title ?? "Unknown"} - ${department?.name ?? "Unknown"}',
              ),
              onTap: () {
                provider.selectItem(employee.id);
                // Close search
              },
            );
          }),
        ],

        if (positions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Positions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...positions.map(
            (position) => ListTile(
              leading: Icon(Icons.work),
              title: Text(position.title),
              subtitle: Text('\$${position.salary.toStringAsFixed(0)}'),
              onTap: () {
                provider.selectItem(position.id);
                // Close search
              },
            ),
          ),
        ],
      ],
    );
  }
}

void main() {
  runApp(OrgChartApp());
}
