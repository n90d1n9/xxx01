import 'package:flutter/material.dart';

import '../models/family_member.dart';
import '../models/relation_type.dart';
import '../models/mahram_relationship.dart';

class MemberCard extends StatelessWidget {
  final FamilyMember member;
  final bool isSelected;
  final bool isDragging;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final List<MahramRelationship> mahramRelationships; // Add this
  final VoidCallback? onShowMahramDetails; // Add this

  const MemberCard({
    super.key,
    required this.member,
    required this.isSelected,
    this.isDragging = false,
    required this.onDelete,
    required this.onEdit,
    this.mahramRelationships = const [], // Initialize with empty list
    this.onShowMahramDetails,
  });

  @override
  Widget build(BuildContext context) {
    final mahramCount =
        mahramRelationships
            .where(
              (r) => r.fromMemberId == member.id || r.toMemberId == member.id,
            )
            .length;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected
                  ? Colors.teal
                  : member.relation == RelationType.deceased
                  ? Colors.red
                  : Colors.grey[300]!,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDragging
                  ? 0.3
                  : isSelected
                  ? 0.2
                  : 0.1,
            ),
            blurRadius:
                isDragging
                    ? 16
                    : isSelected
                    ? 12
                    : 8,
            offset: Offset(
              0,
              isDragging
                  ? 6
                  : isSelected
                  ? 4
                  : 2,
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row with Gender Icon and Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Gender Icon with Mahram Badge
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            member.gender == Gender.male
                                ? [Colors.blue[300]!, Colors.blue[500]!]
                                : [Colors.pink[300]!, Colors.pink[500]!],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      member.gender == Gender.male ? Icons.man : Icons.woman,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Mahram Badge
                  if (mahramCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: onShowMahramDetails,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$mahramCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Menu Button
              PopupMenuButton(
                icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
                itemBuilder:
                    (ctx) => [
                      // Mahram Details Menu Item
                      if (mahramCount > 0)
                        PopupMenuItem(
                          onTap: onShowMahramDetails,
                          child: const Row(
                            children: [
                              Icon(
                                Icons.family_restroom,
                                size: 18,
                                color: Colors.purple,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Lihat Mahram',
                                style: TextStyle(color: Colors.purple),
                              ),
                            ],
                          ),
                        ),
                      // Edit Menu Item
                      PopupMenuItem(
                        onTap: onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      // Delete Menu Item
                      PopupMenuItem(
                        onTap: onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Member Name
          Text(
            member.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Relation Type
          Text(
            _getRelationLabel(member.relation),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          // Age (if available)
          if (member.age > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cake, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${member.age} tahun',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ],

          // Deceased Indicator
          if (member.isDeceased) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 10, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Meninggal',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Mahram Quick Info (if any relationships)
          if (mahramCount > 0) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onShowMahramDetails,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.family_restroom, size: 12, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text(
                      '$mahramCount mahram',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Faraid Share Section
          if (member.faraidShare > 0) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'KETURUNAN',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(member.faraidShare * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Notes Indicator
          if (member.notes != null && member.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Tooltip(
              message: member.notes!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Ada Catatan',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getCardGradient() {
    if (member.relation == RelationType.deceased) {
      return LinearGradient(
        colors: [Colors.red[100]!, Colors.red[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (member.isDeceased) {
      return LinearGradient(
        colors: [Colors.grey[300]!, Colors.grey[200]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [Colors.white, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  String _getRelationLabel(RelationType relation) {
    switch (relation) {
      case RelationType.deceased:
        return 'ALMARHUM';
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
        return 'Brother';
      case RelationType.sister:
        return 'Sister';
      case RelationType.paternalGrandfather:
        return 'P. Kakek';
      case RelationType.paternalGrandmother:
        return 'P. Nenek';
      case RelationType.maternalGrandfather:
        return 'M. Uyut Laki-laki';
      case RelationType.maternalGrandmother:
        return 'M. Uyut Perempuan';
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
