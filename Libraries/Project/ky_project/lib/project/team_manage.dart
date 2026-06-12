import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/legacy.dart';

// Models
class TeamMember {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String email;
  final List<String> permissions;
  final int workload; // Percentage of capacity (0-100)
  final List<Task> assignedTasks;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.email,
    required this.permissions,
    required this.workload,
    required this.assignedTasks,
  });
}

class Task {
  final String id;
  final String title;
  final int hoursEstimated;

  Task({required this.id, required this.title, required this.hoursEstimated});
}

class Role {
  final String id;
  final String name;
  final List<String> permissions;

  Role({required this.id, required this.name, required this.permissions});
}

// Sample data
final List<TeamMember> _sampleMembers = [
  TeamMember(
    id: '1',
    name: 'Alex Johnson',
    role: 'Developer',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    email: 'alex@example.com',
    permissions: ['view_projects', 'edit_tasks', 'comment'],
    workload: 85,
    assignedTasks: [
      Task(id: 't1', title: 'Fix login bug', hoursEstimated: 4),
      Task(id: 't2', title: 'Implement chart', hoursEstimated: 8),
    ],
  ),
  TeamMember(
    id: '2',
    name: 'Sarah Miller',
    role: 'Designer',
    avatarUrl: 'https://i.pravatar.cc/150?img=2',
    email: 'sarah@example.com',
    permissions: ['view_projects', 'upload_assets', 'comment'],
    workload: 60,
    assignedTasks: [
      Task(id: 't3', title: 'Design homepage', hoursEstimated: 12),
    ],
  ),
  TeamMember(
    id: '3',
    name: 'James Wilson',
    role: 'Product Manager',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
    email: 'james@example.com',
    permissions: [
      'view_projects',
      'edit_projects',
      'manage_team',
      'comment',
      'approve',
    ],
    workload: 70,
    assignedTasks: [
      Task(id: 't4', title: 'Product roadmap', hoursEstimated: 16),
      Task(id: 't5', title: 'Client meeting', hoursEstimated: 2),
    ],
  ),
  TeamMember(
    id: '4',
    name: 'Emily Chen',
    role: 'Developer',
    avatarUrl: 'https://i.pravatar.cc/150?img=4',
    email: 'emily@example.com',
    permissions: ['view_projects', 'edit_tasks', 'comment'],
    workload: 90,
    assignedTasks: [
      Task(id: 't6', title: 'API integration', hoursEstimated: 16),
      Task(id: 't7', title: 'Database schema', hoursEstimated: 6),
    ],
  ),
  TeamMember(
    id: '5',
    name: 'Michael Brown',
    role: 'QA Tester',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
    email: 'michael@example.com',
    permissions: ['view_projects', 'report_bugs', 'comment'],
    workload: 45,
    assignedTasks: [
      Task(id: 't8', title: 'Test login flow', hoursEstimated: 4),
      Task(id: 't9', title: 'Regression testing', hoursEstimated: 8),
    ],
  ),
];

final List<Role> _sampleRoles = [
  Role(
    id: 'r1',
    name: 'Developer',
    permissions: ['view_projects', 'edit_tasks', 'comment'],
  ),
  Role(
    id: 'r2',
    name: 'Designer',
    permissions: ['view_projects', 'upload_assets', 'comment'],
  ),
  Role(
    id: 'r3',
    name: 'Product Manager',
    permissions: [
      'view_projects',
      'edit_projects',
      'manage_team',
      'comment',
      'approve',
    ],
  ),
  Role(
    id: 'r4',
    name: 'QA Tester',
    permissions: ['view_projects', 'report_bugs', 'comment'],
  ),
  Role(
    id: 'r5',
    name: 'Admin',
    permissions: [
      'view_projects',
      'edit_projects',
      'manage_team',
      'comment',
      'approve',
      'manage_subscriptions',
      'manage_roles',
    ],
  ),
];

// Providers
final teamMembersProvider =
    StateNotifierProvider<TeamMembersNotifier, List<TeamMember>>((ref) {
      return TeamMembersNotifier();
    });

final rolesProvider = StateNotifierProvider<RolesNotifier, List<Role>>((ref) {
  return RolesNotifier();
});

final selectedMemberProvider = StateProvider<TeamMember?>((ref) => null);

