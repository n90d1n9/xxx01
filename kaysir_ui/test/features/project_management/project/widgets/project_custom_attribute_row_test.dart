import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_attribute_metadata_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attribute_row.dart';

void main() {
  testWidgets('custom attribute row focuses value field when requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ProjectCustomAttributeRowHarness(
        attribute: _repositoryAttribute,
        isFocused: true,
        onChanged: (_) {},
        onRemoved: () {},
      ),
    );
    await tester.pumpAndSettle();

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-repository'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(valueField, findsOneWidget);
    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('custom attribute row emits edit and remove actions', (
    tester,
  ) async {
    ProjectCustomAttribute? changedAttribute;
    var didRemove = false;

    await tester.pumpWidget(
      _ProjectCustomAttributeRowHarness(
        attribute: _repositoryAttribute,
        onChanged: (attribute) => changedAttribute = attribute,
        onRemoved: () => didRemove = true,
      ),
    );

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
}

const _repositoryAttribute = ProjectCustomAttribute(
  key: 'repository',
  label: 'Repository',
  type: ProjectCustomAttributeType.url,
);

const _repositoryMetadata = ProjectDomainAttributeMetadata(
  key: 'repository',
  label: 'Repository',
  type: ProjectCustomAttributeType.url,
  importance: ProjectCustomAttributeImportance.requiredField,
  isDomainTemplate: true,
  isRiskWatched: true,
);

class _ProjectCustomAttributeRowHarness extends StatelessWidget {
  const _ProjectCustomAttributeRowHarness({
    required this.attribute,
    required this.onChanged,
    required this.onRemoved,
    this.isFocused = false,
  });

  final ProjectCustomAttribute attribute;
  final bool isFocused;
  final ValueChanged<ProjectCustomAttribute> onChanged;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 920,
          height: 360,
          child: SingleChildScrollView(
            child: ProjectCustomAttributeRow(
              attribute: attribute,
              isFocused: isFocused,
              metadata: _repositoryMetadata,
              onChanged: onChanged,
              onRemoved: onRemoved,
            ),
          ),
        ),
      ),
    );
  }
}
