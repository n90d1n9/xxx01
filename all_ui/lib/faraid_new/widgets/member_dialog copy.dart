// dialogs/member_dialog.dart
import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/relation_type.dart';

class MemberDialog extends StatefulWidget {
  final bool hasDeceased;
  final FamilyMember? editMember;
  final Function(FamilyMember) onSave;

  const MemberDialog({
    super.key,
    required this.hasDeceased,
    this.editMember,
    required this.onSave,
  });

  @override
  State<MemberDialog> createState() => _MemberDialogState();
}

class _MemberDialogState extends State<MemberDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _photoController = TextEditingController();

  late RelationType _selectedRelation;
  late Gender _selectedGender;
  late bool _isDeceased;

  @override
  void initState() {
    super.initState();
    _initializeForm();

    // Ensure the selected relation is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final options = _getRelationOptions();
      if (!options.contains(_selectedRelation)) {
        setState(() {
          _selectedRelation = options.first;
        });
      }
    });
  }

  void _initializeForm() {
    if (widget.editMember != null) {
      _nameController.text = widget.editMember!.name;
      _ageController.text =
          widget.editMember!.age > 0 ? widget.editMember!.age.toString() : '';
      _photoController.text = widget.editMember!.photoPath ?? '';
      _notesController.text = widget.editMember!.notes ?? '';
      _selectedRelation = widget.editMember!.relation;
      _selectedGender = widget.editMember!.gender;
      _isDeceased = widget.editMember!.isDeceased;
    } else {
      _selectedRelation =
          widget.hasDeceased ? RelationType.spouse : RelationType.deceased;
      _selectedGender = Gender.male;
      _isDeceased = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.editMember != null ? 'Edit Member' : 'Tambah Anggota Keluarga',
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildFormFields(),
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Full Name *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.person),
        ),
        textCapitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<RelationType>(
        value: _selectedRelation,
        decoration: InputDecoration(
          labelText: 'Relation *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.family_restroom),
        ),
        items:
            _getRelationOptions()
                .map(
                  (rel) => DropdownMenuItem(
                    value: rel,
                    child: Text(_getRelationLabel(rel)),
                  ),
                )
                .toList(),
        onChanged: (val) => setState(() => _selectedRelation = val!),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<RelationType>(
        value: _selectedRelation,
        decoration: InputDecoration(
          labelText: 'Relation *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.family_restroom),
        ),
        items: _getRelationDropdownItems(), // Use the new method
        onChanged: (val) => setState(() => _selectedRelation = val!),
      ),

      const SizedBox(height: 16),
      TextField(
        controller: _ageController,
        decoration: InputDecoration(
          labelText: 'Age',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.cake),
        ),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _photoController,
        decoration: InputDecoration(
          labelText: 'Photo URL (Optional)',
          hintText: 'https://example.com/photo.jpg',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.photo),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: 'Notes',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.note),
        ),
        maxLines: 3,
      ),
      if (_selectedRelation != RelationType.deceased) ...[
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Sudah Meninggal'),
          value: _isDeceased,
          onChanged: (val) => setState(() => _isDeceased = val ?? false),
        ),
      ],
    ];
  }

  List<DropdownMenuItem<RelationType>> _getRelationDropdownItems() {
    final options = _getRelationOptions();

    // Debug: Print the options and check for duplicates
    print('Available relation options: $options');
    print('Selected relation: $_selectedRelation');

    final items =
        options.map((rel) {
          final label = _getRelationLabel(rel);
          print('Relation: $rel, Label: $label');
          return DropdownMenuItem<RelationType>(value: rel, child: Text(label));
        }).toList();

    // Check for duplicate values
    final valueSet = <RelationType>{};
    final duplicates = <RelationType>[];
    for (final item in items) {
      if (!valueSet.add(item.value!)) {
        duplicates.add(item.value!);
      }
    }

    if (duplicates.isNotEmpty) {
      print('DUPLICATE VALUES FOUND: $duplicates');
    }

    return items;
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _saveMember,
        child: Text(widget.editMember != null ? 'Save' : 'Tambah'),
      ),
    ];
  }

  void _saveMember() {
    if (_nameController.text.trim().isNotEmpty) {
      final member = FamilyMember(
        id:
            widget.editMember?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        relation: _selectedRelation,
        gender: _selectedGender,
        age: int.tryParse(_ageController.text) ?? 0,
        photoPath:
            _photoController.text.trim().isEmpty
                ? null
                : _photoController.text.trim(),
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        isDeceased:
            _selectedRelation == RelationType.deceased ? false : _isDeceased,
      );
      widget.onSave(member);
      Navigator.pop(context);
    }
  }

  List<RelationType> _getRelationOptions() {
    if (widget.hasDeceased) {
      // Available relations when deceased already exists
      return [
        RelationType.father,
        RelationType.mother,
        RelationType.spouse,
        RelationType.son,
        RelationType.daughter,
        RelationType.brother,
        RelationType.sister,
        RelationType.paternalGrandfather,
        RelationType.paternalGrandmother,
        RelationType.maternalGrandfather,
        RelationType.maternalGrandmother,
        RelationType.grandson,
        RelationType.granddaughter,
        RelationType.uncle,
        RelationType.aunt,
        RelationType.nephew,
        RelationType.niece,
      ];
    } else {
      // Only deceased option when no deceased exists
      return [RelationType.deceased];
    }
  }

  String _getRelationLabel(RelationType relation) {
    switch (relation) {
      case RelationType.deceased:
        return 'Almarhum/Almarhumah';
      case RelationType.father:
        return 'Ayah';
      case RelationType.mother:
        return 'Ibu';
      case RelationType.spouse:
        return 'Pasangan';
      case RelationType.son:
        return 'Anak Laki-laki';
      case RelationType.daughter:
        return 'Anak Perempuan';
      case RelationType.brother:
        return 'Saudara Laki-laki';
      case RelationType.sister:
        return 'Saudara Perempuan';
      case RelationType.paternalGrandfather:
        return 'Kakek (Dari Ayah)';
      case RelationType.paternalGrandmother:
        return 'Nenek (Dari Ayah)';
      case RelationType.maternalGrandfather:
        return 'Kakek (Dari Ibu)';
      case RelationType.maternalGrandmother:
        return 'Nenek (Dari Ibu)';
      case RelationType.grandson:
        return 'Cucu Laki-laki';
      case RelationType.granddaughter:
        return 'Cucu Perempuan';
      case RelationType.uncle:
        return 'Paman';
      case RelationType.aunt:
        return 'Bibi';
      case RelationType.nephew:
        return 'Keponakan Laki-laki';
      case RelationType.niece:
        return 'Keponakan Perempuan';
    }
  }
}
