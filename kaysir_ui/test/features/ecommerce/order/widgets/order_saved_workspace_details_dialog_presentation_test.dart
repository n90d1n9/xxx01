import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_dialog_presentation.dart';

import '../support/order_saved_workspace_fixtures.dart';

void main() {
  test(
    'details dialog presentation describes custom-note workspace chrome',
    () {
      final presentation =
          OrderSavedWorkspaceDetailsDialogPresentation.fromWorkspace(
            savedWorkspacePinnedDeliveryToday,
          );

      expect(presentation.title, 'Workspace details');
      expect(presentation.filterSectionTitle, 'Exact filters');
      expect(presentation.showAutoSummaryPreview, true);
      expect(presentation.shortcutLine.label, 'Shortcut id');
      expect(
        presentation.shortcutLine.value,
        savedWorkspacePinnedDeliveryToday.id,
      );
    },
  );

  test(
    'details dialog presentation hides auto-summary preview for auto notes',
    () {
      final presentation =
          OrderSavedWorkspaceDetailsDialogPresentation.fromWorkspace(
            savedWorkspaceWebOverdue,
          );

      expect(presentation.showAutoSummaryPreview, false);
      expect(presentation.shortcutLine.value, savedWorkspaceWebOverdue.id);
    },
  );
}
