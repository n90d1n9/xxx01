import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// MODELS
enum TimelineLevel { day, month, year, decade, century, millennium }

enum TimelineOrientation { horizontal, vertical }

class HistoricalEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final List<String> imageUrls;
  final TimelineLevel minimumVisibleLevel;

  HistoricalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrls = const [],
    this.minimumVisibleLevel = TimelineLevel.day,
  });
}

// PROVIDERS
final timelineLevelProvider = StateProvider<TimelineLevel>(
  (ref) => TimelineLevel.year,
);
final timelineOrientationProvider = StateProvider<TimelineOrientation>(
  (ref) => TimelineOrientation.horizontal,
);
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedEventProvider = StateProvider<HistoricalEvent?>((ref) => null);

final eventsProvider = Provider<List<HistoricalEvent>>((ref) {
  // This would typically come from a repository/database
  return [
    HistoricalEvent(
      id: '1',
      title: 'Declaration of Independence',
      description:
          'The United States Declaration of Independence was adopted by the Second Continental Congress.',
      date: DateTime(1776, 7, 4),
      minimumVisibleLevel: TimelineLevel.day,
    ),
    HistoricalEvent(
      id: '2',
      title: 'Moon Landing',
      description:
          'Neil Armstrong and Buzz Aldrin became the first humans to walk on the Moon.',
      date: DateTime(1969, 7, 20),
      minimumVisibleLevel: TimelineLevel.day,
    ),
    HistoricalEvent(
      id: '3',
      title: 'Renaissance Period',
      description:
          'The Renaissance was a period in European history marking the transition from the Middle Ages to modernity.',
      date: DateTime(1400, 1, 1),
      minimumVisibleLevel: TimelineLevel.century,
    ),
    // Add more events as needed
  ];
});

final filteredEventsProvider = Provider<List<HistoricalEvent>>((ref) {
  final allEvents = ref.watch(eventsProvider);
  final currentLevel = ref.watch(timelineLevelProvider);

  return allEvents.where((event) {
    // Only show events that are visible at the current level or higher
    final levelIndex = TimelineLevel.values.indexOf(currentLevel);
    final eventLevelIndex = TimelineLevel.values.indexOf(
      event.minimumVisibleLevel,
    );
    return eventLevelIndex <= levelIndex;
  }).toList();
});

// UI COMPONENTS
class TimelineApp extends ConsumerWidget {
  const TimelineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const TimelineScreen(),
    );
  }
}

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientation = ref.watch(timelineOrientationProvider);
    final selectedEvent = ref.watch(selectedEventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Timeline'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              orientation == TimelineOrientation.horizontal
                  ? Icons.swap_vert
                  : Icons.swap_horiz,
            ),
            onPressed: () {
              ref.read(timelineOrientationProvider.notifier).state =
                  orientation == TimelineOrientation.horizontal
                      ? TimelineOrientation.vertical
                      : TimelineOrientation.horizontal;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Level controls
          TimelineLevelControls(),

          // Main timeline view
          Expanded(
            flex: 3,
            child:
                orientation == TimelineOrientation.horizontal
                    ? HorizontalTimelineView()
                    : VerticalTimelineView(),
          ),

          // Event detail view
          if (selectedEvent != null)
            Expanded(flex: 2, child: EventDetailView(event: selectedEvent)),
        ],
      ),
    );
  }
}

class TimelineLevelControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(timelineLevelProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.zoom_in),
            label: const Text('Zoom In'),
            onPressed:
                currentLevel == TimelineLevel.day
                    ? null
                    : () {
                      final levelIndex = TimelineLevel.values.indexOf(
                        currentLevel,
                      );
                      if (levelIndex > 0) {
                        ref.read(timelineLevelProvider.notifier).state =
                            TimelineLevel.values[levelIndex - 1];
                      }
                    },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getLevelDisplayName(currentLevel),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.zoom_out),
            label: const Text('Zoom Out'),
            onPressed:
                currentLevel == TimelineLevel.millennium
                    ? null
                    : () {
                      final levelIndex = TimelineLevel.values.indexOf(
                        currentLevel,
                      );
                      if (levelIndex < TimelineLevel.values.length - 1) {
                        ref.read(timelineLevelProvider.notifier).state =
                            TimelineLevel.values[levelIndex + 1];
                      }
                    },
          ),
        ],
      ),
    );
  }

  String _getLevelDisplayName(TimelineLevel level) {
    switch (level) {
      case TimelineLevel.day:
        return 'Day';
      case TimelineLevel.month:
        return 'Month';
      case TimelineLevel.year:
        return 'Year';
      case TimelineLevel.decade:
        return 'Decade';
      case TimelineLevel.century:
        return 'Century';
      case TimelineLevel.millennium:
        return 'Millennium';
    }
  }
}

