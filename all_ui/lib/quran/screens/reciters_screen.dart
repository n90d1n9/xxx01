import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/quran_provider.dart';

class RecitersScreen extends ConsumerWidget {
  const RecitersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciters = ref.watch(availableRecitersProvider);
    final selectedReciterAsync = ref.watch(selectedReciterProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reciters')),
      body: selectedReciterAsync.when(
        data: (selectedId) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              final isSelected = reciter.id == selectedId;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.person,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                    ),
                  ),
                  title: Text(
                    reciter.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  subtitle: Text(
                    '${reciter.style} • ${reciter.downloadSizeMB.toInt()} MB',
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () async {
                    await ref
                        .read(reciterManagementServiceProvider)
                        .selectReciter(reciter.id);
                    ref.invalidate(selectedReciterProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected ${reciter.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
