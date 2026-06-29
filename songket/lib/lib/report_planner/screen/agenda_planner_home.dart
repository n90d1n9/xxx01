import 'package:device_calendar/device_calendar.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../dummy.dart';
import '../model/agenda_item.dart';
import '../model/category.dart';
import '../model/event_template.dart';
import '../model/priority.dart';
import '../model/reminder_settings.dart';
//import '../service/connectivity_service.dart';
import '../service/export_import_service.dart';
import '../service/local_notification.dart';
import '../state/agenda_items_provider.dart';
import '../state/agenda_provider.dart';
import '../state/ai_provider.dart';
import '../state/calendar_integration_provider.dart';
import '../state/statistic_provider.dart';
import '../state/storage_service_provider.dart';
import '../state/voice_input_provider.dart';
import '../utils/smart_event_parser.dart';
import '../widget/add_event_sheet.dart';
import '../widget/agenda_list_view.dart';
import '../widget/day_view.dart';
import '../widget/filter_sheet.dart';
import '../widget/month_view.dart';
import '../widget/search_sheet.dart';
import '../widget/timeline_view.dart';
import '../widget/week_view.dart';
import 'analytic_screen.dart';

class AgendaPlannerHome extends ConsumerWidget {
  const AgendaPlannerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    /*  final authState = ref.watch(authStateProvider);
    final isOnline = ref.watch(isOnlineProvider);
 */
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                // Online/Offline indicator
                /*  isOnline.when(
                  data: (online) => Icon(
                    online ? Icons.cloud_done : Icons.cloud_off,
                    size: 20,
                    color: online ? Colors.green : Colors.grey,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ), */
              ],
            ),
            Text(
              DateFormat('EEEE, d').format(selectedDate),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'theme') {
                _showThemeSelector(context, ref);
              } else if (value == 'export') {
                _showExportOptions(context, ref);
              } else if (value == 'import') {
                _showImportOptions(context, ref);
              } else if (value == 'analytics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              } else if (value == 'calendar_sync') {
                _showCalendarSync(context, ref);
              } else if (value == 'cloud_sync') {
                _showCloudSync(context, ref);
              } else if (value == 'account') {
                _showAccountSettings(context, ref);
              } else if (value == 'ai_insights') {
                _showAIInsights(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined),
                    SizedBox(width: 8),
                    Text('Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'ai_insights',
                child: Row(
                  children: [
                    Icon(Icons.psychology),
                    SizedBox(width: 8),
                    Text('AI Insights'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cloud_sync',
                child: Row(
                  children: [
                    Icon(Icons.cloud_sync),
                    SizedBox(width: 8),
                    Text('Cloud Sync'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'calendar_sync',
                child: Row(
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Calendar Sync'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'account',
                child: Row(
                  children: [
                    Icon(Icons.account_circle),
                    SizedBox(width: 8),
                    Text('Account'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.palette_outlined),
                    SizedBox(width: 8),
                    Text('Theme'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload_outlined),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download_outlined),
                    SizedBox(width: 8),
                    Text('Import Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatisticsBar(context, ref),
          _buildViewModeSelector(context, ref, viewMode),
          Expanded(child: _buildViewContent(context, ref, viewMode)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice_add',
            onPressed: () => _showVoiceInput(context, ref),
            mini: true,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.mic),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'quick_add',
            onPressed: () => _showQuickAddMenu(context, ref),
            mini: true,
            child: const Icon(Icons.bolt),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'add_event',
            onPressed: () => _showAddEventDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsBar(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.event_note,
            '${stats['totalToday']}',
            'Total',
          ),
          _buildStatItem(
            context,
            Icons.check_circle_outline,
            '${stats['completedToday']}',
            'Done',
          ),
          _buildStatItem(
            context,
            Icons.schedule,
            '${stats['upcomingToday']}',
            'Upcoming',
          ),
          _buildStatItem(
            context,
            Icons.trending_up,
            '${stats['completionRate'].toStringAsFixed(0)}%',
            'Rate',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildViewModeSelector(
    BuildContext context,
    WidgetRef ref,
    ViewMode viewMode,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ViewMode.values.map((mode) {
          final isSelected = mode == viewMode;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getViewModeLabel(mode)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) ref.read(viewModeProvider.notifier).state = mode;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getViewModeLabel(ViewMode mode) {
    switch (mode) {
      case ViewMode.day:
        return 'Day';
      case ViewMode.week:
        return 'Week';
      case ViewMode.month:
        return 'Month';
      case ViewMode.agenda:
        return 'List';
      case ViewMode.timeline:
        return 'Timeline';
    }
  }

  Widget _buildViewContent(
    BuildContext context,
    WidgetRef ref,
    ViewMode viewMode,
  ) {
    switch (viewMode) {
      case ViewMode.day:
        return const DayView();
      case ViewMode.week:
        return const WeekView();
      case ViewMode.month:
        return const MonthView();
      case ViewMode.agenda:
        return const AgendaListView();
      case ViewMode.timeline:
        return const TimelineView();
    }
  }

  void _showSearchSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchSheet(),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEventSheet(),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).state = value;
                  ref.read(storageServiceProvider).saveTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).state = value;
                  ref.read(storageServiceProvider).saveTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: ref.read(themeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).state = value;
                  ref.read(storageServiceProvider).saveTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) async {
    // final items = ref.read(agendaItemsProvider).valueOrNull ?? [];
    final items = ref.read(agendaItemsProvider).value ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Export Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Export as JSON'),
                subtitle: const Text('Full backup with all data'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ExportImportService.exportToJson(items);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exported successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export as CSV'),
                subtitle: const Text('Spreadsheet format'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ExportImportService.exportToCsv(items);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('CSV exported successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                subtitle: const Text('Printable document'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ExportImportService.exportToPdf(items);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF exported successfully!'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export failed: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIInsights(BuildContext context, WidgetRef ref) {
    final items = ref.read(agendaItemsProvider).value ?? [];
    final aiService = ref.read(aiSchedulingServiceProvider);

    final patterns = aiService.analyzeSchedulePatterns(items);
    final suggestions = aiService.generateSmartSuggestions(items);
    final conflicts = aiService.detectConflicts(items);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Insights',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Schedule Patterns
                  _buildInsightCard(
                    context,
                    'Schedule Patterns',
                    Icons.pattern,
                    Colors.blue,
                    [
                      'Best time: ${patterns['productiveTimeRange']}',
                      'Average event: ${patterns['avgEventDuration']} minutes',
                      'Busiest day: ${patterns['busiestDay']}',
                      'Top category: ${patterns['topCategory']}',
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Smart Suggestions
                  if (suggestions.isNotEmpty) ...[
                    _buildInsightCard(
                      context,
                      'Smart Suggestions',
                      Icons.lightbulb,
                      Colors.orange,
                      suggestions,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Conflicts
                  if (conflicts.isNotEmpty) ...[
                    _buildInsightCard(
                      context,
                      'Schedule Conflicts',
                      Icons.warning,
                      Colors.red,
                      conflicts.take(3).map((c) {
                        final e1 = c['event1'] as AgendaItem;
                        final e2 = c['event2'] as AgendaItem;
                        return '⚠️ "${e1.title}" overlaps with "${e2.title}" on ${DateFormat('MMM d').format(e1.startTime)}';
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quick Actions
                  _buildQuickActionsCard(context, ref, aiService),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> insights,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 20, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(insight, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    WidgetRef ref,
    AISchedulingService aiService,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showSmartScheduling(context, ref, aiService);
            },
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Smart Schedule New Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Auto-optimize schedule
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule optimization coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.tune),
            label: const Text('Optimize Schedule'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  void _showSmartScheduling(
    BuildContext context,
    WidgetRef ref,
    AISchedulingService aiService,
  ) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_fix_high, color: Colors.purple),
            SizedBox(width: 12),
            Text('Smart Schedule'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'What do you want to schedule?',
                hintText: 'e.g., Team meeting',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI will find the best time based on your schedule patterns!',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              final items = ref.read(agendaItemsProvider).value ?? [];
              //final items = ref.read(agendaItemsProvider).valueOrNull ?? [];
              final category = aiService.suggestCategory(title);
              final duration = aiService.suggestDuration(title, category);
              final optimalTime = aiService.suggestOptimalTime(
                items,
                duration,
                DateTime.now(),
              );

              final categoryObj = categories.firstWhere(
                (c) => c.name == category,
                orElse: () => categories.first,
              );

              final event = AgendaItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                description: 'AI scheduled event',
                startTime: optimalTime,
                endTime: optimalTime.add(duration),
                color: categoryObj.color,
                category: category,
                priority: Priority.medium,
                reminders: [ReminderSetting(minutesBefore: 15)],
              );

              Navigator.pop(context);

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Smart Schedule'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Event: $title'),
                      Text('Category: $category'),
                      Text(
                        'Suggested time: ${DateFormat('MMM d, HH:mm').format(optimalTime)}',
                      ),
                      Text('Duration: ${duration.inMinutes} minutes'),
                      const SizedBox(height: 16),
                      const Text(
                        '✨ This time was chosen based on your productivity patterns!',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Schedule'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(agendaItemsProvider.notifier).addItem(event);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$title scheduled for ${DateFormat('MMM d, HH:mm').format(optimalTime)}',
                    ),
                  ),
                );
              }
            },
            child: const Text('Find Best Time'),
          ),
        ],
      ),
    );
  }

  void _showCloudSync(BuildContext context, WidgetRef ref) async {
    /*   final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (user == null) {
          _showLoginDialog(context, ref);
          return;
        } */

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_sync, size: 28),
                SizedBox(width: 12),
                Text(
                  'Cloud Sync',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              // 'Signed in as: ${user.email ?? "Anonymous"}',
              'Signe',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.cloud_upload, color: Colors.white),
              ),
              title: const Text('Backup to Cloud'),
              subtitle: const Text('Upload all events to cloud'),
              onTap: () async {
                Navigator.pop(context);

                /*  final items =
                        ref.read(agendaItemsProvider).valueOrNull ?? [];
 */
                final items = ref.read(agendaItemsProvider).value ?? [];
                /*   final syncService = ref.read(cloudSyncServiceProvider);

                    final success = await syncService.syncToCloud(items);

                    if (success) {
                      ref.read(lastSyncTimeProvider.notifier).state =
                          DateTime.now();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Backed up ${items.length} events to cloud',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup failed')),
                      );
                    }
                  }, */
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.cloud_download, color: Colors.white),
              ),
              title: const Text('Restore from Cloud'),
              subtitle: const Text('Download events from cloud'),
              onTap: () async {
                Navigator.pop(context);

                /*  final syncService = ref.read(cloudSyncServiceProvider);
                    final cloudItems = await syncService.downloadFromCloud();

                    if (cloudItems.isNotEmpty) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Restore from Cloud'),
                          content: Text(
                            'Found ${cloudItems.length} events. Replace local data?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Restore'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final notifier = ref.read(agendaItemsProvider.notifier);
                        final currentItems =
                            ref.read(agendaItemsProvider).value ??
                            []; // Changed valueOrNull to value

                        for (final item in currentItems) {
                          await notifier.deleteItem(item.id);
                        }

                        for (final item in cloudItems) {
                          await notifier.addItem(item);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Restored ${cloudItems.length} events',
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No cloud data found')),
                      );
                    } */
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.share, color: Colors.white),
              ),
              title: const Text('Share Event'),
              subtitle: const Text('Generate shareable link'),
              onTap: () {
                Navigator.pop(context);
                _showShareEventDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  } /* ,
      loading: () {},
      error: (_, __) {},
    ); */
}

void _showLoginDialog(BuildContext context, WidgetRef ref) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isSignUp = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(isSignUp ? 'Sign Up' : 'Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => isSignUp = !isSignUp);
              },
              child: Text(
                isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // final authService = ref.read(authServiceProvider);
              // await authService.signInAnonymously();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed in anonymously')),
              );
            },
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              /*  final authService = ref.read(authServiceProvider);
                UserCredential? result;

                if (isSignUp) {
                  result = await authService.signUpWithEmail(email, password);
                } else {
                  result = await authService.signInWithEmail(email, password);
                }

                if (result != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSignUp ? 'Account created!' : 'Signed in!',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Authentication failed')),
                  );
                } */
            },
            child: Text(isSignUp ? 'Sign Up' : 'Sign In'),
          ),
        ],
      ),
    ),
  );
}

void _showShareEventDialog(BuildContext context, WidgetRef ref) {
  final asyncItems = ref.read(agendaItemsProvider);

  // Handle loading/error states
  if (asyncItems.isLoading) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Loading events...')));
    return;
  }

  if (asyncItems.hasError) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Error loading events')));
    return;
  }

  final items = asyncItems.value ?? [];

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Share Event'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.title),
              subtitle: Text(DateFormat('MMM d, HH:mm').format(item.startTime)),
              onTap: () async {
                Navigator.pop(context);

                /*  final syncService = ref.read(cloudSyncServiceProvider);
                  final shareId = await syncService.shareEvent(item);

                  if (shareId != null) {
                    final shareLink = 'agenda://event/$shareId';
                    await Share.share(
                      'Check out this event: ${item.title}\n\n'
                      'Open in Agenda Planner: $shareLink',
                      subject: 'Event: ${item.title}',
                    );
                  } */
              },
            );
          },
        ),
      ),
    ),
  );
}

