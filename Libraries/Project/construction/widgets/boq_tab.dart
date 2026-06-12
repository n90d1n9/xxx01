import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/boq_item.dart';
import '../models/project.dart';
import '../states/boq_provider.dart';
import '../utils/format_helper.dart';
import 'add_boq_dialog.dart';

class BoQTab extends ConsumerWidget {
  final Project project;

  const BoQTab({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBoQ = ref.watch(boqProvider);
    final projectBoQ = allBoQ
        .where((item) => item.projectId == project.id)
        .toList();

    final totalBoQ = projectBoQ.fold<double>(
      0,
      (sum, item) => sum + item.totalHarga,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.indigo[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total BoQ',
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatHelper.currencyFormat.format(totalBoQ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBoQDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah Item'),
              ),
            ],
          ),
        ),
        Expanded(
          child: projectBoQ.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada item BoQ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: projectBoQ.length,
                  itemBuilder: (context, index) {
                    final item = projectBoQ[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          item.item,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(FormatHelper.getCategoryText(item.kategori)),
                            const SizedBox(height: 4),
                            Text(
                              'Volume: ${item.volume} ${item.satuan} × ${FormatHelper.currencyFormat.format(item.hargaSatuan)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              FormatHelper.currencyFormat.format(
                                item.totalHarga,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showEditBoQDialog(context, ref, item),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddBoQDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddBoQDialog(ref: ref, projectId: project.id),
    );
  }

  void _showEditBoQDialog(BuildContext context, WidgetRef ref, BoQItem item) {
    showDialog(
      context: context,
      builder: (context) =>
          AddBoQDialog(ref: ref, projectId: project.id, editItem: item),
    );
  }
}
