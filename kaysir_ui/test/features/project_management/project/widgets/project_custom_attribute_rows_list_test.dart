import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_editor_context_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attribute_rows_list.dart';

void main() {
  testWidgets('custom attribute rows list focuses requested row', (
    tester,
  ) async {
    final rows =
        const ProjectCustomAttributeEditorContextService()
            .build(
              businessDomain: 'Software Development',
              attributes: defaultProjectCustomAttributesForDomain(
                'Software Development',
              ),
            )
            .rows;

    await tester.pumpWidget(
      _ProjectCustomAttributeRowsListHarness(
        rows: rows,
        focusedAttributeKey: 'repository',
        onChanged: (_, _) {},
        onRemoved: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    final rowsList = find.byKey(
      const ValueKey('project-custom-attribute-rows-list'),
    );
    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-repository'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(rowsList, findsOneWidget);
    expect(
      find.byKey(const ValueKey('project-custom-attribute-row-repository')),
      findsOneWidget,
    );
    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets(
    'custom attribute rows list emits indexed edit and remove events',
    (tester) async {
      final rows =
          const ProjectCustomAttributeEditorContextService()
              .build(
                businessDomain: 'Software Development',
                attributes: defaultProjectCustomAttributesForDomain(
                  'Software Development',
                ),
              )
              .rows;
      int? changedIndex;
      ProjectCustomAttribute? changedAttribute;
      int? removedIndex;

      await tester.pumpWidget(
        _ProjectCustomAttributeRowsListHarness(
          rows: rows,
          focusedAttributeKey: '',
          onChanged: (index, attribute) {
            changedIndex = index;
            changedAttribute = attribute;
          },
          onRemoved: (index) => removedIndex = index,
        ),
      );

      final valueField = find.byKey(
        const ValueKey('project-custom-attribute-value-repository'),
      );
      await tester.enterText(
        find.descendant(of: valueField, matching: find.byType(TextField)),
        'https://example.test/release',
      );
      await tester.pump();

      expect(changedIndex, 0);
      expect(changedAttribute?.key, 'repository');
      expect(changedAttribute?.value, 'https://example.test/release');

      await tester.tap(find.byTooltip('Remove Repository'));
      await tester.pump();

      expect(removedIndex, 0);
    },
  );
}

class _ProjectCustomAttributeRowsListHarness extends StatelessWidget {
  const _ProjectCustomAttributeRowsListHarness({
    required this.rows,
    required this.focusedAttributeKey,
    required this.onChanged,
    required this.onRemoved,
  });

  final List<ProjectCustomAttributeEditorRowContext> rows;
  final String focusedAttributeKey;
  final ProjectCustomAttributeIndexedChanged onChanged;
  final ValueChanged<int> onRemoved;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 920,
          height: 460,
          child: SingleChildScrollView(
            child: ProjectCustomAttributeRowsList(
              rows: rows,
              focusedAttributeKey: focusedAttributeKey,
              onChanged: onChanged,
              onRemoved: onRemoved,
            ),
          ),
        ),
      ),
    );
  }
}
