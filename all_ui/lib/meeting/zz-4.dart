// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// uuid: ^4.2.1
// intl: ^0.18.1
// shared_preferences: ^2.2.2
// file_picker: ^6.1.1

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== MODELS ====================

enum MeetingPriority { low, medium, high, urgent }

enum MeetingStatus { scheduled, inProgress, completed, cancelled }

enum MeetingType { standup, planning, review, retrospective, oneOnOne, other }

class Attendee {
  final String id;
  final String name;
  final String email;
  final bool isOrganizer;
  final bool isOptional;
  final AttendeeStatus status;

  Attendee({
    required this.id,
    required this.name,
    required this.email,
    this.isOrganizer = false,
    this.isOptional = false,
    this.status = AttendeeStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isOrganizer': isOrganizer,
    'isOptional': isOptional,
    'status': status.name,
  };

  factory Attendee.fromJson(Map<String, dynamic> json) => Attendee(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    isOrganizer: json['isOrganizer'] ?? false,
    isOptional: json['isOptional'] ?? false,
    status: AttendeeStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AttendeeStatus.pending,
    ),
  );

  Attendee copyWith({
    String? name,
    String? email,
    bool? isOrganizer,
    bool? isOptional,
    AttendeeStatus? status,
  }) {
    return Attendee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isOrganizer: isOrganizer ?? this.isOrganizer,
      isOptional: isOptional ?? this.isOptional,
      status: status ?? this.status,
    );
  }
}

enum AttendeeStatus { pending, accepted, declined, tentative }

