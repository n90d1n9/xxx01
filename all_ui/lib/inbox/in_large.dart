import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Data models
class EmailMessage {
  final String id;
  final String sender;
  final String senderEmail;
  final String subject;
  final String preview;
  final DateTime timestamp;
  final bool isRead;
  final bool isStarred;
  final bool hasAttachment;
  final String? avatarUrl;
  final List<String> labels;

  EmailMessage({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.preview,
    required this.timestamp,
    this.isRead = false,
    this.isStarred = false,
    this.hasAttachment = false,
    this.avatarUrl,
    this.labels = const [],
  });
}

// Sample data provider
final emailsProvider =
    StateNotifierProvider<EmailsNotifier, List<EmailMessage>>((ref) {
      return EmailsNotifier();
    });

class EmailsNotifier extends StateNotifier<List<EmailMessage>> {
  EmailsNotifier()
    : super([
        EmailMessage(
          id: '1',
          sender: 'Alex Johnson',
          senderEmail: 'alex.johnson@example.com',
          subject: 'Project Status Update - Q1 2025',
          preview:
              'I wanted to share the latest updates on our ongoing project. The team has made significant progress on...',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isStarred: true,
          labels: ['Work', 'Important'],
        ),
        EmailMessage(
          id: '2',
          sender: 'Marketing Team',
          senderEmail: 'marketing@company.com',
          subject: 'New Campaign Draft for Review',
          preview:
              'Please find attached the draft of our upcoming marketing campaign. We need your feedback by...',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          hasAttachment: true,
          labels: ['Marketing'],
        ),
        EmailMessage(
          id: '3',
          sender: 'Sarah Williams',
          senderEmail: 'sarah.w@partner.org',
          subject: 'Partnership Opportunity',
          preview:
              'Following our discussion last week, I\'d like to propose a new partnership opportunity between our organizations...',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
          labels: ['Partnership'],
        ),
        EmailMessage(
          id: '4',
          sender: 'Dev Team',
          senderEmail: 'dev-team@company.com',
          subject: 'System Maintenance Scheduled',
          preview:
              'We will be performing scheduled maintenance on our servers this weekend. Please expect some downtime...',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
          labels: ['Tech', 'Internal'],
        ),
        EmailMessage(
          id: '5',
          sender: 'HR Department',
          senderEmail: 'hr@company.com',
          subject: 'Annual Review Process Updates',
          preview:
              'We\'re making some changes to our annual review process. Please read the attached document for details...',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          hasAttachment: true,
          isRead: true,
          labels: ['HR'],
        ),
        EmailMessage(
          id: '6',
          sender: 'Michael Chen',
          senderEmail: 'michael.chen@client.com',
          subject: 'Feedback on Latest Deliverable',
          preview:
              'Thank you for sending over the latest version. I have some feedback I\'d like to discuss in our next meeting...',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          labels: ['Client'],
        ),
        EmailMessage(
          id: '7',
          sender: 'Finance Department',
          senderEmail: 'finance@company.com',
          subject: 'Q1 Expense Reports Due',
          preview:
              'This is a reminder that all Q1 expense reports must be submitted by the end of this week. Please ensure...',
          timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
          isRead: true,
          labels: ['Finance', 'Important'],
        ),
        EmailMessage(
          id: '8',
          sender: 'Product Team',
          senderEmail: 'product@company.com',
          subject: 'New Feature Announcement',
          preview:
              'We\'re excited to announce that we\'ll be rolling out a new feature next month. Here\'s what you need to know...',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          isRead: true,
          labels: ['Product'],
        ),
      ]);

  void toggleRead(String id) {
    state = [
      for (final email in state)
        if (email.id == id)
          EmailMessage(
            id: email.id,
            sender: email.sender,
            senderEmail: email.senderEmail,
            subject: email.subject,
            preview: email.preview,
            timestamp: email.timestamp,
            isRead: !email.isRead,
            isStarred: email.isStarred,
            hasAttachment: email.hasAttachment,
            avatarUrl: email.avatarUrl,
            labels: email.labels,
          )
        else
          email,
    ];
  }