void _showAccountSettings(BuildContext context, WidgetRef ref) {
  /*  final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) { */
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          /*  if (user != null) ...[
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user.email ?? 'Anonymous User'),
                    subtitle: Text('User ID: ${user.uid.substring(0, 8)}...'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      //await ref.read(authServiceProvider).signOut();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out')),
                      );
                    },
                  ),
                ] else ...[
                  const Text('Not signed in'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showLoginDialog(context, ref);
                    },
                    child: const Text('Sign In'),
                  ),
                ], */
        ],
      ),
    ),
  );
  //}
  /* ,
      loading: () {},
      error: (_, __) {},
    ); */
}

void _showCalendarSync(BuildContext context, WidgetRef ref) async {
  final calendarService = ref.read(calendarIntegrationProvider);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sync, size: 28),
              SizedBox(width: 12),
              Text(
                'Calendar Sync',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.upload, color: Colors.white),
            ),
            title: const Text('Export to Device Calendar'),
            subtitle: const Text('Sync all events to your phone calendar'),
            onTap: () async {
              Navigator.pop(context);

              final calendars = await calendarService.getCalendars();
              if (calendars.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No calendars found or permission denied'),
                  ),
                );
                return;
              }

              // Show calendar selection
              final selectedCalendar = await showDialog<Calendar>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Calendar'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: calendars.length,
                      itemBuilder: (context, index) {
                        final calendar = calendars[index];
                        return ListTile(
                          title: Text(calendar.name ?? 'Unnamed'),
                          subtitle: Text(calendar.accountName ?? ''),
                          onTap: () => Navigator.pop(context, calendar),
                        );
                      },
                    ),
                  ),
                ),
              );

              if (selectedCalendar != null) {
                final items = ref.read(agendaItemsProvider).value ?? [];
                int synced = 0;

                for (final item in items) {
                  final success = await calendarService.syncEventToCalendar(
                    item,
                    selectedCalendar.id!,
                  );
                  if (success) synced++;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Synced $synced events to ${selectedCalendar.name}',
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.download, color: Colors.white),
            ),
            title: const Text('Import from Device Calendar'),
            subtitle: const Text('Bring events from your phone calendar'),
            onTap: () async {
              Navigator.pop(context);

              final calendars = await calendarService.getCalendars();
              if (calendars.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No calendars found or permission denied'),
                  ),
                );
                return;
              }

              final selectedCalendar = await showDialog<Calendar>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Calendar'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: calendars.length,
                      itemBuilder: (context, index) {
                        final calendar = calendars[index];
                        return ListTile(
                          title: Text(calendar.name ?? 'Unnamed'),
                          subtitle: Text(calendar.accountName ?? ''),
                          onTap: () => Navigator.pop(context, calendar),
                        );
                      },
                    ),
                  ),
                ),
              );

              if (selectedCalendar != null) {
                final now = DateTime.now();
                final start = now.subtract(const Duration(days: 30));
                final end = now.add(const Duration(days: 90));

                final events = await calendarService.importFromCalendar(
                  selectedCalendar.id!,
                  start,
                  end,
                );

                int imported = 0;
                for (final event in events) {
                  if (event.start != null && event.end != null) {
                    final agendaItem = calendarService.convertCalendarEvent(
                      event,
                      'Work',
                      Colors.blue,
                    );
                    await ref
                        .read(agendaItemsProvider.notifier)
                        .addItem(agendaItem);
                    imported++;
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Imported $imported events from ${selectedCalendar.name}',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

void _showVoiceInput(BuildContext context, WidgetRef ref) async {
  final voiceService = ref.read(voiceInputServiceProvider);

  // Show listening dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.mic, color: Colors.deepPurple),
          SizedBox(width: 12),
          Text('Listening...'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Say something like:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '"Meeting with John tomorrow at 3pm"\n"Gym workout in 2 hours"\n"Lunch today at noon"',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ),
  );

  try {
    final result = await voiceService.listen();
    Navigator.of(context).pop(); // Close listening dialog

    if (result != null && result.isNotEmpty) {
      final event = SmartEventParser.parseVoiceInput(result);

      if (event != null) {
        // Show confirmation dialog
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice input: "$result"',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildConfirmRow('Title', event.title),
                _buildConfirmRow(
                  'Date',
                  DateFormat('MMM d, yyyy').format(event.startTime),
                ),
                _buildConfirmRow(
                  'Time',
                  '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                ),
                _buildConfirmRow('Category', event.category),
                _buildConfirmRow(
                  'Priority',
                  event.priority.toString().split('.').last.toUpperCase(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  // Open edit dialog
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddEventSheet(editItem: event),
                  );
                },
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Create'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await ref.read(agendaItemsProvider.notifier).addItem(event);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event "${event.title}" created!'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state =
                      event.startTime;
                  ref.read(viewModeProvider.notifier).state = ViewMode.day;
                },
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not understand: "$result"'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _showVoiceInput(context, ref),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No speech detected')));
    }
  } catch (e) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Voice input error: $e')));
  }
}

