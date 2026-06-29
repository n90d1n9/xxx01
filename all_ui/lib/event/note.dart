// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      home: const EventListScreen(),
    );
  }
}

// MODELS
// lib/models/event.dart
class Event {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final EventLevel eventLevel;
  final EventStatus status;
  final EventType type;
  final EventCategory category;
  final Location location;
  final List<Content> content;
  final Gallery? gallery;
  final Venue? venue;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.eventLevel,
    required this.status,
    required this.type,
    required this.category,
    required this.location,
    required this.content,
    this.gallery,
    this.venue,
  });
}

class Venue {
  final int id;
  final String name;
  final int capacity;
  final String contactPerson;
  final String contactNumber;
  final Location location;

  Venue({
    required this.id,
    required this.name,
    required this.capacity,
    required this.contactPerson,
    required this.contactNumber,
    required this.location,
  });
}

class Location {
  final int id;
  final String name;
  final String description;

  Location({required this.id, required this.name, required this.description});
}

class Content {
  final int id;
  final String content;
  final DateTime createdAt;

  Content({required this.id, required this.content, required this.createdAt});
}

class Image {
  final int id;
  final String title;
  final String description;
  final DateTime taken;
  final DateTime uploaded;
  final String path;
  final double ownerId;
  final double referenceId;
  final String urlThumbnail;
  final String urlMedium;
  final String urlHD;
  final ImageType type;

  Image({
    required this.id,
    required this.title,
    required this.description,
    required this.taken,
    required this.uploaded,
    required this.path,
    required this.ownerId,
    required this.referenceId,
    required this.urlThumbnail,
    required this.urlMedium,
    required this.urlHD,
    required this.type,
  });
}

class Gallery {
  final int id;
  final String name;
  final String description;
  final List<Image> images;

  Gallery({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
  });
}

class EventCategory {
  final int id;
  final String name;

  EventCategory({required this.id, required this.name});
}

// ENUMS
enum EventStatus {
  DRAFT,
  PUBLISHED,
  CANCELLED,
  COMPLETED,
  POSTPONED;

  String get displayName {
    switch (this) {
      case EventStatus.DRAFT:
        return 'Draft';
      case EventStatus.PUBLISHED:
        return 'Published';
      case EventStatus.CANCELLED:
        return 'Cancelled';
      case EventStatus.COMPLETED:
        return 'Completed';
      case EventStatus.POSTPONED:
        return 'Postponed';
    }
  }

  Color get color {
    switch (this) {
      case EventStatus.DRAFT:
        return Colors.grey;
      case EventStatus.PUBLISHED:
        return Colors.green;
      case EventStatus.CANCELLED:
        return Colors.red;
      case EventStatus.COMPLETED:
        return Colors.blue;
      case EventStatus.POSTPONED:
        return Colors.orange;
    }
  }
}

enum EventLevel { World, National, Regional, Local }

enum EventType {
  CONFERENCE,
  DAUROH,
  WORKSHOP,
  SEMINAR,
  WEBINAR,
  EXHIBITION,
  NETWORKING,
  FESTIVAL,
  MEETING,
  TRAINING;

  String get displayName {
    switch (this) {
      case EventType.CONFERENCE:
        return 'Conference';
      case EventType.DAUROH:
        return 'Dauroh';
      case EventType.WORKSHOP:
        return 'Workshop';
      case EventType.SEMINAR:
        return 'Seminar';
      case EventType.WEBINAR:
        return 'Webinar';
      case EventType.EXHIBITION:
        return 'Exhibition';
      case EventType.NETWORKING:
        return 'Networking Event';
      case EventType.FESTIVAL:
        return 'Festival';
      case EventType.MEETING:
        return 'Meeting';
      case EventType.TRAINING:
        return 'Training';
    }
  }
}

enum ImageType { Thumbnail, Banner, Icon, Gallery }

