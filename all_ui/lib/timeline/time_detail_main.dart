import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Models
class HistoricalEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;

  HistoricalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
  });
}

// Enum for zoom levels
enum ZoomLevel { day, month, year, decade, century, millennium }

// Enum for timeline orientation
enum TimelineOrientation { horizontal, vertical }

// State class for timeline
class TimelineState {
  final List<HistoricalEvent> events;
  final ZoomLevel zoomLevel;
  final DateTime centerDate;
  final TimelineOrientation orientation;
  final HistoricalEvent? selectedEvent;

  TimelineState({
    required this.events,
    required this.zoomLevel,
    required this.centerDate,
    required this.orientation,
    this.selectedEvent,
  });

  TimelineState copyWith({
    List<HistoricalEvent>? events,
    ZoomLevel? zoomLevel,
    DateTime? centerDate,
    TimelineOrientation? orientation,
    HistoricalEvent? selectedEvent,
    bool clearSelectedEvent = false,
  }) {
    return TimelineState(
      events: events ?? this.events,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      centerDate: centerDate ?? this.centerDate,
      orientation: orientation ?? this.orientation,
      selectedEvent:
          clearSelectedEvent ? null : selectedEvent ?? this.selectedEvent,
    );
  }
}

// Mock data repository
class EventRepository {
  List<HistoricalEvent> getEvents() {
    return [
      HistoricalEvent(
        id: '1',
        title: 'Moon Landing',
        description:
            'Neil Armstrong becomes the first human to step on the Moon.',
        date: DateTime(1969, 7, 20),
        imageUrl: 'https://example.com/moon_landing.jpg',
      ),
      HistoricalEvent(
        id: '2',
        title: 'World Wide Web Invented',
        description: 'Tim Berners-Lee invents the World Wide Web.',
        date: DateTime(1989, 3, 12),
        imageUrl: 'https://example.com/www.jpg',
      ),
      HistoricalEvent(
        id: '3',
        title: 'First iPhone Released',
        description:
            'Apple releases the first iPhone, revolutionizing mobile technology.',
        date: DateTime(2007, 6, 29),
        imageUrl: 'https://example.com/iphone.jpg',
      ),
      HistoricalEvent(
        id: '4',
        title: 'Fall of the Berlin Wall',
        description:
            'The Berlin Wall falls, symbolizing the end of the Cold War.',
        date: DateTime(1989, 11, 9),
        imageUrl: 'https://example.com/berlin_wall.jpg',
      ),
      HistoricalEvent(
        id: '5',
        title: 'Ancient Rome Founded',
        description:
            'Traditional date for the founding of Rome by Romulus and Remus.',
        date: DateTime(-753, 4, 21),
        imageUrl: 'https://example.com/rome.jpg',
      ),
      HistoricalEvent(
        id: '6',
        title: 'Declaration of Independence',
        description:
            'The United States Declaration of Independence is adopted.',
        date: DateTime(1776, 7, 4),
        imageUrl: 'https://example.com/independence.jpg',
      ),
    ];
  }
}

// Providers
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final timelineStateProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>((ref) {
      final repository = ref.watch(eventRepositoryProvider);
      return TimelineNotifier(repository);
    });

// State notifier
class TimelineNotifier extends StateNotifier<TimelineState> {
  final EventRepository _repository;

  TimelineNotifier(this._repository)
    : super(
        TimelineState(
          events: _repository.getEvents(),
          zoomLevel: ZoomLevel.year,
          centerDate: DateTime.now(),
          orientation: TimelineOrientation.horizontal,
        ),
      );

  void zoomIn() {
    final currentIndex = ZoomLevel.values.indexOf(state.zoomLevel);
    if (currentIndex > 0) {
      state = state.copyWith(zoomLevel: ZoomLevel.values[currentIndex - 1]);
    }
  }

  void zoomOut() {
    final currentIndex = ZoomLevel.values.indexOf(state.zoomLevel);
    if (currentIndex < ZoomLevel.values.length - 1) {
      state = state.copyWith(zoomLevel: ZoomLevel.values[currentIndex + 1]);
    }
  }

  void changeOrientation() {
    state = state.copyWith(
      orientation:
          state.orientation == TimelineOrientation.horizontal
              ? TimelineOrientation.vertical
              : TimelineOrientation.horizontal,
    );
  }