Widget _buildConfirmRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

void _showQuickAddMenu(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Quick Add',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a template to quickly create an event',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: eventTemplates.length,
              itemBuilder: (context, index) {
                final template = eventTemplates[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showTemplateTimeSelector(context, ref, template);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: template.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: template.color.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(template.icon, size: 40, color: template.color),
                        const SizedBox(height: 8),
                        Text(
                          template.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: template.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _showTemplateTimeSelector(
  BuildContext context,
  WidgetRef ref,
  EventTemplate template,
) {
  final now = DateTime.now();
  final timeOptions = [
    ('Now', now),
    ('In 30 min', now.add(const Duration(minutes: 30))),
    ('In 1 hour', now.add(const Duration(hours: 1))),
    ('In 2 hours', now.add(const Duration(hours: 2))),
    ('Tomorrow 9 AM', DateTime(now.year, now.month, now.day + 1, 9, 0)),
    ('Choose time', null),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When?',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...timeOptions.map((option) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: template.color.withOpacity(0.2),
                  child: Icon(
                    option.$2 == null ? Icons.schedule : Icons.access_time,
                    color: template.color,
                    size: 20,
                  ),
                ),
                title: Text(option.$1),
                subtitle: option.$2 != null
                    ? Text(DateFormat('MMM d, HH:mm').format(option.$2!))
                    : null,
                onTap: () async {
                  Navigator.pop(context);

                  DateTime? selectedTime = option.$2;

                  if (selectedTime == null) {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (time != null) {
                        selectedTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      }
                    }
                  }

                  if (selectedTime != null) {
                    final event = template.createEvent(selectedTime);
                    await ref.read(agendaItemsProvider.notifier).addItem(event);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${template.name} added!'),
                        action: SnackBarAction(
                          label: 'View',
                          onPressed: () {
                            ref.read(selectedDateProvider.notifier).state =
                                selectedTime!;
                            ref.read(viewModeProvider.notifier).state =
                                ViewMode.day;
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}

void _showImportOptions(BuildContext context, WidgetRef ref) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Import from JSON'),
              subtitle: const Text('Restore from backup'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );

                  if (result != null && result.files.single.path != null) {
                    final items = await ExportImportService.importFromJson(
                      result.files.single.path!,
                    );

                    // Show confirmation dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Import Data'),
                        content: Text(
                          'Found ${items.length} events. This will replace your current data. Continue?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // Clear current data and add imported items
                      final notifier = ref.read(agendaItemsProvider.notifier);
                      final currentItems =
                          ref.read(agendaItemsProvider).value ?? [];

                      for (final item in currentItems) {
                        await notifier.deleteItem(item.id);
                      }
                      for (final item in items) {
                        await notifier.addItem(item);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Imported ${items.length} events!'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Import from CSV'),
              subtitle: const Text('Import spreadsheet data'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['csv'],
                  );

                  if (result != null && result.files.single.path != null) {
                    final items = await ExportImportService.importFromCsv(
                      result.files.single.path!,
                    );

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Import CSV'),
                        content: Text(
                          'Found ${items.length} events. Add to existing data?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final notifier = ref.read(agendaItemsProvider.notifier);
                      for (final item in items) {
                        await notifier.addItem(item);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Imported ${items.length} events!'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
  //}
}