// MOCK DATA
// lib/data/mock_data.dart
final mockEvents = [
  Event(
    id: 1,
    name: 'Flutter Developer Conference 2025',
    description:
        'Join us for the biggest Flutter event of the year. Learn from experts and network with fellow developers.',
    startDate: DateTime(2025, 5, 15, 9, 0),
    endDate: DateTime(2025, 5, 17, 18, 0),
    eventLevel: EventLevel.World,
    status: EventStatus.PUBLISHED,
    type: EventType.CONFERENCE,
    category: EventCategory(id: 1, name: 'Development'),
    location: Location(
      id: 1,
      name: 'Tech Convention Center',
      description: 'Modern convention center in the heart of the city',
    ),
    content: [
      Content(
        id: 1,
        content: '''
# Flutter Developer Conference 2025

Join the global Flutter community for three days of learning, sharing, and networking. 

This year's conference will feature:
- Keynote presentations from Google's Flutter team
- Hands-on workshops for all skill levels
- Networking opportunities with industry leaders
- Exclusive previews of upcoming Flutter features
''',
        createdAt: DateTime(2025, 1, 10),
      ),
    ],
    gallery: Gallery(
      id: 1,
      name: 'Event Gallery',
      description: 'Photos from previous events',
      images: [
        Image(
          id: 1,
          title: 'Conference Hall',
          description: 'Main conference hall setup',
          taken: DateTime(2024, 5, 15),
          uploaded: DateTime(2024, 5, 16),
          path: '/images/conf_hall.jpg',
          ownerId: 1.0,
          referenceId: 1.0,
          urlThumbnail: 'https://example.com/thumb/conf_hall.jpg',
          urlMedium: 'https://example.com/medium/conf_hall.jpg',
          urlHD: 'https://example.com/hd/conf_hall.jpg',
          type: ImageType.Gallery,
        ),
      ],
    ),
    venue: Venue(
      id: 1,
      name: 'Tech Convention Center',
      capacity: 2000,
      contactPerson: 'John Smith',
      contactNumber: '+1-555-123-4567',
      location: Location(
        id: 1,
        name: 'Downtown District',
        description: 'Central business district with excellent transport links',
      ),
    ),
  ),
  Event(
    id: 2,
    name: 'Mobile App Design Workshop',
    description:
        'Intensive workshop on creating beautiful and functional mobile app designs.',
    startDate: DateTime(2025, 6, 10, 10, 0),
    endDate: DateTime(2025, 6, 10, 16, 0),
    eventLevel: EventLevel.Regional,
    status: EventStatus.PUBLISHED,
    type: EventType.WORKSHOP,
    category: EventCategory(id: 2, name: 'Design'),
    location: Location(
      id: 2,
      name: 'Design Studio Complex',
      description: 'Creative space for designers',
    ),
    content: [
      Content(
        id: 2,
        content: '''
# Mobile App Design Workshop

A full-day workshop focused on mobile app design principles and practices.

What you'll learn:
- UI/UX fundamentals for mobile
- Design systems and component libraries
- Prototyping with industry-standard tools
- User testing methods
''',
        createdAt: DateTime(2025, 2, 5),
      ),
    ],
    venue: Venue(
      id: 2,
      name: 'Design Studio Complex',
      capacity: 50,
      contactPerson: 'Lisa Wong',
      contactNumber: '+1-555-987-6543',
      location: Location(
        id: 2,
        name: 'Arts District',
        description: 'Vibrant area with many creative studios and galleries',
      ),
    ),
  ),
  Event(
    id: 3,
    name: 'Cloud Security Webinar',
    description:
        'Learn about the latest security practices for cloud applications.',
    startDate: DateTime(2025, 4, 22, 14, 0),
    endDate: DateTime(2025, 4, 22, 16, 0),
    eventLevel: EventLevel.National,
    status: EventStatus.COMPLETED,
    type: EventType.WEBINAR,
    category: EventCategory(id: 3, name: 'Security'),
    location: Location(
      id: 3,
      name: 'Virtual',
      description: 'Online webinar accessible from anywhere',
    ),
    content: [
      Content(
        id: 3,
        content: '''
# Cloud Security Webinar

Join security experts as they discuss the most pressing cloud security challenges and solutions.

Topics:
- Zero trust architecture
- Container security
- Compliance in multi-cloud environments
- Identity and access management best practices
''',
        createdAt: DateTime(2025, 3, 1),
      ),
    ],
    gallery: null,
    venue: null,
  ),
  Event(
    id: 4,
    name: 'Tech Career Fair',
    description: 'Connect with top tech companies looking for talent.',
    startDate: DateTime(2025, 7, 5, 10, 0),
    endDate: DateTime(2025, 7, 6, 17, 0),
    eventLevel: EventLevel.Regional,
    status: EventStatus.DRAFT,
    type: EventType.NETWORKING,
    category: EventCategory(id: 4, name: 'Career'),
    location: Location(
      id: 4,
      name: 'University Campus',
      description: 'Main hall at the university',
    ),
    content: [
      Content(
        id: 4,
        content: '''
# Tech Career Fair

The biggest tech recruitment event of the year!

- Meet recruiters from over 50 tech companies
- On-site interviews for qualified candidates
- Resume review services
- Career development workshops
''',
        createdAt: DateTime(2025, 3, 10),
      ),
    ],
    venue: Venue(
      id: 3,
      name: 'University Grand Hall',
      capacity: 1000,
      contactPerson: 'Mark Johnson',
      contactNumber: '+1-555-234-5678',
      location: Location(
        id: 4,
        name: 'University District',
        description: 'Campus area with modern facilities',
      ),
    ),
  ),
  Event(
    id: 5,
    name: 'Digital Marketing Summit',
    description:
        'Explore the latest trends and strategies in digital marketing.',
    startDate: DateTime(2025, 8, 12, 9, 0),
    endDate: DateTime(2025, 8, 14, 17, 0),
    eventLevel: EventLevel.National,
    status: EventStatus.POSTPONED,
    type: EventType.CONFERENCE,
    category: EventCategory(id: 5, name: 'Marketing'),
    location: Location(
      id: 5,
      name: 'Grand Hotel',
      description: 'Luxury hotel with conference facilities',
    ),
    content: [
      Content(
        id: 5,
        content: '''
# Digital Marketing Summit

Three days of insights, strategies, and networking for digital marketing professionals.

Highlights:
- Keynote from leading industry influencers
- Case studies from successful campaigns
- Workshops on emerging platforms
- Networking reception and gala dinner
''',
        createdAt: DateTime(2025, 4, 1),
      ),
    ],
    venue: Venue(
      id: 4,
      name: 'Grand Hotel Conference Center',
      capacity: 500,
      contactPerson: 'Sarah Brown',
      contactNumber: '+1-555-876-5432',
      location: Location(
        id: 5,
        name: 'Downtown',
        description: 'Central business district',
      ),
    ),
  ),
];