  void selectEvent(HistoricalEvent event) {
    state = state.copyWith(selectedEvent: event);
  }

  void clearSelectedEvent() {
    state = state.copyWith(clearSelectedEvent: true);
  }

  void setCenterDate(DateTime date) {
    state = state.copyWith(centerDate: date);
  }
}

// UI Components
class TimelineViewerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Timeline Viewer',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.light,
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.light,
        home: TimelineScreen(),
      ),
    );
  }
}

class TimelineScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineStateProvider);
    final notifier = ref.read(timelineStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historical Timeline'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              state.orientation == TimelineOrientation.horizontal
                  ? Icons.swap_vert
                  : Icons.swap_horiz,
            ),
            onPressed: () => notifier.changeOrientation(),
            tooltip: 'Change orientation',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimelineLabel(state.zoomLevel, state.centerDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.zoom_in),
                      onPressed: notifier.zoomIn,
                      tooltip: 'Zoom in',
                    ),
                    IconButton(
                      icon: Icon(Icons.zoom_out),
                      onPressed: notifier.zoomOut,
                      tooltip: 'Zoom out',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                state.orientation == TimelineOrientation.horizontal
                    ? HorizontalTimeline(state: state, notifier: notifier)
                    : VerticalTimeline(state: state, notifier: notifier),
          ),
          if (state.selectedEvent != null)
            EventDetailCard(
              event: state.selectedEvent!,
              onClose: notifier.clearSelectedEvent,
            ),
        ],
      ),
    );
  }

  String _formatTimelineLabel(ZoomLevel zoomLevel, DateTime date) {
    switch (zoomLevel) {
      case ZoomLevel.day:
        return DateFormat('MMMM d, yyyy').format(date);
      case ZoomLevel.month:
        return DateFormat('MMMM yyyy').format(date);
      case ZoomLevel.year:
        return DateFormat('yyyy').format(date);
      case ZoomLevel.decade:
        final decade = (date.year ~/ 10) * 10;
        return '${decade}s';
      case ZoomLevel.century:
        final century = (date.year ~/ 100) + 1;
        return '${century}${_getOrdinalSuffix(century)} Century';
      case ZoomLevel.millennium:
        final millennium = (date.year ~/ 1000) + 1;
        return '${millennium}${_getOrdinalSuffix(millennium)} Millennium';
    }
  }

  String _getOrdinalSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

class HorizontalTimeline extends StatelessWidget {
  final TimelineState state;
  final TimelineNotifier notifier;

  const HorizontalTimeline({
    Key? key,
    required this.state,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<HistoricalEvent>.from(state.events)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                // Swipe up - zoom out
                notifier.zoomOut();
              } else if (details.primaryVelocity! > 0) {
                // Swipe down - zoom in
                notifier.zoomIn();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = sortedEvents[index];
                      return TimelineEventItem(
                        event: event,
                        zoomLevel: state.zoomLevel,
                        isSelected: state.selectedEvent?.id == event.id,
                        onTap: () => notifier.selectEvent(event),
                        isHorizontal: true,
                      );
                    }, childCount: sortedEvents.length),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 60,
          child: TimelineRuler(
            zoomLevel: state.zoomLevel,
            centerDate: state.centerDate,
            orientation: TimelineOrientation.horizontal,
          ),
        ),
      ],
    );
  }
}

class VerticalTimeline extends StatelessWidget {
  final TimelineState state;
  final TimelineNotifier notifier;

