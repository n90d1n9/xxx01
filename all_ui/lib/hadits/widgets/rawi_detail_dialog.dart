import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hadith.dart';
import '../models/rawi.dart';
import '../states/hadith_provider.dart';

class RawiDetailDialog extends ConsumerWidget {
  final Rawi rawi;

  const RawiDetailDialog({Key? key, required this.rawi}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final allRawis = ref.watch(rawiListProvider);
    final teachers =
        allRawis.where((r) => rawi.teachers.contains(r.id)).toList();
    final students =
        allRawis.where((r) => rawi.students.contains(r.id)).toList();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr(ref, 'narrator_details'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                rawi.name.get(locale),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rawi.name.ar,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(ref, 'birth', rawi.birthYear),
              _buildInfoRow(ref, 'death', rawi.deathYear),
              _buildInfoRow(ref, 'region', rawi.region.get(locale)),
              const SizedBox(height: 16),
              Text(
                tr(ref, 'biography'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rawi.biography.get(locale),
                  style: const TextStyle(height: 1.5),
                ),
              ),
              if (teachers.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  tr(ref, 'teachers'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...teachers.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(t.name.get(locale)),
                      ],
                    ),
                  ),
                ),
              ],
              if (students.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  tr(ref, 'students'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...students.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(s.name.get(locale)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(WidgetRef ref, String labelKey, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${tr(ref, labelKey)}:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
