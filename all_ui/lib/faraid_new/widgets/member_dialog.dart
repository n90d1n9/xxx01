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
      DropdownButtonFormField<Gender>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.wc),
        ),
        items:
            Gender.values
                .map(
                  (g) => DropdownMenuItem(
                    value: g,
                    child: Row(
                      children: [
                        Icon(
                          g == Gender.male ? Icons.man : Icons.woman,
                          color: g == Gender.male ? Colors.blue : Colors.pink,
                        ),
                        const SizedBox(width: 8),
                        Text(g.name.toUpperCase()),
                      ],
                    ),
                  ),
                )
                .toList(),
        onChanged: (val) => setState(() => _selectedGender = val!),
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
      return RelationType.values
          .where((r) => r != RelationType.deceased)
          .toList();
    }
    return [RelationType.deceased];
  }

  String _getRelationLabel(RelationType relation) {
    const labels = {
      RelationType.deceased: 'Almarhum/Almarhumah',
      RelationType.father: 'Ayah',
      RelationType.mother: 'Ibu',
      RelationType.spouse: 'Pasangan',
      RelationType.son: 'Anak Laki-laki',
      RelationType.daughter: 'Anak Perempuan',
      RelationType.brother: 'Brother',
      RelationType.sister: 'Saudara Perempuan',
      RelationType.paternalGrandfather: 'Kakek (Dari Ayah)',
      RelationType.paternalGrandmother: 'Nenek (Dari Ayah)',
      RelationType.maternalGrandfather: 'Kakek (Dari Ibu)',
      RelationType.maternalGrandmother: 'Nenek (Dari Ibu)',
      RelationType.grandson: 'Cucu Laki-laki',
      RelationType.granddaughter: 'Cucu Perempuan',
      RelationType.uncle: 'Paman',
      RelationType.aunt: 'Bibi',
      RelationType.nephew: 'Keponakan Laki-laki',
      RelationType.niece: 'Keponakan Perempuan',
    };
    return labels[relation] ?? relation.name;
  }
}