  void toggleStar(String id) {
    state = [
      for (final email in state)
        if (email.id == id)
          EmailMessage(
            id: email.id,
            sender: email.sender,
            senderEmail: email.senderEmail,
            subject: email.subject,
            preview: email.preview,
            timestamp: email.timestamp,
            isRead: email.isRead,
            isStarred: !email.isStarred,
            hasAttachment: email.hasAttachment,
            avatarUrl: email.avatarUrl,
            labels: email.labels,
          )
        else
          email,
    ];
  }
}

// Selected email provider
final selectedEmailIdProvider = StateProvider<String?>((ref) => null);

// Theme provider (for light/dark mode)
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Filter provider
enum EmailFilter { all, unread, starred }

final emailFilterProvider = StateProvider<EmailFilter>(
  (ref) => EmailFilter.all,
);

// Filtered emails provider
final filteredEmailsProvider = Provider<List<EmailMessage>>((ref) {
  final filter = ref.watch(emailFilterProvider);
  final emails = ref.watch(emailsProvider);

  switch (filter) {
    case EmailFilter.unread:
      return emails.where((email) => !email.isRead).toList();
    case EmailFilter.starred:
      return emails.where((email) => email.isStarred).toList();
    case EmailFilter.all:
    default:
      return emails;
  }
});

// Main App
void main() {
  runApp(const ProviderScope(child: EmailApp()));
}

class EmailApp extends ConsumerWidget {
  const EmailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'Professional Inbox',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const EmailInboxScreen(),
    );
  }
}