class HorizontalTimelineView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(timelineLevelProvider);
    final events = ref.watch(filteredEventsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Generate timeline ticks based on the current level
    final List<DateTime> timelineTicks = _generateTimelineTicks(
      currentLevel,
      selectedDate,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Timeline
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: timelineTicks.length,
              itemBuilder: (context, index) {
                final date = timelineTicks[index];
                final isSelected = _datesEqual(
                  date,
                  selectedDate,
                  currentLevel,
                );

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = date;
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tick mark
                        Container(
                          height: 20,
                          width: 2,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 4),
                        // Date label
                        Text(
                          _formatDateByLevel(date, currentLevel),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Events for the selected date
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _getEventsForDate(
                      events,
                      selectedDate,
                      currentLevel,
                    ).map((event) => EventCard(event: event)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalTimelineView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(timelineLevelProvider);
    final events = ref.watch(filteredEventsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Generate timeline ticks based on the current level
    final List<DateTime> timelineTicks = _generateTimelineTicks(
      currentLevel,
      selectedDate,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Timeline
          SizedBox(
            width: 100,
            child: ListView.builder(
              itemCount: timelineTicks.length,
              itemBuilder: (context, index) {
                final date = timelineTicks[index];
                final isSelected = _datesEqual(
                  date,
                  selectedDate,
                  currentLevel,
                );

                return GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = date;
                  },
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Date label
                        Text(
                          _formatDateByLevel(date, currentLevel),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                      context,
                                    ).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Tick mark
                        Container(
                          width: 20,
                          height: 2,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Events for the selected date
          Expanded(
            child: ListView(
              children:
                  _getEventsForDate(
                    events,
                    selectedDate,
                    currentLevel,
                  ).map((event) => EventCard(event: event)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends ConsumerWidget {
  final HistoricalEvent event;

  const EventCard({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEvent = ref.watch(selectedEventProvider);
    final isSelected = selectedEvent?.id == event.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedEventProvider.notifier).state = event;
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMd().format(event.date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Event content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // View details button
            if (isSelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Viewing Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EventDetailView extends ConsumerWidget {
  final HistoricalEvent event;

  const EventDetailView({required this.event, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(selectedEventProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),

          // Event details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat.yMMMMd().format(event.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(event.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  // Images (if available)
                  if (event.imageUrls.isNotEmpty) ...[
                    const Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: event.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 32),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HELPER FUNCTIONS
List<DateTime> _generateTimelineTicks(
  TimelineLevel level,
  DateTime centerDate,
) {
  final List<DateTime> ticks = [];
  DateTime startDate;
  DateTime endDate;

  switch (level) {
    case TimelineLevel.day:
      startDate = centerDate.subtract(const Duration(days: 15));
      endDate = centerDate.add(const Duration(days: 15));
      for (var i = 0; i <= 30; i++) {
        ticks.add(startDate.add(Duration(days: i)));
      }
      break;
    case TimelineLevel.month:
      startDate = DateTime(centerDate.year, centerDate.month - 6, 1);
      for (var i = 0; i <= 12; i++) {
        ticks.add(DateTime(startDate.year, startDate.month + i, 1));
      }
      break;
    case TimelineLevel.year:
      startDate = DateTime(centerDate.year - 5, 1, 1);
      for (var i = 0; i <= 10; i++) {
        ticks.add(DateTime(startDate.year + i, 1, 1));
      }
      break;
    case TimelineLevel.decade:
      final baseYear = (centerDate.year ~/ 10) * 10;
      startDate = DateTime(baseYear - 20, 1, 1);
      for (var i = 0; i <= 4; i++) {
        ticks.add(DateTime(startDate.year + (i * 10), 1, 1));
      }
      break;
    case TimelineLevel.century:
      final baseCentury = (centerDate.year ~/ 100) * 100;
      startDate = DateTime(baseCentury - 200, 1, 1);
      for (var i = 0; i <= 4; i++) {
        ticks.add(DateTime(startDate.year + (i * 100), 1, 1));
      }
      break;
    case TimelineLevel.millennium:
      final baseMillennium = (centerDate.year ~/ 1000) * 1000;
      startDate = DateTime(baseMillennium - 1000, 1, 1);
      for (var i = 0; i <= 3; i++) {
        ticks.add(DateTime(startDate.year + (i * 1000), 1, 1));
      }
      break;
  }

  return ticks;
}

String _formatDateByLevel(DateTime date, TimelineLevel level) {
  switch (level) {
    case TimelineLevel.day:
      return DateFormat('d').format(date);
    case TimelineLevel.month:
      return DateFormat('MMM').format(date);
    case TimelineLevel.year:
      return date.year.toString();
    case TimelineLevel.decade:
      final decade = (date.year ~/ 10) * 10;
      return '${decade}s';
    case TimelineLevel.century:
      final century = (date.year ~/ 100) + 1;
      return '$century${_ordinalSuffix(century)} cent.';
    case TimelineLevel.millennium:
      final millennium = (date.year ~/ 1000) + 1;
      return '$millennium${_ordinalSuffix(millennium)} mill.';
  }
}

String _ordinalSuffix(int number) {
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

bool _datesEqual(DateTime a, DateTime b, TimelineLevel level) {
  switch (level) {
    case TimelineLevel.day:
      return a.year == b.year && a.month == b.month && a.day == b.day;
    case TimelineLevel.month:
      return a.year == b.year && a.month == b.month;
    case TimelineLevel.year:
      return a.year == b.year;
    case TimelineLevel.decade:
      return (a.year ~/ 10) == (b.year ~/ 10);
    case TimelineLevel.century:
      return (a.year ~/ 100) == (b.year ~/ 100);
    case TimelineLevel.millennium:
      return (a.year ~/ 1000) == (b.year ~/ 1000);
  }
}

List<HistoricalEvent> _getEventsForDate(
  List<HistoricalEvent> events,
  DateTime date,
  TimelineLevel level,
) {
  return events.where((event) => _datesEqual(event.date, date, level)).toList();
}

// MAIN
void main() {
  runApp(const ProviderScope(child: TimelineApp()));
}
