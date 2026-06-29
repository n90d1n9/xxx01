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
  final List<String> tags;

  HistoricalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    this.tags = const [],
  });
}

// Enums
enum TimelineZoomLevel { day, month, year, decade, century }

enum TimelineOrientation { horizontal, vertical }

// Providers
final eventsProvider = Provider<List<HistoricalEvent>>((ref) {
  // Sample data - would normally come from an API or database
  return [
    HistoricalEvent(
      id: '1',
      title: 'Moon Landing',
      description:
          'Neil Armstrong becomes the first human to set foot on the lunar surface.',
      date: DateTime(1969, 7, 20),
      imageUrl: 'https://example.com/moon-landing.jpg',
      tags: ['Space', 'NASA', 'Cold War'],
    ),
    HistoricalEvent(
      id: '2',
      title: 'World Wide Web Invented',
      description: 'Tim Berners-Lee invents the World Wide Web while at CERN.',
      date: DateTime(1989, 3, 12),
      tags: ['Technology', 'Internet'],
    ),
    HistoricalEvent(
      id: '3',
      title: 'First iPhone Released',
      description:
          'Apple releases the first iPhone, revolutionizing mobile technology.',
      date: DateTime(2007, 6, 29),
      imageUrl: 'https://example.com/iphone.jpg',
      tags: ['Technology', 'Apple'],
    ),
    // More events spanning different time periods
    HistoricalEvent(
      id: '4',
      title: 'French Revolution Begins',
      description:
          'The Storming of the Bastille marks the beginning of the French Revolution.',
      date: DateTime(1789, 7, 14),
      tags: ['Politics', 'Revolution'],
    ),
    HistoricalEvent(
      id: '5',
      title: 'Printing Press Invented',
      description: 'Johannes Gutenberg completes the first printing press.',
      date: DateTime(1440, 1, 1),
      tags: ['Technology', 'Communication'],
    ),
  ];
});

final zoomLevelProvider = StateProvider<TimelineZoomLevel>((ref) {
  return TimelineZoomLevel.year;
});

final orientationProvider = StateProvider<TimelineOrientation>((ref) {
  return TimelineOrientation.horizontal;
});

final selectedEventProvider = StateProvider<HistoricalEvent?>((ref) {
  return null;
});

final focusedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Main App
void main() {
  runApp(const ProviderScope(child: TimelineApp()));
}

