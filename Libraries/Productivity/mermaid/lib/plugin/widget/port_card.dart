import 'package:flutter/material.dart';

import '../model/port_definition.dart';
import 'port_editor_dialog.dart';

class PortCard extends StatefulWidget {
  final PortDefinition port;
  final bool isInput;
  final List<PortDefinition> inputs;
  final List<PortDefinition> outputs;
  const PortCard({
    super.key,
    required this.port,
    required this.isInput,
    required this.inputs,
    required this.outputs,
  });

  @override
  State<PortCard> createState() => _PortCardState();
}

class _PortCardState extends State<PortCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.isInput ? Colors.blue : Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          widget.port.name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${widget.port.dataType} ${widget.port.required ? "(required)" : ""}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _editPort(widget.port, widget.isInput, context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _deletePort(widget.port, widget.isInput),
            ),
          ],
        ),
      ),
    );
  }

  void _editPort(PortDefinition port, bool isInput, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PortEditorDialog(
        existingPort: port,
        onSave: (updatedPort) {
          setState(() {
            final list = isInput ? widget.inputs : widget.outputs;
            final index = list.indexOf(port);
            list[index] = updatedPort;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deletePort(PortDefinition port, bool isInput) {
    setState(() {
      if (isInput) {
        widget.inputs.remove(port);
      } else {
        widget.outputs.remove(port);
      }
    });
  }
}
