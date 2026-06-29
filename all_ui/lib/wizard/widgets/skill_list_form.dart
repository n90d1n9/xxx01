// Step 2: Skills List with Add/Remove/Sort
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/skill_item.dart';
import '../states/user_profile_provider.dart';

class SkillsListForm extends ConsumerStatefulWidget {
  const SkillsListForm({super.key});

  @override
  ConsumerState<SkillsListForm> createState() => _SkillsListFormState();
}

class _SkillsListFormState extends ConsumerState<SkillsListForm> {
  final _nameController = TextEditingController();
  int _selectedLevel = 5;
  String _sortBy = 'name'; // 'name' or 'level'

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_nameController.text.isEmpty) return;

    final skills = ref.read(skillsListProvider);
    final newSkill = SkillItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      level: _selectedLevel,
    );

    ref.read(skillsListProvider.notifier).state = [...skills, newSkill];
    _nameController.clear();
    _selectedLevel = 5;
  }

  void _removeSkill(String id) {
    final skills = ref.read(skillsListProvider);
    ref.read(skillsListProvider.notifier).state =
        skills.where((s) => s.id != id).toList();
  }

  void _updateSkillLevel(String id, int newLevel) {
    final skills = ref.read(skillsListProvider);
    ref.read(skillsListProvider.notifier).state =
        skills.map((skill) {
          if (skill.id == id) {
            return skill.copyWith(level: newLevel);
          }
          return skill;
        }).toList();
  }

  List<SkillItem> _getSortedSkills(List<SkillItem> skills) {
    final sorted = List<SkillItem>.from(skills);
    if (_sortBy == 'name') {
      sorted.sort((a, b) => a.name.compareTo(b.name));
    } else {
      sorted.sort((a, b) => b.level.compareTo(a.level));
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(skillsListProvider);
    final sortedSkills = _getSortedSkills(skills);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Skill Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.stars),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Level:'),
                    Expanded(
                      child: Slider(
                        value: _selectedLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _selectedLevel.toString(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text(
                      _selectedLevel.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Skill'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Skills (${skills.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            DropdownButton<String>(
              value: _sortBy,
              items: const [
                DropdownMenuItem(value: 'name', child: Text('Sort by Name')),
                DropdownMenuItem(value: 'level', child: Text('Sort by Level')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (sortedSkills.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No skills added yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...sortedSkills.map(
            (skill) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(skill.level.toString())),
                title: Text(skill.name),
                subtitle: LinearProgressIndicator(
                  value: skill.level / 10,
                  backgroundColor: Colors.grey[200],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          skill.level > 1
                              ? () =>
                                  _updateSkillLevel(skill.id, skill.level - 1)
                              : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed:
                          skill.level < 10
                              ? () =>
                                  _updateSkillLevel(skill.id, skill.level + 1)
                              : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSkill(skill.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
