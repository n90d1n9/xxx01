import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_filter_controls.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_switch_status_filter_bar.dart';

void main() {
  testWidgets('switch filter controls render search and status filters', (
    tester,
  ) async {
    final searchChanges = <String>[];

    await tester.pumpWidget(
      _FilterControlsHost(onSearchChanged: searchChanges.add),
    );

    expect(find.text('Search modes'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'quick');
    await tester.pump();

    expect(searchChanges, ['quick']);
  });

  testWidgets('switch filter controls report selected status changes', (
    tester,
  ) async {
    final statusChanges = <_FilterStatus>[];

    await tester.pumpWidget(
      _FilterControlsHost(onStatusSelected: statusChanges.add),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ready'));
    await tester.pump();

    expect(statusChanges, [_FilterStatus.ready]);
  });
}

class _FilterControlsHost extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<_FilterStatus>? onStatusSelected;

  const _FilterControlsHost({this.onSearchChanged, this.onStatusSelected});

  @override
  State<_FilterControlsHost> createState() => _FilterControlsHostState();
}

class _FilterControlsHostState extends State<_FilterControlsHost> {
  final _controller = TextEditingController();
  _FilterStatus _status = _FilterStatus.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: POSSwitchFilterControls<_FilterStatus>(
          searchController: _controller,
          searchHintText: 'Search modes',
          onSearchChanged: (value) {
            widget.onSearchChanged?.call(value);
            setState(() {});
          },
          selectedStatus: _status,
          statusOptions: const [
            POSSwitchStatusFilterOption(
              value: _FilterStatus.all,
              label: 'All',
              count: 4,
            ),
            POSSwitchStatusFilterOption(
              value: _FilterStatus.ready,
              label: 'Ready',
              count: 2,
            ),
          ],
          onStatusSelected: (status) {
            widget.onStatusSelected?.call(status);
            setState(() => _status = status);
          },
        ),
      ),
    );
  }
}

enum _FilterStatus { all, ready }
