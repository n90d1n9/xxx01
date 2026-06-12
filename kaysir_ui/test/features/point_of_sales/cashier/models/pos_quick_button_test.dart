import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_manifest.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/pos_quick_button.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';

void main() {
  test('quick button intent exposes stable semantic keys', () {
    const command = POSQuickButtonIntent.commandAction('payment');
    const custom = POSQuickButtonIntent.customFlow(
      targetId: 'split_check',
      payload: {'source': 'table_service'},
    );

    expect(command.isComplete, isTrue);
    expect(command.semanticKey, 'commandAction:payment');
    expect(custom.isComplete, isTrue);
    expect(custom.semanticKey, 'customFlow:split_check');
  });

  test('quick button availability respects surface and runtime context', () {
    const button = POSQuickButton(
      id: 'grocery_weigh_item',
      label: 'Weigh Item',
      description: 'Start weighted item flow.',
      intent: POSQuickButtonIntent.customFlow(targetId: 'weigh_item'),
      surface: POSQuickButtonSurface.primaryGrid,
      supportedFormFactors: [
        POSExperienceFormFactor.desktop,
        POSExperienceFormFactor.tablet,
      ],
      layoutPreferences: [POSLayoutPreference.counter],
      productLines: ['Grocery'],
      requiredTraits: ['weighted-items'],
    );

    expect(
      button.isAvailableFor(
        const POSQuickButtonContext(
          surface: POSQuickButtonSurface.primaryGrid,
          formFactor: POSExperienceFormFactor.tablet,
          layoutPreference: POSLayoutPreference.counter,
          productLine: 'grocery',
          traits: ['weighted-items', 'scanner-first'],
        ),
      ),
      isTrue,
    );
    expect(
      button.isAvailableFor(
        const POSQuickButtonContext(
          surface: POSQuickButtonSurface.commandBar,
          formFactor: POSExperienceFormFactor.tablet,
          layoutPreference: POSLayoutPreference.counter,
          productLine: 'Grocery',
          traits: ['weighted-items'],
        ),
      ),
      isFalse,
    );
    expect(
      button.isAvailableFor(
        const POSQuickButtonContext(
          surface: POSQuickButtonSurface.primaryGrid,
          formFactor: POSExperienceFormFactor.mobile,
          layoutPreference: POSLayoutPreference.counter,
          productLine: 'Grocery',
          traits: ['weighted-items'],
        ),
      ),
      isFalse,
    );
  });
}
