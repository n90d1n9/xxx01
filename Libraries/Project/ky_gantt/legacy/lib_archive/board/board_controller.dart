import 'package:flutter/material.dart';

class BoardController extends ChangeNotifier {
  // Define the tasks in each column
  final Map<String, List<String>> _tasks = {
    "To Do": [],
    "In Progress": [],
    "Done": [],
  };

  // Get tasks for a specific column
  List<String> getTasks(String column) => _tasks[column] ?? [];


/*   void addTask(String column, String task) {
    _tasks[column]?.add(task);
    notifyListeners();
  } */

/*   void moveTask(String fromColumn, String toColumn, String task) {
    _tasks[fromColumn]?.remove(task);
    _tasks[toColumn]?.add(task);
    notifyListeners();
  } */

  String getTaskColumn(String task) {
    return _tasks.entries.firstWhere((entry) => entry.value.contains(task)).key;
  }

  // Add a task to a column
  void addTask(String column, String task) {
    _tasks[column]?.add(task);
    notifyListeners(); // Notify UI to update
  }

  // Move a task from one column to another
  void moveTask(String fromColumn, String toColumn, String task) {
    _tasks[fromColumn]?.remove(task);
    _tasks[toColumn]?.add(task);
    notifyListeners();
  }

  // Remove a task from a column
  void removeTask(String column, String task) {
    _tasks[column]?.remove(task);
    notifyListeners();
  }
}