// RIVERPOD PROVIDERS
// lib/providers/event_providers.dart
final eventListProvider = Provider<List<Event>>((ref) {
  return mockEvents;
});

final eventFilterProvider = StateProvider<EventFilter>((ref) {
  return EventFilter();
});

final filteredEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(eventListProvider);
  final filter = ref.watch(eventFilterProvider);

  return events.where((event) {
    // Apply status filter
    if (filter.statusFilter != null && event.status != filter.statusFilter) {
      return false;
    }

    // Apply type filter
    if (filter.typeFilter != null && event.type != filter.typeFilter) {
      return false;
    }

    // Apply level filter
    if (filter.levelFilter != null && event.eventLevel != filter.levelFilter) {
      return false;
    }

    // Apply search query
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      if (!event.name.toLowerCase().contains(query) &&
          !event.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    return true;
  }).toList();
});

final selectedEventProvider = StateProvider<Event?>((ref) {
  return null;
});

class EventFilter {
  final EventStatus? statusFilter;
  final EventType? typeFilter;
  final EventLevel? levelFilter;
  final String searchQuery;

  EventFilter({
    this.statusFilter,
    this.typeFilter,
    this.levelFilter,
    this.searchQuery = '',
  });

  EventFilter copyWith({
    EventStatus? statusFilter,
    EventType? typeFilter,
    EventLevel? levelFilter,
    String? searchQuery,
  }) {
    return EventFilter(
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      levelFilter: levelFilter ?? this.levelFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// SCREENS
// lib/screens/event_list_screen.dart
class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});

