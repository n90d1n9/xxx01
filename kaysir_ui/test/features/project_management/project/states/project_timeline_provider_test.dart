import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_view_repository.dart';
import 'package:kaysir/features/project_management/project/states/project_portfolio_provider.dart';
import 'package:kaysir/features/project_management/project/states/project_timeline_provider.dart';

void main() {
  test('project timeline provider links portfolio projects to gantt tasks', () {
    final container = ProviderContainer(
      overrides: [
        projectPortfolioViewRepositoryProvider.overrideWithValue(
          ProjectPortfolioViewRepository(
            store: MemoryProjectPortfolioViewSnapshotStore(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tasks = container.read(
      projectTimelineTasksProvider('retail-modernization'),
    );

    expect(tasks.map((task) => task.id), containsAll(['1', '1.1', '1.2']));
    expect(tasks.map((task) => task.title), contains('Project Planning'));
  });
}
