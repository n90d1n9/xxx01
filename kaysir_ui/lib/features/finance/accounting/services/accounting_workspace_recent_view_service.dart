import '../models/accounting_workspace_recent_view.dart';

class AccountingWorkspaceRecentViewService {
  const AccountingWorkspaceRecentViewService({this.maxItems = 5});

  final int maxItems;

  List<AccountingWorkspaceRecentView> record(
    List<AccountingWorkspaceRecentView> current,
    AccountingWorkspaceRecentView view,
  ) {
    if (view.isDefault || maxItems <= 0) {
      return List<AccountingWorkspaceRecentView>.unmodifiable(current);
    }

    final deduped = current
        .where((item) => item.id != view.id)
        .toList(growable: false);

    return List<AccountingWorkspaceRecentView>.unmodifiable(
      [view, ...deduped].take(maxItems),
    );
  }

  List<AccountingWorkspaceRecentView> clear() {
    return const [];
  }
}
