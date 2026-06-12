import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_edit_evaluation_page.dart';
import 'add_edit_program_page.dart.dart';
import 'models/meeting.dart';

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
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditMeetingPage(meeting: meeting),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMeeting(context, ref),
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
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMM dd, yyyy - h:mm a').format(meeting.dateTime),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          if (meeting.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(meeting.description),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _deleteMeeting(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: const Text('Are you sure you want to delete this meeting?'),
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
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==================== ADD/EDIT PROGRAM PAGE ====================

// ==================== EVALUATION DETAILS PAGE ====================

class EvaluationDetailsPage extends ConsumerWidget {
  final Evaluation evaluation;

  const EvaluationDetailsPage({Key? key, required this.evaluation})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditEvaluationPage(evaluation: evaluation),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteEvaluation(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            evaluation.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, yyyy').format(evaluation.evaluationDate),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Card(
            color: _getScoreColor(evaluation.overallScore).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Overall Score',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${evaluation.overallScore}%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(evaluation.overallScore),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (evaluation.summary.isNotEmpty) ...[
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(evaluation.summary),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (evaluation.strengths.isNotEmpty) ...[
            const Text(
              'Strengths',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...evaluation.strengths.map(
              (strength) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.green.shade50,
                child: ListTile(
                  leading: Icon(
                    Icons.thumb_up,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                  title: Text(strength),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (evaluation.weaknesses.isNotEmpty) ...[
            const Text(
              'Weaknesses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...evaluation.weaknesses.map(
              (weakness) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(
                    Icons.thumb_down,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                  title: Text(weakness),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (evaluation.recommendations.isNotEmpty) ...[
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...evaluation.recommendations.map(
              (recommendation) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: Icon(
                    Icons.lightbulb,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  title: Text(recommendation),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _deleteEvaluation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Evaluation'),
        content: const Text('Are you sure you want to delete this evaluation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(evaluationsProvider.notifier)
                  .deleteEvaluation(evaluation.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==================== PROGRAM DETAILS PAGE ====================

class ProgramDetailsPage extends ConsumerWidget {
  final Program program;

  const ProgramDetailsPage({Key? key, required this.program}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditProgramPage(program: program),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteProgram(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            program.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM dd, yyyy').format(program.startDate)} - ${DateFormat('MMM dd, yyyy').format(program.endDate)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: program.progressPercentage / 100,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${program.progressPercentage}% Complete',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (program.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(program.description),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (program.objectives.isNotEmpty) ...[
            const Text(
              'Objectives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...program.objectives.map(
              (obj) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.flag, size: 20),
                  title: Text(obj),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (program.milestones.isNotEmpty) ...[
            const Text(
              'Milestones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...program.milestones.map(
              (milestone) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.timeline, size: 20),
                  title: Text(milestone),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _deleteProgram(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program'),
        content: const Text('Are you sure you want to delete this program?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(programsProvider.notifier).deleteProgram(program.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==================== ADD/EDIT ACTION PLAN PAGE ====================

class AddEditActionPlanPage extends ConsumerStatefulWidget {
  final ActionPlan? plan;

  const AddEditActionPlanPage({Key? key, this.plan}) : super(key: key);

  @override
  ConsumerState<AddEditActionPlanPage> createState() =>
      _AddEditActionPlanPageState();
}

class _AddEditActionPlanPageState extends ConsumerState<AddEditActionPlanPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _ownerController;
  late DateTime _startDate;
  late DateTime _targetEndDate;
  final List<String> _goals = [];
  final List<String> _kpis = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _titleController = TextEditingController(text: plan?.title ?? '');
    _descriptionController = TextEditingController(
      text: plan?.description ?? '',
    );
    _ownerController = TextEditingController(text: plan?.owner ?? '');
    _startDate = plan?.startDate ?? DateTime.now();
    _targetEndDate =
        plan?.targetEndDate ?? DateTime.now().add(const Duration(days: 30));
    if (plan != null) {
      _goals.addAll(plan.goals);
      _kpis.addAll(plan.kpis);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plan == null ? 'New Action Plan' : 'Edit Action Plan',
        ),
        actions: [
          TextButton(onPressed: _saveActionPlan, child: const Text('Save')),
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
            TextFormField(
              controller: _ownerController,
              decoration: const InputDecoration(
                labelText: 'Owner',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Start: ${DateFormat('MMM dd, yyyy').format(_startDate)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectDate(true),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Target End: ${DateFormat('MMM dd, yyyy').format(_targetEndDate)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 24),
            _buildListSection('Goals', _goals, Icons.emoji_events),
            const SizedBox(height: 24),
            _buildListSection('KPIs', _kpis, Icons.show_chart),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          ...items.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(icon, size: 20),
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => setState(() => items.remove(item)),
                ),
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () =>
              _addItem(items, 'Add ${title.substring(0, title.length - 1)}'),
          icon: const Icon(Icons.add),
          label: Text('Add ${title.substring(0, title.length - 1)}'),
        ),
      ],
    );
  }

  void _addItem(List<String> list, String hint) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hint),
        content: TextField(controller: controller, autofocus: true),
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

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _targetEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _targetEndDate = date;
        }
      });
    }
  }

  void _saveActionPlan() {
    if (!_formKey.currentState!.validate()) return;

    final plan = ActionPlan(
      id: widget.plan?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      targetEndDate: _targetEndDate,
      goals: _goals,
      actions: widget.plan?.actions ?? [],
      kpis: _kpis,
      owner: _ownerController.text.isEmpty ? null : _ownerController.text,
      createdAt: widget.plan?.createdAt ?? DateTime.now(),
    );

    if (widget.plan == null) {
      ref.read(actionPlansProvider.notifier).addActionPlan(plan);
    } else {
      ref.read(actionPlansProvider.notifier).updateActionPlan(plan);
    }

    Navigator.pop(context);
  }
}

// ==================== ACTION PLAN DETAILS PAGE ====================

class ActionPlanDetailsPage extends ConsumerWidget {
  final ActionPlan plan;

  const ActionPlanDetailsPage({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Action Plan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditActionPlanPage(plan: plan),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            plan.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('MMM dd, yyyy').format(plan.startDate)} - ${DateFormat('MMM dd, yyyy').format(plan.targetEndDate)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          if (plan.goals.isNotEmpty) ...[
            const Text(
              'Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...plan.goals.map(
              (goal) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.emoji_events, size: 20),
                  title: Text(goal),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== ADD/EDIT EVALUATION PAGE ====================

// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// uuid: ^4.2.1
// intl: ^0.18.1
// shared_preferences: ^2.2.2
// fl_chart: ^0.65.0

// ==================== ENUMS ====================

enum MeetingPriority { low, medium, high, urgent }

enum MeetingStatus { scheduled, inProgress, completed, cancelled }

enum MeetingType {
  standup,
  planning,
  review,
  retrospective,
  oneOnOne,
  program,
  evaluation,
  other,
}

enum ActionItemPriority { low, medium, high, critical }

enum ActionItemStatus { notStarted, inProgress, completed, blocked, cancelled }

enum ProgramStatus { planning, active, onHold, completed, cancelled }

enum EvaluationStatus { draft, inReview, completed }

// ==================== MODELS ====================

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
  final String description;
  final String? assignedTo;
  final DateTime? dueDate;
  final ActionItemStatus status;
  final ActionItemPriority priority;
  final int progressPercentage;
  final DateTime createdAt;
  final String? parentId;
  final List<String> dependencies;
  final List<String> tags;

  ActionItem({
    required this.id,
    required this.title,
    this.description = '',
    this.assignedTo,
    this.dueDate,
    this.status = ActionItemStatus.notStarted,
    this.priority = ActionItemPriority.medium,
    this.progressPercentage = 0,
    required this.createdAt,
    this.parentId,
    this.dependencies = const [],
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'assignedTo': assignedTo,
    'dueDate': dueDate?.toIso8601String(),
    'status': status.name,
    'priority': priority.name,
    'progressPercentage': progressPercentage,
    'createdAt': createdAt.toIso8601String(),
    'parentId': parentId,
    'dependencies': dependencies,
    'tags': tags,
  };

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    assignedTo: json['assignedTo'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    status: ActionItemStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ActionItemStatus.notStarted,
    ),
    priority: ActionItemPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => ActionItemPriority.medium,
    ),
    progressPercentage: json['progressPercentage'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
    parentId: json['parentId'],
    dependencies: List<String>.from(json['dependencies'] ?? []),
    tags: List<String>.from(json['tags'] ?? []),
  );

  ActionItem copyWith({
    String? title,
    String? description,
    String? assignedTo,
    DateTime? dueDate,
    ActionItemStatus? status,
    ActionItemPriority? priority,
    int? progressPercentage,
    String? parentId,
    List<String>? dependencies,
    List<String>? tags,
  }) {
    return ActionItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt,
      parentId: parentId ?? this.parentId,
      dependencies: dependencies ?? this.dependencies,
      tags: tags ?? this.tags,
    );
  }

  bool get isCompleted => status == ActionItemStatus.completed;
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
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
  final String? programId;
  final String? actionPlanId;

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
    this.programId,
    this.actionPlanId,
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
    'programId': programId,
    'actionPlanId': actionPlanId,
  };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dateTime: DateTime.parse(json['dateTime']),
    durationMinutes: json['durationMinutes'] ?? 60,
    attendees: (json['attendees'] as List)
        .map((a) => Attendee.fromJson(a))
        .toList(),
    notes: (json['notes'] as List).map((n) => MeetingNote.fromJson(n)).toList(),
    actionItems: (json['actionItems'] as List)
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
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    recurringPattern: json['recurringPattern'],
    programId: json['programId'],
    actionPlanId: json['actionPlanId'],
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
    String? programId,
    String? actionPlanId,
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
      programId: programId ?? this.programId,
      actionPlanId: actionPlanId ?? this.actionPlanId,
    );
  }

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));
}

class Program {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final ProgramStatus status;
  final List<String> objectives;
  final List<String> stakeholders;
  final String? budget;
  final int progressPercentage;
  final List<String> milestones;
  final List<String> risks;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.objectives,
    required this.stakeholders,
    this.budget,
    this.progressPercentage = 0,
    required this.milestones,
    required this.risks,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status.name,
    'objectives': objectives,
    'stakeholders': stakeholders,
    'budget': budget,
    'progressPercentage': progressPercentage,
    'milestones': milestones,
    'risks': risks,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    status: ProgramStatus.values.firstWhere((e) => e.name == json['status']),
    objectives: List<String>.from(json['objectives'] ?? []),
    stakeholders: List<String>.from(json['stakeholders'] ?? []),
    budget: json['budget'],
    progressPercentage: json['progressPercentage'] ?? 0,
    milestones: List<String>.from(json['milestones'] ?? []),
    risks: List<String>.from(json['risks'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );

  Program copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    ProgramStatus? status,
    List<String>? objectives,
    List<String>? stakeholders,
    String? budget,
    int? progressPercentage,
    List<String>? milestones,
    List<String>? risks,
  }) {
    return Program(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      objectives: objectives ?? this.objectives,
      stakeholders: stakeholders ?? this.stakeholders,
      budget: budget ?? this.budget,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      milestones: milestones ?? this.milestones,
      risks: risks ?? this.risks,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ActionPlan {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime targetEndDate;
  final String? programId;
  final List<String> goals;
  final List<ActionItem> actions;
  final List<String> kpis;
  final int overallProgress;
  final String? owner;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ActionPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.targetEndDate,
    this.programId,
    required this.goals,
    required this.actions,
    required this.kpis,
    this.overallProgress = 0,
    this.owner,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'targetEndDate': targetEndDate.toIso8601String(),
    'programId': programId,
    'goals': goals,
    'actions': actions.map((a) => a.toJson()).toList(),
    'kpis': kpis,
    'overallProgress': overallProgress,
    'owner': owner,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory ActionPlan.fromJson(Map<String, dynamic> json) => ActionPlan(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    startDate: DateTime.parse(json['startDate']),
    targetEndDate: DateTime.parse(json['targetEndDate']),
    programId: json['programId'],
    goals: List<String>.from(json['goals'] ?? []),
    actions: (json['actions'] as List)
        .map((a) => ActionItem.fromJson(a))
        .toList(),
    kpis: List<String>.from(json['kpis'] ?? []),
    overallProgress: json['overallProgress'] ?? 0,
    owner: json['owner'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );

  ActionPlan copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? targetEndDate,
    String? programId,
    List<String>? goals,
    List<ActionItem>? actions,
    List<String>? kpis,
    int? overallProgress,
    String? owner,
  }) {
    return ActionPlan(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      targetEndDate: targetEndDate ?? this.targetEndDate,
      programId: programId ?? this.programId,
      goals: goals ?? this.goals,
      actions: actions ?? this.actions,
      kpis: kpis ?? this.kpis,
      overallProgress: overallProgress ?? this.overallProgress,
      owner: owner ?? this.owner,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Evaluation {
  final String id;
  final String title;
  final String? programId;
  final String? actionPlanId;
  final String? meetingId;
  final EvaluationStatus status;
  final DateTime evaluationDate;
  final List<EvaluationCriteria> criteria;
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final int overallScore;
  final String? evaluator;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Evaluation({
    required this.id,
    required this.title,
    this.programId,
    this.actionPlanId,
    this.meetingId,
    required this.status,
    required this.evaluationDate,
    required this.criteria,
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    this.overallScore = 0,
    this.evaluator,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'programId': programId,
    'actionPlanId': actionPlanId,
    'meetingId': meetingId,
    'status': status.name,
    'evaluationDate': evaluationDate.toIso8601String(),
    'criteria': criteria.map((c) => c.toJson()).toList(),
    'summary': summary,
    'strengths': strengths,
    'weaknesses': weaknesses,
    'recommendations': recommendations,
    'overallScore': overallScore,
    'evaluator': evaluator,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Evaluation.fromJson(Map<String, dynamic> json) => Evaluation(
    id: json['id'],
    title: json['title'],
    programId: json['programId'],
    actionPlanId: json['actionPlanId'],
    meetingId: json['meetingId'],
    status: EvaluationStatus.values.firstWhere((e) => e.name == json['status']),
    evaluationDate: DateTime.parse(json['evaluationDate']),
    criteria: (json['criteria'] as List)
        .map((c) => EvaluationCriteria.fromJson(c))
        .toList(),
    summary: json['summary'],
    strengths: List<String>.from(json['strengths'] ?? []),
    weaknesses: List<String>.from(json['weaknesses'] ?? []),
    recommendations: List<String>.from(json['recommendations'] ?? []),
    overallScore: json['overallScore'] ?? 0,
    evaluator: json['evaluator'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
  );

  Evaluation copyWith({
    String? title,
    String? programId,
    String? actionPlanId,
    String? meetingId,
    EvaluationStatus? status,
    DateTime? evaluationDate,
    List<EvaluationCriteria>? criteria,
    String? summary,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? recommendations,
    int? overallScore,
    String? evaluator,
  }) {
    return Evaluation(
      id: id,
      title: title ?? this.title,
      programId: programId ?? this.programId,
      actionPlanId: actionPlanId ?? this.actionPlanId,
      meetingId: meetingId ?? this.meetingId,
      status: status ?? this.status,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      criteria: criteria ?? this.criteria,
      summary: summary ?? this.summary,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recommendations: recommendations ?? this.recommendations,
      overallScore: overallScore ?? this.overallScore,
      evaluator: evaluator ?? this.evaluator,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class EvaluationCriteria {
  final String name;
  final String description;
  final int score;
  final int maxScore;
  final String? comments;

  EvaluationCriteria({
    required this.name,
    required this.description,
    required this.score,
    this.maxScore = 10,
    this.comments,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'score': score,
    'maxScore': maxScore,
    'comments': comments,
  };

  factory EvaluationCriteria.fromJson(Map<String, dynamic> json) =>
      EvaluationCriteria(
        name: json['name'],
        description: json['description'],
        score: json['score'],
        maxScore: json['maxScore'] ?? 10,
        comments: json['comments'],
      );

  double get percentage => (score / maxScore) * 100;
}

// ==================== PERSISTENCE ====================

class DataRepository {
  static const String _meetingsKey = 'meetings_data';
  static const String _programsKey = 'programs_data';
  static const String _actionPlansKey = 'action_plans_data';
  static const String _evaluationsKey = 'evaluations_data';

  Future<void> saveMeetings(List<Meeting> meetings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = meetings.map((m) => m.toJson()).toList();
    await prefs.setString(_meetingsKey, jsonEncode(jsonData));
  }

  Future<List<Meeting>> loadMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_meetingsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Meeting.fromJson(json)).toList();
  }

  Future<void> savePrograms(List<Program> programs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = programs.map((p) => p.toJson()).toList();
    await prefs.setString(_programsKey, jsonEncode(jsonData));
  }

  Future<List<Program>> loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_programsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Program.fromJson(json)).toList();
  }

  Future<void> saveActionPlans(List<ActionPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = plans.map((p) => p.toJson()).toList();
    await prefs.setString(_actionPlansKey, jsonEncode(jsonData));
  }

  Future<List<ActionPlan>> loadActionPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_actionPlansKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => ActionPlan.fromJson(json)).toList();
  }

  Future<void> saveEvaluations(List<Evaluation> evaluations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = evaluations.map((e) => e.toJson()).toList();
    await prefs.setString(_evaluationsKey, jsonEncode(jsonData));
  }

  Future<List<Evaluation>> loadEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_evaluationsKey);
    if (jsonString == null) return [];
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((json) => Evaluation.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_meetingsKey),
      prefs.remove(_programsKey),
      prefs.remove(_actionPlansKey),
      prefs.remove(_evaluationsKey),
    ]);
  }
}

// ==================== STATE MANAGEMENT ====================

final dataRepositoryProvider = Provider((ref) => DataRepository());

// Meetings
class MeetingsNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  final DataRepository repository;

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
}

final meetingsProvider =
    StateNotifierProvider<MeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => MeetingsNotifier(ref.watch(dataRepositoryProvider)),
    );

// Programs
class ProgramsNotifier extends StateNotifier<AsyncValue<List<Program>>> {
  final DataRepository repository;

  ProgramsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    state = const AsyncValue.loading();
    try {
      final programs = await repository.loadPrograms();
      state = AsyncValue.data(programs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProgram(Program program) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, program];
    state = AsyncValue.data(newState);
    await repository.savePrograms(newState);
  }

  Future<void> updateProgram(Program updatedProgram) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final program in currentState)
        if (program.id == updatedProgram.id) updatedProgram else program,
    ];
    state = AsyncValue.data(newState);
    await repository.savePrograms(newState);
  }

  Future<void> deleteProgram(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((p) => p.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.savePrograms(newState);
  }
}

final programsProvider =
    StateNotifierProvider<ProgramsNotifier, AsyncValue<List<Program>>>(
      (ref) => ProgramsNotifier(ref.watch(dataRepositoryProvider)),
    );

// Action Plans
class ActionPlansNotifier extends StateNotifier<AsyncValue<List<ActionPlan>>> {
  final DataRepository repository;

  ActionPlansNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadActionPlans();
  }

  Future<void> loadActionPlans() async {
    state = const AsyncValue.loading();
    try {
      final plans = await repository.loadActionPlans();
      state = AsyncValue.data(plans);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addActionPlan(ActionPlan plan) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, plan];
    state = AsyncValue.data(newState);
    await repository.saveActionPlans(newState);
  }

  Future<void> updateActionPlan(ActionPlan updatedPlan) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final plan in currentState)
        if (plan.id == updatedPlan.id) updatedPlan else plan,
    ];
    state = AsyncValue.data(newState);
    await repository.saveActionPlans(newState);
  }

  Future<void> deleteActionPlan(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((p) => p.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveActionPlans(newState);
  }
}

final actionPlansProvider =
    StateNotifierProvider<ActionPlansNotifier, AsyncValue<List<ActionPlan>>>(
      (ref) => ActionPlansNotifier(ref.watch(dataRepositoryProvider)),
    );

// Evaluations
class EvaluationsNotifier extends StateNotifier<AsyncValue<List<Evaluation>>> {
  final DataRepository repository;

  EvaluationsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadEvaluations();
  }

  Future<void> loadEvaluations() async {
    state = const AsyncValue.loading();
    try {
      final evaluations = await repository.loadEvaluations();
      state = AsyncValue.data(evaluations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addEvaluation(Evaluation evaluation) async {
    final currentState = state.value ?? [];
    final newState = [...currentState, evaluation];
    state = AsyncValue.data(newState);
    await repository.saveEvaluations(newState);
  }

  Future<void> updateEvaluation(Evaluation updatedEvaluation) async {
    final currentState = state.value ?? [];
    final newState = [
      for (final evaluation in currentState)
        if (evaluation.id == updatedEvaluation.id)
          updatedEvaluation
        else
          evaluation,
    ];
    state = AsyncValue.data(newState);
    await repository.saveEvaluations(newState);
  }

  Future<void> deleteEvaluation(String id) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((e) => e.id != id).toList();
    state = AsyncValue.data(newState);
    await repository.saveEvaluations(newState);
  }
}

final evaluationsProvider =
    StateNotifierProvider<EvaluationsNotifier, AsyncValue<List<Evaluation>>>(
      (ref) => EvaluationsNotifier(ref.watch(dataRepositoryProvider)),
    );

// ==================== MAIN APP ====================

void main() {
  runApp(const ProviderScope(child: MeetingNotesApp()));
}

class MeetingNotesApp extends StatelessWidget {
  const MeetingNotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meeting Management Pro',
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
          DashboardPage(),
          MeetingsListPage(),
          ProgramsPage(),
          ActionPlansPage(),
          EvaluationsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Meetings',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Programs',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Evaluations',
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD PAGE ====================

class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);
    final programsAsync = ref.watch(programsProvider);
    final actionPlansAsync = ref.watch(actionPlansProvider);
    final evaluationsAsync = ref.watch(evaluationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(meetingsProvider);
          ref.invalidate(programsProvider);
          ref.invalidate(actionPlansProvider);
          ref.invalidate(evaluationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Meetings',
                    meetingsAsync.value?.length.toString() ?? '0',
                    Icons.event_note,
                    Colors.blue,
                    context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Programs',
                    programsAsync.value?.length.toString() ?? '0',
                    Icons.folder,
                    Colors.purple,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Action Plans',
                    actionPlansAsync.value?.length.toString() ?? '0',
                    Icons.assignment,
                    Colors.orange,
                    context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Evaluations',
                    evaluationsAsync.value?.length.toString() ?? '0',
                    Icons.assessment,
                    Colors.green,
                    context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Upcoming Meetings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            meetingsAsync.when(
              data: (meetings) {
                final upcoming =
                    meetings
                        .where(
                          (m) =>
                              m.dateTime.isAfter(DateTime.now()) &&
                              m.status == MeetingStatus.scheduled,
                        )
                        .toList()
                      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

                if (upcoming.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No upcoming meetings',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: upcoming
                      .take(3)
                      .map((m) => MeetingCompactCard(meeting: m))
                      .toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading meetings'),
            ),
            const SizedBox(height: 24),
            Text(
              'Active Programs',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            programsAsync.when(
              data: (programs) {
                final active = programs
                    .where((p) => p.status == ProgramStatus.active)
                    .toList();

                if (active.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No active programs',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: active
                      .take(3)
                      .map((p) => ProgramCompactCard(program: p))
                      .toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading programs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MEETINGS LIST PAGE ====================

class MeetingsListPage extends ConsumerWidget {
  const MeetingsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(meetingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meetings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: meetingsAsync.when(
        data: (meetings) {
          if (meetings.isEmpty) {
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
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            itemBuilder: (context, index) =>
                MeetingCompactCard(meeting: meetings[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditMeetingPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== PROGRAMS PAGE ====================

class ProgramsPage extends ConsumerWidget {
  const ProgramsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Programs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: programsAsync.when(
        data: (programs) {
          if (programs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No programs yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            itemBuilder: (context, index) =>
                ProgramCompactCard(program: programs[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditProgramPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== ACTION PLANS PAGE ====================

class ActionPlansPage extends ConsumerWidget {
  const ActionPlansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionPlansAsync = ref.watch(actionPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Action Plans',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: actionPlansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No action plans yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) =>
                ActionPlanCompactCard(plan: plans[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditActionPlanPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== EVALUATIONS PAGE ====================

class EvaluationsPage extends ConsumerWidget {
  const EvaluationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evaluationsAsync = ref.watch(evaluationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Evaluations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: evaluationsAsync.when(
        data: (evaluations) {
          if (evaluations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No evaluations yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: evaluations.length,
            itemBuilder: (context, index) =>
                EvaluationCompactCard(evaluation: evaluations[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditEvaluationPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==================== COMPACT CARDS ====================

class MeetingCompactCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingCompactCard({Key? key, required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingDetailsPage(meeting: meeting),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, h:mm a').format(meeting.dateTime),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Spacer(),
                  _buildStatusChip(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (meeting.status) {
      case MeetingStatus.scheduled:
        color = Colors.blue;
        break;
      case MeetingStatus.inProgress:
        color = Colors.orange;
        break;
      case MeetingStatus.completed:
        color = Colors.green;
        break;
      case MeetingStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        meeting.status.name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProgramCompactCard extends StatelessWidget {
  final Program program;

  const ProgramCompactCard({Key? key, required this.program}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramDetailsPage(program: program),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      program.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: program.progressPercentage / 100,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${program.progressPercentage}% Complete',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Due: ${DateFormat('MMM dd').format(program.endDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (program.status) {
      case ProgramStatus.planning:
        color = Colors.blue;
        break;
      case ProgramStatus.active:
        color = Colors.green;
        break;
      case ProgramStatus.onHold:
        color = Colors.orange;
        break;
      case ProgramStatus.completed:
        color = Colors.grey;
        break;
      case ProgramStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        program.status.name,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ActionPlanCompactCard extends StatelessWidget {
  final ActionPlan plan;

  const ActionPlanCompactCard({Key? key, required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActionPlanDetailsPage(plan: plan)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: plan.overallProgress / 100,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.actions.length} actions',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    '${plan.overallProgress}% Complete',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EvaluationCompactCard extends StatelessWidget {
  final Evaluation evaluation;

  const EvaluationCompactCard({Key? key, required this.evaluation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EvaluationDetailsPage(evaluation: evaluation),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      evaluation.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildScoreBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy').format(evaluation.evaluationDate),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge() {
    Color color;
    if (evaluation.overallScore >= 80) {
      color = Colors.green;
    } else if (evaluation.overallScore >= 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${evaluation.overallScore}%',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
  late DateTime _selectedDateTime;
  late MeetingType _selectedType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final meeting = widget.meeting;
    _titleController = TextEditingController(text: meeting?.title ?? '');
    _descriptionController = TextEditingController(
      text: meeting?.description ?? '',
    );
    _selectedDateTime = meeting?.dateTime ?? DateTime.now();
    _selectedType = meeting?.type ?? MeetingType.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting == null ? 'New Meeting' : 'Edit Meeting'),
        actions: [
          TextButton(onPressed: _saveMeeting, child: const Text('Save')),
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
              items: MeetingType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
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
      attendees: widget.meeting?.attendees ?? [],
      notes: widget.meeting?.notes ?? [],
      actionItems: widget.meeting?.actionItems ?? [],
      priority: widget.meeting?.priority ?? MeetingPriority.medium,
      status: widget.meeting?.status ?? MeetingStatus.scheduled,
      type: _selectedType,
      tags: widget.meeting?.tags ?? [],
      createdAt: widget.meeting?.createdAt ?? DateTime.now(),
    );

    if (widget.meeting == null) {
      ref.read(meetingsProvider.notifier).addMeeting(meeting);
    } else {
      ref.read(meetingsProvider.notifier).updateMeeting(meeting);
    }

    Navigator.pop(context);
  }
}
