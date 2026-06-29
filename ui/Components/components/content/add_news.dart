import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddNewsWidget extends ConsumerWidget {
  const AddNewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final selectedAudience = ref.watch(selectedAudienceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add News'),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.list),
                ),
                initialValue: 'Bookings',
                readOnly: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: 'Start At',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          startDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(
                        labelText: 'Expire At',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          endDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text('Select Audience:'),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(selectedAudienceProvider.notifier).unselectAll();
                    },
                    child: const Text('Unselect All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(selectedAudienceProvider.notifier).selectAll();
                    },
                    child: const Text('Select All'),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              CheckboxListTile(
                title: const Text('Owner'),
                value: selectedAudience.contains('Owner'),
                onChanged: (value) {
                  ref.read(selectedAudienceProvider.notifier).toggle('Owner');
                },
              ),
              CheckboxListTile(
                title: const Text('Manager'),
                value: selectedAudience.contains('Manager'),
                onChanged: (value) {
                  ref.read(selectedAudienceProvider.notifier).toggle('Manager');
                },
              ),
              CheckboxListTile(
                title: const Text('Waiter'),
                value: selectedAudience.contains('Waiter'),
                onChanged: (value) {
                  ref.read(selectedAudienceProvider.notifier).toggle('Waiter');
                },
              ),
              CheckboxListTile(
                title: const Text('Kitchen'),
                value: selectedAudience.contains('Kitchen'),
                onChanged: (value) {
                  ref.read(selectedAudienceProvider.notifier).toggle('Kitchen');
                },
              ),
              CheckboxListTile(
                title: const Text('Cashier'),
                value: selectedAudience.contains('Cashier'),
                onChanged: (value) {
                  ref.read(selectedAudienceProvider.notifier).toggle('Cashier');
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // TODO: Save news data
                    // ...
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final selectedAudienceProvider = StateNotifierProvider<SelectedAudienceNotifier, List<String>>(
  (ref) => SelectedAudienceNotifier(),
);

class SelectedAudienceNotifier extends StateNotifier<List<String>> {
  SelectedAudienceNotifier() : super([]);

  void toggle(String audience) {
    if (state.contains(audience)) {
      state.remove(audience);
    } else {
      state.add(audience);
    }
  }

  void selectAll() {
    state = ['Owner', 'Manager', 'Waiter', 'Kitchen', 'Cashier'];
  }

  void unselectAll() {
    state = [];
  }
}