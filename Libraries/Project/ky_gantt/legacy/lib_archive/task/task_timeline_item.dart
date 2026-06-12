
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';


import '../dependency/dependency.dart';
import '../providers/gantt_state.dart';
import '../milestone/milestone.dart';
import 'task.dart';
import 'task_dialog.dart';



class TaskTimelineItem extends StatefulWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Color color;

  const TaskTimelineItem({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.color = Colors.blue, required Task task,
  });

  @override
  TaskTimelineItemState createState() => TaskTimelineItemState();
}

class TaskTimelineItemState extends State<TaskTimelineItem> {
  late final Task task;
  // final position = _calculatePosition(context);
    
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _showContextMenu(context, details as Offset),
      onPanUpdate: (details) => _handleDrag(context, details),
      child:  Container(
        height: 50,
        child: Stack(
          children: [
            if (task.isMillestone)
              _buildMilestone(context)
            else
              _buildTaskBar(context),
            if (task.predecessorIds.isNotEmpty)
              _buildDependencyLines(context),
          ],
        ),
      ),
    );
  }
/* 
  Positioned(
      left: position['left'],
      child: GestureDetector(
        onTapUp: (details) => _showContextMenu(context, details.globalPosition),
        onHorizontalDragUpdate: (details) => _handleDrag(context, details),
        child: Container(
          width: position['width'],
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildMilestone(context),
              Text(widget.title),
            ],
          ),
        ),
      ),
    ); */
  
  Widget _buildTaskBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: task.style!.color!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(task.name!)),
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(task.assignee!.assigneeAvatar!),
              ),
            ],
          ),
          LinearPercentIndicator(
            percent: task.progress! / 100,
            backgroundColor: Colors.white30,
            progressColor: Colors.white,
            padding: EdgeInsets.zero,
            lineHeight: 4,
          ),
        ],
      ),
    );
  }
  



  // Show context menu with options
  void _showContextMenu(BuildContext context, Offset details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details & const Size(40, 40), // smaller rect for tap position
        Offset.zero & overlay.size
      ),
      items: [
        PopupMenuItem(
          child: const Text('Edit Task'),
          onTap: () {
            // Open task edit dialog
            _openTaskEditDialog(context);
          },
        ),
        PopupMenuItem(
          child: const Text('Delete Task'),
          onTap: () {
            // Implement task deletion
            _deleteTask(context);
          },
        ),
        PopupMenuItem(
          child: const Text('Add Dependency'),
          onTap: () {
            // Implement dependency addition logic
            _addDependency(context);
          },
        ),
      ],
    );
  }

  Widget _buildMilestone(BuildContext context) {
    return CustomPaint(
      painter: MilestonePainter(
        color: task.style!.color!,
        position: _calculatePosition(context),
      ),
    );
  }
  // Build milestone indicator
 /*  Widget _buildMilestone(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 2,
          )
        ],
      ),
    );
  } */

  // Handle drag events for task rescheduling
  void _handleDrag(BuildContext context, DragUpdateDetails details) {
    // Implement drag logic to update task dates
    setState(() {
      // Calculate new start and end dates based on drag
      // This is a simplified example
      final pixelToDateRatio = 1; // adjust based on your timeline scale
      final dateDelta = Duration(days: (details.delta.dx * pixelToDateRatio).round());
      
      widget.startDate.add(dateDelta);
      widget.endDate.add(dateDelta);
    });
  }

  // Build dependency connection lines
  Widget _buildDependencyLines(BuildContext context) {
    return CustomPaint(
      painter: DependencyLinePainter(
        startPoint: Offset.zero, // Calculate actual start point
        endPoints: [], // List of dependency connection points
        color: widget.color, start: Offset.zero, end: Offset.zero,
      ),
    );
  }
  

  // Calculate position and width for timeline rendering
  double _calculatePosition(BuildContext context) {
    //final ganttState = context.read<GanttState>();
    //final totalDays = ganttState.viewEndDate.difference(ganttState.viewStartDate).inDays;
    final taskStartDays = 1;//task.startDate.difference(ganttState.viewStartDate).inDays;
    return taskStartDays * 50.0;
  }
  
  /* Map<String, double> _calculatePosition(BuildContext context) {
    // Assume total timeline width and start/end dates of entire project
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final timelineWidth = renderBox.size.width;
    
    // Example calculation (you'll need to adjust based on your specific timeline logic)
    final totalProjectDuration = 365; // days
    final taskDuration = widget.endDate.difference(widget.startDate).inDays;
    
    final startPosition = (widget.startDate.difference(DateTime(widget.startDate.year)).inDays / totalProjectDuration) * timelineWidth;
    final itemWidth = (taskDuration / totalProjectDuration) * timelineWidth;

    return {
      'left': startPosition,
      'width': itemWidth,
    };
  } */


  /* Widget _buildTaskBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(child: Text(task.name)),
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(task.assigneeAvatar!),
          ),
        ],
      ),
    );
  } */

  

  double _calculateWidth(BuildContext context) {
    final taskDays = task.endDate!.difference(task.startDate!).inDays;
    return taskDays * 50.0;
  }
/* 
  void _showContextMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Edit'),
          onTap: () => _showEditDialog(context),
        ),
        PopupMenuItem(
          child: const Text('Delete'),
          onTap: () => _deleteTask(context),
        ),
      ],
    );
  } */


  // Method to open task edit dialog
  void _openTaskEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return TaskDialog(
          initialTask: Task(
            title: 'title',
            description: '', // You might want to add description to the initial constructor
            startDate: DateTime.now(),
            endDate: DateTime.now(), id: '',
          ),
          onTaskSaved: (updatedTask) {
            // Handle task update
            // This could involve updating the task in a state management solution
            // or calling a callback to update the parent widget
            Navigator.of(dialogContext).pop();
            
            // Example of potential update mechanism
            // taskBloc.add(UpdateTaskEvent(updatedTask));
          },
        );
      },
    );
  }

  // Method to delete task with confirmation
  void _deleteTask(BuildContext context) {
    // Show confirmation dialog before deletion
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete the task "${widget.title}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                // Perform task deletion
                // This could involve:
                // 1. Removing from a list
                // 2. Calling a state management method
                // 3. Updating a database
                
                // Example of potential deletion mechanism
                // taskBloc.add(DeleteTaskEvent(taskId));
                
                // Close confirmation dialog
                Navigator.of(dialogContext).pop();
                
                // Optionally, close or update parent view
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to add task dependencies
  void _addDependency(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return DependencySelectionDialog(
          currentTask: Task(
            title: widget.title,
            description: '',
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
          onDependencyAdded: (dependentTask) {
            // Handle adding dependency
            // This could involve:
            // 1. Updating task dependencies in a data model
            // 2. Calling a state management method
            // 3. Updating UI to show dependency lines
            
            // Example of potential dependency addition
            // taskBloc.add(AddDependencyEvent(
            //   parentTaskId: currentTask.id, 
            //   dependentTaskId: dependentTask.id
            // ));
            
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}




/* 

class TaskTimelineItem extends StatelessWidget {
  final GanttTask task;

  const TaskTimelineItem({required this.task, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _showContextMenu(context, details),
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Stack(
          children: [
            Positioned(
              left: _calculateLeftPosition(context),
              width: _calculateWidth(context),
              top: 0,
              bottom: 0,
              child: _buildTaskBar(context),
            ),
          ],
        ),
      ),
    );
  }


  void _showEditDialog(BuildContext context) {
    // Implement edit dialog
  }

  void _deleteTask(BuildContext context) {
    // Implement delete functionality
  }
} */