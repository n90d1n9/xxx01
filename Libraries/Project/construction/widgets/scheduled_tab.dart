import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/project.dart';
import '../models/schedule.dart';
import '../states/scheduled_provider.dart';
import '../utils/format_helper.dart';
import 'add_scheduled_tab.dart';

class ScheduleTab extends ConsumerWidget {
  final Project project;

  const ScheduleTab({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSchedules = ref.watch(scheduleProvider);
    final projectSchedules =
        allSchedules.where((s) => s.projectId == project.id).toList()
          ..sort((a, b) => a.mulai.compareTo(b.mulai));

    final avgProgress = projectSchedules.isEmpty
        ? 0.0
        : projectSchedules.fold<double>(0, (sum, s) => sum + s.progress) /
              projectSchedules.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Keseluruhan',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${avgProgress.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddScheduleDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Jadwal'),
              ),
            ],
          ),
        ),
        Expanded(
          child: projectSchedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada jadwal',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: projectSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = projectSchedules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () =>
                            _showEditScheduleDialog(context, ref, schedule),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      schedule.aktivitas,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getProgressColor(
                                        schedule.progress,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${schedule.progress}%',
                                      style: TextStyle(
                                        color: _getProgressColor(
                                          schedule.progress,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${FormatHelper.dateFormat.format(schedule.mulai)} - ${FormatHelper.dateFormat.format(schedule.selesai)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              if (schedule.pic != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PIC: ${schedule.pic}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: schedule.progress / 100,
                                backgroundColor: Colors.grey[200],
                                color: _getProgressColor(schedule.progress),
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getProgressColor(int progress) {
    if (progress == 100) return Colors.green;
    if (progress >= 75) return Colors.lightGreen;
    if (progress >= 50) return Colors.orange;
    if (progress >= 25) return Colors.deepOrange;
    return Colors.red;
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(ref: ref, projectId: project.id),
    );
  }

  void _showEditScheduleDialog(
    BuildContext context,
    WidgetRef ref,
    Schedule schedule,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        ref: ref,
        projectId: project.id,
        editSchedule: schedule,
      ),
    );
  }
}