  const VerticalTimeline({
    Key? key,
    required this.state,
    required this.notifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<HistoricalEvent>.from(state.events)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Row(
      children: [
        Container(
          width: 60,
          child: TimelineRuler(
            zoomLevel: state.zoomLevel,
            centerDate: state.centerDate,
            orientation: TimelineOrientation.vertical,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                // Swipe left
                // Could be used for navigation
              } else if (details.primaryVelocity! > 0) {
                // Swipe right
                // Could be used for navigation
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = sortedEvents[index];
                      return TimelineEventItem(
                        event: event,
                        zoomLevel: state.zoomLevel,
                        isSelected: state.selectedEvent?.id == event.id,
                        onTap: () => notifier.selectEvent(event),
                        isHorizontal: false,
                      );
                    }, childCount: sortedEvents.length),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TimelineRuler extends StatelessWidget {
  final ZoomLevel zoomLevel;
  final DateTime centerDate;
  final TimelineOrientation orientation;

  const TimelineRuler({
    Key? key,
    required this.zoomLevel,
    required this.centerDate,
    required this.orientation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Generate tick marks based on zoom level
    List<Widget> ticks = _generateTicks(zoomLevel, orientation, theme);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child:
          orientation == TimelineOrientation.horizontal
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ticks,
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ticks,
              ),
    );
  }

  List<Widget> _generateTicks(
    ZoomLevel zoomLevel,
    TimelineOrientation orientation,
    ThemeData theme,
  ) {
    List<Widget> ticks = [];

    // This is a simplified version - in a real app you'd generate ticks based on visible range
    switch (zoomLevel) {
      case ZoomLevel.day:
        for (int i = 0; i < 5; i++) {
          final date = DateTime(
            centerDate.year,
            centerDate.month,
            centerDate.day + i - 2,
          );
          ticks.add(_buildTick(DateFormat('d').format(date), theme));
        }
        break;
      case ZoomLevel.month:
        for (int i = 0; i < 5; i++) {
          final date = DateTime(centerDate.year, centerDate.month + i - 2, 1);
          ticks.add(_buildTick(DateFormat('MMM').format(date), theme));
        }
        break;
      case ZoomLevel.year:
        for (int i = 0; i < 5; i++) {
          final year = centerDate.year + i - 2;
          ticks.add(_buildTick(year.toString(), theme));
        }
        break;
      case ZoomLevel.decade:
        for (int i = 0; i < 5; i++) {
          final decade = ((centerDate.year ~/ 10) * 10) + (i - 2) * 10;
          ticks.add(_buildTick('${decade}s', theme));
        }
        break;
      case ZoomLevel.century:
        for (int i = 0; i < 5; i++) {
          final century = ((centerDate.year ~/ 100) + 1) + i - 2;
          ticks.add(_buildTick('${century}C', theme));
        }
        break;
      case ZoomLevel.millennium:
        for (int i = 0; i < 5; i++) {
          final millennium = ((centerDate.year ~/ 1000) + 1) + i - 2;
          final label =
              millennium <= 0 ? '${-millennium + 1}K BC' : '${millennium}K';
          ticks.add(_buildTick(label, theme));
        }
        break;
    }

    return ticks;
  }

  Widget _buildTick(String label, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TimelineEventItem extends StatelessWidget {
  final HistoricalEvent event;
  final ZoomLevel zoomLevel;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHorizontal;

  const TimelineEventItem({
    Key? key,
    required this.event,
    required this.zoomLevel,
    required this.isSelected,
    required this.onTap,
    required this.isHorizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Skip events that shouldn't be visible at current zoom level
    if (!_shouldShowEventAtZoomLevel(event.date, zoomLevel)) {
      return SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isHorizontal ? 200 : null,
        height: isHorizontal ? null : 100,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child:
              isHorizontal
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatEventDate(event.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        event.description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatEventDate(event.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              event.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              event.description,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  String _formatEventDate(DateTime date) {
    if (date.year < 0) {
      return '${-date.year} BCE';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  bool _shouldShowEventAtZoomLevel(DateTime date, ZoomLevel zoomLevel) {
    // This is a simplified logic - in a real app, you'd check if the event
    // falls within the visible time range at the current zoom level
    return true;
  }
}

class EventDetailCard extends StatelessWidget {
  final HistoricalEvent event;
  final VoidCallback onClose;

  const EventDetailCard({Key? key, required this.event, required this.onClose})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDetailedDate(event.date),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (event.imageUrl != null)
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(event.imageUrl!),
                          onError: (exception, stackTrace) => SizedBox.shrink(),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(event.description, style: theme.textTheme.bodyLarge),
                  // In a real app, you would add more details here
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.book),
                        label: Text('Learn More'),
                        onPressed: () {
                          // In a real app, navigate to a detailed page
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDetailedDate(DateTime date) {
    if (date.year < 0) {
      final formatter = DateFormat('MMMM d');
      return '${formatter.format(date)}, ${-date.year} BCE';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

void main() {
  runApp(TimelineViewerApp());
}
