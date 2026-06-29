import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/family.dart';
import '../models/gender.dart';
import '../states/family_provider.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Gender _gender = Gender.male;
  bool _isDeceased = false;
  DateTime? _birthDate;
  DateTime? _deathDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Family Member'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: Gender.male, child: Text('Male')),
                  DropdownMenuItem(value: Gender.female, child: Text('Female')),
                ],
                onChanged: (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? 'Select Birth Date'
                      : DateFormat('MMM dd, yyyy').format(_birthDate!),
                ),
                leading: const Icon(Icons.cake),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _birthDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _birthDate = date);
                },
                trailing:
                    _birthDate != null
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _birthDate = null),
                        )
                        : null,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Meninggal'),
                value: _isDeceased,
                onChanged: (value) => setState(() => _isDeceased = value!),
              ),
              if (_isDeceased)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _deathDate == null
                        ? 'Select Death Date'
                        : DateFormat('MMM dd, yyyy').format(_deathDate!),
                  ),
                  leading: const Icon(Icons.event),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deathDate ?? DateTime.now(),
                      firstDate: _birthDate ?? DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _deathDate = date);
                  },
                  trailing:
                      _deathDate != null
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _deathDate = null),
                          )
                          : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final member = FamilyMember(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                gender: _gender,
                isDeceased: _isDeceased,
                birthDate: _birthDate,
                deathDate: _deathDate,
              );
              ref.read(familyProvider.notifier).addMember(member);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
