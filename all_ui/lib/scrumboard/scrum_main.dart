import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

// Models
class Task {
  final String id;
  final String title;
  final String description;
  final String assignee;
  final int storyPoints;
  final DateTime createdAt;
  final String? avatarUrl;
  final Color labelColor;
  final TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignee,
    required this.storyPoints,
    required this.createdAt,
    this.avatarUrl,
    required this.labelColor,
    required this.status,
  });

  Task copyWith({
    String? title,
    String? description,
    String? assignee,
    int? storyPoints,
    String? avatarUrl,
    Color? labelColor,
    TaskStatus? status,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      storyPoints: storyPoints ?? this.storyPoints,
      createdAt: this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      labelColor: labelColor ?? this.labelColor,
      status: status ?? this.status,
    );
  }
}

enum TaskStatus { backlog, todo, inProgress, review, done }

// State notifiers and providers
class TasksNotifier extends StateNotifier<List<Task>> {
  TasksNotifier()
    : super([
        Task(
          id: '1',
          title: 'Create user authentication flow',
          description:
              'Implement login, signup, and password reset functionalities',
          assignee: 'Alex Chen',
          storyPoints: 5,
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          labelColor: Colors.purple,
          status: TaskStatus.todo,
        ),
        Task(
          id: '2',
          title: 'Design dashboard UI',
          description:
              'Create wireframes and implement responsive dashboard layout',
          assignee: 'Maya Johnson',
          storyPoints: 3,
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          labelColor: Colors.blue,
          status: TaskStatus.inProgress,
        ),
        Task(
          id: '3',
          title: 'Implement API endpoints',
          description:
              'Create REST API endpoints for user data and task management',
          assignee: 'Sam Wilson',
          storyPoints: 8,
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          labelColor: Colors.green,
          status: TaskStatus.review,
        ),
        Task(
          id: '4',
          title: 'Setup CI/CD pipeline',
          description:
              'Configure GitHub Actions for automated testing and deployment',
          assignee: 'Jordan Lee',
          storyPoints: 5,
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          labelColor: Colors.orange,
          status: TaskStatus.done,
        ),
        Task(
          id: '5',
          title: 'Write unit tests',
          description: 'Create comprehensive test coverage for core components',
          assignee: 'Taylor Swift',
          storyPoints: 3,
          createdAt: DateTime.now().subtract(Duration(days: 4)),
          labelColor: Colors.red,
          status: TaskStatus.backlog,
        ),
        Task(
          id: '6',
          title: 'Optimize image loading',
          description:
              'Implement lazy loading and caching for better performance',
          assignee: 'Alex Chen',
          storyPoints: 2,
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          labelColor: Colors.teal,
          status: TaskStatus.backlog,
        ),
      ]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void updateTask(Task updatedTask) {
    state =
        state.map((task) {
          if (task.id == updatedTask.id) {
            return updatedTask;
          }
          return task;
        }).toList();
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void moveTask(String taskId, TaskStatus newStatus) {
    state =
        state.map((task) {
          if (task.id == taskId) {
            return task.copyWith(status: newStatus);
          }
          return task;
        }).toList();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<Task>>((ref) {
  return TasksNotifier();
});

final filteredTasksProvider = Provider.family<List<Task>, TaskStatus>((
  ref,
  status,
) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((task) => task.status == status).toList();
});

final selectedTaskProvider = StateProvider<Task?>((ref) => null);

// UI Components
class ScrumBoardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Column(
        children: [
          _buildAppBar(context, ref),
          Expanded(child: _buildScrumBoard(context, ref)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6C5CE7),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTaskDialog(context, ref),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Project Nexus',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              Spacer(),
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF6C5CE7).withValues(alpha: 0.1),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF6C5CE7),
                  size: 18,
                ),
              ),
              SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Sprint 4', '8 days left', Icons.timer_outlined),
              SizedBox(width: 16),
              _buildStatCard(
                'Tasks',
                '${ref.watch(tasksProvider).length} total',
                Icons.task_alt,
              ),
              SizedBox(width: 16),
              _buildStatCard('Team', '6 members', Icons.people_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6C5CE7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF6C5CE7), size: 16),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrumBoard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sprint Board',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTaskColumn(
                  context,
                  ref,
                  'Backlog',
                  TaskStatus.backlog,
                  Color(0xFF808080),
                ),
                _buildTaskColumn(
                  context,
                  ref,
                  'To Do',
                  TaskStatus.todo,
                  Color(0xFF6C5CE7),
                ),
                _buildTaskColumn(
                  context,
                  ref,
                  'In Progress',
                  TaskStatus.inProgress,
                  Color(0xFF00B894),
                ),
                _buildTaskColumn(
                  context,
                  ref,
                  'Review',
                  TaskStatus.review,
                  Color(0xFFFD9644),
                ),
                _buildTaskColumn(
                  context,
                  ref,
                  'Done',
                  TaskStatus.done,
                  Color(0xFF26DE81),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskColumn(
    BuildContext context,
    WidgetRef ref,
    String title,
    TaskStatus status,
    Color color,
  ) {
    final tasks = ref.watch(filteredTasksProvider(status));

    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                iconSize: 16,
                icon: Icon(Icons.add, color: Colors.grey.shade600),
                onPressed:
                    () =>
                        _showAddTaskDialog(context, ref, initialStatus: status),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: DragTarget<String>(
              onAccept: (taskId) {
                ref.read(tasksProvider.notifier).moveTask(taskId, status);
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(context, ref, tasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return Draggable<String>(
      data: task.id,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 250,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                task.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCardContent(context, ref, task),
      ),
      child: _buildTaskCardContent(context, ref, task),
    );
  }

  Widget _buildTaskCardContent(BuildContext context, WidgetRef ref, Task task) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedTaskProvider.notifier).state = task;
        _showTaskDetailsDialog(context, ref, task);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.labelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'SP: ${task.storyPoints}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: task.labelColor,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              task.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: 8),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          task.avatarUrl != null
                              ? NetworkImage(task.avatarUrl!)
                              : NetworkImage(
                                'https://i.pravatar.cc/150?u=${task.assignee}',
                              ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      task.assignee,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_formatDate(task.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  void _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    TaskStatus? initialStatus,
  }) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final assigneeController = TextEditingController();
    final storyPointsController = TextEditingController();

    TaskStatus selectedStatus = initialStatus ?? TaskStatus.todo;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Create New Task',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: assigneeController,
                              decoration: InputDecoration(
                                labelText: 'Assignee',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: storyPointsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Story Points',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<TaskStatus>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            TaskStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_statusToString(status)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Label Color:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 16),
                          _buildColorPicker(Colors.purple, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.blue, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.green, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.orange, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.red, selectedColor, (color) {
                            setState(() => selectedColor = color);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Create'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        assigneeController.text.isNotEmpty &&
                        storyPointsController.text.isNotEmpty) {
                      final task = Task(
                        id: Uuid().v4(),
                        title: titleController.text,
                        description: descriptionController.text,
                        assignee: assigneeController.text,
                        storyPoints: int.parse(storyPointsController.text),
                        createdAt: DateTime.now(),
                        labelColor: selectedColor,
                        status: selectedStatus,
                      );
                      ref.read(tasksProvider.notifier).addTask(task);
                      Navigator.pop(context);
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

  Widget _buildColorPicker(
    Color color,
    Color selectedColor,
    Function(Color) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        margin: EdgeInsets.only(right: 8),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  void _showTaskDetailsDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.pop(context);
                  _showEditTaskDialog(context, ref, task);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  ref.read(tasksProvider.notifier).deleteTask(task.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: Container(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: task.labelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SP: ${task.storyPoints}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: task.labelColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusToString(task.status),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    task.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            task.avatarUrl != null
                                ? NetworkImage(task.avatarUrl!)
                                : NetworkImage(
                                  'https://i.pravatar.cc/150?u=${task.assignee}',
                                ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignee',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            task.assignee,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Created',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    final assigneeController = TextEditingController(text: task.assignee);
    final storyPointsController = TextEditingController(
      text: task.storyPoints.toString(),
    );

    var selectedStatus = task.status;
    var selectedColor = task.labelColor;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Task',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: assigneeController,
                              decoration: InputDecoration(
                                labelText: 'Assignee',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: storyPointsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Story Points',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<TaskStatus>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            TaskStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_statusToString(status)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Label Color:',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 16),
                          _buildColorPicker(Colors.purple, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.blue, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.green, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.orange, selectedColor, (
                            color,
                          ) {
                            setState(() => selectedColor = color);
                          }),
                          _buildColorPicker(Colors.red, selectedColor, (color) {
                            setState(() => selectedColor = color);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Update'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        assigneeController.text.isNotEmpty &&
                        storyPointsController.text.isNotEmpty) {
                      final updatedTask = task.copyWith(
                        title: titleController.text,
                        description: descriptionController.text,
                        assignee: assigneeController.text,
                        storyPoints: int.parse(storyPointsController.text),
                        labelColor: selectedColor,
                        status: selectedStatus,
                      );
                      ref.read(tasksProvider.notifier).updateTask(updatedTask);
                      Navigator.pop(context);
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
}

// Main app
class ScrumBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Color(0xFFF7F8FA),
          fontFamily: 'Poppins',
        ),
        home: ScrumBoardScreen(),
      ),
    );
  }
}

void main() {
  runApp(ScrumBoardApp());
}
