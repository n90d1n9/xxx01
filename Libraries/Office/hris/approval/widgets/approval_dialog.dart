import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/supervisor.dart';

class SupervisorApprovalDialog extends ConsumerStatefulWidget {
  final SupervisorAction action;

  const SupervisorApprovalDialog({super.key, required this.action});

  @override
  ConsumerState<SupervisorApprovalDialog> createState() =>
      _SupervisorApprovalDialogState();
}

class _SupervisorApprovalDialogState
    extends ConsumerState<SupervisorApprovalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supervisor Approval Required'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Text('Action: ${widget.action.actionType}'),
            Text('Requested by: ${widget.action.requestedBy}'),
            Text('Reason: ${widget.action.reason}'), */
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Supervisor Username',
              ),
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Username is required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Supervisor Password',
              ),
              obscureText: true,
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Password is required' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleApproval,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Approve'),
        ),
      ],
    );
  }

  Future<void> _handleApproval() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    /* try {
      final securityService = ref.read(securityProvider);
      final approved = await securityService.verifySupervisor(
        username: _usernameController.text,
        password: _passwordController.text,
        action: widget.action,
      );

      if (approved) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Invalid supervisor credentials';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    } */
  }
}
