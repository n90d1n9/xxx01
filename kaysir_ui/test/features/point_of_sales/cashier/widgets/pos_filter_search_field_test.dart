import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_filter_search_field.dart';

void main() {
  testWidgets('filter search field renders hint and forwards query changes', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(_POSFilterSearchFieldHost(onChanged: changes.add));

    expect(find.text('Search catalog'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pump();

    expect(changes, ['coffee']);
  });

  testWidgets('filter search field shows clear action when query is active', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(_POSFilterSearchFieldHost(onChanged: changes.add));

    expect(find.byTooltip('Clear search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'latte');
    await tester.pump();

    expect(find.byTooltip('Clear search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(find.text('latte'), findsNothing);
    expect(find.byTooltip('Clear search'), findsNothing);
    expect(changes, ['latte', '']);
  });
}

class _POSFilterSearchFieldHost extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _POSFilterSearchFieldHost({required this.onChanged});

  @override
  State<_POSFilterSearchFieldHost> createState() =>
      _POSFilterSearchFieldHostState();
}

class _POSFilterSearchFieldHostState extends State<_POSFilterSearchFieldHost> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: POSFilterSearchField(
          controller: _controller,
          hintText: 'Search catalog',
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {});
          },
        ),
      ),
    );
  }
}