class ActionItem {
  final String id;
  final String title;
  final String? assignedTo;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  ActionItem({
    required this.id,
    required this.title,
    this.assignedTo,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'assignedTo': assignedTo,
    'dueDate': dueDate?.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
    id: json['id'],
    title: json['title'],
    assignedTo: json['assignedTo'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    isCompleted: json['isCompleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );

  ActionItem copyWith({
    String? title,
    String? assignedTo,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return ActionItem(
      id: id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}

class MeetingNote {
  final String id;
  final String content;
  final DateTime timestamp;
  final String? author;

  MeetingNote({
    required this.id,
    required this.content,
    required this.timestamp,
    this.author,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'author': author,
  };

  factory MeetingNote.fromJson(Map<String, dynamic> json) => MeetingNote(
    id: json['id'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    author: json['author'],
  );
}

class Meeting {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final int durationMinutes;
  final List<Attendee> attendees;
  final List<MeetingNote> notes;
  final List<ActionItem> actionItems;
  final MeetingPriority priority;
  final MeetingStatus status;
  final MeetingType type;
  final String? location;
  final String? meetingLink;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? recurringPattern;

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.durationMinutes = 60,
    required this.attendees,
    required this.notes,
    required this.actionItems,
    required this.priority,
    required this.status,
    required this.type,
    this.location,
    this.meetingLink,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.recurringPattern,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'durationMinutes': durationMinutes,
    'attendees': attendees.map((a) => a.toJson()).toList(),
    'notes': notes.map((n) => n.toJson()).toList(),
    'actionItems': actionItems.map((a) => a.toJson()).toList(),
    'priority': priority.name,
    'status': status.name,
    'type': type.name,
    'location': location,
    'meetingLink': meetingLink,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'recurringPattern': recurringPattern,
  };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dateTime: DateTime.parse(json['dateTime']),
    durationMinutes: json['durationMinutes'] ?? 60,
    attendees:
        (json['attendees'] as List).map((a) => Attendee.fromJson(a)).toList(),
    notes: (json['notes'] as List).map((n) => MeetingNote.fromJson(n)).toList(),
    actionItems:
        (json['actionItems'] as List)
            .map((a) => ActionItem.fromJson(a))
            .toList(),
    priority: MeetingPriority.values.firstWhere(
      (e) => e.name == json['priority'],
    ),
    status: MeetingStatus.values.firstWhere((e) => e.name == json['status']),
    type: MeetingType.values.firstWhere((e) => e.name == json['type']),
    location: json['location'],
    meetingLink: json['meetingLink'],
    tags: List<String>.from(json['tags'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    recurringPattern: json['recurringPattern'],
  );

  Meeting copyWith({
    String? title,
    String? description,
    DateTime? dateTime,
    int? durationMinutes,
    List<Attendee>? attendees,
    List<MeetingNote>? notes,
    List<ActionItem>? actionItems,
    MeetingPriority? priority,
    MeetingStatus? status,
    MeetingType? type,
    String? location,
    String? meetingLink,
    List<String>? tags,
    DateTime? updatedAt,
    String? recurringPattern,
  }) {
    return Meeting(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      attendees: attendees ?? this.attendees,
      notes: notes ?? this.notes,
      actionItems: actionItems ?? this.actionItems,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      type: type ?? this.type,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));
}

// ==================== STATISTICS ====================

class MeetingStatistics {
  final int totalMeetings;
  final int upcomingMeetings;
  final int completedMeetings;
  final int totalActionItems;
  final int completedActionItems;
  final Map<MeetingType, int> meetingsByType;
  final Map<MeetingPriority, int> meetingsByPriority;

  MeetingStatistics({
    required this.totalMeetings,
    required this.upcomingMeetings,
    required this.completedMeetings,
    required this.totalActionItems,
    required this.completedActionItems,
    required this.meetingsByType,
    required this.meetingsByPriority,
  });
}

// ==================== PERSISTENCE ====================

class MeetingRepository {
  static const String _storageKey = 'meetings_data';

  Future<void> saveMeetings(List<Meeting> meetings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = meetings.map((m) => m.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonData));
  }

  Future<List<Meeting>> loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Meeting.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

// ==================== STATE MANAGEMENT ====================

final meetingRepositoryProvider = Provider((ref) => MeetingRepository());

class MeetingsNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  final MeetingRepository repository;

  MeetingsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadMeetings();
  }

  Future<void> loadMeetings() async {
    state = const AsyncValue.loading();
    try {
      final meetings = await repository.loadMeetings();
      state = AsyncValue.data(meetings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addMeeting(Meeting meeting) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, meeting];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> updateMeeting(Meeting updatedMeeting) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final meeting in currentState)
        if (meeting.id == updatedMeeting.id) updatedMeeting else meeting,
    ];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> deleteMeeting(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((m) => m.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }

  Future<void> updateMeetingStatus(String id, MeetingStatus status) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final meeting in currentState)
        if (meeting.id == id) meeting.copyWith(status: status) else meeting,
    ];
    state = AsyncValue.data(newState);
    await repository.saveMeetings(newState);
  }
}

final meetingsProvider =
    StateNotifierProvider<MeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => MeetingsNotifier(ref.watch(meetingRepositoryProvider)),
    );

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTagsProvider = StateProvider<Set<String>>((ref) => {});
final selectedStatusProvider = StateProvider<MeetingStatus?>((ref) => null);
final selectedTypeProvider = StateProvider<MeetingType?>((ref) => null);
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final filteredMeetingsProvider = Provider<List<Meeting>>((ref) {
  final meetingsAsync = ref.watch(meetingsProvider);
  final meetings = meetingsAsync.value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedTags = ref.watch(selectedTagsProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);
  final selectedType = ref.watch(selectedTypeProvider);
  final dateRange = ref.watch(dateRangeProvider);

  return meetings.where((meeting) {
    if (query.isNotEmpty) {
      final matchesQuery =
          meeting.title.toLowerCase().contains(query) ||
          meeting.description.toLowerCase().contains(query) ||
          meeting.attendees.any((a) => a.name.toLowerCase().contains(query));
      if (!matchesQuery) return false;
    }

    if (selectedTags.isNotEmpty) {
      final matchesTags = meeting.tags.any((tag) => selectedTags.contains(tag));
      if (!matchesTags) return false;
    }

    if (selectedStatus != null && meeting.status != selectedStatus) {
      return false;
    }

    if (selectedType != null && meeting.type != selectedType) {
      return false;
    }

    if (dateRange != null) {
      final isInRange =
          meeting.dateTime.isAfter(dateRange.start) &&
          meeting.dateTime.isBefore(dateRange.end.add(const Duration(days: 1)));
      if (!isInRange) return false;
    }

    return true;
  }).toList();
});

final allTagsProvider = Provider<Set<String>>((ref) {
  final meetingsAsync = ref.watch(meetingsProvider);
  final meetings = meetingsAsync.value ?? [];
  final tags = <String>{};
  for (final meeting in meetings) {
    tags.addAll(meeting.tags);
  }
  return tags;
});

final statisticsProvider = Provider<MeetingStatistics>((ref) {
  final meetingsAsync = ref.watch(meetingsProvider);
  final meetings = meetingsAsync.value ?? [];

  final now = DateTime.now();
  final upcoming =
      meetings
          .where(
            (m) =>
                m.dateTime.isAfter(now) && m.status == MeetingStatus.scheduled,
          )
          .length;
  final completed =
      meetings.where((m) => m.status == MeetingStatus.completed).length;

  final allActionItems = meetings.expand((m) => m.actionItems).toList();
  final completedActionItems =
      allActionItems.where((a) => a.isCompleted).length;

  final byType = <MeetingType, int>{};
  final byPriority = <MeetingPriority, int>{};

  for (final meeting in meetings) {
    byType[meeting.type] = (byType[meeting.type] ?? 0) + 1;
    byPriority[meeting.priority] = (byPriority[meeting.priority] ?? 0) + 1;
  }

  return MeetingStatistics(
    totalMeetings: meetings.length,
    upcomingMeetings: upcoming,
    completedMeetings: completed,
    totalActionItems: allActionItems.length,
    completedActionItems: completedActionItems,
    meetingsByType: byType,
    meetingsByPriority: byPriority,
  );
});

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: MeetingNotesApp()));
}

class MeetingNotesApp extends StatelessWidget {
  const MeetingNotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Notes Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade800),
          ),
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}