class EmailInboxScreen extends ConsumerWidget {
  const EmailInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Left Sidebar
            NavigationRail(
              extended: true,
              minExtendedWidth: 250,
              selectedIndex: 0,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.inbox),
                  label: Text('Inbox'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.send),
                  label: Text('Sent'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star),
                  label: Text('Starred'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.delete),
                  label: Text('Trash'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.label),
                  label: Text('Labels'),
                ),
              ],
              onDestinationSelected: (index) {
                // Handle navigation
              },
              trailing: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      ListTile(
                        leading: CircleAvatar(child: Text('JD')),
                        title: const Text('John Doe'),
                        subtitle: const Text('john.doe@example.com'),
                        dense: true,
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        dense: true,
                        onTap: () {},
                      ),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: ref.watch(isDarkModeProvider),
                        onChanged: (value) {
                          ref.read(isDarkModeProvider.notifier).state = value;
                        },
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Email List and Detail Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(-3, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Email List
                    SizedBox(
                      width: 400,
                      child: Column(
                        children: [
                          // Search and Filter Bar
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search emails',
                                      prefixIcon: const Icon(Icons.search),
                                      filled: true,
                                      fillColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                    ),
                                  ),
                                ),
                                PopupMenuButton<EmailFilter>(
                                  icon: const Icon(Icons.filter_list),
                                  onSelected: (filter) {
                                    ref
                                        .read(emailFilterProvider.notifier)
                                        .state = filter;
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: EmailFilter.all,
                                          child: Text('All'),
                                        ),
                                        const PopupMenuItem(
                                          value: EmailFilter.unread,
                                          child: Text('Unread'),
                                        ),
                                        const PopupMenuItem(
                                          value: EmailFilter.starred,
                                          child: Text('Starred'),
                                        ),
                                      ],
                                ),
                              ],
                            ),
                          ),
                          // Email List
                          Expanded(child: EmailListView()),
                        ],
                      ),
                    ),
                    // Email Detail View
                    const VerticalDivider(width: 1),
                    Expanded(flex: 2, child: EmailDetailView()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new email
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class EmailListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emails = ref.watch(filteredEmailsProvider);
    final selectedEmailId = ref.watch(selectedEmailIdProvider);

    return ListView.builder(
      itemCount: emails.length,
      itemBuilder: (context, index) {
        final email = emails[index];
        final isSelected = email.id == selectedEmailId;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          elevation: isSelected ? 1 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              ref.read(selectedEmailIdProvider.notifier).state = email.id;
              if (!email.isRead) {
                ref.read(emailsProvider.notifier).toggleRead(email.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar or initials
                  CircleAvatar(
                    backgroundColor:
                        email.isRead
                            ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                            : Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        email.isRead
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onPrimary,
                    child: Text(email.sender.substring(0, 1)),
                  ),
                  const SizedBox(width: 12),
                  // Email Content Preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                email.sender,
                                style: TextStyle(
                                  fontWeight:
                                      email.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(email.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.subject,
                          style: TextStyle(
                            fontWeight:
                                email.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email.preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Labels
                        Wrap(
                          spacing: 4,
                          children:
                              email.labels
                                  .map(
                                    (label) => Chip(
                                      label: Text(
                                        label,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action Icons
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          email.isStarred ? Icons.star : Icons.star_border,
                          color: email.isStarred ? Colors.amber : null,
                        ),
                        onPressed: () {
                          ref
                              .read(emailsProvider.notifier)
                              .toggleStar(email.id);
                        },
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                      ),
                      if (email.hasAttachment)
                        const Icon(Icons.attach_file, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return DateFormat.jm().format(date); // Today, show time
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat.E().format(date); // Weekday
    } else {
      return DateFormat.MMMd().format(date); // Month and day
    }
  }
}

class EmailDetailView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEmailId = ref.watch(selectedEmailIdProvider);
    final emails = ref.watch(emailsProvider);

    if (selectedEmailId == null) {
      return const Center(child: Text('Select an email to view its contents'));
    }

    final selectedEmail = emails.firstWhere(
      (email) => email.id == selectedEmailId,
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(selectedEmailIdProvider.notifier).state = null;
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.archive),
                tooltip: 'Archive',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.mail),
                tooltip: 'Mark as unread',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.schedule),
                tooltip: 'Snooze',
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  selectedEmail.isStarred ? Icons.star : Icons.star_border,
                  color: selectedEmail.isStarred ? Colors.amber : null,
                ),
                tooltip: selectedEmail.isStarred ? 'Unstar' : 'Star',
                onPressed: () {
                  ref
                      .read(emailsProvider.notifier)
                      .toggleStar(selectedEmail.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                tooltip: 'More options',
                onPressed: () {},
              ),
            ],
          ),
          const Divider(),

          // Subject Line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              selectedEmail.subject,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // Sender Info
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Text(selectedEmail.sender.substring(0, 1)),
            ),
            title: Row(
              children: [
                Text(selectedEmail.sender),
                const SizedBox(width: 8),
                Text(
                  '<${selectedEmail.senderEmail}>',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'To: me - ${DateFormat.yMMMd().add_jm().format(selectedEmail.timestamp)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.reply),
                  tooltip: 'Reply',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.reply_all),
                  tooltip: 'Reply all',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.forward),
                  tooltip: 'Forward',
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Email Labels
          if (selectedEmail.labels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                spacing: 8,
                children:
                    selectedEmail.labels
                        .map(
                          (label) => Chip(
                            label: Text(label),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
              ),
            ),

          const Divider(),

          // Email Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dear Team,\n\n'
                    '${selectedEmail.preview}\n\n'
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia odio vitae vestibulum. Donec in efficitur ipsum. Curabitur eget sagittis orci, at fermentum urna. Nulla facilisi. Sed fermentum, mi in dignissim lobortis, neque felis placerat dui, a porta ante lectus non est.\n\n'
                    'Phasellus vel felis consectetur, cursus nibh in, faucibus eros. Etiam aliquam nisl vel mi pellentesque, non congue felis euismod. Aliquam convallis condimentum nulla, ac dictum tortor malesuada in. Aliquam erat volutpat. Donec finibus ipsum a mi fermentum, quis dignissim ipsum molestie.\n\n'
                    'Best regards,\n'
                    '${selectedEmail.sender}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  // Attachments
                  if (selectedEmail.hasAttachment)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attachments',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AttachmentCard(
                                name: 'Document.pdf',
                                size: '2.4 MB',
                                icon: Icons.picture_as_pdf,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 16),
                              AttachmentCard(
                                name: 'Image.jpg',
                                size: '3.7 MB',
                                icon: Icons.image,
                                color: Colors.blue.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Quick Reply
          Card(
            margin: const EdgeInsets.only(top: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(child: const Text('JD')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Reply to this email...',
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttachmentCard extends StatelessWidget {
  final String name;
  final String size;
  final IconData icon;
  final Color color;

  const AttachmentCard({
    required this.name,
    required this.size,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