final filteredMembersProvider = StateProvider<List<TeamMember>>((ref) {
  final members = ref.watch(teamMembersProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return members;
  }

  return members
      .where(
        (member) =>
            member.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            member.role.toLowerCase().contains(searchQuery.toLowerCase()) ||
            member.email.toLowerCase().contains(searchQuery.toLowerCase()),
      )
      .toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final subscriptionStatusProvider = StateProvider<bool>((ref) => true);

final subscriptionInfoProvider = Provider(
  (ref) => {
    'plan': 'Business Pro',
    'seats': 10,
    'usedSeats': 5,
    'expiryDate': '2025-06-15',
    'features': [
      'Team Management',
      'Advanced Analytics',
      'Priority Support',
      'Custom Permissions',
      'Unlimited Projects',
    ],
  },
);

// Notifiers
class TeamMembersNotifier extends StateNotifier<List<TeamMember>> {
  TeamMembersNotifier() : super(_sampleMembers);

  void updateMember(TeamMember updatedMember) {
    state = state.map((member) {
      if (member.id == updatedMember.id) {
        return updatedMember;
      }
      return member;
    }).toList();
  }

  void addMember(TeamMember newMember) {
    state = [...state, newMember];
  }

  void removeMember(String id) {
    state = state.where((member) => member.id != id).toList();
  }
}

class RolesNotifier extends StateNotifier<List<Role>> {
  RolesNotifier() : super(_sampleRoles);

  void updateRole(Role updatedRole) {
    state = state.map((role) {
      if (role.id == updatedRole.id) {
        return updatedRole;
      }
      return role;
    }).toList();
  }

  void addRole(Role newRole) {
    state = [...state, newRole];
  }

  void removeRole(String id) {
    state = state.where((role) => role.id != id).toList();
  }
}

// Main Widget
class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final subscriptionInfo = ref.watch(subscriptionInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {},
              child: Chip(
                label: Text(
                  '${subscriptionInfo['plan']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: subscriptionStatus
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                avatar: Icon(
                  subscriptionStatus ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Directory', icon: Icon(Icons.people_outline)),
            Tab(
              text: 'Roles & Permissions',
              icon: Icon(Icons.admin_panel_settings_outlined),
            ),
            Tab(text: 'Workload', icon: Icon(Icons.insights_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MemberDirectoryTab(),
          RolePermissionsTab(),
          WorkloadVisualizationTab(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return _tabController.index == 0
              ? FloatingActionButton(
                  onPressed: () => _showAddMemberDialog(context),
                  child: const Icon(Icons.person_add),
                  tooltip: 'Add Team Member',
                )
              : _tabController.index == 1
              ? FloatingActionButton(
                  onPressed: () => _showAddRoleDialog(context),
                  child: const Icon(Icons.add_moderator),
                  tooltip: 'Add Role',
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddMemberDialog());
  }

  void _showAddRoleDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddRoleDialog());
  }
}

// Member Directory Tab
class MemberDirectoryTab extends ConsumerWidget {
  const MemberDirectoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filteredMembers = ref.watch(filteredMembersProvider);
    final subscriptionInfo = ref.watch(subscriptionInfoProvider);

    return Column(
      children: [
        // Subscription Info Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade700,
                Colors.purpleAccent.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${subscriptionInfo['usedSeats']}/${subscriptionInfo['seats']} seats used',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expires: ${subscriptionInfo['expiryDate']}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Manage Plan'),
              ),
            ],
          ),
        ),

        // Search and Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = '',
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Member List
        Expanded(
          child: filteredMembers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No members found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return _buildMemberCard(context, member);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, TeamMember member) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Show member details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with workload indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(member.avatarUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getWorkloadColor(member.workload),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '${member.workload}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Member details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.role,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: member.permissions
                          .map(
                            (permission) => Chip(
                              label: Text(
                                permission
                                    .split('_')
                                    .map(
                                      (word) =>
                                          word[0].toUpperCase() +
                                          word.substring(1),
                                    )
                                    .join(' '),
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                    tooltip: 'Edit Member',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {},
                    tooltip: 'Remove Member',
                    color: Colors.red.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getWorkloadColor(int workload) {
    if (workload < 50) {
      return Colors.green;
    } else if (workload < 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// Roles & Permissions Tab
class RolePermissionsTab extends ConsumerWidget {
  const RolePermissionsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return _buildRoleCard(context, role);
      },
    );
  }

  Widget _buildRoleCard(BuildContext context, Role role) {
    final isAdmin = role.name == 'Admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.security : Icons.shield_outlined,
                      size: 24,
                      color: isAdmin ? Colors.purple : Colors.blueAccent,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (!isAdmin) // Don't allow editing Admin role
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {},
                        tooltip: 'Edit Role',
                      ),
                    if (!isAdmin) // Don't allow deleting Admin role
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {},
                        tooltip: 'Delete Role',
                        color: Colors.red.shade400,
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Permissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: role.permissions.map((permission) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPermissionIcon(permission),
                        size: 16,
                        color: _getPermissionColor(permission),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        permission
                            .split('_')
                            .map(
                              (word) =>
                                  word[0].toUpperCase() + word.substring(1),
                            )
                            .join(' '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPermissionIcon(String permission) {
    switch (permission) {
      case 'view_projects':
        return Icons.visibility;
      case 'edit_projects':
        return Icons.edit;
      case 'manage_team':
        return Icons.people;
      case 'comment':
        return Icons.comment;
      case 'approve':
        return Icons.check_circle;
      case 'manage_subscriptions':
        return Icons.subscriptions;
      case 'manage_roles':
        return Icons.admin_panel_settings;
      case 'edit_tasks':
        return Icons.task_alt;
      case 'upload_assets':
        return Icons.cloud_upload;
      case 'report_bugs':
        return Icons.bug_report;
      default:
        return Icons.extension;
    }
  }

  Color _getPermissionColor(String permission) {
    switch (permission) {
      case 'view_projects':
        return Colors.blue;
      case 'edit_projects':
        return Colors.orange;
      case 'manage_team':
        return Colors.purple;
      case 'comment':
        return Colors.green;
      case 'approve':
        return Colors.red;
      case 'manage_subscriptions':
        return Colors.teal;
      case 'manage_roles':
        return Colors.deepPurple;
      case 'edit_tasks':
        return Colors.indigo;
      case 'upload_assets':
        return Colors.amber;
      case 'report_bugs':
        return Colors.pink;
      default:
        return Colors.blueGrey;
    }
  }
}

// Workload Visualization Tab
class WorkloadVisualizationTab extends ConsumerWidget {
  const WorkloadVisualizationTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(teamMembersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkloadSummaryCard(context, members),
          const SizedBox(height: 20),
          _buildWorkloadChart(context, members),
          const SizedBox(height: 20),
          const Text(
            'Individual Workloads',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...members
              .map((member) => _buildMemberWorkloadCard(context, member))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWorkloadSummaryCard(
    BuildContext context,
    List<TeamMember> members,
  ) {
    // Calculate stats
    final avgWorkload = members.isEmpty
        ? 0
        : members.fold<int>(0, (sum, member) => sum + member.workload) /
              members.length;

    final overloadedCount = members
        .where((member) => member.workload > 80)
        .length;
    final underutilizedCount = members
        .where((member) => member.workload < 40)
        .length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Workload Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Avg Workload',
                  '${avgWorkload.toStringAsFixed(1)}%',
                  Icons.analytics_outlined,
                  _getWorkloadColor(avgWorkload.toInt()),
                ),
                _buildStatItem(
                  context,
                  'Overloaded',
                  '$overloadedCount',
                  Icons.warning_amber_outlined,
                  Colors.red,
                ),
                _buildStatItem(
                  context,
                  'Underutilized',
                  '$underutilizedCount',
                  Icons.person_outline,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWorkloadChart(BuildContext context, List<TeamMember> members) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workload Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${members[groupIndex].name}\n${rod.toY.toInt()}%',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= members.length || value < 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              members[value.toInt()].name.split(' ')[0],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 20 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: members.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final TeamMember member = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: member.workload.toDouble(),
                          color: _getWorkloadColor(member.workload),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Under 50%', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('50% - 80%', Colors.orange),
                const SizedBox(width: 16),
                _buildLegendItem('Over 80%', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildMemberWorkloadCard(BuildContext context, TeamMember member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      member.role,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getWorkloadColor(
                      member.workload,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${member.workload}% Workload',
                    style: TextStyle(
                      color: _getWorkloadColor(member.workload),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: member.workload / 100,
                backgroundColor: Colors.grey.shade200,
                color: _getWorkloadColor(member.workload),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            if (member.assignedTasks.isNotEmpty) ...[
              Text(
                'Assigned Tasks (${member.assignedTasks.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...member.assignedTasks
                  .map((task) => _buildTaskItem(task))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(task.title, style: const TextStyle(fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${task.hoursEstimated}h',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWorkloadColor(int workload) {
    if (workload < 50) {
      return Colors.green;
    } else if (workload < 80) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

// Add Member Dialog
class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'Developer';
  final List<String> _selectedPermissions = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(rolesProvider);
    final subscriptionInfo = ref.watch(subscriptionInfoProvider);
    final members = ref.watch(teamMembersProvider);

    final usedSeats = subscriptionInfo['usedSeats'] as int;
    final totalSeats = subscriptionInfo['seats'] as int;
    final seatsRemaining = totalSeats - usedSeats;

    // Get role from selected role name
    final selectedRoleObj = roles.firstWhere(
      (role) => role.name == _selectedRole,
      orElse: () => roles.first,
    );

    return AlertDialog(
      title: const Text('Add Team Member'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seats info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have $seatsRemaining of $totalSeats seats remaining in your plan.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
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

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role.name,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;

                      // Update permissions based on selected role
                      final role = roles.firstWhere(
                        (r) => r.name == value,
                        orElse: () => roles.first,
                      );
                      _selectedPermissions.clear();
                      _selectedPermissions.addAll(role.permissions);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Permissions section
              const Text(
                'Permissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedRoleObj.permissions.map((permission) {
                  final isSelected = _selectedPermissions.contains(permission);
                  return FilterChip(
                    label: Text(
                      permission
                          .split('_')
                          .map(
                            (word) => word[0].toUpperCase() + word.substring(1),
                          )
                          .join(' '),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPermissions.add(permission);
                        } else {
                          _selectedPermissions.remove(permission);
                        }
                      });
                    },
                  );
                }).toList(),
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
          onPressed: seatsRemaining <= 0
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final newMember = TeamMember(
                      id: (members.length + 1).toString(),
                      name: _nameController.text,
                      role: _selectedRole,
                      avatarUrl:
                          'https://i.pravatar.cc/150?img=${members.length + 1}',
                      email: _emailController.text,
                      permissions: _selectedPermissions,
                      workload: 0,
                      assignedTasks: [],
                    );

                    ref.read(teamMembersProvider.notifier).addMember(newMember);
                    Navigator.of(context).pop();
                  }
                },
          child: const Text('Add Member'),
        ),
      ],
    );
  }
}

// Add Role Dialog
class AddRoleDialog extends ConsumerStatefulWidget {
  const AddRoleDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends ConsumerState<AddRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<String> _selectedPermissions = [];

  final List<String> _allPermissions = [
    'view_projects',
    'edit_projects',
    'manage_team',
    'comment',
    'approve',
    'edit_tasks',
    'upload_assets',
    'report_bugs',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(rolesProvider);

    return AlertDialog(
      title: const Text('Add Role'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
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
                  if (roles.any(
                    (role) => role.name.toLowerCase() == value.toLowerCase(),
                  )) {
                    return 'Role name already exists';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Permissions section
              const Text(
                'Select Permissions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allPermissions.map((permission) {
                  final isSelected = _selectedPermissions.contains(permission);
                  return FilterChip(
                    label: Text(
                      permission
                          .split('_')
                          .map(
                            (word) => word[0].toUpperCase() + word.substring(1),
                          )
                          .join(' '),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPermissions.add(permission);
                        } else {
                          _selectedPermissions.remove(permission);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (_selectedPermissions.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Please select at least one permission',
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                ),
              ],
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
          onPressed: _selectedPermissions.isEmpty
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final newRole = Role(
                      id: 'r${roles.length + 1}',
                      name: _nameController.text,
                      permissions: _selectedPermissions,
                    );

                    ref.read(rolesProvider.notifier).addRole(newRole);
                    Navigator.of(context).pop();
                  }
                },
          child: const Text('Add Role'),
        ),
      ],
    );
  }
}

// Main App
class TeamManagementApp extends StatelessWidget {
  const TeamManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Team Management',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: const TeamManagementScreen(),
      ),
    );
  }
}

void main() {
  runApp(const TeamManagementApp());
}