// ==================== MAIN NAVIGATION ====================

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          MeetingsHomePage(),
          ActionItemsPage(),
          StatisticsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected:
            (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Meetings',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Actions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}

// ==================== HOME PAGE ====================

class MeetingsHomePage extends ConsumerWidget {
  const MeetingsHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    final meetings = ref.watch(filteredMeetingsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Meeting Notes Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref),
          ),
        ],
      ),
      body: meetingsAsync.when(
        data: (allMeetings) {
          if (allMeetings.isEmpty) {
            return _buildEmptyState(context);
          }

          final now = DateTime.now();
          final upcoming =
              meetings
                  .where(
                    (m) =>
                        m.dateTime.isAfter(now) &&
                        m.status == MeetingStatus.scheduled,
                  )
                  .toList()
                ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          final today =
              meetings.where((m) {
                final isToday =
                    m.dateTime.year == now.year &&
                    m.dateTime.month == now.month &&
                    m.dateTime.day == now.day;
                return isToday && m.status != MeetingStatus.completed;
              }).toList();

          final past =
              meetings
                  .where(
                    (m) =>
                        m.dateTime.isBefore(now) ||
                        m.status == MeetingStatus.completed ||
                        m.status == MeetingStatus.cancelled,
                  )
                  .toList()
                ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(meetingsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (today.isNotEmpty) ...[
                  _buildSectionHeader('Today', today.length, Icons.today),
                  const SizedBox(height: 12),
                  ...today.map((m) => MeetingCard(meeting: m)),
                  const SizedBox(height: 24),
                ],
                if (upcoming.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Upcoming',
                    upcoming.length,
                    Icons.upcoming,
                  ),
                  const SizedBox(height: 12),
                  ...upcoming.take(5).map((m) => MeetingCard(meeting: m)),
                  const SizedBox(height: 24),
                ],
                if (past.isNotEmpty) ...[
                  _buildSectionHeader('Past', past.length, Icons.history),
                  const SizedBox(height: 12),
                  ...past.take(10).map((m) => MeetingCard(meeting: m)),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(meetingsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMeeting(context),
        icon: const Icon(Icons.add),
        label: const Text('New Meeting'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No meetings yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first meeting to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Meetings'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by title, description, or attendee',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterBottomSheet(),
    );
  }

  void _navigateToAddMeeting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditMeetingPage()),
    );
  }
}