  @override
  ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  final searchController = TextEditingController();
  bool isFilterExpanded = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(filteredEventsProvider);
    final filter = ref.watch(eventFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Events',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFilterExpanded
                        ? Icons.filter_list_off
                        : Icons.filter_list,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      isFilterExpanded = !isFilterExpanded;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    // Calendar view toggle
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      ref.read(eventFilterProvider.notifier).state = filter
                          .copyWith(searchQuery: value);
                    },
                  ),
                ),
              ),
            ),
            if (isFilterExpanded)
              SliverToBoxAdapter(child: _buildFilterSection(filter)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '${events.length} Events Found',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final event = events[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EventCard(event: event),
                  );
                }, childCount: events.length),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new event
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(EventFilter filter) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Events',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown<EventStatus>(
                  'Status',
                  EventStatus.values,
                  filter.statusFilter,
                  (val) => filter.copyWith(statusFilter: val),
                  (status) => status.displayName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown<EventType>(
                  'Type',
                  EventType.values,
                  filter.typeFilter,
                  (val) => filter.copyWith(typeFilter: val),
                  (type) => type.displayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown<EventLevel>(
                  'Level',
                  EventLevel.values,
                  filter.levelFilter,
                  (val) => filter.copyWith(levelFilter: val),
                  (level) => level.toString().split('.').last,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  onPressed: () {
                    ref.read(eventFilterProvider.notifier).state = EventFilter(
                      searchQuery: filter.searchQuery,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
    String label,
    List<T> items,
    T? selectedValue,
    EventFilter Function(T?) onChanged,
    String Function(T) getDisplayName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: selectedValue,
              hint: Text('All $label'),
              items: [
                DropdownMenuItem<T>(value: null, child: Text('All $label')),
                ...items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(getDisplayName(item)),
                      ),
                    )
                    .toList(),
              ],
              onChanged: (value) {
                ref.read(eventFilterProvider.notifier).state = onChanged(value);
              },
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// lib/widgets/event_card.dart
class EventCard extends ConsumerWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Format dates
    final DateFormat dateFormat = DateFormat('MMM d, yyyy');
    final DateFormat timeFormat = DateFormat('h:mm a');
    final String formattedStartDate = dateFormat.format(event.startDate);
    final String formattedStartTime = timeFormat.format(event.startDate);

    // Handle multi-day events
    String dateTimeText;
    if (event.endDate != null) {
      if (dateFormat.format(event.startDate) ==
          dateFormat.format(event.endDate!)) {
        // Same day event
        final String formattedEndTime = timeFormat.format(event.endDate!);
        dateTimeText =
            '$formattedStartDate, $formattedStartTime - $formattedEndTime';
      } else {
        // Multi-day event
        final String formattedEndDate = dateFormat.format(event.endDate!);
        dateTimeText = '$formattedStartDate - $formattedEndDate';
      }
    } else {
      // Single date event
      dateTimeText = '$formattedStartDate, $formattedStartTime';
    }

    return GestureDetector(
      onTap: () {
        ref.read(selectedEventProvider.notifier).state = event;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventDetailScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or colored banner
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getColorForEventType(event.type),
                    _getColorForEventType(event.type).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  if (event.gallery != null && event.gallery!.images.isNotEmpty)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: event.gallery!.images.first.urlMedium,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorForEventType(
                          event.type,
                        ).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        event.type.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: event.status.color.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        event.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            event.eventLevel.toString().split('.').last,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateTimeText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForEventType(EventType type) {
    switch (type) {
      case EventType.CONFERENCE:
        return Colors.indigo;
      case EventType.DAUROH:
        return Colors.teal;
      case EventType.WORKSHOP:
        return Colors.deepOrange;
      case EventType.SEMINAR:
        return Colors.purple;
      case EventType.WEBINAR:
        return Colors.blue;
      case EventType.EXHIBITION:
        return Colors.amber;
      case EventType.NETWORKING:
        return Colors.pink;
      case EventType.FESTIVAL:
        return Colors.green;
      case EventType.MEETING:
        return Colors.brown;
      case EventType.TRAINING:
        return Colors.red;
    }
  }
}

// lib/screens/event_detail_screen.dart
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(selectedEventProvider);

    if (event == null) {
      return const Scaffold(body: Center(child: Text('No event selected')));
    }

    // Format dates
    final DateFormat dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final DateFormat timeFormat = DateFormat('h:mm a');
    final String formattedStartDate = dateFormat.format(event.startDate);
    final String formattedStartTime = timeFormat.format(event.startDate);

    String dateTimeText;
    if (event.endDate != null) {
      if (dateFormat.format(event.startDate) ==
          dateFormat.format(event.endDate!)) {
        // Same day event
        final String formattedEndTime = timeFormat.format(event.endDate!);
        dateTimeText =
            '$formattedStartDate\n$formattedStartTime - $formattedEndTime';
      } else {
        // Multi-day event
        final String formattedEndDate = dateFormat.format(event.endDate!);
        final String formattedEndTime = timeFormat.format(event.endDate!);
        dateTimeText =
            '$formattedStartDate, $formattedStartTime -\n$formattedEndDate, $formattedEndTime';
      }
    } else {
      // Single date event
      dateTimeText = '$formattedStartDate\n$formattedStartTime';
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, event),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(
                          Icons.event,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        label: Text(event.type.displayName),
                        backgroundColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(
                          Icons.public,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        label: Text(
                          event.eventLevel.toString().split('.').last,
                        ),
                        backgroundColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: event.status.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: event.status.color,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          event.status.displayName,
                          style: TextStyle(
                            color: event.status.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    event.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(context, event, dateTimeText),
                  const SizedBox(height: 24),
                  if (event.venue != null)
                    _buildVenueSection(context, event.venue!),
                  const SizedBox(height: 24),
                  _buildContentSection(context, event),
                  const SizedBox(height: 24),
                  if (event.gallery != null)
                    _buildGallerySection(context, event.gallery!),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context, Event event) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (event.gallery != null && event.gallery!.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: event.gallery!.images.first.urlHD,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) =>
                        Container(color: _getColorForEventType(event.type)),
                errorWidget:
                    (context, url, error) => Container(
                      color: _getColorForEventType(event.type),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getColorForEventType(event.type),
                      _getColorForEventType(event.type).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.category.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Event Details',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () {
            // Share functionality
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border, color: Colors.white),
          ),
          onPressed: () {
            // Bookmark functionality
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    Event event,
    String dateTimeText,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Date & Time',
              dateTimeText,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.location_on,
              'Location',
              event.location.name,
              subtitle: event.location.description,
            ),
            if (event.venue != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                context,
                Icons.business,
                'Venue',
                event.venue!.name,
                subtitle: 'Capacity: ${event.venue!.capacity} people',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String content, {
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueSection(BuildContext context, Venue venue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Venue Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            venue.location.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildVenueInfoItem(
                        context,
                        Icons.people,
                        'Capacity',
                        '${venue.capacity} people',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildVenueInfoItem(
                        context,
                        Icons.person,
                        'Contact Person',
                        venue.contactPerson,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildVenueInfoItem(
                  context,
                  Icons.phone,
                  'Contact Number',
                  venue.contactNumber,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context, Event event) {
    if (event.content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Event',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Using a simplified markdown renderer
                Text(
                  event.content.first.content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGallerySection(BuildContext context, Gallery gallery) {
    if (gallery.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Gallery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show all images
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.images.length,
            itemBuilder: (context, index) {
              final image = gallery.images[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 160,
                    height: 180,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: image.urlMedium,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              image.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add to calendar
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // Register
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Register Now'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForEventType(EventType type) {
    switch (type) {
      case EventType.CONFERENCE:
        return Colors.indigo;
      case EventType.DAUROH:
        return Colors.teal;
      case EventType.WORKSHOP:
        return Colors.deepOrange;
      case EventType.SEMINAR:
        return Colors.purple;
      case EventType.WEBINAR:
        return Colors.blue;
      case EventType.EXHIBITION:
        return Colors.amber;
      case EventType.NETWORKING:
        return Colors.pink;
      case EventType.FESTIVAL:
        return Colors.green;
      case EventType.MEETING:
        return Colors.brown;
      case EventType.TRAINING:
        return Colors.red;
    }
  }
}

// Add this to your pubspec.yaml
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  google_fonts: ^5.1.0
  intl: ^0.18.1
  flutter_svg: ^2.0.7
  cached_network_image: ^3.2.3
  markdown_widget: ^2.3.0
*/
