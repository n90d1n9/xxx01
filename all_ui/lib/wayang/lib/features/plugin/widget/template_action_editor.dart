import 'package:flutter/material.dart';

import '../model/action/template_action.dart';

class TemplateActionEditor extends StatefulWidget {
  final TemplateAction action;
  final Function(TemplateAction) onChanged;

  const TemplateActionEditor({
    super.key,
    required this.action,
    required this.onChanged,
  });

  @override
  State<TemplateActionEditor> createState() => _TemplateActionEditorState();
}

class _TemplateActionEditorState extends State<TemplateActionEditor> {
  late TextEditingController _templateController;
  late String _engine;

  @override
  void initState() {
    super.initState();
    _templateController = TextEditingController(text: widget.action.template);
    _engine = widget.action.templateEngine;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _engine,
          decoration: const InputDecoration(
            labelText: 'Template Engine',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          items: [
            'mustache',
            'handlebars',
            'jinja2',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) {
            setState(() => _engine = value!);
            _updateAction();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _templateController,
          style: const TextStyle(color: Colors.white),
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Template',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: 'Hello {{name}}, your order #{{order.id}} is ready!',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateAction(),
        ),
      ],
    );
  }

  void _updateAction() {
    widget.onChanged(
      TemplateAction(
        template: _templateController.text,
        templateEngine: _engine,
      ),
    );
  }
}