class TimelineApp extends StatelessWidget {
  const TimelineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeline Explorer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
        ),
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
    final orientation = ref.watch(orientationProvider);
    final zoomLevel = ref.watch(zoomLevelProvider);
    final selectedEvent = ref.watch(selectedEventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Explorer'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              orientation == TimelineOrientation.horizontal
                  ? Icons.swap_horiz
                  : Icons.swap_vert,
            ),
            onPressed: () {
              ref.read(orientationProvider.notifier).state =
                  orientation == TimelineOrientation.horizontal
                      ? TimelineOrientation.vertical
                      : TimelineOrientation.horizontal;
            },
            tooltip: 'Switch orientation',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(context, ref),
            tooltip: 'Jump to date',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildZoomControls(ref, zoomLevel),
          Expanded(
            child: Stack(
              children: [
                _buildTimeline(context, ref),
                if (selectedEvent != null)
                  _buildEventDetailOverlay(context, ref, selectedEvent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls(WidgetRef ref, TimelineZoomLevel currentZoomLevel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _zoomButton(ref, TimelineZoomLevel.day, currentZoomLevel, 'Day'),
          _zoomButton(ref, TimelineZoomLevel.month, currentZoomLevel, 'Month'),
          _zoomButton(ref, TimelineZoomLevel.year, currentZoomLevel, 'Year'),
          _zoomButton(
            ref,
            TimelineZoomLevel.decade,
            currentZoomLevel,
            'Decade',
          ),
          _zoomButton(
            ref,
            TimelineZoomLevel.century,
            currentZoomLevel,
            'Century',
          ),
        ],
      ),
    );
  }

  Widget _zoomButton(
    WidgetRef ref,
    TimelineZoomLevel level,
    TimelineZoomLevel currentLevel,
    String label,
  ) {
    final isSelected = level == currentLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          ref.read(zoomLevelProvider.notifier).state = level;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.indigo : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.indigo,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.indigo.shade200,
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final orientation = ref.watch(orientationProvider);
    final zoomLevel = ref.watch(zoomLevelProvider);
    final focusedDate = ref.watch(focusedDateProvider);

    return GestureDetector(
      onScaleUpdate: (details) {
        if (details.scale > 1.2) {
          _zoomIn(ref);
        } else if (details.scale < 0.8) {
          _zoomOut(ref);
        }
      },
      child:
          orientation == TimelineOrientation.horizontal
              ? _buildHorizontalTimeline(
                context,
                ref,
                events,
                zoomLevel,
                focusedDate,
              )
              : _buildVerticalTimeline(
                context,
                ref,
                events,
                zoomLevel,
                focusedDate,
              ),
    );
  }

  Widget _buildHorizontalTimeline(
    BuildContext context,
    WidgetRef ref,
    List<HistoricalEvent> events,
    TimelineZoomLevel zoomLevel,
    DateTime focusedDate,
  ) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          width: MediaQuery.of(context).size.width * 3, // Allow scrolling
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height / 2 - 2,
                child: Container(height: 4, color: Colors.grey.shade300),
              ),
              ...events.map((event) {
                final position = _calculateHorizontalPosition(
                  context,
                  event.date,
                  zoomLevel,
                  focusedDate,
                );

                return Positioned(
                  left: position,
                  top: MediaQuery.of(context).size.height / 2 - 80,
                  child: _buildEventNode(
                    context,
                    ref,
                    event,
                    orientation: TimelineOrientation.horizontal,
                  ),
                );
              }).toList(),
              ...events.map((event) {
                final position = _calculateHorizontalPosition(
                  context,
                  event.date,
                  zoomLevel,
                  focusedDate,
                );

                return Positioned(
                  left: position,
                  top: MediaQuery.of(context).size.height / 2,
                  child: _buildTimeMarker(context, event.date, zoomLevel),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalTimeline(
    BuildContext context,
    WidgetRef ref,
    List<HistoricalEvent> events,
    TimelineZoomLevel zoomLevel,
    DateTime focusedDate,
  ) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height * 2, // Allow scrolling
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: MediaQuery.of(context).size.width / 2 - 2,
                child: Container(width: 4, color: Colors.grey.shade300),
              ),
              ...events.map((event) {
                final position = _calculateVerticalPosition(
                  context,
                  event.date,
                  zoomLevel,
                  focusedDate,
                );

                return Positioned(
                  top: position,
                  left: MediaQuery.of(context).size.width / 2 - 80,
                  child: _buildEventNode(
                    context,
                    ref,
                    event,
                    orientation: TimelineOrientation.vertical,
                  ),
                );
              }).toList(),
              ...events.map((event) {
                final position = _calculateVerticalPosition(
                  context,
                  event.date,
                  zoomLevel,
                  focusedDate,
                );

                return Positioned(
                  top: position,
                  left: MediaQuery.of(context).size.width / 2 + 10,
                  child: _buildTimeMarker(context, event.date, zoomLevel),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateHorizontalPosition(
    BuildContext context,
    DateTime date,
    TimelineZoomLevel zoomLevel,
    DateTime focusedDate,
  ) {
    final width = MediaQuery.of(context).size.width;
    final center = width * 1.5; // Middle of the scrollable area

    // Calculate difference based on zoom level
    int difference;
    double scale;

    switch (zoomLevel) {
      case TimelineZoomLevel.day:
        difference = date.difference(focusedDate).inDays;
        scale = 50.0; // 50 pixels per day
        break;
      case TimelineZoomLevel.month:
        difference =
            (date.year * 12 + date.month) -
            (focusedDate.year * 12 + focusedDate.month);
        scale = 120.0; // 120 pixels per month
        break;
      case TimelineZoomLevel.year:
        difference = date.year - focusedDate.year;
        scale = 150.0; // 150 pixels per year
        break;
      case TimelineZoomLevel.decade:
        difference = (date.year ~/ 10) - (focusedDate.year ~/ 10);
        scale = 200.0; // 200 pixels per decade
        break;
      case TimelineZoomLevel.century:
        difference = (date.year ~/ 100) - (focusedDate.year ~/ 100);
        scale = 300.0; // 300 pixels per century
        break;
    }

    return center + (difference * scale);
  }

  double _calculateVerticalPosition(
    BuildContext context,
    DateTime date,
    TimelineZoomLevel zoomLevel,
    DateTime focusedDate,
  ) {
    final height = MediaQuery.of(context).size.height;
    final center = height; // Middle of the scrollable area

    // Calculate difference based on zoom level
    int difference;
    double scale;

    switch (zoomLevel) {
      case TimelineZoomLevel.day:
        difference = date.difference(focusedDate).inDays;
        scale = 50.0; // 50 pixels per day
        break;
      case TimelineZoomLevel.month:
        difference =
            (date.year * 12 + date.month) -
            (focusedDate.year * 12 + focusedDate.month);
        scale = 120.0; // 120 pixels per month
        break;
      case TimelineZoomLevel.year:
        difference = date.year - focusedDate.year;
        scale = 150.0; // 150 pixels per year
        break;
      case TimelineZoomLevel.decade:
        difference = (date.year ~/ 10) - (focusedDate.year ~/ 10);
        scale = 200.0; // 200 pixels per decade
        break;
      case TimelineZoomLevel.century:
        difference = (date.year ~/ 100) - (focusedDate.year ~/ 100);
        scale = 300.0; // 300 pixels per century
        break;
    }

    return center + (difference * scale);
  }

  Widget _buildEventNode(
    BuildContext context,
    WidgetRef ref,
    HistoricalEvent event, {
    required TimelineOrientation orientation,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedEventProvider.notifier).state = event;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 150,
              height: 100,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().format(event.date),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  if (event.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children:
                          event.tags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.indigo.shade800,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                ],
              ),
            ),
          ),
          Container(width: 2, height: 40, color: Colors.indigo),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMarker(
    BuildContext context,
    DateTime date,
    TimelineZoomLevel zoomLevel,
  ) {
    String label;

    switch (zoomLevel) {
      case TimelineZoomLevel.day:
        label = DateFormat.MMMd().format(date);
        break;
      case TimelineZoomLevel.month:
        label = DateFormat.yMMM().format(date);
        break;
      case TimelineZoomLevel.year:
        label = date.year.toString();
        break;
      case TimelineZoomLevel.decade:
        final decade = (date.year ~/ 10) * 10;
        label = '${decade}s';
        break;
      case TimelineZoomLevel.century:
        final century = (date.year ~/ 100) + 1;
        label = '${century}th century';
        break;
    }

    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
    );
  }

  Widget _buildEventDetailOverlay(
    BuildContext context,
    WidgetRef ref,
    HistoricalEvent event,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedEventProvider.notifier).state = null;
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap from propagating
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            ref.read(selectedEventProvider.notifier).state =
                                null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMMd().format(event.date),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (event.imageUrl != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(event.imageUrl!),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    if (event.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            event.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _zoomIn(WidgetRef ref) {
    final currentZoom = ref.read(zoomLevelProvider);
    switch (currentZoom) {
      case TimelineZoomLevel.century:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.decade;
        break;
      case TimelineZoomLevel.decade:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.year;
        break;
      case TimelineZoomLevel.year:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.month;
        break;
      case TimelineZoomLevel.month:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.day;
        break;
      case TimelineZoomLevel.day:
        // Already at maximum zoom
        break;
    }
  }

  void _zoomOut(WidgetRef ref) {
    final currentZoom = ref.read(zoomLevelProvider);
    switch (currentZoom) {
      case TimelineZoomLevel.day:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.month;
        break;
      case TimelineZoomLevel.month:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.year;
        break;
      case TimelineZoomLevel.year:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.decade;
        break;
      case TimelineZoomLevel.decade:
        ref.read(zoomLevelProvider.notifier).state = TimelineZoomLevel.century;
        break;
      case TimelineZoomLevel.century:
        // Already at minimum zoom
        break;
    }
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final currentDate = ref.read(focusedDateProvider);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1, 1, 1),
      lastDate: DateTime(3000, 12, 31),
    );

    if (selectedDate != null) {
      ref.read(focusedDateProvider.notifier).state = selectedDate;
    }
  }
}
