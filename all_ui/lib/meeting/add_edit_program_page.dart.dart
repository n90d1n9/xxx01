import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'zz-8.dart';

class AddEditProgramPage extends ConsumerStatefulWidget {
  final Program? program;

  const AddEditProgramPage({super.key, this.program});

  @override
  ConsumerState<AddEditProgramPage> createState() => _AddEditProgramPageState();
}

class _AddEditProgramPageState extends ConsumerState<AddEditProgramPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _endDate;
  late ProgramStatus _status;
  late EvaluationStatus _evaluationStatus;
  late int _progressPercentage;

  late DateTime _evaluationDate;
  final List<String> _strengths = [];
  final List<String> _weaknesses = [];
  final List<String> _recommendations = [];
  late TextEditingController _summaryController;

  final List<String> _objectives = [];
  final List<String> _stakeholders = [];
  final List<String> _milestones = [];
  final List<String> _risks = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final program = widget.program;
    _titleController = TextEditingController(text: program?.title ?? '');
    _descriptionController = TextEditingController(
      text: program?.description ?? '',
    );
    _budgetController = TextEditingController(text: program?.budget ?? '');
    _startDate = program?.startDate ?? DateTime.now();
    _endDate = program?.endDate ?? DateTime.now().add(const Duration(days: 90));
    _status = program?.status ?? ProgramStatus.planning;
    _progressPercentage = program?.progressPercentage ?? 0;
    if (program != null) {
      _objectives.addAll(program.objectives);
      _stakeholders.addAll(program.stakeholders);
      _milestones.addAll(program.milestones);
      _risks.addAll(program.risks);
    }

    //_evaluationDate = evaluation?.evaluationDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program == null ? 'New Program' : 'Edit Program'),
        actions: [
          TextButton(onPressed: _saveProgram, child: const Text('Save')),
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
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                prefixIcon: Icon(Icons.summarize),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EvaluationStatus>(
              value: _evaluationStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.info),
              ),
              items:
                  EvaluationStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _evaluationStatus = value);
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
                'Date: ${DateFormat('MMM dd, yyyy').format(_evaluationDate)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectDate,
            ),
            const SizedBox(height: 24),
            _buildListSection('Strengths', _strengths, Icons.thumb_up),
            const SizedBox(height: 24),
            _buildListSection('Weaknesses', _weaknesses, Icons.thumb_down),
            const SizedBox(height: 24),
            _buildListSection(
              'Recommendations',
              _recommendations,
              Icons.lightbulb,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _saveProgram() {
    if (!_formKey.currentState!.validate()) return;

    final program = Program(
      id: widget.program?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      objectives: _objectives,
      stakeholders: _stakeholders,
      budget: _budgetController.text.isEmpty ? null : _budgetController.text,
      progressPercentage: _progressPercentage,
      milestones: _milestones,
      risks: _risks,
      createdAt: widget.program?.createdAt ?? DateTime.now(),
    );

    if (widget.program == null) {
      ref.read(programsProvider.notifier).addProgram(program);
    } else {
      ref.read(programsProvider.notifier).updateProgram(program);
    }

    Navigator.pop(context);
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
          onPressed:
              () => _addItem(
                items,
                'Add ${title.substring(0, title.length - 1)}',
              ),
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
      builder:
          (context) => AlertDialog(
            title: Text(hint),
            content: TextField(
              controller: controller,
              autofocus: true,
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _evaluationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() => _evaluationDate = date);
    }
  }
}
