// main.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

void main() {
  runApp(const ProviderScope(child: TeamManagementApp()));
}

class TeamManagementApp extends StatelessWidget {
  const TeamManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}

// theme/app_theme.dart

class AppTheme {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color darkBackgroundColor = Color(0xFF121212);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        background: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: primaryColor),
        selectedLabelTextStyle: TextStyle(color: primaryColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        background: darkBackgroundColor,
      ),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: secondaryColor),
        selectedLabelTextStyle: TextStyle(color: secondaryColor),
      ),
    );
  }
}

// models/team_member.dart
class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarUrl;
  final List<String> projects;
  final Map<String, bool> permissions;
  final int workload; // 0-100 percentage

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.projects,
    required this.permissions,
    required this.workload,
  });

  TeamMember copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    List<String>? projects,
    Map<String, bool>? permissions,
    int? workload,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      projects: projects ?? this.projects,
      permissions: permissions ?? this.permissions,
      workload: workload ?? this.workload,
    );
  }
}

// models/role.dart
class Role {
  final String id;
  final String name;
  final Map<String, bool> defaultPermissions;

  const Role({
    required this.id,
    required this.name,
    required this.defaultPermissions,
  });
}

// providers/team_provider.dart

final teamMembersProvider =
    StateNotifierProvider<TeamMembersNotifier, List<TeamMember>>((ref) {
      return TeamMembersNotifier();
    });

class TeamMembersNotifier extends StateNotifier<List<TeamMember>> {
  TeamMembersNotifier()
    : super([
        TeamMember(
          id: '1',
          name: 'Alex Johnson',
          email: 'alex@example.com',
          role: 'Project Manager',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          projects: ['Mobile App', 'Website Redesign'],
          permissions: {
            'view_team': true,
            'edit_team': true,
            'delete_team': true,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': true,
          },
          workload: 80,
        ),
        TeamMember(
          id: '2',
          name: 'Samantha Lee',
          email: 'samantha@example.com',
          role: 'Developer',
          avatarUrl: 'https://i.pravatar.cc/150?img=5',
          projects: ['Mobile App'],
          permissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': true,
          },
          workload: 65,
        ),
        TeamMember(
          id: '3',
          name: 'Miguel Rodriguez',
          email: 'miguel@example.com',
          role: 'Designer',
          avatarUrl: 'https://i.pravatar.cc/150?img=3',
          projects: ['Website Redesign', 'Brand Identity'],
          permissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': true,
          },
          workload: 50,
        ),
        TeamMember(
          id: '4',
          name: 'Taylor Swift',
          email: 'taylor@example.com',
          role: 'Developer',
          avatarUrl: 'https://i.pravatar.cc/150?img=9',
          projects: ['Mobile App', 'API Integration'],
          permissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': false,
          },
          workload: 90,
        ),
        TeamMember(
          id: '5',
          name: 'Jordan Smith',
          email: 'jordan@example.com',
          role: 'QA Engineer',
          avatarUrl: 'https://i.pravatar.cc/150?img=7',
          projects: ['Mobile App', 'Website Redesign'],
          permissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': false,
            'view_analytics': true,
          },
          workload: 70,
        ),
      ]);

  void addMember(TeamMember member) {
    state = [...state, member];
  }

  void updateMember(String id, TeamMember updatedMember) {
    state = [
      for (final member in state)
        if (member.id == id) updatedMember else member,
    ];
  }

  void deleteMember(String id) {
    state = state.where((member) => member.id != id).toList();
  }

  void updateMemberPermission(String memberId, String permission, bool value) {
    state = [
      for (final member in state)
        if (member.id == memberId)
          member.copyWith(
            permissions: {...member.permissions, permission: value},
          )
        else
          member,
    ];
  }

  void updateMemberWorkload(String memberId, int workload) {
    state = [
      for (final member in state)
        if (member.id == memberId)
          member.copyWith(workload: workload)
        else
          member,
    ];
  }
}

