int? findBestMatchingBranchPathIndex(
  String path,
  Iterable<String?> branchPaths,
) {
  final normalizedPath = normalizeAdminRoutePath(path);
  var bestIndex = -1;
  var bestPathLength = -1;
  var index = 0;

  for (final branchPath in branchPaths) {
    if (branchPath != null &&
        adminRoutePathMatches(normalizedPath, branchPath) &&
        normalizeAdminRoutePath(branchPath).length > bestPathLength) {
      bestIndex = index;
      bestPathLength = normalizeAdminRoutePath(branchPath).length;
    }
    index += 1;
  }

  return bestIndex == -1 ? null : bestIndex;
}

bool adminRoutePathMatches(String path, String routePath) {
  final normalizedPath = normalizeAdminRoutePath(path);
  final normalizedRoutePath = normalizeAdminRoutePath(routePath);

  return normalizedPath == normalizedRoutePath ||
      normalizedPath.startsWith('$normalizedRoutePath/');
}

bool adminRouteIsBranchDefaultRequest(String path, String? routePath) {
  if (routePath == null) return false;
  if (adminRouteHasQueryOrFragment(path)) return false;

  return normalizeAdminRoutePath(path) == normalizeAdminRoutePath(routePath);
}

int adminRouteLocationMatchScore(String location, String? routePath) {
  final normalizedRoutePath = routePath?.trim();
  if (normalizedRoutePath == null || normalizedRoutePath.isEmpty) {
    return -1;
  }

  final targetUri = Uri.parse(normalizedRoutePath);
  final locationUri = Uri.parse(location.trim());
  final targetPath = normalizeAdminRoutePath(normalizedRoutePath);
  final locationPath = normalizeAdminRoutePath(location);

  if (!adminRoutePathMatches(locationPath, targetPath)) {
    return -1;
  }

  if (targetUri.hasQuery || targetUri.hasFragment) {
    final queryMatches = targetUri.queryParameters.entries.every(
      (entry) => locationUri.queryParameters[entry.key] == entry.value,
    );
    final fragmentMatches =
        targetUri.fragment.isEmpty ||
        targetUri.fragment == locationUri.fragment;
    if (!queryMatches || !fragmentMatches) {
      return -1;
    }

    return 100000 +
        targetPath.length +
        targetUri.query.length +
        targetUri.fragment.length;
  }

  return targetPath.length;
}

bool adminRouteHasQueryOrFragment(String path) {
  final uri = Uri.parse(path.trim());
  return uri.hasQuery || uri.hasFragment;
}

String normalizeAdminRoutePath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty || trimmed == '/') return '/';
  final parsedPath = Uri.parse(trimmed).path;
  final normalizedPath = parsedPath.isEmpty ? '/' : parsedPath;
  return normalizedPath.endsWith('/') && normalizedPath.length > 1
      ? normalizedPath.substring(0, normalizedPath.length - 1)
      : normalizedPath;
}
