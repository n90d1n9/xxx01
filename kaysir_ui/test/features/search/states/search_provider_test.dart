import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/search/states/search_provider.dart';

void main() {
  test('empty query clears suggestions and results', () async {
    final notifier = SearchNotifier();

    await notifier.updateQuery('desk');
    await notifier.performSearch();

    expect(notifier.state.suggestions, isNotEmpty);
    expect(notifier.state.results, isNotEmpty);

    await notifier.updateQuery('');

    expect(notifier.state.query, isEmpty);
    expect(notifier.state.suggestions, isEmpty);
    expect(notifier.state.results, isEmpty);
  });

  test(
    'stale suggestion responses do not overwrite newer query state',
    () async {
      final notifier = SearchNotifier();

      final staleUpdate = notifier.updateQuery('desk');
      final emptyUpdate = notifier.updateQuery('');

      await Future.wait([staleUpdate, emptyUpdate]);

      expect(notifier.state.query, isEmpty);
      expect(notifier.state.suggestions, isEmpty);
    },
  );
}