// ==================== FILTER SHEET ====================

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(selectedStatusProvider);
    final selectedType = ref.watch(selectedTypeProvider);
    final selectedTags = ref.watch(selectedTagsProvider);
    final allTags = ref.watch(allTagsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  ref.read(selectedStatusProvider.notifier).state = null;
                  ref.read(selectedTypeProvider.notifier).state = null;
                  ref.read(selectedTagsProvider.notifier).state = {};
                  ref.read(dateRangeProvider.notifier).state = null;
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                MeetingStatus.values.map((status) {
                  final isSelected = selectedStatus == status;
                  return FilterChip(
                    label: Text(status.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedStatusProvider.notifier).state =
                          selected ? status : null;
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                MeetingType.values.map((type) {
                  final isSelected = selectedType == type;
                  return FilterChip(
                    label: Text(type.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedTypeProvider.notifier).state =
                          selected ? type : null;
                    },
                  );
                }).toList(),
          ),
          if (allTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  allTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newTags = {...selectedTags};
                        if (selected) {
                          newTags.add(tag);
                        } else {
                          newTags.remove(tag);
                        }
                        ref.read(selectedTagsProvider.notifier).state = newTags;
                      },
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== MEETING CARD ====================

class MeetingCard extends ConsumerWidget {
  final Meeting meeting;

  const MeetingCard({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildPriorityBadge(),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatusChip(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(meeting.dateTime),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${timeFormat.format(meeting.dateTime)} (${meeting.durationMinutes}m)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              if (meeting.location != null || meeting.meetingLink != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      meeting.location != null ? Icons.location_on : Icons.link,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meeting.location ?? meeting.meetingLink ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (meeting.attendees.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${meeting.attendees.length} attendees',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (meeting.actionItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meeting.actionItems.where((a) => a.isCompleted).length}/${meeting.actionItems.length} actions completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              if (meeting.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      meeting.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (meeting.type) {
      case MeetingType.standup:
        icon = Icons.groups;
        color = Colors.blue;
        break;
      case MeetingType.planning:
        icon = Icons.calendar_view_week;
        color = Colors.purple;
        break;
      case MeetingType.review:
        icon = Icons.rate_review;
        color = Colors.green;
        break;
      case MeetingType.retrospective:
        icon = Icons.replay;
        color = Colors.orange;
        break;
      case MeetingType.oneOnOne:
        icon = Icons.person;
        color = Colors.teal;
        break;
      case MeetingType.other:
        icon = Icons.event;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    String label;

    switch (meeting.priority) {
      case MeetingPriority.urgent:
        color = Colors.red.shade700;
        label = 'Urgent';
        break;
      case MeetingPriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case MeetingPriority.medium:
        color = Colors.orange;
        label = 'Med';
        break;
      case MeetingPriority.low:
        color = Colors.green;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;
    String label;

    switch (meeting.status) {
      case MeetingStatus.scheduled:
        color = Colors.blue;
        icon = Icons.schedule;
        label = 'Scheduled';
        break;
      case MeetingStatus.inProgress:
        color = Colors.orange;
        icon = Icons.play_circle;
        label = 'In Progress';
        break;
      case MeetingStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Completed';
        break;
      case MeetingStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeetingDetailsPage(meeting: meeting)),
    );
  }
}

// ==================== ACTION ITEMS PAGE ====================

class ActionItemsPage extends ConsumerWidget {
  const ActionItemsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Action Items',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: meetingsAsync.when(
        data: (meetings) {
          final allActionItems = <String, List<ActionItem>>{};

          for (final meeting in meetings) {
            for (final action in meeting.actionItems) {
              final key = meeting.id;
              if (!allActionItems.containsKey(key)) {
                allActionItems[key] = [];
              }
              allActionItems[key]!.add(action);
            }
          }

          if (allActionItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_box_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No action items yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          final pendingActions = <MapEntry<String, ActionItem>>[];
          final completedActions = <MapEntry<String, ActionItem>>[];

          allActionItems.forEach((meetingId, actions) {
            for (final action in actions) {
              final entry = MapEntry(meetingId, action);
              if (action.isCompleted) {
                completedActions.add(entry);
              } else {
                pendingActions.add(entry);
              }
            }
          });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingActions.isNotEmpty) ...[
                _buildSectionHeader('Pending', pendingActions.length),
                const SizedBox(height: 12),
                ...pendingActions.map((entry) {
                  final meeting = meetings.firstWhere((m) => m.id == entry.key);
                  return ActionItemCard(
                    actionItem: entry.value,
                    meeting: meeting,
                  );
                }),
                const SizedBox(height: 24),
              ],
              if (completedActions.isNotEmpty) ...[
                _buildSectionHeader('Completed', completedActions.length),
                const SizedBox(height: 12),
                ...completedActions.map((entry) {
                  final meeting = meetings.firstWhere((m) => m.id == entry.key);
                  return ActionItemCard(
                    actionItem: entry.value,
                    meeting: meeting,
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ACTION ITEM CARD ====================

class ActionItemCard extends ConsumerWidget {
  final ActionItem actionItem;
  final Meeting meeting;

  const ActionItemCard({
    Key? key,
    required this.actionItem,
    required this.meeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        actionItem.dueDate != null &&
        actionItem.dueDate!.isBefore(DateTime.now()) &&
        !actionItem.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: actionItem.isCompleted,
          onChanged: (value) {
            final updatedActions =
                meeting.actionItems.map((a) {
                  if (a.id == actionItem.id) {
                    return a.copyWith(isCompleted: value ?? false);
                  }
                  return a;
                }).toList();

            ref
                .read(meetingsProvider.notifier)
                .updateMeeting(meeting.copyWith(actionItems: updatedActions));
          },
        ),
        title: Text(
          actionItem.title,
          style: TextStyle(
            decoration:
                actionItem.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: ${meeting.title}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (actionItem.assignedTo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    actionItem.assignedTo!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
            if (actionItem.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: isOverdue ? Colors.red : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(actionItem.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey.shade600,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 4),
                    Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== STATISTICS PAGE ====================

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            'Total Meetings',
            stats.totalMeetings.toString(),
            Icons.event,
            theme.colorScheme.primary,
          ),
          _buildStatCard(
            'Upcoming',
            stats.upcomingMeetings.toString(),
            Icons.upcoming,
            Colors.blue,
          ),
          _buildStatCard(
            'Completed',
            stats.completedMeetings.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatCard(
            'Action Items',
            '${stats.completedActionItems}/${stats.totalActionItems}',
            Icons.check_box,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          const Text(
            'Meetings by Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...stats.meetingsByType.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(_getTypeIcon(entry.key)),
                title: Text(entry.key.name),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const Text(
            'Meetings by Priority',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...stats.meetingsByPriority.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.flag, color: _getPriorityColor(entry.key)),
                title: Text(entry.key.name),
                trailing: Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(MeetingType type) {
    switch (type) {
      case MeetingType.standup:
        return Icons.groups;
      case MeetingType.planning:
        return Icons.calendar_view_week;
      case MeetingType.review:
        return Icons.rate_review;
      case MeetingType.retrospective:
        return Icons.replay;
      case MeetingType.oneOnOne:
        return Icons.person;
      case MeetingType.other:
        return Icons.event;
    }
  }

  Color _getPriorityColor(MeetingPriority priority) {
    switch (priority) {
      case MeetingPriority.urgent:
        return Colors.red.shade700;
      case MeetingPriority.high:
        return Colors.red;
      case MeetingPriority.medium:
        return Colors.orange;
      case MeetingPriority.low:
        return Colors.green;
    }
  }
}

// ==================== ADD/EDIT MEETING PAGE ====================

class AddEditMeetingPage extends ConsumerStatefulWidget {
  final Meeting? meeting;

  const AddEditMeetingPage({Key? key, this.meeting}) : super(key: key);

  @override
  ConsumerState<AddEditMeetingPage> createState() => _AddEditMeetingPageState();
}

class _AddEditMeetingPageState extends ConsumerState<AddEditMeetingPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _meetingLinkController;
  late DateTime _selectedDateTime;
  late int _durationMinutes;
  late MeetingPriority _selectedPriority;
  late MeetingStatus _selectedStatus;
  late MeetingType _selectedType;
  final List<Attendee> _attendees = [];
  final List<MeetingNote> _notes = [];
  final List<ActionItem> _actionItems = [];
  final List<String> _tags = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final meeting = widget.meeting;
    _titleController = TextEditingController(text: meeting?.title ?? '');
    _descriptionController = TextEditingController(
      text: meeting?.description ?? '',
    );
    _locationController = TextEditingController(text: meeting?.location ?? '');
    _meetingLinkController = TextEditingController(
      text: meeting?.meetingLink ?? '',
    );
    _selectedDateTime = meeting?.dateTime ?? DateTime.now();
    _durationMinutes = meeting?.durationMinutes ?? 60;
    _selectedPriority = meeting?.priority ?? MeetingPriority.medium;
    _selectedStatus = meeting?.status ?? MeetingStatus.scheduled;
    _selectedType = meeting?.type ?? MeetingType.other;
    if (meeting != null) {
      _attendees.addAll(meeting.attendees);
      _notes.addAll(meeting.notes);
      _actionItems.addAll(meeting.actionItems);
      _tags.addAll(meeting.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting == null ? 'New Meeting' : 'Edit Meeting'),
        actions: [
          TextButton(
            onPressed: _saveMeeting,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MeetingType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Meeting Type',
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  MeetingType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(
                DateFormat('MMM dd, yyyy - h:mm a').format(_selectedDateTime),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _durationMinutes,
              decoration: const InputDecoration(
                labelText: 'Duration',
                prefixIcon: Icon(Icons.timer),
              ),
              items:
                  [15, 30, 45, 60, 90, 120, 180].map((minutes) {
                    return DropdownMenuItem(
                      value: minutes,
                      child: Text('$minutes minutes'),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _durationMinutes = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MeetingPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag),
              ),
              items:
                  MeetingPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name.toUpperCase()),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedPriority = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MeetingStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.info),
              ),
              items:
                  MeetingStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _meetingLinkController,
              decoration: const InputDecoration(
                labelText: 'Meeting Link (Zoom, Teams, etc.)',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),
            _buildListSection(
              'Tags',
              _tags,
              Icons.tag,
              'Add tag',
              simple: true,
            ),
            const SizedBox(height: 24),
            _buildAttendeesSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildActionItemsSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendees',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._attendees.map((attendee) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(attendee.name[0].toUpperCase()),
              ),
              title: Text(attendee.name),
              subtitle: Text(attendee.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => setState(() => _attendees.remove(attendee)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addAttendee,
          icon: const Icon(Icons.add),
          label: const Text('Add attendee'),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._notes.map((note) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.note, size: 20),
              title: Text(note.content),
              subtitle: Text(
                DateFormat('MMM dd, h:mm a').format(note.timestamp),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => setState(() => _notes.remove(note)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addNote,
          icon: const Icon(Icons.add),
          label: const Text('Add note'),
        ),
      ],
    );
  }

  Widget _buildActionItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Action Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._actionItems.map((action) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Checkbox(
                value: action.isCompleted,
                onChanged: (value) {
                  final index = _actionItems.indexOf(action);
                  setState(() {
                    _actionItems[index] = action.copyWith(
                      isCompleted: value ?? false,
                    );
                  });
                },
              ),
              title: Text(action.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (action.assignedTo != null)
                    Text(
                      'Assigned: ${action.assignedTo}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (action.dueDate != null)
                    Text(
                      'Due: ${DateFormat('MMM dd').format(action.dueDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => setState(() => _actionItems.remove(action)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addActionItem,
          icon: const Icon(Icons.add),
          label: const Text('Add action item'),
        ),
      ],
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon,
    String hint, {
    bool simple = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                items.map((item) {
                  return Chip(
                    label: Text(item),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(() => items.remove(item)),
                  );
                }).toList(),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _addSimpleItem(items, hint),
          icon: const Icon(Icons.add),
          label: Text(hint),
        ),
      ],
    );
  }

  void _addSimpleItem(List<String> list, String hint) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(hint),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: hint),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    setState(() => list.add(controller.text));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _addAttendee() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    bool isOrganizer = false;
    bool isOptional = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Attendee'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        title: const Text('Organizer'),
                        value: isOrganizer,
                        onChanged:
                            (value) =>
                                setState(() => isOrganizer = value ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        title: const Text('Optional'),
                        value: isOptional,
                        onChanged:
                            (value) =>
                                setState(() => isOptional = value ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            emailController.text.isNotEmpty) {
                          final attendee = Attendee(
                            id: const Uuid().v4(),
                            name: nameController.text,
                            email: emailController.text,
                            isOrganizer: isOrganizer,
                            isOptional: isOptional,
                          );
                          this.setState(() => _attendees.add(attendee));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _addNote() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Note'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter note'),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    final note = MeetingNote(
                      id: const Uuid().v4(),
                      content: controller.text,
                      timestamp: DateTime.now(),
                    );
                    setState(() => _notes.add(note));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _addActionItem() {
    final titleController = TextEditingController();
    final assignedToController = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Action Item'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: assignedToController,
                        decoration: const InputDecoration(
                          labelText: 'Assigned To',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text(
                          dueDate == null
                              ? 'No due date'
                              : DateFormat('MMM dd, yyyy').format(dueDate!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => dueDate = date);
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final action = ActionItem(
                            id: const Uuid().v4(),
                            title: titleController.text,
                            assignedTo:
                                assignedToController.text.isEmpty
                                    ? null
                                    : assignedToController.text,
                            dueDate: dueDate,
                            createdAt: DateTime.now(),
                          );
                          this.setState(() => _actionItems.add(action));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveMeeting() {
    if (!_formKey.currentState!.validate()) return;

    final meeting = Meeting(
      id: widget.meeting?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      dateTime: _selectedDateTime,
      durationMinutes: _durationMinutes,
      attendees: _attendees,
      notes: _notes,
      actionItems: _actionItems,
      priority: _selectedPriority,
      status: _selectedStatus,
      type: _selectedType,
      location:
          _locationController.text.isEmpty ? null : _locationController.text,
      meetingLink:
          _meetingLinkController.text.isEmpty
              ? null
              : _meetingLinkController.text,
      tags: _tags,
      createdAt: widget.meeting?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.meeting == null) {
      ref.read(meetingsProvider.notifier).addMeeting(meeting);
    } else {
      ref.read(meetingsProvider.notifier).updateMeeting(meeting);
    }

    Navigator.pop(context);
  }
}

// ==================== MEETING DETAILS PAGE ====================

class MeetingDetailsPage extends ConsumerWidget {
  final Meeting meeting;

  const MeetingDetailsPage({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        actions: [
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
            onSelected:
                (value) => _handleMenuAction(context, ref, value.toString()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            meeting.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoChip(meeting.type.name, Icons.category, Colors.blue),
          const SizedBox(height: 8),
          _buildInfoChip(meeting.status.name, Icons.info, _getStatusColor()),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.calendar_today,
            DateFormat('EEEE, MMM dd, yyyy').format(meeting.dateTime),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            '${DateFormat('h:mm a').format(meeting.dateTime)} - ${DateFormat('h:mm a').format(meeting.endTime)} (${meeting.durationMinutes}m)',
          ),
          if (meeting.location != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, meeting.location!),
          ],
          if (meeting.meetingLink != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.link, meeting.meetingLink!),
          ],
          const SizedBox(height: 24),
          if (meeting.description.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(meeting.description),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (meeting.attendees.isNotEmpty) ...[
            _buildSectionTitle('Attendees (${meeting.attendees.length})'),
            ...meeting.attendees.map((a) => _buildAttendeeCard(a)),
            const SizedBox(height: 24),
          ],
          if (meeting.notes.isNotEmpty) ...[
            _buildSectionTitle('Notes (${meeting.notes.length})'),
            ...meeting.notes.map((n) => _buildNoteCard(n)),
            const SizedBox(height: 24),
          ],
          if (meeting.actionItems.isNotEmpty) ...[
            _buildSectionTitle('Action Items (${meeting.actionItems.length})'),
            ...meeting.actionItems.map(
              (a) => _buildActionCard(context, ref, a),
            ),
            const SizedBox(height: 24),
          ],
          if (meeting.tags.isNotEmpty) ...[
            _buildSectionTitle('Tags'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  meeting.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
      floatingActionButton:
          meeting.status == MeetingStatus.scheduled
              ? FloatingActionButton.extended(
                onPressed: () {
                  ref
                      .read(meetingsProvider.notifier)
                      .updateMeeting(
                        meeting.copyWith(status: MeetingStatus.inProgress),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting started')),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Meeting'),
              )
              : meeting.status == MeetingStatus.inProgress
              ? FloatingActionButton.extended(
                onPressed: () {
                  ref
                      .read(meetingsProvider.notifier)
                      .updateMeeting(
                        meeting.copyWith(status: MeetingStatus.completed),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting completed')),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete'),
                backgroundColor: Colors.green,
              )
              : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeCard(Attendee attendee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(attendee.name[0].toUpperCase())),
        title: Row(
          children: [
            Text(attendee.name),
            if (attendee.isOrganizer) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Organizer',
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                ),
              ),
            ],
            if (attendee.isOptional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(attendee.email),
        trailing: _buildAttendeeStatusIcon(attendee.status),
      ),
    );
  }

  Widget _buildAttendeeStatusIcon(AttendeeStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case AttendeeStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AttendeeStatus.declined:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case AttendeeStatus.tentative:
        icon = Icons.help;
        color = Colors.orange;
        break;
      case AttendeeStatus.pending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildNoteCard(MeetingNote note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.note, size: 20),
        title: Text(note.content),
        subtitle: Text(
          DateFormat('MMM dd, h:mm a').format(note.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    WidgetRef ref,
    ActionItem action,
  ) {
    final isOverdue =
        action.dueDate != null &&
        action.dueDate!.isBefore(DateTime.now()) &&
        !action.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: action.isCompleted,
          onChanged: (value) {
            final updatedActions =
                meeting.actionItems.map((a) {
                  if (a.id == action.id) {
                    return a.copyWith(isCompleted: value ?? false);
                  }
                  return a;
                }).toList();

            ref
                .read(meetingsProvider.notifier)
                .updateMeeting(meeting.copyWith(actionItems: updatedActions));
          },
        ),
        title: Text(
          action.title,
          style: TextStyle(
            decoration: action.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (action.assignedTo != null) ...[
              const SizedBox(height: 4),
              Text(
                'Assigned: ${action.assignedTo}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (action.dueDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(action.dueDate!)}${isOverdue ? ' - OVERDUE' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.red : null,
                  fontWeight: isOverdue ? FontWeight.bold : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (meeting.status) {
      case MeetingStatus.scheduled:
        return Colors.blue;
      case MeetingStatus.inProgress:
        return Colors.orange;
      case MeetingStatus.completed:
        return Colors.green;
      case MeetingStatus.cancelled:
        return Colors.red;
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditMeetingPage(meeting: meeting),
          ),
        );
        break;
      case 'duplicate':
        final duplicated = Meeting(
          id: const Uuid().v4(),
          title: '${meeting.title} (Copy)',
          description: meeting.description,
          dateTime: meeting.dateTime.add(const Duration(days: 7)),
          durationMinutes: meeting.durationMinutes,
          attendees: meeting.attendees,
          notes: [],
          actionItems: [],
          priority: meeting.priority,
          status: MeetingStatus.scheduled,
          type: meeting.type,
          location: meeting.location,
          meetingLink: meeting.meetingLink,
          tags: meeting.tags,
          createdAt: DateTime.now(),
        );
        ref.read(meetingsProvider.notifier).addMeeting(duplicated);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Meeting duplicated')));
        break;
      case 'share':
        _showShareDialog(context);
        break;
      case 'delete':
        _deleteMeeting(context, ref);
        break;
    }
  }

  void _showShareDialog(BuildContext context) {
    final summary = _generateMeetingSummary();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Share Meeting'),
            content: SingleChildScrollView(child: Text(summary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Here you would implement actual sharing functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting summary copied')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  String _generateMeetingSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Meeting: ${meeting.title}');
    buffer.writeln(
      'Date: ${DateFormat('MMM dd, yyyy - h:mm a').format(meeting.dateTime)}',
    );
    buffer.writeln('Duration: ${meeting.durationMinutes} minutes');

    if (meeting.location != null) {
      buffer.writeln('Location: ${meeting.location}');
    }

    if (meeting.meetingLink != null) {
      buffer.writeln('Link: ${meeting.meetingLink}');
    }

    buffer.writeln('\nDescription:');
    buffer.writeln(meeting.description);

    if (meeting.attendees.isNotEmpty) {
      buffer.writeln('\nAttendees:');
      for (final attendee in meeting.attendees) {
        buffer.writeln('- ${attendee.name} (${attendee.email})');
      }
    }

    if (meeting.notes.isNotEmpty) {
      buffer.writeln('\nNotes:');
      for (final note in meeting.notes) {
        buffer.writeln('- ${note.content}');
      }
    }

    if (meeting.actionItems.isNotEmpty) {
      buffer.writeln('\nAction Items:');
      for (final action in meeting.actionItems) {
        final status = action.isCompleted ? '✓' : '○';
        buffer.write('$status ${action.title}');
        if (action.assignedTo != null) {
          buffer.write(' (${action.assignedTo})');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  void _deleteMeeting(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Meeting'),
            content: const Text(
              'Are you sure you want to delete this meeting? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(meetingsProvider.notifier).deleteMeeting(meeting.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meeting deleted')),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
