import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_state.dart';
import '../models/gender.dart';
import '../states/family_provider.dart';

class MemberDetailsPanel extends ConsumerWidget {
  final String memberId;

  const MemberDetailsPanel({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyProvider);
    final member = familyState.members[memberId];

    if (member == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(left: BorderSide(color: Colors.grey.shade300, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    member.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(familyProvider.notifier).selectMember(null);
                  },
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 8),
            _buildInfoSection(context, 'Basic Information', [
              _buildInfoRow(
                'Gender',
                member.gender == Gender.male ? 'Male' : 'Female',
                Icons.person,
              ),
              _buildInfoRow(
                'Status',
                member.isDeceased ? 'Meninggal' : 'Living',
                member.isDeceased ? Icons.close : Icons.check_circle,
              ),
              if (member.age != null)
                _buildInfoRow('Age', '${member.age} years', Icons.cake),
            ]),
            const SizedBox(height: 16),
            _buildMahramSection(context, ref, familyState, memberId),
            const SizedBox(height: 16),
            if (familyState.inheritanceData != null &&
                familyState.deceasedMemberId != null)
              _buildInheritanceSection(context, familyState, memberId),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildMahramSection(
    BuildContext context,
    WidgetRef ref,
    FamilyState familyState,
    String memberId,
  ) {
    final notifier = ref.read(familyProvider.notifier);
    final mahramList = <Widget>[];
    final nonMahramList = <Widget>[];

    for (final otherMember in familyState.members.values) {
      if (otherMember.id == memberId) continue;

      final status = notifier.checkMahramStatus(memberId, otherMember.id);

      final tile = Card(
        color: status.isMahram ? Colors.green.shade50 : Colors.red.shade50,
        child: ListTile(
          leading: Icon(
            status.isMahram ? Icons.check_circle : Icons.cancel,
            color: status.isMahram ? Colors.green : Colors.red,
          ),
          title: Text(otherMember.name, style: const TextStyle(fontSize: 13)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status.reason, style: const TextStyle(fontSize: 11)),
              if (status.category != 'Unknown')
                Text(
                  status.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          dense: true,
          onTap: () {
            ref.read(familyProvider.notifier).selectMember(otherMember.id);
          },
        ),
      );

      if (status.isMahram) {
        mahramList.add(tile);
      } else {
        nonMahramList.add(tile);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mahram Status (Islamic Law)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 8),
        if (mahramList.isNotEmpty) ...[
          Text(
            'Mahram (${mahramList.length})',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          ...mahramList,
          const SizedBox(height: 8),
        ],
        if (nonMahramList.isNotEmpty) ...[
          Text(
            'Non-Mahram (${nonMahramList.length})',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          ...nonMahramList,
        ],
      ],
    );
  }

  Widget _buildInheritanceSection(
    BuildContext context,
    FamilyState familyState,
    String memberId,
  ) {
    final deceasedMember = familyState.members[familyState.deceasedMemberId];
    final inheritanceInfo = familyState.inheritanceData?[memberId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keturunan dari ${deceasedMember?.name ?? "Meninggal"}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 8),
        if (inheritanceInfo != null)
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Share:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(inheritanceInfo.share * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (inheritanceInfo.actualAmount > 0) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Jumlah:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\${inheritanceInfo.actualAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Text(
                    'Kategori: ${inheritanceInfo.category}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inheritanceInfo.explanation,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (inheritanceInfo.detailedCalculation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Perhitungan: ${inheritanceInfo.detailedCalculation}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Card(
            color: Colors.grey.shade100,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tidak ada keturunan dari anggota keluarga ini',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
