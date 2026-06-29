import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/all_path.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return Routes.config(ref: ref);
});

// Navigation state provider
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>(
      (ref) => NavigationNotifier(),
    );

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier()
    : super(
        NavigationState(
          transitionType: TransitionType.fade,
          currentPath: PathApps.home,
          currentIndex: 0,
          currentValue: '',
        ),
      );

  bool _isBuilding = false;

  void setCurrentPath(String path) {
    if (_isBuilding) {
      Future.microtask(() => _setCurrentPathInternal(path));
    } else {
      _setCurrentPathInternal(path);
    }
  }

  void _setCurrentPathInternal(String path) {
    final index = _pathToIndex(path);
    if (state.currentPath != path || state.currentIndex != index) {
      state = state.copyWith(currentPath: path, currentIndex: index);
    }
  }

  // Similar protection for other state modification methods
  void setIndex(int index) {
    if (_isBuilding) {
      Future.microtask(() => _setIndexInternal(index));
    } else {
      _setIndexInternal(index);
    }
  }

  void _setIndexInternal(int index) {
    final path = _indexToPath(index);
    state = state.copyWith(
      currentIndex: index,
      currentPath: path ?? state.currentPath,
    );
  }

  // Add this to track build state
  void trackBuildState(bool isBuilding) {
    _isBuilding = isBuilding;
  }

  // Add this method to handle route changes
  void handleRouteChange(String newPath, {bool isReplace = false}) {
    final updatedHistory = List<String>.from(state.routeHistory);

    if (isReplace && updatedHistory.isNotEmpty) {
      // Replace the last route
      updatedHistory[updatedHistory.length - 1] = newPath;
    } else {
      // Add new route to history
      updatedHistory.add(newPath);
    }

    // Map path to index for bottom nav
    final index = _pathToIndex(newPath);

    state = state.copyWith(
      currentPath: newPath,
      currentIndex: index,
      routeHistory: updatedHistory,
    );
  }

  int _pathToIndex(String path) {
    switch (path) {
      case PathApps.home:
        return 0;
      case PathApps.inbox:
        return 2;
      case PathApps.profile:
        return 3;
      default:
        return state
            .currentIndex; // maintain current index if path doesn't match
    }
  }

  String? _indexToPath(int index) {
    switch (index) {
      case 0:
        return PathApps.home;
      case 3:
        return PathApps.profile;
      default:
        return null; // return null if index doesn't match main tabs
    }
  }
}

enum TransitionType { slide, fade, none }

class NavigationState {
  final TransitionType transitionType;
  final String currentPath;
  final int currentIndex;
  final dynamic currentValue;
  final List<String> routeHistory; // Track complete navigation history

  NavigationState({
    required this.transitionType,
    required this.currentPath,
    required this.currentIndex,
    this.currentValue,
    this.routeHistory = const [],
  });

  NavigationState copyWith({
    TransitionType? transitionType,
    String? currentPath,
    int? currentIndex,
    dynamic currentValue,
    List<String>? routeHistory,
  }) {
    return NavigationState(
      transitionType: transitionType ?? this.transitionType,
      currentPath: currentPath ?? this.currentPath,
      currentIndex: currentIndex ?? this.currentIndex,
      currentValue: currentValue ?? this.currentValue,
      routeHistory: routeHistory ?? this.routeHistory,
    );
  }
}
