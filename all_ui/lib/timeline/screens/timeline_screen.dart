import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_state.dart';
import '../models/timeline_view.dart';
import '../models/user_profile.dart';
import '../states/timeline_provider.dart';
import '../states/user_profile_provider.dart';
import '../widgets/active_filter_chips.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/category_filter.dart';
import '../widgets/comparison_sheet.dart';
import '../widgets/event_grap.dart';
import '../widgets/event_list.dart';
import '../widgets/events_grid.dart';
import '../widgets/events_map.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/minilimeline.dart';
import '../widgets/sort_option.dart';
import '../widgets/statistic_sheet.dart';
import '../widgets/tag_filter.dart';
import '../widgets/vertical_timeline.dart';
import '../widgets/view_mode_selector.dart';
import '../widgets/view_selector.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProfileProvider.notifier).updateStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timelineProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, state, userProfile),
          const SliverToBoxAdapter(child: SearchBar()),
          const SliverToBoxAdapter(child: ViewSelector()),
          const SliverToBoxAdapter(child: ViewModeSelector()),
          const SliverToBoxAdapter(child: CategoryFilter()),
          const SliverToBoxAdapter(child: TagFilter()),
          const SliverToBoxAdapter(child: ActiveFiltersChips()),
          const SliverToBoxAdapter(child: SortOptions()),
          if (state.showTimeline)
            const SliverToBoxAdapter(child: MiniTimeline()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          _buildEventsList(state),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: _buildFAB(state),
      drawer: const AppDrawer(),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    TimelineState state,
    UserProfile userProfile,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      actions: [
        IconButton(
          icon: Icon(
            state.showFavorites ? Icons.favorite : Icons.favorite_border,
            color: state.showFavorites ? Colors.red : null,
          ),
          onPressed: () => _showStatistics(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Historical Timeline Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF6C63FF).withOpacity(0.7),
                    const Color(0xFFFF6B9D).withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBadge(
                    Icons.emoji_events,
                    '${userProfile.totalPoints}',
                    'Points',
                  ),
                  _buildStatBadge(
                    Icons.local_fire_department,
                    '${userProfile.streakDays}',
                    'Day Streak',
                  ),
                  _buildStatBadge(
                    Icons.stars,
                    '${userProfile.achievements.length}',
                    'Achievements',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(TimelineState state) {
    switch (state.viewMode) {
      case ViewMode.grid:
        return const EventsGrid();
      case ViewMode.timeline:
        return const VerticalTimeline();
      case ViewMode.map:
        return const EventsMap();
      case ViewMode.graph:
        return const EventsGraph();
      case ViewMode.list:
      default:
        return const EventsList();
    }
  }

  Widget _buildFAB(TimelineState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.comparisonMode && state.comparisonEventIds.isNotEmpty)
          FloatingActionButton(
            heroTag: 'compare',
            mini: true,
            onPressed: () => _showComparison(context),
            backgroundColor: Colors.amber,
            child: Badge(
              label: Text('${state.comparisonEventIds.length}'),
              child: const Icon(Icons.compare_arrows),
            ),
          ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          onPressed: () => ref.read(timelineProvider.notifier).toggleTimeline(),
          icon: Icon(
            state.showTimeline ? Icons.visibility_off : Icons.visibility,
          ),
          label: Text(state.showTimeline ? 'Hide Timeline' : 'Show Timeline'),
          backgroundColor: const Color(0xFF6C63FF),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterSheet(),
    );
  }

  void _showStatistics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const StatisticsSheet(),
    );
  }

  void _showComparison(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ComparisonSheet(),
    );
  }
}
