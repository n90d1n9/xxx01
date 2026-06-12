import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_attribute_metadata_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_attribute_metadata_chip_bar.dart';

void main() {
  testWidgets(
    'domain attribute metadata chip bar renders required risk field',
    (tester) async {
      const metadata = ProjectDomainAttributeMetadata(
        key: 'permit-id',
        label: 'Permit ID',
        type: ProjectCustomAttributeType.text,
        importance: ProjectCustomAttributeImportance.requiredField,
        isDomainTemplate: true,
        isRiskWatched: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProjectDomainAttributeMetadataChipBar(metadata: metadata),
          ),
        ),
      );

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Risk signal'), findsOneWidget);
    },
  );

  testWidgets('domain attribute metadata chip bar renders custom fields', (
    tester,
  ) async {
    const metadata = ProjectDomainAttributeMetadata(
      key: 'local-note',
      label: 'Local Note',
      type: ProjectCustomAttributeType.text,
      importance: ProjectCustomAttributeImportance.optional,
      isDomainTemplate: false,
      isRiskWatched: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectDomainAttributeMetadataChipBar(metadata: metadata),
        ),
      ),
    );

    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Risk signal'), findsNothing);
  });
}
