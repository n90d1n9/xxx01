import '../models/accounting_menu_catalog.dart';
import '../models/accounting_menu_saved_view.dart';
import '../models/accounting_workspace_next_action.dart';
import '../models/accounting_workspace_overview.dart';

class AccountingWorkspaceOverviewService {
  const AccountingWorkspaceOverviewService();

  AccountingWorkspaceOverview summarize({
    required Iterable<AccountingMenuSection> sections,
    required Iterable<AccountingMenuSavedView> savedViews,
    required Iterable<AccountingWorkspaceNextAction> priorityActions,
  }) {
    var screenCount = 0;
    var shortcutCount = 0;

    for (final section in sections) {
      screenCount += section.screenDestinations.length;
      shortcutCount += section.shortcutDestinations.length;
    }

    return AccountingWorkspaceOverview(
      sectionCount: sections.length,
      screenCount: screenCount,
      shortcutCount: shortcutCount,
      savedViewCount: savedViews.length,
      priorityActionCount: priorityActions.length,
    );
  }
}
