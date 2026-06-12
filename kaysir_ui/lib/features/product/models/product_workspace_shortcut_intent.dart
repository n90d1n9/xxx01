class ProductWorkspaceShortcutIntent {
  const ProductWorkspaceShortcutIntent.route(this.path);

  final String path;

  String? get routePath {
    final normalizedPath = path.trim();
    return normalizedPath.isEmpty ? null : normalizedPath;
  }

  bool get hasRoute => routePath != null;
}
