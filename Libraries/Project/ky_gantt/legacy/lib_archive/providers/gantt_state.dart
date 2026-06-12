// Enhanced State Management
import 'package:flutter/material.dart';

import '../task/task.dart';

class GanttState extends ChangeNotifier {
  final List<Task> _tasks = [];
  final DateTime _viewStartDate = DateTime.now();
  final DateTime _viewEndDate = DateTime.now().add(const Duration(days: 30));
  double _zoomLevel = 1.0;
  bool _showCriticalPath = false;
  final Map<String, bool> _filters = {
    'showCompleted': true,
    'showMilestones': true,
    'showOverdue': true,
  };

  List<Task> get tasks => _applyFilters(_tasks);
  DateTime get viewStartDate => _viewStartDate;
  DateTime get viewEndDate => _viewEndDate;
  double get zoomLevel => _zoomLevel;
  bool get showCriticalPath => _showCriticalPath;

  List<Task> _applyFilters(List<Task> tasks) {
    return tasks.where((task) {
      if (!_filters['showCompleted']! && task.progress! >= 100) return false;
      if (!_filters['showMilestones']! && task.isMillestone) return false;
      if (!_filters['showOverdue']! && task.endDate!.isBefore(DateTime.now())) {
        return false;
      }
      return true;
    }).toList();
  }

  void setZoomLevel(double level) {
    _zoomLevel = level.clamp(0.5, 2.0);
    notifyListeners();
  }

  void toggleCriticalPath() {
    _showCriticalPath = !_showCriticalPath;
    notifyListeners();
  }

  void updateFilter(String key, bool value) {
    _filters[key] = value;
    notifyListeners();
  }

  List<Task> getCriticalPath() {
    // Implement critical path calculation algorithm
    return [];
  }

  void exportToCSV() {
    // Implement CSV export
  }

  Future<void> saveToPreferences() async {
    // Implement state persistence
  }

  Future<void> loadFromPreferences() async {
    // Implement state loading
  }
}


/* 

// State Management
class GanttState extends ChangeNotifier {
  List<Task> _tasks = [];
  DateTime _viewStartDate = DateTime.now();
  DateTime _viewEndDate = DateTime.now().add(const Duration(days: 30));
  
  List<Task> get tasks => _tasks;
  DateTime get viewStartDate => _viewStartDate;
  DateTime get viewEndDate => _viewEndDate;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTaskDates(String taskId, DateTime newStart, DateTime newEnd) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].startDate = newStart;
      _tasks[taskIndex].endDate = newEnd;
      notifyListeners();
    }
  }

  void updateViewRange(DateTime start, DateTime end) {
    _viewStartDate = start;
    _viewEndDate = end;
    notifyListeners();
  }
}
 */