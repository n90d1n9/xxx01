import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_chain_service.dart';

void main() {
  test('gantt dependency chain follows upstream predecessors', () {
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 1,
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 6),
      progress: 0.2,
      dependsOn: 'design',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 6, 10),
      end: DateTime(2026, 6, 15),
      dependsOn: 'build',
    );

    final chain = buildGanttDependencyChain(
      task: launch,
      dependencyTasks: [design, build, launch],
      today: DateTime(2026, 5, 31),
    );

    expect(chain.nodes.map((node) => node.taskId), ['build', 'design']);
    expect(chain.nodes.first.state, GanttDependencyChainState.waiting);
    expect(chain.nodes.last.state, GanttDependencyChainState.ready);
    expect(chain.nodes.first.positionLabel, 'Nearest');
    expect(chain.nodes.last.positionLabel, 'Upstream 2');
    expect(chain.totalCount, 2);
    expect(chain.attentionCount, 1);
    expect(chain.readyCount, 1);
    expect(chain.predecessorCountLabel, '2 predecessors');
    expect(chain.attentionCountLabel, '1 needs attention');
    expect(chain.readyCountLabel, '1 ready');
    expect(chain.state, GanttDependencyChainState.waiting);
    expect(chain.summary, 'Waiting on Build.');
  });

  test('gantt dependency chain reports missing and cyclic paths', () {
    final missingChain = buildGanttDependencyChain(
      task: _task(
        id: 'launch',
        title: 'Launch',
        start: DateTime(2026, 6, 10),
        end: DateTime(2026, 6, 15),
        dependsOn: 'missing',
      ),
      dependencyTasks: const [],
      today: DateTime(2026, 5, 31),
    );

    expect(missingChain.state, GanttDependencyChainState.missing);
    expect(missingChain.nodes.single.title, 'Task missing');
    expect(missingChain.attentionCount, 1);
    expect(missingChain.attentionCountLabel, '1 needs attention');

    final first = _task(
      id: 'first',
      title: 'First',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 2),
      dependsOn: 'second',
    );
    final second = _task(
      id: 'second',
      title: 'Second',
      start: DateTime(2026, 6, 3),
      end: DateTime(2026, 6, 4),
      dependsOn: 'first',
    );

    final cyclicChain = buildGanttDependencyChain(
      task: first,
      dependencyTasks: [first, second],
      today: DateTime(2026, 5, 31),
    );

    expect(cyclicChain.state, GanttDependencyChainState.cycle);
    expect(cyclicChain.nodes.last.state, GanttDependencyChainState.cycle);
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
    dependsOn: dependsOn,
  );
}
