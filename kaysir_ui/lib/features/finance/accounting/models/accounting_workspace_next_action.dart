class AccountingWorkspaceNextAction {
  const AccountingWorkspaceNextAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.path,
    required this.registerRoute,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final String path;
  final bool registerRoute;
}
