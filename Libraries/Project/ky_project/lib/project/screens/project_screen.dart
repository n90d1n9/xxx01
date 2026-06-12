import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../project.dart';
import 'edit_project_screen.dart';

class ProjectManagementScreen extends ConsumerWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectId = ref.watch(selectedProjectIdProvider);
    final project = ref.watch(selectedProjectProvider);
    
    if (project == null) {
      return Scaffold(
        body: Center(
          child: Text('Project not found (ID: $projectId)'),
        ),
      );
    }
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              // Left Navigation Rail - Same as before
              NavigationRail(
                extended: true,
                minExtendedWidth: 240,
                selectedIndex: 1, // Projects tab selected
                backgroundColor: const Color(0xFF1A1F38),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: const IconThemeData(color: Color(0xFF9CA3AF)),
                selectedLabelTextStyle: const TextStyle(color: Colors.white),
                unselectedLabelTextStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                onDestinationSelected: (index) {
                  // Navigation logic would go here
                  if (index == 1) {
                    Navigator.of(context).pop();
                  }
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment),
                    label: Text('Projects'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.task_outlined),
                    selectedIcon: Icon(Icons.task),
                    label: Text('Tasks'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: Text('Team'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.assessment_outlined),
                    selectedIcon: Icon(Icons.assessment),
                    label: Text('Reports'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
              
              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // App Bar
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Back to Projects',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1F38),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(project.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              project.status,
                              style: TextStyle(
                                fontSize: 14,
                                color: _getStatusColor(project.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProjectScreen(projectId: project.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Project'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Project Tabs
                    Container(
                      color: Colors.white,
                      child: TabBar(
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Tasks'),
                          Tab(text: 'Team'),
                          Tab(text: 'Files'),
                        ],
                        labelColor: const Color(0xFF4F46E5),
                        unselectedLabelColor: const Color(0xFF6B7280),
                        indicatorColor: const Color(0xFF4F46E5),
                      ),
                    ),
                    
                    // Tab Content
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF5F8FA),
                        child: TabBarView(
                          children: [
                            // Overview Tab
                            _buildOverviewTab(context, ref, project),
                            
                            // Tasks Tab
                            _buildTasksTab(context, ref, project),
                            
                            // Team Tab
                            _buildTeamTab(context, ref, project),
                            
                            // Files Tab
                            _buildFilesTab(context, ref, project),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab(BuildContext context, WidgetRef ref, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Stats Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.insert_chart_outlined, color: Color(0xFF4F46E5)),
                            SizedBox(width: 8),
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: project.actualProgress / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              project.actualProgress >= project.plannedProgress
                                  ? Colors.green
                                  : project.actualProgress >= project.plannedProgress * 0.8
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Actual Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${project.actualProgress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Planned Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${project.plannedProgress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              // Budget Card
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF4F46E5)),
                            SizedBox(width: 8),
                            Text(
                              'Budget',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${NumberFormat('#,###').format(project.budget)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1F38),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Spent',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${NumberFormat('#,###').format(project.budget * 0.7)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Remaining',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${NumberFormat('#,###').format(project.budget * 0.3)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Timeline Card
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color(0xFF4F46E5)),
                            SizedBox(width: 8),
                            Text(
                              'Timeline',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM d, y').format(project.startDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward, color: Colors.grey),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM d, y').format(project.endDate),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${project.endDate.difference(project.startDate).inDays} days',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Days Left',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${project.endDate.difference(DateTime.now()).inDays} days',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: project.endDate.difference(DateTime.now()).inDays > 7
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Project Description
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_outlined, color: Color(0xFF4F46E5)),
                      SizedBox(width: 8),
                      Text(
                        'Project Description',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Milestones
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.flag_outlined, color: Color(0xFF4F46E5)),
                          SizedBox(width: 8),
                          Text(
                            'Milestones',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add milestone logic
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Milestone'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F46E5),
                          side: const BorderSide(color: Color(0xFF4F46E5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sample milestones - in a real app, these would come from the project
                  _buildMilestoneItem(
                    'Requirements Gathering',
                    DateFormat('MMM d, y').format(project.startDate.add(const Duration(days: 14))),
                    true, // completed
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneItem(
                    'Design Approval',
                    DateFormat('MMM d, y').format(project.startDate.add(const Duration(days: 30))),
                    true, // completed
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneItem(
                    'Alpha Release',
                    DateFormat('MMM d, y').format(project.startDate.add(const Duration(days: 60))),
                    false, // not completed
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneItem(
                    'Beta Testing',
                    DateFormat('MMM d, y').format(project.startDate.add(const Duration(days: 90))),
                    false, // not completed
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneItem(
                    'Final Release',
                    DateFormat('MMM d, y').format(project.endDate),
                    false, // not completed
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMilestoneItem(String title, String date, bool completed) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF4F46E5) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(
            completed ? Icons.check : Icons.circle,
            size: 16,
            color: completed ? Colors.white : Colors.grey[400],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: completed ? const Color(0xFF1A1F38) : Colors.grey[600],
              decoration: completed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTasksTab(BuildContext context, WidgetRef ref, Project project) {
    // Sample task data - in a real app, these would come from a provider
    final tasks = [
      {
        'title': 'Create wireframes for dashboard',
        'status': 'Completed',
        'assignee': 'Emma Johnson',
        'dueDate': DateTime.now().add(const Duration(days: 1)),
        'priority': 'High'
      },
      {
        'title': 'Implement user authentication',
        'status': 'In Progress',
        'assignee': 'Jacob Wilson',
        'dueDate': DateTime.now().add(const Duration(days: 3)),
        'priority': 'High'
      },
      {
        'title': 'Design database schema',
        'status': 'Completed',
        'assignee': 'Olivia Martinez',
        'dueDate': DateTime.now().add(const Duration(days: -2)),
        'priority': 'Medium'
      },
      {
        'title': 'Create API documentation',
        'status': 'To Do',
        'assignee': 'Noah Garcia',
        'dueDate': DateTime.now().add(const Duration(days: 7)),
        'priority': 'Low'
      },
      {
        'title': 'Implement notification system',
        'status': 'In Progress',
        'assignee': 'Sophia Anderson',
        'dueDate': DateTime.now().add(const Duration(days: 5)),
        'priority': 'Medium'
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Project Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1F38),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add task logic
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Task Filters
          Row(
            children: [
              _buildFilterChip('All Tasks', true),
              const SizedBox(width: 8),
              _buildFilterChip('To Do', false),
              const SizedBox(width: 8),
              _buildFilterChip('In Progress', false),
              const SizedBox(width: 8),
              _buildFilterChip('Completed', false),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search and Sort Bar
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Due Date',
                    items: ['Due Date', 'Priority', 'Status', 'Assignee']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {},
                    icon: const Icon(Icons.sort),
                    hint: const Text('Sort by'),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tasks Table
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Task Title',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Assignee',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Due Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Priority',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Actions column
                      ],
                    ),
                  ),
                  
                  // Table Rows
                  ...tasks.map((task) => _buildTaskRow(task)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (value) {},
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4F46E5).withOpacity(0.1),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: const Color(0xFF4F46E5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
  
  Widget _buildTaskRow(Map<String, dynamic> task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              task['title'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(task['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(