// providers/roles_provider.dart

final rolesProvider = StateNotifierProvider<RolesNotifier, List<Role>>((ref) {
  return RolesNotifier();
});

class RolesNotifier extends StateNotifier<List<Role>> {
  RolesNotifier()
    : super([
        Role(
          id: '1',
          name: 'Administrator',
          defaultPermissions: {
            'view_team': true,
            'edit_team': true,
            'delete_team': true,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': true,
          },
        ),
        Role(
          id: '2',
          name: 'Project Manager',
          defaultPermissions: {
            'view_team': true,
            'edit_team': true,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': true,
          },
        ),
        Role(
          id: '3',
          name: 'Developer',
          defaultPermissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': false,
          },
        ),
        Role(
          id: '4',
          name: 'Designer',
          defaultPermissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': true,
            'view_analytics': false,
          },
        ),
        Role(
          id: '5',
          name: 'QA Engineer',
          defaultPermissions: {
            'view_team': true,
            'edit_team': false,
            'delete_team': false,
            'view_projects': true,
            'edit_projects': false,
            'view_analytics': true,
          },
        ),
      ]);

  void addRole(Role role) {
    state = [...state, role];
  }

  void updateRole(String id, Role updatedRole) {
    state = [
      for (final role in state)
        if (role.id == id) updatedRole else role,
    ];
  }

  void deleteRole(String id) {
    state = state.where((role) => role.id != id).toList();
  }
}

// providers/view_provider.dart

enum ViewType { directory, permissions, workload }

final selectedViewProvider = StateProvider<ViewType>((ref) {
  return ViewType.directory;
});

