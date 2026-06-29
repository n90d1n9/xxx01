import 'package:flutter/material.dart';

import '../model/action/http_request_action.dart';

class HttpRequestActionEditor extends StatefulWidget {
  final HttpRequestAction action;
  final Function(HttpRequestAction) onChanged;

  const HttpRequestActionEditor({
    super.key,
    required this.action,
    required this.onChanged,
  });

  @override
  State<HttpRequestActionEditor> createState() =>
      _HttpRequestActionEditorState();
}

class _HttpRequestActionEditorState extends State<HttpRequestActionEditor> {
  late TextEditingController _urlController;
  late String _selectedMethod;
  late Map<String, String> _headers;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.action.urlTemplate);
    _selectedMethod = widget.action.method;
    _headers = Map.from(widget.action.headers);
    _bodyController = TextEditingController(
      text: widget.action.bodyTemplate ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedMethod,
          decoration: const InputDecoration(
            labelText: 'HTTP Method',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          items: [
            'GET',
            'POST',
            'PUT',
            'DELETE',
            'PATCH',
          ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (value) {
            setState(() => _selectedMethod = value!);
            _updateAction();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'URL Template',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: 'https://api.example.com/users/{{inputs.userId}}',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateAction(),
        ),
        const SizedBox(height: 16),
        const Text('Headers', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ..._headers.entries.map((e) => _buildHeaderRow(e.key, e.value)),
        TextButton.icon(
          onPressed: _addHeader,
          icon: const Icon(Icons.add),
          label: const Text('Add Header'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bodyController,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Body Template (JSON)',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: '{"key": "{{inputs.value}}"}',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateAction(),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$key: $value',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              setState(() => _headers.remove(key));
              _updateAction();
            },
          ),
        ],
      ),
    );
  }

  void _addHeader() {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final valueController = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Add Header',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Key',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              TextField(
                controller: valueController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Value',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  setState(
                    () => _headers[keyController.text] = valueController.text,
                  );
                  _updateAction();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _updateAction() {
    widget.onChanged(
      HttpRequestAction(
        method: _selectedMethod,
        urlTemplate: _urlController.text,
        headers: _headers,
        bodyTemplate: _bodyController.text.isEmpty
            ? null
            : _bodyController.text,
      ),
    );
  }
}



/* 


class HttpRequestActionEditor extends StatefulWidget {
  final HttpRequestAction action;
  final Function(HttpRequestAction) onChanged;

  const HttpRequestActionEditor({Key? key, required this.action, required this.onChanged}) : super(key: key);

  @override
  State<HttpRequestActionEditor> createState() => _HttpRequestActionEditorState();
}

class _HttpRequestActionEditorState extends State<HttpRequestActionEditor> {
  late TextEditingController _urlController;
  late String _selectedMethod;
  late Map<String, String> _headers;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.action.urlTemplate);
    _selectedMethod = widget.action.method;
    _headers = Map.from(widget.action.headers);
    _bodyController = TextEditingController(text: widget.action.bodyTemplate ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedMethod,
          decoration: const InputDecoration(
            labelText: 'HTTP Method',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedMethod = value!);
            _updateAction();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'URL Template',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: 'https://api.example.com/users/{{inputs.userId}}',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateAction(),
        ),
        const SizedBox(height: 16),
        const Text('Headers', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        ..._headers.entries.map((e) => _buildHeaderRow(e.key, e.value)),
        TextButton.icon(
          onPressed: _addHeader,
          icon: const Icon(Icons.add),
          label: const Text('Add Header'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bodyController,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Body Template (JSON)',
            labelStyle: TextStyle(color: Colors.white70),
            hintText: '{"key": "{{inputs.value}}"}',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateAction(),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text('$key: $value', style: const TextStyle(color: Colors.white70)),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              setState(() => _headers.remove(key));
              _updateAction();
            },
          ),
        ],
      ),
    );
  }

  void _addHeader() {
    showDialog(
      context: context,
      builder: (context) {
        final keyController = TextEditingController();
        final valueController = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Add Header', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Key', labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextField(
                controller: valueController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Value', labelStyle: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() => _headers[keyController.text] = valueController.text);
                  _updateAction();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _updateAction() {
    widget.onChanged(HttpRequestAction(
      method: _selectedMethod,
      urlTemplate: _urlController.text,
      headers: _headers,
      bodyTemplate: _bodyController.text.isEmpty ? null : _bodyController.text,
    ));
  }
}

 */