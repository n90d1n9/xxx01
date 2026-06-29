import 'package:flutter/material.dart';

import 'models/task.dart';

final now = DateTime.now();
final dummytasks = [
  Task(
    id: '1',
    title: 'Project Planning',
    startDate: now.subtract(const Duration(days: 5)),
    endDate: now.add(const Duration(days: 2)),
    progress: 0.8,
    color: Colors.blue,
    subtasks: [
      Task(
        id: '1.1',
        title: 'Requirements Gathering',
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 2)),
        progress: 1.0,
        color: Colors.blue.shade300,
      ),
      Task(
        id: '1.2',
        title: 'Resource Allocation',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 2)),
        progress: 0.6,
        color: Colors.blue.shade300,
      ),
    ],
  ),
  Task(
    id: '2',
    title: 'Design Phase',
    startDate: now.add(const Duration(days: 3)),
    endDate: now.add(const Duration(days: 10)),
    progress: 0.2,
    color: Colors.green,
    dependsOn: '1',
  ),
  Task(
    id: '3',
    title: 'Development',
    startDate: now.add(const Duration(days: 11)),
    endDate: now.add(const Duration(days: 25)),
    progress: 0.0,
    color: Colors.orange,
    dependsOn: '2',
  ),
  Task(
    id: '4',
    title: 'Testing',
    startDate: now.add(const Duration(days: 25)),
    endDate: now.add(const Duration(days: 30)),
    progress: 0.0,
    color: Colors.purple,
    dependsOn: '3',
  ),
];