// screens/dashboard_screen.dart

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedView = ref.watch(selectedViewProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Row(
        children: [
          const AppSideNav(),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTitle(selectedView),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      _buildActionButton(context, selectedView),
                    ],
                  ),
                ),
                Expanded(child: _buildSelectedView(selectedView, screenWidth)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(ViewType viewType) {
    switch (viewType) {
      case ViewType.directory:
        return 'Team Directory';
      case ViewType.permissions:
        return 'Roles & Permissions';
      case ViewType.workload:
        return 'Team Workload';
    }
  }

  Widget _buildActionButton(BuildContext context, ViewType viewType) {
    switch (viewType) {
      case ViewType.directory:
        return ElevatedButton.icon(
          onPressed: () {
            // Add member functionality would go here
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Add Member'),
        );
      case ViewType.permissions:
        return ElevatedButton.icon(
          onPressed: () {
            // Add role functionality would go here
          },
          icon: const Icon(Icons.add_circle),
          label: const Text('Add Role'),
        );
      case ViewType.workload:
        return ElevatedButton.icon(
          onPressed: () {
            // Refresh workload data functionality would go here
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Data'),
        );
    }
  }

  Widget _buildSelectedView(ViewType viewType, double screenWidth) {
    switch (viewType) {
      case ViewType.directory:
        return const DirectoryView();
      case ViewType.permissions:
        return const PermissionsView();
      case ViewType.workload:
        return const WorkloadView();
    }
  }
}

// widgets/app_side_nav.dart

class AppSideNav extends ConsumerWidget {
  const AppSideNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedView = ref.watch(selectedViewProvider);

    return NavigationRail(
      extended: true,
      minExtendedWidth: 200,
      selectedIndex: selectedView.index,
      onDestinationSelected: (index) {
        ref.read(selectedViewProvider.notifier).state = ViewType.values[index];
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Directory'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.security_outlined),
          selectedIcon: Icon(Icons.security),
          label: Text('Permissions'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Workload'),
        ),
      ],
    );
  }
}

// widgets/directory_view.dart

class DirectoryView extends ConsumerWidget {
  const DirectoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return MemberCard(member: member);
        },
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final TeamMember member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(member.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        member.role,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        member.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Member options menu
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Projects:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  member.projects.map((project) {
                    return Chip(
                      label: Text(project),
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workload: ${member.workload}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: member.workload / 100,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    color: _getWorkloadColor(member.workload, context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getWorkloadColor(int workload, BuildContext context) {
    if (workload < 50) {
      return Colors.green;
    } else if (workload < 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// widgets/permissions_view.dart

class PermissionsView extends ConsumerWidget {
  const PermissionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    final teamMembers = ref.watch(teamMembersProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Roles section
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: roles.length,
                        itemBuilder: (context, index) {
                          final role = roles[index];
                          return ListTile(
                            title: Text(role.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Edit role
                              },
                            ),
                            onTap: () {
                              // Select role
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Permissions section
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Permission')),
                              for (final role in roles)
                                DataColumn(label: Text(role.name)),
                            ],
                            rows: [
                              _buildPermissionRow(
                                'View Team',
                                'view_team',
                                roles,
                                ref,
                              ),
                              _buildPermissionRow(
                                'Edit Team',
                                'edit_team',
                                roles,
                                ref,
                              ),
                              _buildPermissionRow(
                                'Delete Team',
                                'delete_team',
                                roles,
                                ref,
                              ),
                              _buildPermissionRow(
                                'View Projects',
                                'view_projects',
                                roles,
                                ref,
                              ),
                              _buildPermissionRow(
                                'Edit Projects',
                                'edit_projects',
                                roles,
                                ref,
                              ),
                              _buildPermissionRow(
                                'View Analytics',
                                'view_analytics',
                                roles,
                                ref,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildPermissionRow(
    String label,
    String permissionKey,
    List<Role> roles,
    WidgetRef ref,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(label)),
        for (final role in roles)
          DataCell(
            Checkbox(
              value: role.defaultPermissions[permissionKey] ?? false,
              onChanged: (value) {
                // Update permission
              },
            ),
          ),
      ],
    );
  }
}

// widgets/workload_view.dart

class WorkloadView extends ConsumerWidget {
  const WorkloadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamMembers = ref.watch(teamMembersProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart section
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Workload Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Expanded(child: BarChartWidget(members: teamMembers)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details section
          Expanded(
            flex: 1,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workload Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: teamMembers.length,
                        itemBuilder: (context, index) {
                          final member = teamMembers[index];
                          return WorkloadListItem(member: member);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final List<TeamMember> members;

  const BarChartWidget({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            //tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${members[groupIndex].name}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${rod.toY.round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < members.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      members[value.toInt()].name.split(
                        ' ',
                      )[0], // Just the first name
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${value.toInt()}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              interval: 20,
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, horizontalInterval: 20),
        barGroups:
            members.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: member.workload.toDouble(),
                    color: _getWorkloadColor(member.workload),
                    width: 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Color _getWorkloadColor(int workload) {
    if (workload < 50) {
      return Colors.green;
    } else if (workload < 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class WorkloadListItem extends ConsumerWidget {
  final TeamMember member;

  const WorkloadListItem({super.key, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      member.role,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: member.workload.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: '${member.workload}%',
                    activeColor: _getWorkloadColor(member.workload),
                    onChanged: (value) {
                      ref
                          .read(teamMembersProvider.notifier)
                          .updateMemberWorkload(member.id, value.round());
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${member.workload}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Color _getWorkloadColor(int workload) {
    if (workload < 50) {
      return Colors.green;
    } else if (workload < 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// Add a member form dialog
class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'Developer';
  final List<String> _selectedProjects = [];
  int _workload = 50;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(rolesProvider).map((role) => role.name).toList();

    return AlertDialog(
      title: const Text('Add Team Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                value: _selectedRole,
                items:
                    roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Projects:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ProjectCheckboxItem(
                    project: 'Mobile App',
                    isSelected: _selectedProjects.contains('Mobile App'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedProjects.add('Mobile App');
                        } else {
                          _selectedProjects.remove('Mobile App');
                        }
                      });
                    },
                  ),
                  ProjectCheckboxItem(
                    project: 'Website Redesign',
                    isSelected: _selectedProjects.contains('Website Redesign'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedProjects.add('Website Redesign');
                        } else {
                          _selectedProjects.remove('Website Redesign');
                        }
                      });
                    },
                  ),
                  ProjectCheckboxItem(
                    project: 'API Integration',
                    isSelected: _selectedProjects.contains('API Integration'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedProjects.add('API Integration');
                        } else {
                          _selectedProjects.remove('API Integration');
                        }
                      });
                    },
                  ),
                  ProjectCheckboxItem(
                    project: 'Brand Identity',
                    isSelected: _selectedProjects.contains('Brand Identity'),
                    onChanged: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedProjects.add('Brand Identity');
                        } else {
                          _selectedProjects.remove('Brand Identity');
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Text('Workload:'), Text('${_workload}%')],
              ),
              Slider(
                value: _workload.toDouble(),
                min: 0,
                max: 100,
                divisions: 10,
                label: '${_workload}%',
                onChanged: (value) {
                  setState(() {
                    _workload = value.round();
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final teamMembersNotifier = ref.read(
                teamMembersProvider.notifier,
              );
              final newMember = TeamMember(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                email: _emailController.text,
                role: _selectedRole,
                avatarUrl:
                    'https://i.pravatar.cc/150?img=${DateTime.now().second % 10}',
                projects: _selectedProjects,
                permissions: _getDefaultPermissionsForRole(_selectedRole, ref),
                workload: _workload,
              );
              teamMembersNotifier.addMember(newMember);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Map<String, bool> _getDefaultPermissionsForRole(
    String roleName,
    WidgetRef ref,
  ) {
    final role = ref
        .read(rolesProvider)
        .firstWhere(
          (role) => role.name == roleName,
          orElse:
              () => Role(
                id: '0',
                name: 'Default',
                defaultPermissions: {
                  'view_team': true,
                  'edit_team': false,
                  'delete_team': false,
                  'view_projects': true,
                  'edit_projects': false,
                  'view_analytics': false,
                },
              ),
        );
    return role.defaultPermissions;
  }
}

class ProjectCheckboxItem extends StatelessWidget {
  final String project;
  final bool isSelected;
  final Function(bool) onChanged;

  const ProjectCheckboxItem({
    super.key,
    required this.project,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(project),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}

// Add role dialog
class AddRoleDialog extends ConsumerStatefulWidget {
  const AddRoleDialog({super.key});

  @override
  ConsumerState<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends ConsumerState<AddRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Map<String, bool> _permissions = {
    'view_team': true,
    'edit_team': false,
    'delete_team': false,
    'view_projects': true,
    'edit_projects': false,
    'view_analytics': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Role'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Default Permissions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPermissionSwitch('View Team', 'view_team'),
              _buildPermissionSwitch('Edit Team', 'edit_team'),
              _buildPermissionSwitch('Delete Team', 'delete_team'),
              _buildPermissionSwitch('View Projects', 'view_projects'),
              _buildPermissionSwitch('Edit Projects', 'edit_projects'),
              _buildPermissionSwitch('View Analytics', 'view_analytics'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final rolesNotifier = ref.read(rolesProvider.notifier);
              final newRole = Role(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                defaultPermissions: Map.from(_permissions),
              );
              rolesNotifier.addRole(newRole);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildPermissionSwitch(String label, String permissionKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: _permissions[permissionKey] ?? false,
            onChanged: (value) {
              setState(() {
                _permissions[permissionKey] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Edit Member Dialog
class EditMemberDialog extends ConsumerStatefulWidget {
  final TeamMember member;

  const EditMemberDialog({super.key, required this.member});

  @override
  ConsumerState<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends ConsumerState<EditMemberDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late String _selectedRole;
  late final List<String> _selectedProjects;
  late int _workload;
  late final Map<String, bool> _permissions;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _emailController = TextEditingController(text: widget.member.email);
    _selectedRole = widget.member.role;
    _selectedProjects = List.from(widget.member.projects);
    _workload = widget.member.workload;
    _permissions = Map.from(widget.member.permissions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(rolesProvider).map((role) => role.name).toList();

    return AlertDialog(
      title: const Text('Edit Team Member'),
      content: DefaultTabController(
        length: 3,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Profile'),
                  Tab(text: 'Projects'),
                  Tab(text: 'Permissions'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildProfileTab(roles),
                    _buildProjectsTab(),
                    _buildPermissionsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final teamMembersNotifier = ref.read(teamMembersProvider.notifier);
            final updatedMember = widget.member.copyWith(
              name: _nameController.text,
              email: _emailController.text,
              role: _selectedRole,
              projects: _selectedProjects,
              permissions: _permissions,
              workload: _workload,
            );
            teamMembersNotifier.updateMember(widget.member.id, updatedMember);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildProfileTab(List<String> roles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.member.avatarUrl),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            value: _selectedRole,
            items:
                roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('Workload:'), Text('${_workload}%')],
          ),
          Slider(
            value: _workload.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            label: '${_workload}%',
            onChanged: (value) {
              setState(() {
                _workload = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Projects',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ProjectCheckboxItem(
                project: 'Mobile App',
                isSelected: _selectedProjects.contains('Mobile App'),
                onChanged: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedProjects.add('Mobile App');
                    } else {
                      _selectedProjects.remove('Mobile App');
                    }
                  });
                },
              ),
              ProjectCheckboxItem(
                project: 'Website Redesign',
                isSelected: _selectedProjects.contains('Website Redesign'),
                onChanged: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedProjects.add('Website Redesign');
                    } else {
                      _selectedProjects.remove('Website Redesign');
                    }
                  });
                },
              ),
              ProjectCheckboxItem(
                project: 'API Integration',
                isSelected: _selectedProjects.contains('API Integration'),
                onChanged: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedProjects.add('API Integration');
                    } else {
                      _selectedProjects.remove('API Integration');
                    }
                  });
                },
              ),
              ProjectCheckboxItem(
                project: 'Brand Identity',
                isSelected: _selectedProjects.contains('Brand Identity'),
                onChanged: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedProjects.add('Brand Identity');
                    } else {
                      _selectedProjects.remove('Brand Identity');
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Individual Permissions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPermissionSwitch('View Team', 'view_team'),
          _buildPermissionSwitch('Edit Team', 'edit_team'),
          _buildPermissionSwitch('Delete Team', 'delete_team'),
          _buildPermissionSwitch('View Projects', 'view_projects'),
          _buildPermissionSwitch('Edit Projects', 'edit_projects'),
          _buildPermissionSwitch('View Analytics', 'view_analytics'),
        ],
      ),
    );
  }

  Widget _buildPermissionSwitch(String label, String permissionKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: _permissions[permissionKey] ?? false,
            onChanged: (value) {
              setState(() {
                _permissions[permissionKey] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

// Update DashboardScreen to include dialog openings
// Update this function in the DashboardScreen class
Widget _buildActionButton(BuildContext context, ViewType viewType) {
  switch (viewType) {
    case ViewType.directory:
      return ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddMemberDialog(),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
      );
    case ViewType.permissions:
      return ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddRoleDialog(),
          );
        },
        icon: const Icon(Icons.add_circle),
        label: const Text('Add Role'),
      );
    case ViewType.workload:
      return ElevatedButton.icon(
        onPressed: () {
          // Refresh workload data functionality would go here
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh Data'),
      );
  }
}

// pubspec.yaml
/*
name: team_management_app
description: A new Flutter project for team management.

# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  flutter_riverpod: ^2.3.6
  fl_chart: ^0.62.0
  uuid: ^3.0.7
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.2

flutter:
  uses-material-design: true
*/
