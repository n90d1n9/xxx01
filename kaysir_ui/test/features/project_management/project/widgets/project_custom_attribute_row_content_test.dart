import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_attribute_metadata_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attribute_row_content.dart';

void main() {
  testWidgets('custom attribute row content wires editable controls', (
    tester,
  ) async {
    final labelController = TextEditingController(text: _repository.label);
    final focusNode = FocusNode();
    addTearDown(labelController.dispose);
    addTearDown(focusNode.dispose);

    ProjectCustomAttribute? changedAttribute;
    var didRemove = false;

    await tester.pumpWidget(
      _ProjectCustomAttributeRowContentHarness(
        attribute: _repository,
        labelController: labelController,
        focusNode: focusNode,
        onChanged: (attribute) => changedAttribute = attribute,
        onRemoved: () => didRemove = true,
      ),
    );

    expect(
      find.byKey(const ValueKey('project-custom-attribute-wide-repository')),
      findsOneWidget,
    );
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Risk signal'), findsOneWidget);

    await tester.tap(find.text('URL'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text').last);
    await tester.pumpAndSettle();

    expect(changedAttribute?.type, ProjectCustomAttributeType.text);

    changedAttribute = null;
    await tester.enterText(
      find.widgetWithIcon(TextField, Icons.label_outline),
      'Delivery Portal',
    );
    await tester.pump();

    expect(changedAttribute?.label, 'Delivery Portal');

    changedAttribute = null;
    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-repository'),
    );
    await tester.enterText(
      find.descendant(of: valueField, matching: find.byType(TextField)),
      'https://example.test/delivery',
    );
    await tester.pump();

    expect(changedAttribute?.value, 'https://example.test/delivery');

    await tester.tap(find.byTooltip('Remove Repository'));
    await tester.pump();

    expect(didRemove, isTrue);
  });

  testWidgets('custom attribute row content stacks fields on narrow widths', (
    tester,
  ) async {
    final labelController = TextEditingController(text: _repository.label);
    final focusNode = FocusNode();
    addTearDown(labelController.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _ProjectCustomAttributeRowContentHarness(
        width: 360,
        attribute: _repository,
        labelController: labelController,
        focusNode: focusNode,
        onChanged: (_) {},
        onRemoved: () {},
      ),
    );

    expect(
      find.byKey(const ValueKey('project-custom-attribute-narrow-repository')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-custom-attribute-type-repository')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('project-custom-attribute-remove-repository')),
      findsOneWidget,
    );
  });
}

const _repository = ProjectCustomAttribute(
  key: 'repository',
  label: 'Repository',
  type: ProjectCustomAttributeType.url,
);

const _metadata = ProjectDomainAttributeMetadata(
  key: 'repository',
  label: 'Repository',
  type: ProjectCustomAttributeType.url,
  importance: ProjectCustomAttributeImportance.requiredField,
  isDomainTemplate: true,
  isRiskWatched: true,
);

class _ProjectCustomAttributeRowContentHarness extends StatelessWidget {
  const _ProjectCustomAttributeRowContentHarness({
    required this.attribute,
    required this.labelController,
    required this.focusNode,
    required this.onChanged,
    required this.onRemoved,
    this.width = 920,
  });

  final ProjectCustomAttribute attribute;
  final TextEditingController labelController;
  final FocusNode focusNode;
  final ValueChanged<ProjectCustomAttribute> onChanged;
  final VoidCallback onRemoved;
  final double width;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: ProjectCustomAttributeRowContent(
            attribute: attribute,
            metadata: _metadata,
            labelController: labelController,
            valueFocusNode: focusNode,
            autofocusValueField: false,
            onChanged: onChanged,
            onRemoved: onRemoved,
          ),
        ),
      ),
    );
  }
}
