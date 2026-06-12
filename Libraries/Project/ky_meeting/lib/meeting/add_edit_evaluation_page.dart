import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'zz-8.dart';

class AddEditEvaluationPage extends ConsumerStatefulWidget {
  final Evaluation? evaluation;
  final Program? program;

  const AddEditEvaluationPage({Key? key, this.evaluation, this.program})
    : super(key: key);

  @override
  ConsumerState<AddEditEvaluationPage> createState() =>
      _AddEditEvaluationPageState();
}

class _AddEditEvaluationPageState extends ConsumerState<AddEditEvaluationPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late DateTime _startDate;
  late DateTime _endDate;
  late ProgramStatus _programStatus;
  late EvaluationStatus _status;
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
    _programStatus = program?.status ?? ProgramStatus.planning;
    _progressPercentage = program?.progressPercentage ?? 0;
    if (program != null) {
      _objectives.addAll(program.objectives);
      _stakeholders.addAll(program.stakeholders);
      _milestones.addAll(program.milestones);
      _risks.addAll(program.risks);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /* 

  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late DateTime _evaluationDate;
  late EvaluationStatus _status;
  final List<String> _strengths = [];
  final List<String> _weaknesses = [];
  final List<String> _recommendations = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final evaluation = widget.evaluation;
    _titleController = TextEditingController(text: evaluation?.title ?? '');
    _summaryController = TextEditingController(text: evaluation?.summary ?? '');
    _evaluationDate = evaluation?.evaluationDate ?? DateTime.now();
    _status = evaluation?.status ?? EvaluationStatus.draft;
    if (evaluation != null) {
      _strengths.addAll(evaluation.strengths);
      _weaknesses.addAll(evaluation.weaknesses);
      _recommendations.addAll(evaluation.recommendations);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.evaluation == null ? 'New Evaluation' : 'Edit Evaluation',
        ),
        actions: [
          TextButton(onPressed: _saveEvaluation, child: const Text('Save')),
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
            DropdownButtonFormField<ProgramStatus>(
              value: _programStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.info),
              ),
              items: ProgramStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _programStatus = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Progress: $_progressPercentage%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _progressPercentage.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '$_progressPercentage%',
              onChanged: (value) =>
                  setState(() => _progressPercentage = value.toInt()),
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
                'End: ${DateFormat('MMM dd, yyyy').format(_endDate)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 24),
            _buildListSection('Objectives', _objectives, Icons.flag),
            const SizedBox(height: 24),
            _buildListSection('Stakeholders', _stakeholders, Icons.people),
            const SizedBox(height: 24),
            _buildListSection('Milestones', _milestones, Icons.timeline),
            const SizedBox(height: 24),
            _buildListSection('Risks', _risks, Icons.warning),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _saveEvaluation() {
    if (!_formKey.currentState!.validate()) return;

    final evaluation = Evaluation(
      id: widget.evaluation?.id ?? const Uuid().v4(),
      title: _titleController.text,
      status: _status,
      evaluationDate: _evaluationDate,
      criteria: widget.evaluation?.criteria ?? [],
      summary: _summaryController.text,
      strengths: _strengths,
      weaknesses: _weaknesses,
      recommendations: _recommendations,
      overallScore: widget.evaluation?.overallScore ?? 0,
      createdAt: widget.evaluation?.createdAt ?? DateTime.now(),
    );

    if (widget.evaluation == null) {
      ref.read(evaluationsProvider.notifier).addEvaluation(evaluation);
    } else {
      ref.read(evaluationsProvider.notifier).updateEvaluation(evaluation);
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
          onPressed: () => _addItem(items, 'Add $title'),
          icon: const Icon(Icons.add),
          label: Text('Add $title'),
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
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}
