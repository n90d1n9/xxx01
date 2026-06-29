import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family.dart';
import '../models/gender.dart';
import '../states/family_provider.dart';

class AddRelationDialog extends ConsumerStatefulWidget {
  final String fromMemberId;

  const AddRelationDialog({super.key, required this.fromMemberId});

  @override
  ConsumerState<AddRelationDialog> createState() => _AddRelationDialogState();
}

class _AddRelationDialogState extends ConsumerState<AddRelationDialog> {
  String? _selectedMemberId;
  RelationType _relationType = RelationType.child;

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyProvider);
    final availableMembers =
        familyState.members.values
            .where((m) => m.id != widget.fromMemberId)
            .toList();

    return AlertDialog(
      title: const Text('Add Relationship'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedMemberId,
            decoration: const InputDecoration(labelText: 'Select Member'),
            items:
                availableMembers
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            Icon(
                              m.gender == Gender.male
                                  ? Icons.male
                                  : Icons.female,
                              size: 18,
                              color:
                                  m.gender == Gender.male
                                      ? Colors.blue
                                      : Colors.pink,
                            ),
                            const SizedBox(width: 8),
                            Text(m.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _selectedMemberId = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<RelationType>(
            value: _relationType,
            decoration: const InputDecoration(labelText: 'Relationship Type'),
            items: const [
              DropdownMenuItem(
                value: RelationType.spouse,
                child: Text('Pasangan'),
              ),
              DropdownMenuItem(value: RelationType.child, child: Text('Child')),
              DropdownMenuItem(
                value: RelationType.parent,
                child: Text('Parent'),
              ),
              DropdownMenuItem(
                value: RelationType.sibling,
                child: Text('Sibling'),
              ),
            ],
            onChanged: (value) => setState(() => _relationType = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _selectedMemberId == null
                  ? null
                  : () {
                    ref
                        .read(familyProvider.notifier)
                        .addRelation(
                          FamilyRelation(
                            fromId: widget.fromMemberId,
                            toId: _selectedMemberId!,
                            type: _relationType,
                          ),
                        );
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Relationship added successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
