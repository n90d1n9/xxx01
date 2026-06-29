import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Models
class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final EventType type;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.type,
  });
}

enum EventType { appointment, note, reminder, task }

// Providers
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final eventsProvider =
    StateNotifierProvider<EventsNotifier, List<CalendarEvent>>(
      (ref) => EventsNotifier(),
    );

class EventsNotifier extends StateNotifier<List<CalendarEvent>> {
  EventsNotifier() : super([]);

  void addEvent(CalendarEvent event) {
    state = [...state, event];
  }

  void updateEvent(CalendarEvent updatedEvent) {
    state = [
      for (final event in state)
        if (event.id == updatedEvent.id) updatedEvent else event,
    ];
  }

  void deleteEvent(String eventId) {
    state = state.where((event) => event.id != eventId).toList();
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return state
        .where(
          (event) =>
              event.startTime.year == day.year &&
              event.startTime.month == day.month &&
              event.startTime.day == day.day,
        )
        .toList();
  }
}

// Main Screen
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final events = ref.watch(eventsProvider);
    final eventsForSelectedDay = ref
        .read(eventsProvider.notifier)
        .getEventsForDay(selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCalendarTab(selectedDate, eventsForSelectedDay),
                  _buildAgendaTab(events),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventBottomSheet(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Calendar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {},
              ),
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://api.placeholder/32/32'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[700],
        tabs: const [
          Tab(text: 'Calendar'),
          Tab(text: 'Agenda'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(
    DateTime selectedDate,
    List<CalendarEvent> eventsForSelectedDay,
  ) {
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.all(20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                return ref.read(eventsProvider.notifier).getEventsForDay(day);
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                ref.read(selectedDateProvider.notifier).state = selectedDay;
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 3,
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (eventsForSelectedDay.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No events for today',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final event in eventsForSelectedDay)
                  _buildEventCard(event),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final IconData iconData;
    switch (event.type) {
      case EventType.appointment:
        iconData = Icons.calendar_today;
        break;
      case EventType.note:
        iconData = Icons.note;
        break;
      case EventType.reminder:
        iconData = Icons.alarm;
        break;
      case EventType.task:
        iconData = Icons.check_circle_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: event.color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: event.color.withValues(alpha: 0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: event.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: event.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[700]),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditEventBottomSheet(context, event);
                } else if (value == 'delete') {
                  ref.read(eventsProvider.notifier).deleteEvent(event.id);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaTab(List<CalendarEvent> events) {
    final Map<String, List<CalendarEvent>> groupedEvents = {};

    for (var event in events) {
      final dateStr = DateFormat('yyyy-MM-dd').format(event.startTime);
      if (!groupedEvents.containsKey(dateStr)) {
        groupedEvents[dateStr] = [];
      }
      groupedEvents[dateStr]!.add(event);
    }

    final sortedDates = groupedEvents.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateStr = sortedDates[index];
        final date = DateTime.parse(dateStr);
        final dayEvents = groupedEvents[dateStr]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                DateFormat('EEEE, MMMM d').format(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            for (final event in dayEvents) _buildEventCard(event),
          ],
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Column(
            children: [
              _buildSettingsItem(
                'Account',
                Icons.person_outline,
                Colors.blue,
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                'Calendar Display',
                Icons.calendar_view_month_outlined,
                Colors.orange,
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                'Notifications',
                Icons.notifications_none_outlined,
                Colors.purple,
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                'Event Categories',
                Icons.label_outline,
                Colors.green,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Column(
            children: [
              _buildSettingsItem('Sync', Icons.sync, Colors.teal, onTap: () {}),
              const Divider(height: 1),
              _buildSettingsItem(
                'Backup',
                Icons.backup_outlined,
                Colors.indigo,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Column(
            children: [
              _buildSettingsItem(
                'Help & Support',
                Icons.help_outline,
                Colors.amber,
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                'About',
                Icons.info_outline,
                Colors.red,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _showAddEventBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final startDate = ref.read(selectedDateProvider);
    final endDate = startDate.add(const Duration(hours: 1));

    final startTimeController = TextEditingController(
      text: DateFormat('h:mm a').format(startDate),
    );
    final endTimeController = TextEditingController(
      text: DateFormat('h:mm a').format(endDate),
    );

    EventType selectedType = EventType.appointment;
    Color selectedColor = Colors.blue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add New Event',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleController,
                      decoration: _inputDecoration('Title', Icons.title),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: _inputDecoration(
                        'Description',
                        Icons.description,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: startTimeController,
                            decoration: _inputDecoration(
                              'Start Time',
                              Icons.access_time,
                            ),
                            readOnly: true,
                            onTap: () async {
                              // Time picker would go here
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: endTimeController,
                            decoration: _inputDecoration(
                              'End Time',
                              Icons.access_time,
                            ),
                            readOnly: true,
                            onTap: () async {
                              // Time picker would go here
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Event Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          EventType.values.map((type) {
                            final isSelected = type == selectedType;

                            String label;
                            switch (type) {
                              case EventType.appointment:
                                label = 'Appointment';
                                break;
                              case EventType.note:
                                label = 'Note';
                                break;
                              case EventType.reminder:
                                label = 'Reminder';
                                break;
                              case EventType.task:
                                label = 'Task';
                                break;
                            }

                            return ChoiceChip(
                              label: Text(label),
                              selected: isSelected,
                              selectedColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[700],
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedType = type;
                                  });
                                }
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Color',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            Colors.blue,
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.teal,
                          ].map((color) {
                            final isSelected = color == selectedColor;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: Colors.black,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                        : null,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final newEvent = CalendarEvent(
                            id: now.millisecondsSinceEpoch.toString(),
                            title:
                                titleController.text.isNotEmpty
                                    ? titleController.text
                                    : 'Untitled Event',
                            description:
                                descriptionController.text.isNotEmpty
                                    ? descriptionController.text
                                    : 'No description',
                            startTime: startDate,
                            endTime: endDate,
                            color: selectedColor,
                            type: selectedType,
                          );
                          ref.read(eventsProvider.notifier).addEvent(newEvent);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditEventBottomSheet(BuildContext context, CalendarEvent event) {
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(
      text: event.description,
    );

    final startTimeController = TextEditingController(
      text: DateFormat('h:mm a').format(event.startTime),
    );
    final endTimeController = TextEditingController(
      text: DateFormat('h:mm a').format(event.endTime),
    );

    var selectedType = event.type;
    var selectedColor = event.color;

    // Similar implementation as _showAddEventBottomSheet but for editing
    // You would update the event instead of adding a new one
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}

// Main app entry point
class CalendarApp extends StatelessWidget {
  const CalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Calendar App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[50],
            elevation: 0,
          ),
          fontFamily: 'Poppins',
        ),
        home: const CalendarScreen(),
      ),
    );
  }
}

void main() {
  runApp(const CalendarApp());
}
