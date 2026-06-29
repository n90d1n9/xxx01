import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organization Statement App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          _isDarkMode
              ? ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.indigo,
                brightness: Brightness.dark,
                textTheme: GoogleFonts.poppinsTextTheme(
                  ThemeData(brightness: Brightness.dark).textTheme,
                ),
              )
              : ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.indigo,
                brightness: Brightness.light,
                textTheme: GoogleFonts.poppinsTextTheme(),
              ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Organization Statements',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle theme',
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show menu
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Statement Viewer'),
              Tab(text: 'Create Statement'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [StatementViewerScreen(), StatementFormScreen()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _tabController.animateTo(1);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class StatementViewerScreen extends StatefulWidget {
  const StatementViewerScreen({Key? key}) : super(key: key);

  @override
  State<StatementViewerScreen> createState() => _StatementViewerScreenState();
}

class _StatementViewerScreenState extends State<StatementViewerScreen> {
  final List<StatementDocument> _statements = [
    StatementDocument(
      id: '001',
      title: 'Q1 Financial Statement',
      date: DateTime(2025, 1, 15),
      author: 'Financial Department',
      content:
          'This document outlines the financial performance for Q1 2025, including revenue growth of 12% compared to the previous quarter...',
      isImportant: true,
    ),
    StatementDocument(
      id: '002',
      title: 'Annual Corporate Policy Update',
      date: DateTime(2025, 2, 28),
      author: 'HR Department',
      content:
          'Please review the revised corporate policies that will be effective starting March 15, 2025. Major changes include remote work...',
      isImportant: false,
    ),
    StatementDocument(
      id: '003',
      title: 'Project Milestone Announcement',
      date: DateTime(2025, 3, 10),
      author: 'Project Management Office',
      content:
          'We are pleased to announce that phase one of the Global Expansion Project has been successfully completed ahead of schedule...',
      isImportant: true,
    ),
    StatementDocument(
      id: '004',
      title: 'Board Meeting Minutes',
      date: DateTime(2025, 4, 5),
      author: 'Executive Office',
      content:
          'The board discussed the following items: strategic direction for Q2 2025, review of global operations, approval of new investment...',
      isImportant: true,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<StatementDocument> _filteredStatements = [];

  @override
  void initState() {
    super.initState();
    _filteredStatements = _statements;
    _searchController.addListener(_filterStatements);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStatements() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStatements =
          _statements.where((statement) {
            return statement.title.toLowerCase().contains(query) ||
                statement.author.toLowerCase().contains(query) ||
                statement.content.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            controller: _searchController,
            hintText: 'Search statements...',
            leading: const Icon(Icons.search),
            trailing: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _filteredStatements.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No statements found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredStatements.length,
                      itemBuilder: (context, index) {
                        final statement = _filteredStatements[index];
                        return StatementCard(
                          statement: statement,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => StatementDetailScreen(
                                      statement: statement,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class StatementCard extends StatelessWidget {
  final StatementDocument statement;
  final VoidCallback onTap;

  const StatementCard({Key? key, required this.statement, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (statement.isImportant)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.priority_high,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Important',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    formatter.format(statement.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                statement.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                statement.author,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                statement.content.length > 100
                    ? '${statement.content.substring(0, 100)}...'
                    : statement.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatementDetailScreen extends StatelessWidget {
  final StatementDocument statement;

  const StatementDetailScreen({Key? key, required this.statement})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (statement.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Document',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                statement.title,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statement.author,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    formatter.format(statement.date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                statement.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              Center(
                child: FilledButton.icon(
                  onPressed: () {
                    // Download or export functionality
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export as PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatementFormScreen extends StatefulWidget {
  const StatementFormScreen({Key? key}) : super(key: key);

  @override
  State<StatementFormScreen> createState() => _StatementFormScreenState();
}

class _StatementFormScreenState extends State<StatementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isImportant = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create new statement
      final newStatement = StatementDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        author: _authorController.text,
        date: _selectedDate,
        content: _contentController.text,
        isImportant: _isImportant,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Statement created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear form
      _titleController.clear();
      _authorController.clear();
      _contentController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _isImportant = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Statement',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Statement Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author/Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author or department';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Mark as Important'),
                subtitle: const Text(
                  'Highlight this statement as requiring attention',
                ),
                value: _isImportant,
                onChanged: (value) {
                  setState(() {
                    _isImportant = value;
                  });
                },
                secondary: Icon(
                  Icons.priority_high,
                  color:
                      _isImportant ? Theme.of(context).colorScheme.error : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Statement Content',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Enter the full statement content here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _titleController.clear();
                        _authorController.clear();
                        _contentController.clear();
                        setState(() {
                          _selectedDate = DateTime.now();
                          _isImportant = false;
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Form'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Statement'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class StatementDocument {
  final String id;
  final String title;
  final DateTime date;
  final String author;
  final String content;
  final bool isImportant;

  StatementDocument({
    required this.id,
    required this.title,
    required this.date,
    required this.author,
    required this.content,
    this.isImportant = false,
  });
}
