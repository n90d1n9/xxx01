// main_screen.dart - Your main screen with persistent bottom bar
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Navigation state provider
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Page transition type provider
final pageTransitionTypeProvider = StateProvider<TransitionType>((ref) {
  return TransitionType.slide;
});

enum TransitionType { slide, fade, none }

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          _showTransitionSelector(context, ref);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showTransitionSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransitionSelectorSheet(),
    );
  }
}

// Custom Bottom Navigation Bar
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          height: 80,
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.search_outlined, Icons.search, 'Search'),
              const SizedBox(width: 60), // Space for floating button
              _buildNavItem(2, Icons.person_outline, Icons.person, 'Profile'),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(label),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                width: isSelected ? 20 : 0,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Floating Action Button
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.tune,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// Transition Selector Sheet
class TransitionSelectorSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTransition = ref.watch(pageTransitionTypeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Page Transitions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...TransitionType.values.map((type) => _TransitionOption(
            type: type,
            isSelected: currentTransition == type,
            onTap: () {
              ref.read(pageTransitionTypeProvider.notifier).state = type;
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TransitionOption extends StatelessWidget {
  final TransitionType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransitionOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getIconForTransition(type),
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
        title: Text(
          _getTitleForTransition(type),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        subtitle: Text(_getDescriptionForTransition(type)),
        trailing: isSelected 
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected 
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : Colors.transparent,
      ),
    );
  }

  IconData _getIconForTransition(TransitionType type) {
    switch (type) {
      case TransitionType.slide:
        return Icons.swipe;
      case TransitionType.fade:
        return Icons.blur_on;
      case TransitionType.none:
        return Icons.flash_off;
    }
  }

  String _getTitleForTransition(TransitionType type) {
    switch (type) {
      case TransitionType.slide:
        return 'Slide Transition';
      case TransitionType.fade:
        return 'Fade Transition';
      case TransitionType.none:
        return 'No Transition';
    }
  }

  String _getDescriptionForTransition(TransitionType type) {
    switch (type) {
      case TransitionType.slide:
        return 'Pages slide in from the side';
      case TransitionType.fade:
        return 'Pages fade in and out smoothly';
      case TransitionType.none:
        return 'Instant page changes';
    }
  }
}

// Enhanced Routes class with transition support
class EnhancedRoutes extends Routes {
  static GoRoute pageWithTransition(String path, Widget page, WidgetRef ref) {
    final transitionType = ref.read(pageTransitionTypeProvider);
    
    switch (transitionType) {
      case TransitionType.slide:
        return Routes.pageSlideTrans(path, page);
      case TransitionType.fade:
        return Routes.pageFadeTrans(path, page);
      case TransitionType.none:
        return Routes.pageNoTrans(path, page);
    }
  }

  static StatefulShellBranch shellBranchWithTransition(
    String name,
    String path,
    Widget child,
    WidgetRef ref, [
    List<RouteBase>? routes,
  ]) {
    final transitionType = ref.read(pageTransitionTypeProvider);
    GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    
    return StatefulShellBranch(
      navigatorKey: navigatorKey,
      routes: [
        GoRoute(
          name: name,
          path: path,
          pageBuilder: (context, state) {
            switch (transitionType) {
              case TransitionType.slide:
                return SlideTransitionPage(child: child);
              case TransitionType.fade:
                return FadeTransitionPage(child: child);
              case TransitionType.none:
                return NoTransitionPage(child: child);
            }
          },
          routes: routes ?? [],
        ),
      ],
    );
  }
}

// Usage example for your FeaturesRegistry
class NavigationFeature {
  static void register() {
    // Add your navigation branches
    Routes.addBranches([
      Routes.shellBranch('search', '/search', const SearchScreen()),
      Routes.shellBranch('profile', '/profile', const ProfileScreen()),
      Routes.shellBranch('settings', '/settings', const SettingsScreen()),
    ]);
  }
}

// Sample screens
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text('Search Screen', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text('Profile Screen', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text('Settings Screen', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}