import '../task/task.dart';

class TaskColumn extends ConsumerWidget {
  final TaskStatus status;
  final List<Task> tasks;

  const TaskColumn({
    required this.status,
    required this.tasks,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Task>(
      onAccept: (task) {
        ref.read(taskListProvider.notifier).moveTask(task.id, status);
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                status.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Draggable<Task>(
                    data: task,
                    feedback: TaskCard(task: task),
                    child: TaskCard(
                      task: task,
                      onTap: () => context.push('/task/${task.id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
